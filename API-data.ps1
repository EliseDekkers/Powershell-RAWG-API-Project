# Instellingen voor API-aanroep
$rawgKey = "66d6d395fad240b7805b15fca5779ffe"  # Zet hier je eigen API-sleutel in
$allResults = @()  # Array om alle resultaten op te slaan
$page = 1  # Begin bij pagina 1
$moreResults = $true  # Vlag om te controleren of er meer resultaten zijn

# Loop door de pagina's totdat er geen meer resultaten zijn
while ($moreResults) {
    # Maak de API-aanroep met de huidige pagina
    $url = "https://api.rawg.io/api/games?token&key=$rawgKey&page=$page"
    $response = Invoke-RestMethod -Uri $url -Headers @{ "X-Api-Key" = $rawgKey }

    # Voeg de resultaten van deze pagina toe aan de array
    $allResults += $response.results

    # Controleer of er meer resultaten zijn (als het aantal resultaten op deze pagina minder dan 100 is, stoppen we)
    if ($response.results.Count -lt 100) {
        $moreResults = $false  # Geen extra pagina's nodig
    } else {
        $page++  # Ga naar de volgende pagina
    }
}

# Bekijk het aantal verzamelde resultaten
Write-Host "Aantal verzamelde games: $($allResults.Count)"

# Als je de gegevens in Out-GridView wilt bekijken
$allResults | Out-GridView
