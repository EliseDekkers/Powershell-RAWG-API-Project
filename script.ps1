# Functie voor het sorteren van de gegevens
function Sort-Games {
    param (
        [array]$games,  # De verzamelde gegevens van de games
        [string]$sortField  # Het veld waarop gesorteerd moet worden
    )
    
    if ($sortField -ne "geen" -and $games[0].PSObject.Properties.Name -contains $sortField) {
        # Als een geldig veld is ingevoerd, sorteer de gegevens
        $games = $games | Sort-Object -Property $sortField
        Write-Host "Gegevens zijn gesorteerd op '$sortField'."
    } elseif ($sortField -eq "geen") {
        # Als "geen" is ingevoerd, laat de gegevens ongesorteerd
        Write-Host "Geen sortering toegepast."
    } else {
        Write-Host "Ongeldig veld ingevoerd voor sorteren. Geen sortering toegepast."
    }
    
    return $games
}

# Functie voor het selecteren van velden en het toepassen van sorteren
function Get-SortedGames {
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

    # Toon de beschikbare velden
    Write-Host "`nBeschikbare velden voor sorteren:"
    $fields.GetEnumerator() | Sort-Object Key | Format-Table -Property Key, Value -AutoSize

    # Vraag de gebruiker om een veld te kiezen voor sorteren
    $sortField = Read-Host "Kies een veld voor sorteren, of typ 'geen' om niet te sorteren"

    # Vraag de gebruiker om velden te selecteren voor de kolommen
    $selectedFields = Get-FieldSelection
    
    # Geneste gegevens uitbreiden
    $expandedGames = Expand-GameData

    # Sorteer de gegevens op basis van de geselecteerde sorteerwaarde
    $sortedGames = Sort-Games -games $expandedGames -sortField $sortField

    # Toon de gesorteerde gegevens in de gewenste weergave
    Show-GamesView -viewType "table" -games $sortedGames
}
