$html = [System.IO.File]::ReadAllText("$PSScriptRoot/index.html")

# 1. Add layerSensors state in App
$html = $html.Replace(
    "const [layerAnomalies, setLayerAnomalies] = useState(true);",
    "const [layerAnomalies, setLayerAnomalies] = useState(true);`n      const [layerSensors, setLayerSensors] = useState(true);"
)

# 2. Add layerSensors parameter to DigitalTwinSVGMap definition
$html = $html.Replace(
    "layerPressureHeatmap,`n      lineage`n    }) {",
    "layerPressureHeatmap,`n      layerSensors = true,`n      lineage`n    }) {"
)

# 3. Add sensor rendering and elevated styles to DigitalTwinSVGMap in index.html
# First, let's inject elevated shadow filter in defs
$html = $html.Replace(
    '<filter id="glow-burst"',
    '<filter id="elevated-shadow" x="-20%" y="-20%" width="150%" height="150%"><feDropShadow dx="0" dy="6" stdDeviation="4" floodColor="#00E5FF" floodOpacity="0.35" /></filter>`n              <filter id="glow-burst"'
)

# Replace SVG map inner content to support grid lines, elevated ridges, elevated pipe shadows, in-pipe sensors, and elevated node pills
$oldSvgPipes = @'
                    {/* Pipe background track */}
                    <line
                      x1={u.x}
                      y1={u.y}
                      x2={v.x}
                      y2={v.y}
                      stroke="#0D1422"
                      strokeWidth={strokeWidth + 2}
                      strokeLinecap="round"
                    />

                    {/* Main Pipe Color Line */}
                    <line
                      x1={u.x}
                      y1={u.y}
                      x2={v.x}
                      y2={v.y}
                      stroke={strokeColor}
                      strokeWidth={strokeWidth}
                      strokeLinecap="round"
                      strokeOpacity={isSelected ? 1 : 0.85}
                    />

                    {/* Directional Flow Animation Line */}
                    {layerFlowArrows && (
                      <line
                        x1={u.x}
                        y1={u.y}
                        x2={v.x}
                        y2={v.y}
                        stroke={isSelected ? '#FFFFFF' : strokeColor}
                        strokeWidth={strokeWidth * 0.5}
                        className={animClass}
                        strokeOpacity={0.9}
                        markerEnd={`url(#${markerId})`}
                      />
                    )}

                    {/* Pipe ID Badge on mid-point */}
                    <g transform={`translate(${(u.x + v.x) / 2}, ${(u.y + v.y) / 2})`}>
                      <rect
                        x="-18"
                        y="-9"
                        width="36"
                        height="18"
                        rx="4"
                        fill="#080D18"
                        stroke={isSelected ? '#20D9F3' : '#1E2F48'}
                        strokeWidth="1"
                      />
                      <text
                        x="0"
                        y="3"
                        textAnchor="middle"
                        fill={isSelected ? '#20D9F3' : '#94A3B8'}
                        fontSize="9"
                        fontFamily="JetBrains Mono"
                        fontWeight="600"
                      >
                        {pipe.id}
                      </text>
                    </g>
'@

