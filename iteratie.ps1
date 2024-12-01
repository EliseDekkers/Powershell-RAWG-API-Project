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
