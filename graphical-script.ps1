# Stap 1: Definieer je API-sleutel en URL
$rawgKey = "66d6d395fad240b7805b15fca5779ffe"  
$url = "https://api.rawg.io/api/games?token&key=$rawgKey"
$headers = @{ "X-Api-Key" = $rawgKey }

# Haal de gegevens op van de API
$response = Invoke-RestMethod -Uri $url -Headers $headers

# Stap 2: Maak een lijst van relevante velden
$gamesData = $response.results | ForEach-Object {
    [PSCustomObject]@{
        ID              = $_.id
        Name            = $_.name
        Released       = (Get-Date $_.released).ToString("yyyy-MM-dd")  # Formatteer de datum
        Rating          = $_.rating
        Playtime        = $_.playtime
        ESRBRating      = $_.esrb_rating.name
        Metacritic      = $_.metacritic
        Platforms       = ($_.platforms | ForEach-Object { $_.platform.slug }) -join ", "  # Lijst van platforms
        Updated         = (Get-Date $_.updated).ToString("yyyy-MM-dd")  # Formatteer de datum
    }
}

# Stap 3: Toon de gegevens in een GridView voor selectie
$gamesData | Out-GridView -Title "Selecteer Gegevens om te Bekijken"