$newSvgPipes = @'
                    {/* Elevated Pipe Bridge Ground Shadows & Trestle Pylons */}
                    {pipe.isElevatedPipe && (
                      <g>
                        <line
                          x1={u.x}
                          y1={u.y + 12}
                          x2={v.x}
                          y2={v.y + 12}
                          stroke="rgba(0, 0, 0, 0.6)"
                          strokeWidth={strokeWidth + 4}
                          strokeLinecap="round"
                        />
                        <line x1={(u.x * 2 + v.x) / 3} y1={(u.y * 2 + v.y) / 3} x2={(u.x * 2 + v.x) / 3} y2={(u.y * 2 + v.y) / 3 + 12} stroke="#20D9F3" strokeWidth="2" />
                        <line x1={(u.x + v.x * 2) / 3} y1={(u.y + v.y * 2) / 3} x2={(u.x + v.x * 2) / 3} y2={(u.y + v.y * 2) / 3 + 12} stroke="#20D9F3" strokeWidth="2" />
                      </g>
                    )}

                    {/* Pipe background track */}
                    <line
                      x1={u.x}
                      y1={u.y}
                      x2={v.x}
                      y2={v.y}
                      stroke="#0D1422"
                      strokeWidth={strokeWidth + 2}
                      strokeLinecap="round"
                    />

                    {/* Elevated Pipeline Outer Cyan Glow */}
                    {pipe.isElevatedPipe && (
                      <line
                        x1={u.x}
                        y1={u.y}
                        x2={v.x}
                        y2={v.y}
                        stroke="#20D9F3"
                        strokeWidth={strokeWidth + 4}
                        strokeOpacity="0.35"
                        strokeLinecap="round"
                      />
                    )}

                    {/* Main Pipe Color Line */}
                    <line
                      x1={u.x}
                      y1={u.y}
                      x2={v.x}
                      y2={v.y}
                      stroke={strokeColor}
                      strokeWidth={strokeWidth}
                      strokeLinecap="round"
                      strokeOpacity={isSelected ? 1 : 0.85}
                    />

                    {/* Directional Flow Animation Line */}
                    {layerFlowArrows && (
                      <line
                        x1={u.x}
                        y1={u.y}
                        x2={v.x}
                        y2={v.y}
                        stroke={isSelected ? '#FFFFFF' : strokeColor}
                        strokeWidth={strokeWidth * 0.5}
                        className={animClass}
                        strokeOpacity={0.9}
                        markerEnd={`url(#${markerId})`}
                      />
                    )}

                    {/* IN-PIPE SENSORS: Setup in between nodes to detect sewage & contamination */}
                    {layerSensors && pipe.sensors && pipe.sensors.map(sensor => {
                      const frac = sensor.positionPercent / 100;
                      const sx = u.x + (v.x - u.x) * frac;
                      const sy = u.y + (v.y - u.y) * frac;
                      const isAlarm = sensor.status === 'ALARM_CONTAMINATION';
                      const isWarning = sensor.status === 'WARNING';
                      const sensorFill = isAlarm ? '#EF4444' : isWarning ? '#F59E0B' : '#20D9F3';

                      return (
                        <g key={sensor.id} className="cursor-pointer">
                          {isAlarm && (
                            <circle cx={sx} cy={sy} r="10" fill="rgba(239, 68, 68, 0.45)" stroke="#EF4444" strokeWidth="1.5" className="anim-burst" />
                          )}
                          <rect
                            x={sx - 5.5}
                            y={sy - 5.5}
                            width="11"
                            height="11"
                            rx="2"
                            transform={`rotate(45, ${sx}, ${sy})`}
                            fill={sensorFill}
                            stroke="#080D18"
                            strokeWidth="2"
                          />
                          <circle cx={sx} cy={sy} r="2" fill="#080D18" />
                          <g transform={`translate(${sx}, ${sy - 12})`}>
                            <rect
                              x="-26"
                              y="-8"
                              width="52"
                              height="14"
                              rx="3"
                              fill="#080D18"
                              stroke={isAlarm ? '#EF4444' : '#1E2F48'}
                              strokeWidth="1"
                            />
                            <text
                              x="0"
                              y="2.5"
                              textAnchor="middle"
                              fill={isAlarm ? '#EF4444' : '#20D9F3'}
                              fontSize="7.5"
                              fontFamily="JetBrains Mono"
                              fontWeight="bold"
                            >
                              {isAlarm ? '☣ CONTAM' : `S:${sensor.parameters.freeChlorineMgL}Cl`}
                            </text>
                          </g>
                        </g>
                      );
                    })}

                    {/* Pipe ID Badge on mid-point */}
                    <g transform={`translate(${(u.x + v.x) / 2}, ${(u.y + v.y) / 2})`}>
                      <rect
                        x={pipe.isElevatedPipe ? "-28" : "-18"}
                        y="-9"
                        width={pipe.isElevatedPipe ? "56" : "36"}
                        height="18"
                        rx="4"
                        fill="#080D18"
                        stroke={pipe.isElevatedPipe ? '#20D9F3' : (isSelected ? '#20D9F3' : '#1E2F48')}
                        strokeWidth={pipe.isElevatedPipe ? "1.5" : "1"}
                      />
                      <text
                        x="0"
                        y="3"
                        textAnchor="middle"
                        fill={pipe.isElevatedPipe ? '#20D9F3' : (isSelected ? '#20D9F3' : '#94A3B8')}
                        fontSize="8.5"
                        fontFamily="JetBrains Mono"
                        fontWeight="600"
                      >
                        {pipe.isElevatedPipe ? `▲ ${pipe.id}` : pipe.id}
                      </text>
                    </g>
