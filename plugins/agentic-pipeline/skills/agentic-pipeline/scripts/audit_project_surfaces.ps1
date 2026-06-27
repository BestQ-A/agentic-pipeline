param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [int]$MaxGuidanceDepth = 4,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:ScanWarnings = [System.Collections.Generic.List[object]]::new()

function Add-ScanWarning {
    param(
        [string]$Operation,
        [string]$Path,
        [string]$Message
    )
    $script:ScanWarnings.Add([pscustomobject]@{
        operation = $Operation
        path = $Path
        message = $Message
    }) | Out-Null
}

function Resolve-ExistingPath {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "ProjectRoot does not exist: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

function Get-RelativePath {
    param(
        [string]$Root,
        [string]$Path
    )
    $rootUri = [System.Uri]::new(($Root.TrimEnd('\') + '\'))
    $pathUri = [System.Uri]::new($Path)
    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace('/', '\')
}

function Get-FileSummary {
    param(
        [string]$Root,
        [string]$Path
    )
    $item = Get-Item -LiteralPath $Path -Force
    [pscustomobject]@{
        path = Get-RelativePath -Root $Root -Path $item.FullName
        bytes = $item.Length
        modifiedUtc = $item.LastWriteTimeUtc.ToString('o')
    }
}

function Get-DirectFiles {
    param(
        [string]$Root,
        [string]$Directory
    )
    if (-not (Test-Path -LiteralPath $Directory)) {
        return @()
    }
    try {
        @(Get-ChildItem -LiteralPath $Directory -File -Force | Sort-Object FullName | ForEach-Object {
            Get-FileSummary -Root $Root -Path $_.FullName
        })
    }
    catch {
        Add-ScanWarning -Operation 'list-files' -Path $Directory -Message $_.Exception.Message
        @()
    }
}

function Get-ChildDirectories {
    param(
        [string]$Root,
        [string]$Directory
    )
    if (-not (Test-Path -LiteralPath $Directory)) {
        return @()
    }
    try {
        @(Get-ChildItem -LiteralPath $Directory -Directory -Force | Sort-Object FullName | ForEach-Object {
            $fileCount = 0
            try {
                $fileCount = @(Get-ChildItem -LiteralPath $_.FullName -File -Force).Count
            }
            catch {
                Add-ScanWarning -Operation 'count-direct-files' -Path $_.FullName -Message $_.Exception.Message
            }
            [pscustomobject]@{
                path = Get-RelativePath -Root $Root -Path $_.FullName
                fileCount = $fileCount
            }
        })
    }
    catch {
        Add-ScanWarning -Operation 'list-directories' -Path $Directory -Message $_.Exception.Message
        @()
    }
}

function Test-IgnoredDirectory {
    param([string]$Name)
    $ignored = @(
        '.git', '.hg', '.svn',
        'node_modules', 'vendor', 'vendor_imports', 'plugins',
        'dist', 'build', 'out', 'target', 'bin', 'obj',
        '.next', '.nuxt', '.svelte-kit',
        '.cache', 'cache', '.turbo', '.parcel-cache',
        '.tmp', 'tmp',
        'coverage', '.pytest_cache', '__pycache__',
        'package-output', 'build-output', 'dependency-cache'
    )
    return $ignored -contains $Name
}

function Get-GuidanceFiles {
    param(
        [string]$Root,
        [string[]]$Names,
        [int]$MaxDepth
    )

    $queue = [System.Collections.Generic.Queue[object]]::new()
    $queue.Enqueue([pscustomobject]@{ Path = $Root; Depth = 0 })
    $results = [System.Collections.Generic.List[object]]::new()

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()

        try {
            $files = @(Get-ChildItem -LiteralPath $current.Path -File -Force)
        }
        catch {
            Add-ScanWarning -Operation 'list-guidance-files' -Path $current.Path -Message $_.Exception.Message
            $files = @()
        }

        foreach ($file in $files) {
            if ($Names -contains $file.Name) {
                $results.Add((Get-FileSummary -Root $Root -Path $file.FullName)) | Out-Null
            }
        }

        if ($current.Depth -ge $MaxDepth) {
            continue
        }

        try {
            $directories = @(Get-ChildItem -LiteralPath $current.Path -Directory -Force)
        }
        catch {
            Add-ScanWarning -Operation 'list-guidance-directories' -Path $current.Path -Message $_.Exception.Message
            $directories = @()
        }

        foreach ($directory in $directories) {
            if (Test-IgnoredDirectory -Name $directory.Name) {
                continue
            }
            $queue.Enqueue([pscustomobject]@{
                Path = $directory.FullName
                Depth = $current.Depth + 1
            })
        }
    }

    @($results | Sort-Object path)
}

function Resolve-OutputPath {
    param(
        [string]$Root,
        [string]$Path
    )
    if ([System.IO.Path]::IsPathRooted($Path)) {
        $candidate = [System.IO.Path]::GetFullPath($Path)
    }
    else {
        $candidate = [System.IO.Path]::GetFullPath((Join-Path $Root $Path))
    }

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    if (-not $candidate.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "OutputPath must be inside ProjectRoot. ProjectRoot=$Root OutputPath=$candidate"
    }
    return $candidate
}

$root = Resolve-ExistingPath -Path $ProjectRoot

$rootGuidanceNames = @('AGENTS.md', 'AGENTS.override.md', 'CLAUDE.md', 'README.md')
$folderGuidanceNames = @('AGENTS.md', 'AGENTS.override.md', 'CLAUDE.md')
$rootGuidance = foreach ($name in $rootGuidanceNames) {
    $path = Join-Path $root $name
    if (Test-Path -LiteralPath $path) {
        Get-FileSummary -Root $root -Path $path
    }
}
$folderGuidance = @(Get-GuidanceFiles -Root $root -Names $folderGuidanceNames -MaxDepth $MaxGuidanceDepth)
$guidance = @(@($rootGuidance) + @($folderGuidance) | Sort-Object path -Unique)

$surfaceDirectories = [ordered]@{
    codexAgents = Join-Path $root '.codex\agents'
    codexSkills = Join-Path $root '.codex\skills'
    projectAgentsSkills = Join-Path $root '.agents\skills'
    rules = Join-Path $root 'rules'
    cursorRules = Join-Path $root '.cursor\rules'
    windsurfRules = Join-Path $root '.windsurf\rules'
    scripts = Join-Path $root 'scripts'
    tests = Join-Path $root 'tests'
    omxContext = Join-Path $root '.omx\context'
    omxArtifacts = Join-Path $root '.omx\artifacts'
    omxState = Join-Path $root '.omx\state'
    skilloptFeedback = Join-Path $root '.skillopt-sleep\feedback'
}

$surfaces = [ordered]@{}
foreach ($entry in $surfaceDirectories.GetEnumerator()) {
    $directories = @(Get-ChildDirectories -Root $root -Directory $entry.Value)
    $files = @(Get-DirectFiles -Root $root -Directory $entry.Value)
    $surfaces[$entry.Key] = [pscustomobject]@{
        exists = Test-Path -LiteralPath $entry.Value
        directories = $directories
        files = $files
    }
}

$commandFiles = @('package.json', 'pnpm-workspace.yaml', 'pyproject.toml', 'Cargo.toml', 'go.mod', 'Makefile', 'CMakeLists.txt', '*.sln', '*.csproj', '*.vcxproj')
$commands = foreach ($pattern in $commandFiles) {
    try {
        @(Get-ChildItem -LiteralPath $root -Filter $pattern -File -Force | Sort-Object FullName | ForEach-Object {
            Get-FileSummary -Root $root -Path $_.FullName
        })
    }
    catch {
        Add-ScanWarning -Operation 'list-command-files' -Path $root -Message $_.Exception.Message
    }
}

$report = [pscustomobject]@{
    projectRoot = $root
    generatedUtc = [DateTime]::UtcNow.ToString('o')
    maxGuidanceDepth = $MaxGuidanceDepth
    guidanceFiles = @($guidance)
    surfaces = $surfaces
    commandFiles = @($commands)
    scanWarnings = @($script:ScanWarnings)
}

$json = $report | ConvertTo-Json -Depth 8
if ($OutputPath) {
    $resolvedOutputPath = Resolve-OutputPath -Root $root -Path $OutputPath
    if ((Test-Path -LiteralPath $resolvedOutputPath) -and -not $Force) {
        throw "OutputPath already exists. Use -Force to overwrite: $resolvedOutputPath"
    }
    $parent = Split-Path -Parent $resolvedOutputPath
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Set-Content -LiteralPath $resolvedOutputPath -Value $json -Encoding UTF8
}

$json
