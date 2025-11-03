##############################################
#       DaUfooo´s Windows GPU Reset          #
##############################################

# Prüfen, ob PowerShell als Administrator läuft
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $IsAdmin) {
    Write-Host "Starte Skript mit Administratorrechten neu..." -ForegroundColor Yellow
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ---------------------------------------------------
# GPU-Erkennung
$gpus = Get-PnpDevice -Class Display | Where-Object { $_.Status -eq "OK" }

if ($gpus.Count -eq 0) {
    Write-Host "Keine funktionierenden GPUs gefunden!" -ForegroundColor Red
    exit
}

Write-Host "Folgende GPU(s) wurden erkannt:" -ForegroundColor Cyan
$gpus | ForEach-Object { Write-Host "- $($_.FriendlyName)" -ForegroundColor Cyan }

# ---------------------------------------------------
# Benutzerabfrage
$choice = Read-Host "`nMöchtest du die GPU(s) neu starten? (1 = Ja, 2 = Nein)"

if ($choice -eq "1") {
    foreach ($gpu in $gpus) {
        Write-Host "`nStarte GPU neu: $($gpu.FriendlyName)" -ForegroundColor Green

        # GPU deaktivieren
        Disable-PnpDevice -InstanceId $gpu.InstanceId -Confirm:$false
        Start-Sleep -Milliseconds 1000

        # GPU wieder aktivieren
        Enable-PnpDevice -InstanceId $gpu.InstanceId -Confirm:$false
        Write-Host "GPU $($gpu.FriendlyName) wurde neu gestartet." -ForegroundColor Green
    }
    Write-Host "`nFertig! Die GPU(s) wurden neu initialisiert." -ForegroundColor Green
} else {
    Write-Host "Abgebrochen. Keine Änderungen vorgenommen." -ForegroundColor Yellow
}
