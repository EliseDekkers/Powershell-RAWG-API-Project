# Voorbeeld van een response met gegevens van je API
$response = @(
    @{
        name = "Game 1"
        released = "2024-11-29"
        rating = 8.5
        playtime = 120
    }
    @{
        name = "Game 2"
        released = "2023-09-15"
        rating = 7.8
        playtime = 90
    }
    @{
        name = "Game 3"
        released = "2022-05-20"
        rating = 9.2
        playtime = 150
    }
)

# Verwerk de gegevens: voeg jaar toe van de release en verwerk rating
$graphData = $response | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.name
        Released = (Get-Date $_.released).Year   # Jaar van release
        Rating = [math]::Round($_.rating * 10)    # Rating * 10 voor weergave
        Playtime = $_.playtime
    }
}

# Toon de verwerkte gegevens in een GridView
$graphData | Out-GridView -Title "Game Data"
