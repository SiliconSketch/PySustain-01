$mock = [System.IO.File]::ReadAllText("$PSScriptRoot/src/data/mockNetwork.ts")
$html = [System.IO.File]::ReadAllText("$PSScriptRoot/index.html")

# Extract createPipeSensors function and BASE_PIPES
$createSensorsMatch = [regex]::Match($mock, '(?s)(function createPipeSensors.*?const BASE_PIPES: Omit<NetworkPipe, ''sensors''>\[\] = \[\s*// --- ROW 1 HORIZONTAL ---.*?\];)')
if (-not $createSensorsMatch.Success) {
    throw "Failed to extract createPipeSensors and BASE_PIPES"
}

$sensorAndBasePipes = $createSensorsMatch.Groups[1].Value
$replacementPipes = @"
$sensorAndBasePipes

    const RAW_PIPES = BASE_PIPES.map(pipe => ({
      ...pipe,
      sensors: createPipeSensors(pipe)
    }));
"@

# Replace RAW_PIPES definition in index.html
$html = [regex]::Replace($html, '(?s)const RAW_PIPES = \[.*?\];', $replacementPipes)

# Invalidate cache so new pipe sensors load immediately
$html = $html.Replace("'pipegraph_pipes_grid25'", "'pipegraph_pipes_sensors_v3'")
$html = $html.Replace("'pipegraph_nodes_grid25'", "'pipegraph_nodes_sensors_v3'")

[System.IO.File]::WriteAllText("$PSScriptRoot/index.html", $html, [System.Text.Encoding]::UTF8)
Write-Output "SUCCESS: Injected in-pipe sensors into index.html RAW_PIPES"
