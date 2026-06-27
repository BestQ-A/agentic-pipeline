param(
    [Parameter(Mandatory = $false)]
    [string]$SkillRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Contains {
    param(
        [string]$Content,
        [string]$Pattern,
        [string]$Name
    )
    if ($Content -notmatch $Pattern) {
        throw "Missing contract marker: $Name"
    }
}

$skillPath = Join-Path $SkillRoot 'SKILL.md'
if (-not (Test-Path -LiteralPath $skillPath)) {
    throw "SKILL.md not found: $skillPath"
}

$content = Get-Content -LiteralPath $skillPath -Raw

$requiredMarkers = [ordered]@{
    guidanceGate = '## Guidance Adherence Gate'
    environmentGate = '## Environment Preflight Gate'
    guidanceBindingShape = 'guidance_binding:'
    environmentPreflightShape = 'environment_preflight:'
    noBindingNoAction = 'No guidance binding means no downstream action'
    noPreflightDowngrade = 'do not downgrade them to warnings'
    handoffBinding = 'Include the guidance binding, preflight status, allowed actions, forbidden actions'
    subagentGuidance = 'guidance_followed:'
    subagentPreflight = 'preflight_used:'
    retentionCorrection = 'update the owning project skill with a new preflight check'
}

foreach ($entry in $requiredMarkers.GetEnumerator()) {
    Assert-Contains -Content $content -Pattern ([regex]::Escape($entry.Value)) -Name $entry.Key
}

[pscustomobject]@{
    status = 'pass'
    skill = $skillPath
    checkedMarkers = @($requiredMarkers.Keys)
    checkedAt = [DateTime]::UtcNow.ToString('o')
} | ConvertTo-Json -Depth 4
