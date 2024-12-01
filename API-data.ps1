# API-instellingen
$rawgKey = "Jouw_API_Sleutel"
$url = "https://api.rawg.io/api/games?key=$rawgKey"

# API-aanroep om het aantal resultaten per pagina te controleren
$response = Invoke-RestMethod -Uri $url -Headers @{ "X-Api-Key" = $rawgKey }

# Controleer het aantal resultaten op de eerste pagina
Write-Host "Aantal games op de eerste pagina: $($response.results.Count)"
Write-Host "Aantal verzamelde games: $($response.results.Count)"
