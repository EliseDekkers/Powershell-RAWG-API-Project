#RAWG API KEY en basis URL voor API-aanroep
$rawgKey = "66d6d395fad240b7805b15fca5779ffe"
$url = "https://api.rawg.io/api/games?token&key=$rawgKey"

#Stel de headers in voor de API-aanroep
$headers= @{ "X-Api-Key" = $rawgKey }

#Haal de gegevens op van RAWG API
$response=Invoke-RestMethod -Uri $url -Headers $headers

#Functie voor het ophalen van games met een rating boven 3
function Get-Games {
    param(
        [int]$minRating = 3 
    )

    #Filteren van de games die voldoen aan de rating
    $filteredGames=$response.results | Where-Object { $_.rating -gt $minRating }

    return $filteredGames
}

#Funtcie voor het interactief opstellen van een tabel
function Show-GamesTable {
    param(
        [int]$minRating
    )

    #Haal de gefilterde games op
    $games=Get-Games -minRating $minRating

    #Vraag de gebruiker welke kolommen ze willen zien
    $columns = Read-Host "Welke kolommen wil je zien? (id, name, released, rating, playtime)"

    #Splits de kolommen die de gebruiker heeft ingevoerd
    $columnsArray=$columns.Split(",") | ForEach-Object { $_.Trim() }

    #Maak een dynamische tabel
    $games | Select-Object $columnsArray | Format-Table -AutoSize
    }

    #Vraag de gebruiker om de minimale rating
    $minRating=Read-Host "Geef de minimale rating (standaard 3)"

    #Zet standaardwaarde in als de gebruiker geen invoer geeft
    if (-not $minRating) { $minRating = 3 }

    #Roep de functie aan om de interactieve tabel te tonen
    Show-GamesTable -minRating $minRating