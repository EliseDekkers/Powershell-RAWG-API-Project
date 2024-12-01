# RAWG API Key
$rawgKey = "66d6d395fad240b7805b15fca5779ffe"

# Variabelen voor paginatie
$allResults = @()  # Array om alle resultaten op te slaan
$page = 1  # Begin bij pagina 1
$maxPages = 10  # Maximaal aantal pagina's
$moreResults = $true  # Vlag om te controleren of er meer resultaten zijn

# Loop door de pagina's totdat we $maxPages pagina's hebben opgehaald of geen meer resultaten zijn
while ($moreResults -and $page -le $maxPages) {
    # Maak de API-aanroep met de huidige pagina
    $url = "https://api.rawg.io/api/games?token&key=$rawgKey&page=$page"
    $response = Invoke-RestMethod -Uri $url

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

# Functie om geneste gegevens op te splitsen voor gebruik in tabel/grid
function Expand-GameData {
    # Breid de gegevens in $allResults uit
    $allResults | ForEach-Object {
        $game=$_
        $status_yet=$allResults.added_by_status | ForEach-Object { $_.yet }
        $status_owned=$allResults.added_by_status | ForEach-Object { $_.owned }
        $status_beaten=$allResults.added_by_status | ForEach-Object { $_.beaten }
        $status_toplay=$allResults.added_by_status | ForEach-Object { $_.toplay }
        $status_dropped=$allResults.added_by_status | ForEach-Object { $_.dropped }
        $status_playing=$allResults.added_by_status | ForEach-Object { $_.playing }
        $genres=$allResults.genres | ForEach-Object { $_.name }
        $tags=$allResults.tags | ForEach-Object { $_.name }
        $esrb_rating=$allResults.esrb_rating | ForEach-Object { $_.name }
        [PSCustomObject]@{
            ID                = $game.id
            Name              = $game.name
            Released          = $game.released
            Playtime          = $game.playtime
            Rating            = $game.rating
            Rating_top        = $game.rating_top
            Ratings_count     = $game.ratings_count
            Reviews_count     = $game.reviews_count
            Added             = $game.added
            Status_yet        = $status_yet
            Status_owned      = $status_owned
            Status_beaten     = $status_beaten
            Status_toplay     = $status_toplay
            Status_dropped    = $status_dropped
            Status_playing    = $status_playing
            genres            = $genres -join ", "
            Tags              = $tags -join ", "
            ESRB_Rating       = $esrb_rating
            Metacritic        = $game.metacritic
            Suggestions_Count = $game.suggestions_count
        }
    }
}

# Functie voor interactieve tabel- of gridweergave
function Show-GamesView {
    param(
        [string]$viewType = "table"  # Kies: 'table' voor Format-Table of 'grid' voor Out-GridView
    )

    # Geneste gegevens uitbreiden
    $expandedGames = Expand-GameData

    # Vraag de gebruiker welke velden ze willen zien
    $columns = Read-Host "Welke velden wil je zien? (bijv. id, name, released, rating, rating_top, ratings_count, reviews_count, genres, tags, esrb_rating, metacritic,suggestions_count)"

    # Splits de kolomnamen en filter de gegevens
    $columnsArray = $columns.Split(",") | ForEach-Object { $_.Trim() }

    if ($viewType -eq "grid") {
        # Out-GridView weergeven
        $expandedGames | Select-Object $columnsArray | Out-GridView -Title "Games View"
    } else {
        # Format-Table weergeven
        $expandedGames | Select-Object $columnsArray | Format-Table -AutoSize
    }
}

# Vraag de gebruiker welke weergave ze willen gebruiken
$viewType = Read-Host "Wil je een tabel (table) of grid (grid) weergave?"

# Roep de functie aan om de gegevens te tonen
Show-GamesView -viewType $viewType
