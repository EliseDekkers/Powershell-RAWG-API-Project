# API-instellingen
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

    # Controleer of er meer resultaten zijn
    # Als het aantal resultaten op deze pagina minder dan 20 is, weten we dat we klaar zijn
    if ($response.results.Count -lt 20) {
        $moreResults = $false  # Geen extra pagina's nodig
    } else {
        $page++  # Ga naar de volgende pagina
    }

    # Laat zien hoeveel resultaten we tot nu toe hebben verzameld
    Write-Host "Aantal verzamelde games tot nu toe: $($allResults.Count)"
}

# Bekijk het totale aantal verzamelde resultaten
Write-Host "Totaal aantal verzamelde games: $($allResults.Count)"

# Optioneel: toon de resultaten in Out-GridView voor visualisatie
$allResults | Out-GridView

