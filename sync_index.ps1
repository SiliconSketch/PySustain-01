$mock = [System.IO.File]::ReadAllText("$PSScriptRoot/src/data/mockNetwork.ts")
$html = [System.IO.File]::ReadAllText("$PSScriptRoot/index.html")

function Get-Array([string]$name) {
    $pattern = "(?s)export const " + $name + "(?::\s*[^=]+)?\s*=\s*(\[.*?\]);"
    $m = [regex]::Match($mock, $pattern)
    if ($m.Success) { return $m.Groups[1].Value }
    throw "Could not find $name"
}

$nodes = Get-Array "MOCK_NODES"
$pipes = Get-Array "MOCK_PIPES"
$anom = Get-Array "MOCK_ANOMALIES"
$wo = Get-Array "MOCK_WORK_ORDERS"
$contam = Get-Array "MOCK_CONTAMINATION_PATHS"

$html = [regex]::Replace($html, '(?s)const RAW_NODES = \[.*?\];', "const RAW_NODES = " + $nodes + ";")
$html = [regex]::Replace($html, '(?s)const RAW_PIPES = \[.*?\];', "const RAW_PIPES = " + $pipes + ";")
$html = [regex]::Replace($html, '(?s)const RAW_ANOMALIES = \[.*?\];', "const RAW_ANOMALIES = " + $anom + ";")
$html = [regex]::Replace($html, '(?s)const RAW_WORK_ORDERS = \[.*?\];', "const RAW_WORK_ORDERS = " + $wo + ";")
$html = [regex]::Replace($html, '(?s)const RAW_CONTAMINATION_PATHS = \[.*?\];', "const RAW_CONTAMINATION_PATHS = " + $contam + ";")

$newZones = @"
const ZONES_LIST = [
      { id: 'ALL', name: 'All Grid Sectors (5x5 Mesh)' },
      { id: 'ZONE_NORTH', name: 'Sector 1: North Elevated Ridge & Highway' },
      { id: 'ZONE_CENTRAL', name: 'Sector 2: Central Commercial Core' },
      { id: 'ZONE_TECH', name: 'Sector 3: CyberCity Tech Corridor' },
      { id: 'ZONE_EAST', name: 'Sector 4: East Industrial Park' },
      { id: 'ZONE_SOUTH', name: 'Sector 5: South Low Basin & Sanitation' }
    ];
"@

$html = [regex]::Replace($html, '(?s)const ZONES_LIST = \[.*?\];', $newZones)

$html = $html.Replace("useState('P-108')", "useState('P-03-04')")
$html = $html.Replace("useState(1.55)", "useState(2.45)")

$html = $html.Replace("'pipegraph_nodes'", "'pipegraph_nodes_grid25'")
$html = $html.Replace("'pipegraph_pipes'", "'pipegraph_pipes_grid25'")
$html = $html.Replace("'pipegraph_anomalies'", "'pipegraph_anomalies_grid25'")
$html = $html.Replace("'pipegraph_workorders'", "'pipegraph_workorders_grid25'")
$html = $html.Replace("'pipegraph_contamination'", "'pipegraph_contamination_grid25'")

[System.IO.File]::WriteAllText("$PSScriptRoot/index.html", $html, [System.Text.Encoding]::UTF8)
Write-Output "SUCCESS: Updated index.html"
