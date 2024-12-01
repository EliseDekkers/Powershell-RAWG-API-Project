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
    $allResults | ForEach-Object {
        [PSCustomObject]@{
            ID                = $_.id
            Name              = $_.name
            Released          = $_.released
            Playtime          = $_.playtime
            Rating            = $_.rating
            RatingTop         = $_.rating_top
            Tags              = ($_.tags | ForEach-Object { $_.name }) -join ", "
            ESRB_Rating       = $_?.esrb_rating?.name
            Platforms         = ($_.platforms | ForEach-Object { $_.platform?.name }) -join ", "
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
    $expandedGames = Expand-GameData

    # Vraag de gebruiker welke velden ze willen zien
    $columns = Read-Host "Welke velden wil je zien? (bijv. id, name, released, rating, ratingtop, tags, esrb_rating, platforms, metacritic, suggestions_count)"

    # Splits de kolomnamen en filter de gegevens
    $columnsArray = $columns.Split(",") | ForEach-Object { $_.Trim() }

    # Vraag de gebruiker om het veld waarop ze willen sorteren
    $sortField = Read-Host "Op welk veld wil je sorteren? (bijv. rating, playtime, metacritic)"
    if (-not $sortField) { $sortField = "rating" }  # Standaardwaarde als niets wordt opgegeven

    # Vraag de gebruiker om de sorteervolgorde
    $sortOrder = Read-Host "Wil je sorteren oplopend (asc) of aflopend (desc)?"
    $descending = $sortOrder -eq "desc"

    # Sorteer de gegevens
    $sortedGames = if ($descending) {
        $expandedGames | Sort-Object -Property $sortField -Descending
    } else {
        $expandedGames | Sort-Object -Property $sortField
    }

    if ($viewType -eq "grid") {
        # Out-GridView weergeven
        $sortedGames | Select-Object $columnsArray | Out-GridView -Title "Games View"
    } else {
        # Format-Table weergeven
        $sortedGames | Select-Object $columnsArray | Format-Table -AutoSize
    }
}

# Vraag de gebruiker welke weergave ze willen gebruiken
$viewType = Read-Host "Wil je een tabel (table) of grid (grid) weergave?"

# Roep de functie aan om de gegevens te tonen
Show-GamesView -viewType $viewType
