. "$PSScriptRoot\common.ps1"
Test-Prerequisites
if ((Test-Container 'airbyte-abctl-control-plane') -and -not (Test-Path '.tools\managed-airbyte')) {
    throw 'Airbyte existe deja. Ce kit cible une machine neuve : voir README, cohabitation.'
}
New-Item -ItemType Directory -Force '.tools' | Out-Null
if (-not (Test-Path '.env')) {
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $lines = foreach ($line in [IO.File]::ReadAllLines((Join-Path $PSScriptRoot '.env.example'))) {
            if ($line -match '^([A-Z_]+)=GENERER$') {
                $key = $Matches[1]
                $bytes = New-Object byte[] 16
                $rng.GetBytes($bytes)
                $secret = ([BitConverter]::ToString($bytes)).Replace('-', '').ToLowerInvariant()
                "$key=$secret"
            } else { $line }
        }
        [IO.File]::WriteAllLines((Join-Path $PSScriptRoot '.env'), $lines, (New-Object Text.UTF8Encoding($false)))
    } finally { $rng.Dispose() }
}
Test-Environment
$machineArch = $env:PROCESSOR_ARCHITECTURE
if ($env:PROCESSOR_ARCHITEW6432) { $machineArch = $env:PROCESSOR_ARCHITEW6432 }
switch ($machineArch.ToUpperInvariant()) {
    'AMD64' { $arch = 'amd64' }
    'ARM64' { $arch = 'arm64' }
    default { throw 'Windows 64 bits est requis.' }
}
$archive = "abctl-v0.30.4-windows-$arch.zip"
if (-not (Test-Path $script:Abctl)) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $archivePath = Join-Path $PSScriptRoot ".tools\$archive"
    Invoke-WebRequest -UseBasicParsing "https://github.com/airbytehq/abctl/releases/download/v0.30.4/$archive" -OutFile $archivePath
    $checksumLine = Get-Content 'abctl-checksums.txt' | Where-Object { ($_ -split '\s+')[-1] -eq $archive }
    if (-not $checksumLine) { throw 'Empreinte attendue absente.' }
    $expected = ($checksumLine -split '\s+')[0]
    if ((Get-FileHash -Algorithm SHA256 $archivePath).Hash.ToLowerInvariant() -ne $expected) { throw 'Empreinte abctl incorrecte.' }
    Expand-Archive -LiteralPath $archivePath -DestinationPath '.tools\extracted' -Force
    $binary = Get-ChildItem '.tools\extracted' -Recurse -Filter abctl.exe | Select-Object -First 1
    if (-not $binary) { throw 'Executable abctl absent.' }
    Copy-Item $binary.FullName $script:Abctl
}
Invoke-Native $script:Abctl @('version')
New-Item -ItemType File -Force '.tools\managed-airbyte' | Out-Null
Invoke-Native $script:Abctl @('local', 'install', '--chart-version', '2.3.0', '--low-resource-mode', '--no-browser')
Invoke-Native docker @('network', 'inspect', 'kind', '--format', '{{.Name}}')
Start-Services
Write-Host 'Identifiants Airbyte (a garder prives) :'
Invoke-Native $script:Abctl @('local', 'credentials')
Write-Host 'Les autres mots de passe sont dans .env. Lire README.md.'
