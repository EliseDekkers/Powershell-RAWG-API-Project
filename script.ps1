# RAWG API Key en basis URL voor API-aanroep
$rawgKey = "66d6d395fad240b7805b15fca5779ffe"
$url = "https://api.rawg.io/api/games?key=$rawgKey"

# Haal de gegevens op van de RAWG API
$response = Invoke-RestMethod -Uri $url

# Functie om geneste gegevens op te splitsen voor gebruik in de tabel of grid
function Expand-GameData {
    param(
        [array]$games
    )

    $games | ForEach-Object {
        [PSCustomObject]@{
            ID                = $_.id
            Name              = $_.name
            Released          = $_.released
            Playtime          = $_.playtime
            Rating            = $_.rating
            Tags              = ($_?.tags | ForEach-Object { $_.name }) -join ", "
            ESRB_Rating       = $_?.esrb_rating?.name
            Platforms         = ($_?.platforms | ForEach-Object { $_.platform?.name }) -join ", "
            Metacritic        = $_.metacritic
            Suggestions_Count = $_.suggestions_count
        }
    }
}

# Functie voor interactieve tabel- of gridweergave
function Show-GamesView {
    param(
        [string]$viewType = "table"  # Kies: 'table' voor Format-Table of 'grid' voor Out-GridView
    )

    # Geneste gegevens uitbreiden
    $expandedGames = Expand-GameData -games $response.results

    # Vraag de gebruiker welke velden ze willen zien
    $columns = Read-Host "Welke velden wil je zien? (bijv. ID, Name, Released, Rating, Tags, ESRB_Rating, Platforms)"

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
