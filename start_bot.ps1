# BotAlerte - Script PowerShell avec sélection de configuration
# Version moderne du start_bot.bat

# Configuration de la console
$Host.UI.RawUI.WindowTitle = "Bot de Surveillance Universel"

# Couleurs
$colors = @{
    Info = "Cyan"
    Success = "Green"  
    Warning = "Yellow"
    Error = "Red"
    Menu = "White"
}

# Émojis
$emojis = @{
    Robot = "🤖"
    Rocket = "🚀"
    Test = "🧪"
    Email = "📧"
    Gear = "⚙️"
    List = "📋"
    Search = "🔍"
    Exit = "❌"
    Check = "✅"
    Warning = "⚠️"
    Info = "💡"
    File = "📄"
}

function Show-Header {
    Clear-Host
    Write-Host "========================================" -ForegroundColor $colors.Info
    Write-Host "   $($emojis.Robot) BOT DE SURVEILLANCE UNIVERSEL" -ForegroundColor $colors.Info
    Write-Host "========================================" -ForegroundColor $colors.Info
    Write-Host ""
}

function Select-Configuration {
    $configs = Get-ChildItem -Name "*.json" | Sort-Object
    
    if ($configs.Count -eq 0) {
        Write-Host "$($emojis.Warning) Aucune configuration trouvée" -ForegroundColor $colors.Error
        Write-Host "$($emojis.Info) Créez d'abord une configuration (option 4)" -ForegroundColor $colors.Info
        return $null
    }
    
    Write-Host ""
    Write-Host "$($emojis.List) Configurations disponibles:" -ForegroundColor $colors.Menu
    Write-Host ""
    
    for ($i = 0; $i -lt $configs.Count; $i++) {
        $config = $configs[$i]
        Write-Host "[$($i+1)] $($emojis.File) $config" -ForegroundColor $colors.Success
        
        # Essayer d'extraire le nom du monitor
        try {
            $content = Get-Content $config | ConvertFrom-Json
            if ($content.monitor_name) {
                Write-Host "     $($emojis.List) $($content.monitor_name)" -ForegroundColor $colors.Info
            }
        } catch {
            # Ignorer les erreurs de parsing JSON
        }
    }
    
    Write-Host ""
    $choice = Read-Host "Choisissez une configuration (1-$($configs.Count)) ou Entrée pour config.json"
    
    if ([string]::IsNullOrEmpty($choice)) {
        if (Test-Path "config.json") {
            return "config.json"
        } else {
            Write-Host "$($emojis.Warning) config.json non trouvé" -ForegroundColor $colors.Error
            return $null
        }
    }
    
    $choiceNum = 0
    if ([int]::TryParse($choice, [ref]$choiceNum) -and $choiceNum -ge 1 -and $choiceNum -le $configs.Count) {
        return $configs[$choiceNum - 1]
    } else {
        Write-Host "$($emojis.Warning) Choix invalide" -ForegroundColor $colors.Error
        return $null
    }
}

function Start-Bot {
    Write-Host ""
    Write-Host "$($emojis.Rocket) Démarrage du bot de surveillance..." -ForegroundColor $colors.Success
    
    $selectedConfig = Select-Configuration
    if (-not $selectedConfig) {
        return
    }
    
    Write-Host ""
    Write-Host "$($emojis.Info) Configuration: $selectedConfig" -ForegroundColor $colors.Info
    Write-Host "$($emojis.Info) Appuyez sur Ctrl+C pour arrêter" -ForegroundColor $colors.Info
    Write-Host ""
    
    python universal_monitor.py $selectedConfig
}

function Test-Configuration {
    Write-Host ""
    Write-Host "$($emojis.Test) Test de la configuration..." -ForegroundColor $colors.Menu
    
    $selectedConfig = Select-Configuration
    if (-not $selectedConfig) {
        return
    }
    
    Write-Host ""
    Write-Host "$($emojis.Info) Test de: $selectedConfig" -ForegroundColor $colors.Info
    Write-Host ""
    
    python test_universal.py $selectedConfig
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour continuer"
}