'@

$html = $html.Replace($oldSvgPipes, $newSvgPipes)

# Update node rendering in SVG Map for elevated pillars
$oldNodeRender = @'
                    {/* Main Node Circle */}
                    <circle
                      cx={node.x}
                      cy={node.y}
                      r={nodeRadius}
                      fill={nodeFill}
                      stroke={nodeStroke}
                      strokeWidth={isSelectedNode ? 3 : 2}
                    />

                    {/* Node Label Text */}
                    <text
                      x={node.x}
                      y={node.y + nodeRadius + 13}
                      textAnchor="middle"
                      fill="#CBD5E1"
                      fontSize="10"
                      fontFamily="Inter"
                      fontWeight="500"
                    >
                      {node.name.split(' ')[0]} {node.name.split(' ')[1] || ''}
                    </text>

                    {/* Pressure readout pill under label */}
                    <rect
                      x={node.x - 22}
                      y={node.y + nodeRadius + 18}
                      width="44"
                      height="14"
                      rx="3"
                      fill="#080D18"
                      stroke={node.actualPressure < 2.0 ? '#EF4444' : '#1E2F48'}
                      strokeWidth="1"
                    />
                    <text
                      x={node.x}
                      y={node.y + nodeRadius + 28}
                      textAnchor="middle"
                      fill={node.actualPressure < 2.0 ? '#EF4444' : '#38BDF8'}
                      fontSize="9"
                      fontFamily="JetBrains Mono"
                      fontWeight="600"
                    >
                      {node.actualPressure.toFixed(2)} bar
                    </text>
'@

$newNodeRender = @'
                    {/* Elevated Node Pillar & Shadow */}
                    {node.isElevated && (
                      <g>
                        <ellipse cx={node.x} cy={node.y + 12} rx="14" ry="5" fill="rgba(0, 229, 255, 0.25)" />
                        <line x1={node.x} y1={node.y} x2={node.x} y2={node.y + 12} stroke="#20D9F3" strokeWidth="2" strokeDasharray="2 2" />
                      </g>
                    )}

                    {/* Main Node Circle */}
                    <circle
                      cx={node.x}
                      cy={node.y}
                      r={node.isElevated ? 12 : nodeRadius}
                      fill={nodeFill}
                      stroke={node.isElevated ? '#20D9F3' : nodeStroke}
                      strokeWidth={node.isElevated ? 2.5 : (isSelectedNode ? 3 : 2)}
                    />

                    {/* Node Label Text */}
                    <text
                      x={node.x}
                      y={node.y - (node.isElevated ? 16 : (nodeRadius + 4))}
                      textAnchor="middle"
                      fill={node.isElevated ? '#20D9F3' : '#CBD5E1'}
                      fontSize="9.5"
                      fontFamily="Inter"
                      fontWeight={node.isElevated ? "bold" : "500"}
                    >
                      {node.id} {node.isElevated ? '▲' : ''}
                    </text>

                    {/* Elevation & Pressure readout pill */}
                    <rect
                      x={node.x - 26}
                      y={node.y + nodeRadius + (node.isElevated ? 14 : 3)}
                      width="52"
                      height="14"
                      rx="3"
                      fill="#080D18"
                      stroke={node.actualPressure < 2.0 ? '#EF4444' : (node.isElevated ? '#20D9F3' : '#1E2F48')}
                      strokeWidth="1"
                    />
                    <text
                      x={node.x}
                      y={node.y + nodeRadius + (node.isElevated ? 24 : 13)}
                      textAnchor="middle"
                      fill={node.actualPressure < 2.0 ? '#EF4444' : (node.isElevated ? '#20D9F3' : '#38BDF8')}
                      fontSize="8.5"
                      fontFamily="JetBrains Mono"
                      fontWeight="600"
                    >
                      {node.isElevated ? `${node.elevation}m | ${node.actualPressure.toFixed(1)}b` : `${node.actualPressure.toFixed(2)}b`}
                    </text>
