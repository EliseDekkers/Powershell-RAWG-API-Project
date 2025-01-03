# RAWG API Key
$rawgKey = Read-Host -Prompt "66d6d395fad240b7805b15fca5779ffe" -AsSecureString | ConvertFrom-SecureString

# Variabelen voor paginatie
$allResults = @()  # Array om alle resultaten op te slaan
$page = 1  # Begin bij pagina 1
$maxPages = 10  # Maximaal aantal pagina's
$moreResults = $true  # Vlag om te controleren of er meer resultaten zijn
$maxRecords = Read-Host "Voer het maximaal aantal gegevens in (minimum 20 en maximaal 200)"

if ([int]$maxRecords -gt 200) {
    Write-Host "Maximaal aantal gegevens is 200. Het aantal wordt aangepast naar 200."
    $maxRecords = 200
}

if ([int]$maxRecords -lt 20) {
    Write-Host "Minimum aantal gegevens is 20. Het aantal wordt aangepast naar 20."
    $maxRecords = 20
}

# Loop door de pagina's totdat we $maxPages pagina's hebben opgehaald of geen meer resultaten zijn
while ($moreResults -and $page -le $maxPages -and $allResults.Count -lt $maxRecords) {
    # Maak de API-aanroep met de huidige pagina
    $url = "https://api.rawg.io/api/games?token&key=$rawgKey&page=$page"
    #Foutafhandeling bij API-aanroep
    try {
    $response = Invoke-RestMethod -Uri $url -ErrorAction Stop
    if (-not $response.results) {
        Write-Host "Geen resultaten gevonden. Controleer je API-sleutel of parameters."
        break
    }
} catch {
    Write-Host "Fout bij het ophalen van gegevens: $($_.Exception.Message)"
    exit
}

    # Voeg de resultaten van deze pagina toe aan de array
    $allResults += $response.results

    # Controleer of er meer resultaten zijn
    if ($response.results.Count -lt 20 -or $allResults.Count -ge $maxRecords) {
        $moreResults = $false  # Geen extra pagina's nodig
    } else {
        $page++  # Ga naar de volgende pagina
    }

    # Laat zien hoeveel resultaten we tot nu toe hebben verzameld
    Write-Host "Aantal verzamelde games tot nu toe: $($allResults.Count)"
}

# Bekijk het totale aantal verzamelde resultaten
Write-Host "Totaal aantal verzamelde games: $($allResults.Count)"

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
        # Vraag de gebruiker of ze oplopend of aflopend willen sorteren
        $sortDirection = Read-Host "Wil je sorteren van laag naar hoog (L) of hoog naar laag (H)?"
        
        # Validatie voor de sorteerrichting
        while ($sortDirection -ne "L" -and $sortDirection -ne "H") {
            Write-Host "Ongeldige sorteerrichting. Voer 'L' voor laag naar hoog of 'H' voor hoog naar laag in."
            $sortDirection = Read-Host "Wil je sorteren van laag naar hoog (L) of hoog naar laag (H)?"
        }

        if ($sortDirection -eq "L") {
            $sortedGames = $expandedGames | Sort-Object -Property $sortField
            Write-Host "Gegevens gesorteerd op '$sortField' van laag naar hoog."
        } elseif ($sortDirection -eq "H") {
            $sortedGames = $expandedGames | Sort-Object -Property $sortField -Descending
            Write-Host "Gegevens gesorteerd op '$sortField' van hoog naar laag."
        }
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

    # Vraag de gebruiker of ze willen exporteren
    $exportChoice = Read-Host "Wil je de gegevens exporteren naar CSV of JSON? (CSV/JSON/Nee)"
    if ($exportChoice -eq "CSV") {
        Export-DataToCSV $sortedGames $columns
    } elseif ($exportChoice -eq "JSON") {
        Export-DataToJSON $sortedGames $columns
    }
}