function Setup-Email {
    Write-Host ""
    Write-Host "$($emojis.Email) Configuration de l'email..." -ForegroundColor $colors.Menu
    python setup_email.py
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour continuer"
}

function Create-Configuration {
    Write-Host ""
    Write-Host "$($emojis.Gear) Création d'une nouvelle configuration..." -ForegroundColor $colors.Menu
    python config_generator.py
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour continuer"
}

function Show-Configurations {
    Write-Host ""
    Write-Host "$($emojis.List) Configurations disponibles:" -ForegroundColor $colors.Menu
    Write-Host ""
    
    $configs = Get-ChildItem -Name "*.json" | Sort-Object
    
    foreach ($config in $configs) {
        Write-Host "$($emojis.File) $config" -ForegroundColor $colors.Success
        
        # Essayer d'extraire des infos du JSON
        try {
            $content = Get-Content $config | ConvertFrom-Json
            if ($content.monitor_name) {
                Write-Host "   $($emojis.List) $($content.monitor_name)" -ForegroundColor $colors.Info
            }
            if ($content.websites) {
                Write-Host "   🌐 $($content.websites.Count) site(s)" -ForegroundColor $colors.Warning
            }
        } catch {
            Write-Host "   $($emojis.Warning) Erreur de lecture JSON" -ForegroundColor $colors.Error
        }
        Write-Host ""
    }
    
    Read-Host "Appuyez sur Entrée pour continuer"
}

function Test-Manual {
    Write-Host ""
    Write-Host "$($emojis.Search) Test manuel de recherche..." -ForegroundColor $colors.Menu
    
    $selectedConfig = Select-Configuration
    if (-not $selectedConfig) {
        return
    }
    
    Write-Host ""
    Write-Host "$($emojis.Info) Test manuel avec: $selectedConfig" -ForegroundColor $colors.Info
    Write-Host ""
    
    python test_universal.py $selectedConfig
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour continuer"
}

function Show-Menu {
    Write-Host "Choisissez une option:" -ForegroundColor $colors.Menu
    Write-Host ""
    Write-Host "[1] $($emojis.Rocket) Démarrer le bot (surveillance continue)" -ForegroundColor $colors.Success
    Write-Host "[2] $($emojis.Test) Tester la configuration" -ForegroundColor $colors.Info
    Write-Host "[3] $($emojis.Email) Configurer l'email" -ForegroundColor $colors.Info
    Write-Host "[4] $($emojis.Gear) Créer une nouvelle configuration" -ForegroundColor $colors.Warning
    Write-Host "[5] $($emojis.List) Voir les configurations existantes" -ForegroundColor $colors.Info
    Write-Host "[6] $($emojis.Search) Test manuel de recherche" -ForegroundColor $colors.Info
    Write-Host "[7] $($emojis.Exit) Quitter" -ForegroundColor $colors.Error
    Write-Host ""
    
    $choice = Read-Host "Votre choix (1-7)"
    return $choice
}

# Script principal
Set-Location $PSScriptRoot

while ($true) {
    Show-Header
    $choice = Show-Menu
    
    switch ($choice) {
        "1" { Start-Bot }
        "2" { Test-Configuration }
        "3" { Setup-Email }
        "4" { Create-Configuration }
        "5" { Show-Configurations }
        "6" { Test-Manual }
        "7" { 
            Write-Host ""
            Write-Host "$($emojis.Check) Au revoir !" -ForegroundColor $colors.Success
            Start-Sleep -Seconds 1
            exit 0
        }
        default {
            Write-Host "$($emojis.Warning) Choix invalide, essayez encore." -ForegroundColor $colors.Error
            Start-Sleep -Seconds 2
        }
    }
}