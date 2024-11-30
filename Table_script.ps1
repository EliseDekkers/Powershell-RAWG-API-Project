# RAWG API Key en basis URL voor API-aanroep
$rawgKey = "66d6d395fad240b7805b15fca5779ffe"
$url = "https://api.rawg.io/api/games?token&key=$rawgKey"

# Stel de headers in voor de API-aanroep
$headers = @{ "X-Api-Key" = $rawgKey }

# Haal de gegevens op van de RAWG API
$response = Invoke-RestMethod -Uri $url -Headers $headers

# Functie voor het ophalen van games met een rating tussen twee waarden
function Get-GamesByRating {
    param(
        [int]$minRating,  # Minimum rating
        [int]$maxRating   # Maximum rating
    )

    # Filteren van de games die binnen het opgegeven ratingbereik vallen
    $filteredGames = $response.results | Where-Object { $_.rating -ge $minRating -and $_.rating -le $maxRating }

    return $filteredGames
}

# Functie voor het sorteren van de games op basis van rating of playtime
function Sort-Games {
    param(
        [array]$games,  # De lijst van gefilterde games
        [string]$sortBy # De kolom waarop gesorteerd moet worden: 'rating' of 'playtime'
    )

    # Sorteer de games op de opgegeven kolom (rating of playtime)
    if ($sortBy -eq 'rating') {
        return $games | Sort-Object -Property rating -Descending
    } elseif ($sortBy -eq 'playtime') {
        return $games | Sort-Object -Property playtime -Descending
    } else {
        return $games
    }
}

# Functie voor het interactief opstellen van een tabel
function Show-GamesTable {
    param(
        [int]$minRating,
        [int]$maxRating,
        [string]$sortBy
    )

    # Haal de gefilterde games op
    $games = Get-GamesByRating -minRating $minRating -maxRating $maxRating

    # Sorteer de games op basis van de opgegeven kolom
    $sortedGames = Sort-Games -games $games -sortBy $sortBy

    # Vraag de gebruiker welke kolommen ze willen zien
    $columns = Read-Host "Welke kolommen wil je zien? (id, name, rating, released, playtime)"

    # Splits de kolommen die de gebruiker heeft ingevoerd
    $columnsArray = $columns.Split(",") | ForEach-Object { $_.Trim() }

    # Maak een dynamische tabel
    $sortedGames | Select-Object $columnsArray | Format-Table -AutoSize
}

# Vraag de gebruiker om de minimale en maximale rating
$minRating = Read-Host "Geef de minimale rating (standaard 1)"
$maxRating = Read-Host "Geef de maximale rating (standaard 5)"

# Zet standaardwaarde in als de gebruiker geen invoer geeft
if (-not $minRating) { $minRating = 1 }
if (-not $maxRating) { $maxRating = 5 }

# Vraag de gebruiker om de kolom waarop gesorteerd moet worden (rating of playtime)
$sortBy = Read-Host "Op welke kolom wil je sorteren? (rating of playtime)"

# Zet standaardwaarde in als de gebruiker geen invoer geeft
if (-not $sortBy) { $sortBy = 'rating' }

# Roep de functie aan om de interactieve tabel te tonen
Show-GamesTable -minRating $minRating -maxRating $maxRating -sortBy $sortBy