'@

$html = $html.Replace($oldNodeRender, $newNodeRender)

# Add layerSensors button in Overview map toolbar
$html = $html.Replace(
    '<button`n                            onClick={() => setLayerFlowArrows(!layerFlowArrows)}',
    '<button`n                            onClick={() => setLayerSensors(!layerSensors)}`n                            className={`px-2 py-1 rounded text-[11px] font-medium border ${layerSensors ? ''bg-cyan-500/20 border-cyan-500/50 text-cyan-400'' : ''bg-brand-surface border-brand-border text-slate-500''}`}`n                          >`n                            IoT In-Pipe Sensors`n                          </button>`n                          <button`n                            onClick={() => setLayerFlowArrows(!layerFlowArrows)}'
)

# Pass layerSensors in both DigitalTwinSVGMap tags
$html = $html.Replace(
    "layerPressureHeatmap={layerPressureHeatmap}`n                          lineage={lineage}",
    "layerPressureHeatmap={layerPressureHeatmap}`n                          layerSensors={layerSensors}`n                          lineage={lineage}"
)
$html = $html.Replace(
    "layerPressureHeatmap={layerPressureHeatmap}`n                        lineage={lineage}",
    "layerPressureHeatmap={layerPressureHeatmap}`n                        layerSensors={layerSensors}`n                        lineage={lineage}"
)

# Add Sensor telemetry card to PipeDetailDrawer in index.html
$oldSpecsEnd = @'
              <div className="flex justify-between text-slate-400">
                <span>Downstream Node:</span>
                <span className="font-mono text-brand-blue font-bold">{pipe.toNodeId}</span>
              </div>
            </div>
          </div>
'@

