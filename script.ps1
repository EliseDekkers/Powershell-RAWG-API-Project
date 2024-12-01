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
            Genres            = $genres -join ", "
            Tags              = $tags -join ", "
            ESRB_Rating       = $esrb_rating
            Metacritic        = $game.metacritic
            Suggestions_Count = $game.suggestions_count
        }
    }
}

# Functie om iteratief velden te selecteren
function Get-FieldSelection {
    $fields = @{
        1  = "ID"
        2  = "Name"
        3  = "Released"
        4  = "Playtime"
        5  = "Rating"
        6  = "Rating_top"
        7  = "Ratings_count"
        8  = "Reviews_count"
        9  = "Added"
        10 = "Status_yet"
        11 = "Status_owned"
        12 = "Status_beaten"
        13 = "Status_toplay"
        14 = "Status_dropped"
        15 = "Status_playing"
        16 = "Genres"
        17 = "Tags"
        18 = "ESRB_Rating"
        19 = "Metacritic"
        20 = "Suggestions_Count"
    }

    # Toon velden in tabelvorm
    Write-Host "`nBeschikbare velden:"
    $fields.GetEnumerator() | Sort-Object Key | Format-Table -Property Key, Value -AutoSize

    # Iteratief velden selecteren
    $selectedFields = @()
    while ($selectedFields.Count -lt 5) {
        $input = Read-Host "Voer een nummer in om een veld toe te voegen (of type 'stop' om te stoppen)"

        if ($input -eq "stop") {
            break
        }

        # Controleer of de invoer geldig is
        if ($fields.ContainsKey([int]$input)) {
            $field = $fields[[int]$input]

            if ($selectedFields -contains $field) {
                Write-Host "Dit veld is al toegevoegd."
            } else {
                $selectedFields += $field
                Write-Host "Veld '$field' toegevoegd."
            }
        } else {
            Write-Host "Ongeldig nummer. Probeer opnieuw."
        }
    }

    if ($selectedFields.Count -eq 0) {
        Write-Host "Geen velden geselecteerd. Standaardveld 'Name' wordt gebruikt."
        $selectedFields = @("Name")
    }

    return $selectedFields
}


# Functie voor interactieve tabel- of gridweergave
function Show-GamesView {
    param(
        [string]$viewType = "table"  # Kies: 'table' voor Format-Table of 'grid' voor Out-GridView
    )

    # Geneste gegevens uitbreiden
    $expandedGames = Expand-GameData

    # Vraag gebruiker om velden te selecteren
    $columns = Get-FieldSelection

    if ($viewType -eq "grid") {
        # Out-GridView weergeven
        $expandedGames | Select-Object $columns | Out-GridView -Title "Games View"
    } else {
        # Format-Table weergeven
        $expandedGames | Select-Object $columns | Format-Table -AutoSize
    }
}

# Vraag de gebruiker welke weergave ze willen gebruiken
$viewType = Read-Host "Wil je een tabel (table) of grid (grid) weergave?"

# Roep de functie aan om de gegevens te tonen
Show-GamesView -viewType $viewType
