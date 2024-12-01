# Functie voor interactieve tabel/gridweergave met sortering
function Show-GamesView {
    param(
        [string]$viewType = "table"  # Kies: 'table' voor Format-Table of 'grid' voor Out-GridView
    )

    # Geneste gegevens uitbreiden
    $expandedGames = Expand-GameData

    # Vraag gebruiker om velden te selecteren
    $columns = Get-FieldSelection

    # Vraag gebruiker om een veld te kiezen voor sortering
    $sortField = Read-Host "Voer het veld in waarop je de gegevens wilt sorteren (bijvoorbeeld 'Rating', of 'geen' om niet te sorteren)"

    if ($sortField -eq "geen") {
        Write-Host "Geen sortering toegepast."
        $sortedGames = $expandedGames
    } elseif ($expandedGames -and ($expandedGames | Get-Member -Name $sortField -MemberType NoteProperty)) {
        # Controleer of het veld bestaat en voer sortering uit
        $sortedGames = $expandedGames | Sort-Object -Property $sortField -Descending
        Write-Host "Gegevens gesorteerd op '$sortField'."
    } else {
        Write-Host "Ongeldig veld voor sortering. Gegevens worden niet gesorteerd."
        $sortedGames = $expandedGames
    }

    # Vraag de gebruiker hoeveel resultaten ze willen zien
    $displayCount = Read-Host "Hoeveel resultaten wil je weergeven (max $maxRecords)?"

    if ([int]$displayCount -gt $maxRecords) {
        Write-Host "Aantal weergegeven resultaten wordt beperkt tot $maxRecords."
        $displayCount = $maxRecords
    }

    # Beperk het aantal weergegeven resultaten
    $sortedGames = $sortedGames | Select-Object -First $displayCount

    if ($viewType -eq "grid") {
        # Out-GridView weergeven
        $sortedGames | Select-Object $columns | Out-GridView -Title "Games View"
    } else {
        # Format-Table weergeven
        $sortedGames | Select-Object $columns | Format-Table -AutoSize
    }
}

# Functie om geneste gegevens op te splitsen voor gebruik in tabel/grid
function Expand-GameData {
    $allResults | ForEach-Object {
        $game = $_
        $status_yet = $game.added_by_status.yet
        $status_owned = $game.added_by_status.owned
        $status_beaten = $game.added_by_status.beaten
        $status_toplay = $game.added_by_status.toplay
        $status_dropped = $game.added_by_status.dropped
        $status_playing = $game.added_by_status.playing
        $genres = $game.genres | ForEach-Object { $_.name }
        $tags = $game.tags | ForEach-Object { $_.name }
        $esrb_rating = if ($game.esrb_rating) { $game.esrb_rating.name } else { "N/A" }

        [PSCustomObject]@{
            ID                = $game.id
            Name              = $game.name
            Released          = $game.released
            Playtime          = $game.playtime
            Rating            = $game.rating
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
        6  = "Ratings_count"
        7  = "Reviews_count"
        8  = "Added"
        9 = "Status_yet"
        10 = "Status_owned"
        11 = "Status_beaten"
        12 = "Status_toplay"
        13 = "Status_dropped"
        14 = "Status_playing"
        15 = "Genres"
        16 = "Tags (Beperkt de leesbaarheid door de vele waardes in een tabel, hierdoor wordt de iteratie na deze selectie stopgezet)"
        17 = "ESRB_Rating"
        18 = "Metacritic"
        19 = "Suggestions_Count"
    }

    # Toon velden in tabelvorm
    Write-Host "`nBeschikbare velden:"
    $fields.GetEnumerator() | Sort-Object Key | ForEach-Object {
        Write-Host "$($_.Key)`t$($_.Value)"
    }
    
    # Iteratief velden selecteren
    $selectedFields = @()
    while ($selectedFields.Count -lt 5) {
        $input = Read-Host "Voer een nummer in om een veld toe te voegen (of type 'stop' om te stoppen)"

        if ($input -eq "stop") {
            break
        }

        if ($fields.ContainsKey([int]$input)) {
            $field = $fields[[int]$input]

            # Stop iteratie als "Tags" wordt geselecteerd
            if ($field -eq "Tags") {
                Write-Host "Tags geselecteerd. De iteratie wordt gestopt."
                $selectedFields += $field
                break
            }

            # Voeg veld toe als het nog niet geselecteerd is
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

# Vraag de gebruiker welke weergave ze willen gebruiken
$viewType = Read-Host "Wil je een tabel (table) of grid (grid) weergave?"

# Roep de functie aan om de gegevens te tonen
Show-GamesView -viewType $viewType
