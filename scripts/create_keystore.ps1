<#
PowerShell helper to create an Android release keystore and write android/key.properties.
Run from project root in an elevated PowerShell where `keytool` is available.

Usage:
  .\scripts\create_keystore.ps1
#>

param()

function Read-Secret([string]$prompt) {
    Write-Host -NoNewline "$prompt: "
    $pw = Read-Host -AsSecureString
    return ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw)))
}

$alias = Read-Host "Enter key alias (example: my_key_alias)"
if ([string]::IsNullOrWhiteSpace($alias)) { Write-Error "Alias is required."; exit 1 }

$storeFile = Read-Host "Keystore output path relative to project (default: android/app/my-release-key.jks)"
if ([string]::IsNullOrWhiteSpace($storeFile)) { $storeFile = "android/app/my-release-key.jks" }

$storePassword = Read-Secret "Enter keystore password (storePassword)"
$keyPassword = Read-Secret "Enter key password (keyPassword)"

# Ensure output directory exists
$outDir = Split-Path $storeFile -Parent
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

$keytool = "keytool"
Write-Host "Running keytool to create keystore at $storeFile"

$cmd = "$keytool -genkeypair -v -keystore `"$storeFile`" -alias $alias -keyalg RSA -keysize 2048 -validity 10000 -storepass $storePassword -keypass $keyPassword -dname \"CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, S=Unknown, C=US\""

Write-Host "Command:" $cmd

$proc = Start-Process -FilePath $keytool -ArgumentList @("-genkeypair","-v","-keystore","$storeFile","-alias","$alias","-keyalg","RSA","-keysize","2048","-validity","10000","-storepass","$storePassword","-keypass","$keyPassword","-dname","CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, S=Unknown, C=US") -NoNewWindow -Wait -PassThru

if ($proc.ExitCode -ne 0) { Write-Error "keytool failed with exit code $($proc.ExitCode). Ensure JDK is installed and keytool is on PATH."; exit $proc.ExitCode }

# Write key.properties (DO NOT COMMIT)
$kpPath = "android/key.properties"
"storePassword=$storePassword`nkeyPassword=$keyPassword`nkeyAlias=$alias`nstoreFile=$storeFile" | Out-File -FilePath $kpPath -Encoding utf8

Write-Host "Keystore created: $storeFile"
Write-Host "Wrote: $kpPath (do NOT commit this file)"
