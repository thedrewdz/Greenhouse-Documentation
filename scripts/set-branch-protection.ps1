<#
.SYNOPSIS
    Apply branch protection to the main branch of a governed Greenhouse repository.

.DESCRIPTION
    Applies classic branch protection to `main` in the specified repository using the
    GitHub REST API. Configuration matches ADR-0005:

    - The named check or checks are the only required status check contexts.
    - strict: true  — the branch must be up to date before the check is sufficient.
    - Admin enforcement on — no bypass, including for the maintainer.
    - No required reviewers.
    - Force-push and deletion disabled.

    Idempotent: running it twice against the same repository produces the same state
    and no error. Prints the resulting protection payload as evidence of the run.

.PARAMETER Repo
    Short repository name, e.g. Greenhouse-Services. Do not include the owner prefix.

.PARAMETER Check
    One or more required status check context names (job names, not workflow names).
    e.g. build-and-test  or  no-new-c-in-firmware,host-tests

    Confirm names with:
      gh api repos/thedrewdz/<Repo>/commits/HEAD/check-runs --jq '.check_runs[].name'

    An unknown context name creates an unsatisfiable gate with no bypass.

.EXAMPLE
    .\set-branch-protection.ps1 -Repo Greenhouse-Services -Check build-and-test
    .\set-branch-protection.ps1 -Repo Greenhouse-Firmware -Check no-new-c-in-firmware,host-tests

.NOTES
    Prerequisites:
    - gh CLI authenticated with an account that has Admin on the target repository.
    - The named check must already be reporting on main; protecting with an unknown
      context name will create a rule that can never be satisfied.

    Consequence:
    Protecting Greenhouse-Services or Greenhouse-Firmware makes main PR-only in
    that repository. Direct pushes — including docs-only pushes — will be rejected.
    See ADR-0005 § Consequence.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Repo,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]] $Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Owner  = 'thedrewdz'
$Branch = 'main'
$ApiPath = "repos/$Owner/$Repo/branches/$Branch/protection"

$Body = @{
    required_status_checks         = @{
        strict   = $true
        contexts = @($Check)
    }
    enforce_admins                  = $true
    required_pull_request_reviews   = $null
    restrictions                    = $null
    allow_force_pushes              = $false
    allow_deletions                 = $false
} | ConvertTo-Json -Depth 5

Write-Host "Applying branch protection to $Owner/$Repo @ $Branch ..."
Write-Host "  Required checks: $($Check -join ', ')"
Write-Host "  Strict         : true (branch must be up to date)"
Write-Host "  Admin bypass   : disabled"
Write-Host ""

$Result = $Body | gh api -X PUT $ApiPath --input - 2>&1

if ($LASTEXITCODE -ne 0) {
    throw "gh api returned exit code $LASTEXITCODE. Output:`n$Result"
}

Write-Host "Protection applied. Verifying resulting state:"
Write-Host ""

# Fetch current protection state as evidence of the run.
gh api "repos/$Owner/$Repo/branches/$Branch/protection"
