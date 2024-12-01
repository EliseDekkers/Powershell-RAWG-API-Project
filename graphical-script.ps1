# Stap 1: Filter en verwerk de gegevens
$graphData = $response.results | Where-Object {
    $_.released -ne $null -and $_.rating -ne $null
} | ForEach-Object {
    try {
        # Extract year from release date
        $year = (Get-Date $_.released).Year
        if ($year -ge 1990 -and $year -le 2024) {  # Valid range for years
            [PSCustomObject]@{
                X = $year                                     # Release year for X-axis
                Y = [int][math]::Round($_.rating * 10)        # Scaled rating for Y-axis
            }
        }
    } catch {
        # Skip invalid dates
    }
}

# Stap 2: Verwijder lege records
$graphData = $graphData | Where-Object { $_ -ne $null }

# Stap 3: Maak de Datapoints Array
$datapoints = $graphData | ForEach-Object {
    @($_.X, $_.Y)  # X = Release Year, Y = Rating
}

# Stap 4: Visualiseer de gegevens met de juiste titels
Show-Graph -Datapoints $datapoints -GraphTitle "Rating vs Released Year" `
           -XAxisTitle "Release Year" -YAxisTitle "Rating (x10)" `
           -XAxisStep 5 -YAxisStep 10 -Type "Scatter"
