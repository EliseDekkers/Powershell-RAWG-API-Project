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
        [PSCustomObject]@{
            ID                = $_.id
            Name              = $_.name
            Released          = $_.released
            Playtime          = $_.playtime
            Rating            = $_.rating
            Rating_top        = $_.rating_top
            Ratings_count     = $_.ratings_count
            Reviews_count     = $_.reviews_count
            Added             = $_.added
            Genres            = ($_.genres | ForEach-Object { $_.name }) -join ", "
            Tags              = ($_.tags | ForEach-Object { $_.name }) -join ", "
            ESRB_Rating       = $_?.esrb_rating?.name
            Metacritic        = $_.metacritic
            Suggestions_Count = $_.suggestions_count
        }
    }
}

# Functie om beschikbare velden weer te geven en selectie te vergemakkelijken
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
        10 = "Genres"
        11 = "Tags"
        12 = "ESRB_Rating"
        13 = "Metacritic"
        14 = "Suggestions_Count"
    }

    # Toon velden in tabelvorm
    Write-Host "`nBeschikbare velden:"
    $fields.GetEnumerator() | Sort-Object Key | Format-Table -Property Key, Value -AutoSize

    # Vraag gebruiker om selectie
    $selectedNumbers = Read-Host "Voer de nummers in van de gewenste velden (gescheiden door komma's)"
    $selectedFields = $selectedNumbers -split "," | ForEach-Object { $fields[[int]$_] }

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