$newSpecsEnd = @'
              <div className="flex justify-between text-slate-400">
                <span>Downstream Node:</span>
                <span className="font-mono text-brand-blue font-bold">{pipe.toNodeId}</span>
              </div>
              {pipe.isElevatedPipe && (
                <div className="pt-1.5 border-t border-brand-border/40 space-y-1">
                  <div className="flex justify-between text-brand-cyan font-semibold">
                    <span>Span Profile:</span>
                    <span>▲ Elevated Aerial Trestle</span>
                  </div>
                  <div className="flex justify-between text-slate-400">
                    <span>Elevation Δz:</span>
                    <span className="font-mono text-amber-400">{pipe.elevationDiff ? `${pipe.elevationDiff > 0 ? '+' : ''}${pipe.elevationDiff} m` : 'Variable'}</span>
                  </div>
                  {pipe.trestleHeight && (
                    <div className="flex justify-between text-slate-400">
                      <span>Pier Height:</span>
                      <span className="font-mono text-slate-200">{pipe.trestleHeight} m above ground</span>
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>

          {/* IN-PIPE IOT SENSORS CARD */}
          {pipe.sensors && pipe.sensors.length > 0 && (
            <div className="bg-brand-surface rounded-xl border border-brand-border p-3 space-y-2.5">
              <div className="flex items-center justify-between">
                <div className="text-[10px] uppercase font-mono font-bold text-slate-400 tracking-wider flex items-center gap-1.5">
                  <span className="w-2 h-2 rounded-full bg-brand-cyan animate-pulse"></span>
                  <span>In-Pipe Online Sensors ({pipe.sensors.length})</span>
                </div>
                <span className="text-[9px] font-mono text-brand-cyan bg-brand-cyan/10 px-1.5 py-0.5 rounded border border-brand-cyan/30">
                  {pipe.fromNodeId} ↔ {pipe.toNodeId}
                </span>
              </div>

              <div className="space-y-2">
                {pipe.sensors.map(sensor => {
                  const isAlarm = sensor.status === 'ALARM_CONTAMINATION';
                  const isWarning = sensor.status === 'WARNING';
                  const badgeStyle = isAlarm
                    ? 'bg-red-500/20 text-red-400 border-red-500/40'
                    : isWarning
                    ? 'bg-amber-500/20 text-amber-400 border-amber-500/40'
                    : 'bg-emerald-500/20 text-emerald-400 border-emerald-500/40';

                  return (
                    <div
                      key={sensor.id}
                      className={`p-2.5 rounded-lg border text-[11px] space-y-1.5 ${
                        isAlarm ? 'bg-red-500/10 border-red-500/40' : 'bg-brand-dark border-brand-border/80'
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <span className="font-mono font-bold text-white flex items-center gap-1">
                          <span className={isAlarm ? 'text-red-400' : 'text-brand-cyan'}>◆</span>
                          {sensor.id}
                          <span className="text-slate-400 font-normal text-[10px]">({sensor.positionPercent}% span)</span>
                        </span>
                        <span className={`px-1.5 py-0.5 rounded text-[9px] font-mono font-bold border ${badgeStyle}`}>
                          {sensor.status}
                        </span>
                      </div>

                      <div className="text-[10px] text-slate-300 font-medium">{sensor.name}</div>

                      <div className="grid grid-cols-3 gap-1.5 font-mono text-[10px] pt-1 border-t border-brand-border/40">
                        <div className="bg-brand-surface p-1 rounded text-center">
                          <span className="text-slate-500 text-[8.5px] block">Turbidity</span>
                          <span className={`font-bold ${sensor.parameters.turbidityNtu > 4 ? 'text-red-400' : 'text-slate-200'}`}>
                            {sensor.parameters.turbidityNtu} NTU
                          </span>
                        </div>
                        <div className="bg-brand-surface p-1 rounded text-center">
                          <span className="text-slate-500 text-[8.5px] block">Free Cl₂</span>
                          <span className={`font-bold ${sensor.parameters.freeChlorineMgL < 0.2 ? 'text-red-400' : 'text-emerald-400'}`}>
                            {sensor.parameters.freeChlorineMgL} mg/L
                          </span>
                        </div>
                        <div className="bg-brand-surface p-1 rounded text-center">
                          <span className="text-slate-500 text-[8.5px] block">pH Level</span>
                          <span className="font-bold text-slate-200">{sensor.parameters.phLevel}</span>
                        </div>
                      </div>

                      {(sensor.parameters.eColiCfuPer100ml > 0 || (sensor.parameters.ammoniaPpm && sensor.parameters.ammoniaPpm > 0.5)) && (
                        <div className="p-1.5 rounded bg-red-950/40 border border-red-500/30 text-[9.5px] space-y-0.5">
                          <div className="text-red-400 font-bold flex items-center justify-between">
                            <span>☣ Sewage Ingress Alert:</span>
                            <span>E. coli: {sensor.parameters.eColiCfuPer100ml} CFU</span>
                          </div>
                          <div className="text-slate-300">
                            Ammonia: {sensor.parameters.ammoniaPpm} ppm | H₂S: {sensor.parameters.h2sLevelPpm} ppm
                          </div>
                        </div>
                      )}

                      {sensor.alertSummary && (
                        <div className="text-[9.5px] text-red-300 italic pt-0.5">
                          {sensor.alertSummary}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          )}
'@

$html = $html.Replace($oldSpecsEnd, $newSpecsEnd)

[System.IO.File]::WriteAllText("$PSScriptRoot/index.html", $html, [System.Text.Encoding]::UTF8)
Write-Output "SUCCESS: Enhanced index.html with sensor rendering and inspection cards"