# Functie om geneste gegevens op te splitsen voor gebruik in tabel/grid
function Expand-GameData {
    $allResults | ForEach-Object {
        [PSCustomObject]@{
            ID                = $_.id
            Name              = $_.name
            Released          = $_.released
            Playtime          = $_.playtime
            Rating            = $_.rating
            Ratings_count     = $_.ratings_count
            Reviews_count     = $_.reviews_count
            Added             = $_.added
            Status_yet        = $_.added_by_status.yet
            Status_owned      = $_.added_by_status.owned
            Status_beaten     = $_.added_by_status.beaten
            Status_toplay     = $_.added_by_status.toplay
            Status_dropped    = $_.added_by_status.dropped
            Status_playing    = $_.added_by_status.playing
            Genres            = ($_.genres | ForEach-Object { $_.name }) -join ", "
            Tags              = ($_.tags | ForEach-Object { $_.name }) -join ", "
            ESRB_Rating       = if ($_.esrb_rating -and $_.esrb_rating.name) { $_.esrb_rating.name } else { "N/A" }
            Metacritic        = $_.metacritic
            Suggestions_Count = $_.suggestions_count
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
        9  = "Status_yet"
        10 = "Status_owned"
        11 = "Status_beaten"
        12 = "Status_toplay"
        13 = "Status_dropped"
        14 = "Status_playing"
        15 = "Genres"
        16 = "ESRB_Rating"
        17 = "Metacritic"
        18 = "Suggestions_Count"
    }
    # Voeg de optie 'Alle bovenstaande velden' alleen toe als grid gekozen is
    if ($viewType -eq "grid") {
        $fields[19] = "Tags"
        $fields[20] = "Alle bovenstaande velden"
    }

    # Toon velden in tabelvorm
    Write-Host "`nBeschikbare velden:"
    $fields.GetEnumerator() | Sort-Object Key | ForEach-Object {
        Write-Host "$($_.Key)`t$($_.Value)"
    }

    $selectedFields = @()

    while ($true) {
        $input = Read-Host "Voer een nummer in om een veld toe te voegen (of type 'stop' om te stoppen)"

        if ($input -eq "stop") {
            break
        }

        if ($input -match '^\d+$' -and $fields.ContainsKey([int]$input)) {
            $field = $fields[[int]$input]

            if ([int]$input -eq 20) {
                # Alle velden geselecteerd, behalve "Alle bovenstaande velden"
                $selectedFields = $fields.GetEnumerator() | Sort-Object Key | Where-Object { $_.Key -ne 20 } | ForEach-Object { $_.Value }
                Write-Host "Optie 'Alle bovenstaande velden' geselecteerd. Iteratie beëindigd."
                break
            }

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

# Functie voor exporteren naar CSV
function Export-DataToCSV {
    param (
        [Parameter(Mandatory=$true)]
        [Array]$data,

        [Parameter(Mandatory=$true)]
        [Array]$columns
    )

    $filePath = Read-Host "Voer het pad in waar je het CSV-bestand wilt opslaan (bijv. C:\pad\naar\bestand.csv)"
    $data | Select-Object $columns | Export-Csv -Path $filePath -NoTypeInformation
    Write-Host "De gegevens zijn succesvol geëxporteerd naar CSV: $filePath"
}

# Functie voor exporteren naar JSON
function Export-DataToJSON {
    param (
        [Parameter(Mandatory=$true)]
        [Array]$data,

        [Parameter(Mandatory=$true)]
        [Array]$columns
    )

    $filePath = Read-Host "Voer het pad in waar je het JSON-bestand wilt opslaan (bijv. C:\pad\naar\bestand.json)"
    $data | Select-Object $columns | ConvertTo-Json -Depth 5 | Set-Content -Path $filePath
    Write-Host "De gegevens zijn succesvol geëxporteerd naar JSON: $filePath"
}

# Vraag de gebruiker welke weergave (tabel of grid) ze willen gebruiken
do {
    $viewType = Read-Host "Wil je de gegevens in een tabel (table) of grid (grid) weergave zien?"
} while ($viewType -ne "table" -and $viewType -ne "grid")

Show-GamesView -viewType $viewType
