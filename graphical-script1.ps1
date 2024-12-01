# Stap 1: Filter en verwerk de gegevens
$graphData = $response.results | Where-Object {
    $_.released -ne $null -and $_.rating -ne $null
} | ForEach-Object {
    try {
        # Extract the last two digits of the release year
        $yearShort = (Get-Date $_.released).Year % 100  # Laatste twee cijfers van het jaar
        [PSCustomObject]@{
            X = $yearShort                                # Jaar voor X-as (laatste twee cijfers)
            Y = [int][math]::Round($_.rating * 10)        # Rating maal 10 voor Y-as
        }
    } catch {
        # Skip invalid dates
    }
}

# Stap 2: Verwijder lege records
$graphData = $graphData | Where-Object { $_ -ne $null }

# Stap 3: Maak de Datapoints Array
$datapoints = $graphData | ForEach-Object {
    @($_.X, $_.Y)  # X = Last two digits of release year, Y = Rating
}

# Stap 4: Visualiseer de gegevens
Show-Graph -Datapoints $datapoints -GraphTitle "Rating vs Released Year" `
           -XAxisTitle "Last Two Digits of Release Year" -YAxisTitle "Rating (x10)" -Type "Scatter"
