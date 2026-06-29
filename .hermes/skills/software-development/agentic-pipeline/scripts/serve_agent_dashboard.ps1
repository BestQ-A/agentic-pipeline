param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [string]$DashboardDir = '.pipeline\dashboard',

    [Parameter(Mandatory = $false)]
    [Alias('Host')]
    [string]$ListenHost = '127.0.0.1',

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 65535)]
    [int]$Port = 8765
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ExistingRoot {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "ProjectRoot does not exist: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

function Resolve-ContainedPath {
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
        throw "DashboardDir must be inside ProjectRoot. ProjectRoot=$Root DashboardDir=$candidate"
    }
    return $candidate
}

function Get-ContentType {
    param([string]$Path)
    switch ([System.IO.Path]::GetExtension($Path).ToLowerInvariant()) {
        '.html' { 'text/html; charset=utf-8' }
        '.json' { 'application/json; charset=utf-8' }
        '.md' { 'text/markdown; charset=utf-8' }
        '.txt' { 'text/plain; charset=utf-8' }
        default { 'application/octet-stream' }
    }
}

$root = Resolve-ExistingRoot -Path $ProjectRoot
$dashboardPath = Resolve-ContainedPath -Root $root -Path $DashboardDir
if (-not (Test-Path -LiteralPath $dashboardPath)) {
    throw "Dashboard directory does not exist. Run update_agent_dashboard.ps1 first: $dashboardPath"
}

$prefixHost = $ListenHost
if ($ListenHost -eq '0.0.0.0' -or $ListenHost -eq '*') {
    $prefixHost = '+'
}

$prefix = "http://$prefixHost`:$Port/"
$displayUrl = "http://$ListenHost`:$Port/agentic-pipeline-dashboard.html"
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
    Write-Host "Serving Agentic Pipeline dashboard from $dashboardPath"
    Write-Host "Open $displayUrl"
    Write-Host 'Press Ctrl+C to stop.'

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        try {
            $requestPath = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))
            if ([string]::IsNullOrWhiteSpace($requestPath)) {
                $requestPath = 'agentic-pipeline-dashboard.html'
            }

            $candidate = [System.IO.Path]::GetFullPath((Join-Path $dashboardPath $requestPath))
            $dashboardFull = [System.IO.Path]::GetFullPath($dashboardPath).TrimEnd('\') + '\'
            if (-not $candidate.StartsWith($dashboardFull, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
                $context.Response.StatusCode = 404
                $bytes = [System.Text.Encoding]::UTF8.GetBytes('Not found')
            }
            else {
                $context.Response.StatusCode = 200
                $context.Response.ContentType = Get-ContentType -Path $candidate
                $context.Response.Headers['Cache-Control'] = 'no-store'
                $bytes = [System.IO.File]::ReadAllBytes($candidate)
            }
            $context.Response.ContentLength64 = $bytes.Length
            $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        catch {
            $context.Response.StatusCode = 500
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($_.Exception.Message)
            $context.Response.ContentLength64 = $bytes.Length
            $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        finally {
            $context.Response.OutputStream.Close()
        }
    }
}
finally {
    if ($listener.IsListening) {
        $listener.Stop()
    }
    $listener.Close()
}
