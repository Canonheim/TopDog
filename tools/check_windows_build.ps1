[CmdletBinding()]
param(
    [string]$Executable = (Join-Path $PSScriptRoot '..\builds\TopDog.exe'),
    [ValidateSet('title','match')][string]$Scene = 'title',
    [ValidateRange(2,20)][int]$Seconds = 8,
    [ValidateRange(25,60)][int]$TimeoutSeconds = 45
)
$ErrorActionPreference = 'Stop'
$Executable = (Resolve-Path -LiteralPath $Executable).Path
if (Get-Process -Name TopDog -ErrorAction SilentlyContinue) {
    throw 'Close the running Top Dog game before starting this check.'
}
$artifacts = Join-Path ([IO.Path]::GetTempPath()) ('topdog-check-' + [Guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($artifacts) | Out-Null
$shot = Join-Path $artifacts ($Scene + '.png')
$stdout = Join-Path $artifacts 'stdout.log'
$stderr = Join-Path $artifacts 'stderr.log'
# --quit-after bypasses Main.quit_game and hits the known Godot release teardown
# crash. The screenshot hook renders a real frame, then uses the game's Quit path.
$arguments = @('--windowed', '--', '--no-steam', ('"--shot=' + $shot.Replace('\','/') + ',' + $Seconds + '"'))
if ($Scene -eq 'match') { $arguments += '--demo' }
$run = Start-Process -FilePath $Executable -ArgumentList $arguments -WorkingDirectory ([IO.Path]::GetDirectoryName($Executable)) -WindowStyle Hidden -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
if (-not $run.WaitForExit($TimeoutSeconds * 1000)) {
    # Only terminate the process created by this check; never an existing game.
    & taskkill.exe /PID $run.Id /T /F | Out-Null
    throw "Build check timed out. Logs: $artifacts"
}
$run.Refresh()
if ($run.ExitCode -ne 0) { throw "Build check exited $($run.ExitCode). Logs: $artifacts" }
$errors = @(Select-String -LiteralPath $stdout,$stderr -Pattern '^(SCRIPT ERROR|ERROR):')
if ($errors.Count -gt 0) { throw "Build check logged errors: $($errors.Line -join '; '). Logs: $artifacts" }
if (-not (Test-Path -LiteralPath $shot)) { throw "No rendered screenshot. Logs: $artifacts" }
$bytes = [IO.File]::ReadAllBytes($shot)
if ($bytes.Length -lt 1000 -or [BitConverter]::ToString($bytes,0,8) -ne '89-50-4E-47-0D-0A-1A-0A') {
    throw "Invalid rendered screenshot: $shot"
}
if (-not (Select-String -LiteralPath $stdout -SimpleMatch 'SHOT ' -Quiet)) { throw "Capture completion marker missing: $stdout" }
[pscustomobject]@{ Result='PASS'; Scene=$Scene; ExitCode=$run.ExitCode; Screenshot=$shot; Logs=$artifacts }
