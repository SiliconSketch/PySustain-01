# PipeGraph — AI-Driven Digital Twin for Smart Water Infrastructure

> **“See the Network. Detect the Invisible.”**  
> AI-powered digital twins for safer, smarter, more sustainable water distribution & sanitation networks.

---

## 🌟 Executive Summary

**PipeGraph** is an enterprise-grade, pure-software digital twin command center engineered for municipal water distribution and sanitation utilities. Traditional physical leak detection relies on expensive hardware sensors, acoustic correlators, and manual field patrols that cover only a fraction of municipal grids. PipeGraph demonstrates how software-based spatial graph modeling, Physics-Informed Neural Network (PINN) formulations, and real-time hydraulic state estimation can detect micro-leaks, pipe ruptures, sewage cross-contamination risks, and hydraulic blockages—**without requiring specialized hardware retrofits across every pipeline.**

Developed as a state-of-the-art smart-city command center for municipal engineers, water utility operators, and disaster management teams, PipeGraph provides complete situational awareness across water supply and wastewater networks.

---

## 🚀 Key Highlights & Capabilities

1. **Pure-Software Spatial Digital Twin Map:**
   - Multi-utility GIS graph visualization representing drinking water mains, gravity sewer trunks, pumping stations, and overhead reservoirs.
   - Real-time zoom, pan, lineage tracing (upstream source feeder path & downstream distribution cascade).
   - Animated directional flow velocity vectors and pressure contour gradients.
   - Dynamic layer toggling: Potable Water Grid, Sanitation Sewer Network, Pressure Contours, Flow Vectors, and Anomaly Overlays.

2. **Four Network Classifications:**
   - 🟢 **Normal Operations:** Balanced hydraulic grade lines and stable laminar flow.
   - 🟡 **Minor Degradation / Micro-leaks:** Subtle baseline pressure deviations ($\Delta P \approx -0.25$ to $-0.5$ bar), early acoustic joint seepage detection.
   - 🔴 **Critical Pipe Bursts:** Catastrophic pressure collapse ($\Delta P < -1.5$ bar, $z \le -3.5\sigma$), rapid mass water loss, emergency isolation trigger.
   - 🟣 **Wastewater Ingestion & Blockages:** Sub-atmospheric negative pressure transients ($P < 0.2$ bar) creating suction/back-siphonage from adjacent sewer lines, or upstream head accumulation from sediment siltation.

3. **Physics-Informed Hydraulic Engine:**
   - $\Delta P_i = P_i^{actual} - P_i^{expected}$
   - $z_i = \frac{P_i^{actual} - P_i^{expected}}{\sigma_i}$
   - Hydraulic headloss & energy balance: $P_{upstream} - P_{downstream} = \rho g \Delta z + h_L$
   - Real-time interactive pressure slider for live on-the-fly hydraulic state perturbation and explainable AI diagnosis.

4. **Non-Revenue Water (NRW) & Financial Impact Engine:**
   - $V_{day} = Q_{loss} \times 24 \text{ (m³/day)}$
   - $C_{day} = V_{day} \times C_{unit} \text{ (₹/day)}$
   - Granular financial drain projections across individual zones, top offender pipe rankings, and CSV export.

5. **Emergency Work Order & Dispatch System:**
   - Kanban Board and List views with SLA tracking (45-minute urgent SLA for ruptures, 30-minute SLA for contamination).
   - **Simulated Rule-Based AI Dispatch:** Multi-criteria optimization matching incident severity and location to specialized municipal crews (e.g., Rapid Rupture Repair Crew Alpha, Sanitation Hazmat Squad, Acoustic Leak Beta).

6. **Sanitation Cross-Contamination Pathway Tracer:**
   - Detects sub-atmospheric pressure transients adjacent to surcharged sewer conduits.
   - Traces downstream affected residential nodes and vulnerable populations.
   - One-click containment protocol trigger (hyper-chlorination & isolation valve shutdown).

---

## 💻 How to Run the Application

The project has been prepared in two complete formats:

### Method A: Immediate Zero-Dependency Instant Run (Recommended)
You do not need to install Node.js, npm, or Python.
1. Open Windows File Explorer and navigate to:
   ```
   C:\Users\Dell\.gemini\antigravity\scratch\pipegraph
   ```
2. Double-click **`index.html`** or right-click and choose **Open with Microsoft Edge / Google Chrome**.
3. The complete application will launch immediately with full interactive features, animations, maps, inspector drawers, and live simulation controls!

### Method B: Vite + TypeScript Development Server (When Node.js is installed)
```bash
# Navigate to the project directory
cd C:\Users\Dell\.gemini\antigravity\scratch\pipegraph

# Install dependencies
npm install

# Start Vite dev server
npm run dev

# Open http://localhost:3000 in your browser
```

---

## 📐 Mathematical & Physics Formulations

### 1. Pressure Deviation & Statistical Significance (Z-Score)
For each node $i$:
$$\Delta P_i = P_i^{actual} - P_i^{expected}$$
$$z_i = \frac{P_i^{actual} - P_i^{expected}}{\sigma_i}$$
where:
- $P_i^{actual}$: Real-time measured or model-inferred pressure at node $i$ (bar).
- $P_i^{expected}$: Diurnally calibrated baseline pressure modeled by the physics engine (bar).
- $\sigma_i$: Model prediction variability / standard deviation (bar).

### 2. Energy Grade Line & Hydraulic Head Loss
Between upstream node $u$ and downstream node $v$:
$$P_u - P_v = \rho g \Delta z + h_L$$
where:
- $\rho = 1000\text{ kg/m}^3$ (Fluid density of potable water).
- $g = 9.81\text{ m/s}^2$ (Gravitational acceleration).
- $\Delta z = z_v - z_u$ (Elevation differential).
- $h_L$: Friction head loss modeled by Darcy-Weisbach:
  $$h_L = f \cdot \frac{L}{D} \cdot \frac{v^2}{2g}$$

### 3. Orifice Leakage Discharge Formulation
For structural ruptures and micro-orifices:
$$Q_{loss} = C_d \cdot A_{orifice} \cdot \sqrt{\frac{2 \Delta P}{\rho}}$$

### 4. Non-Revenue Water (NRW) & Financial Impact
$$V_{day} = Q_{loss} \times 24 \text{ m}^3/\text{day}$$
$$C_{day} = V_{day} \times C_{unit} \text{ (₹/day)}$$
$$C_{month} = C_{day} \times 30 \text{ (₹/month)}$$
where $C_{unit}$ is the municipal water tariff (default ₹22.50 / $\text{m}^3$).

---

## 📁 Project Architecture & File Hierarchy

```
C:\Users\Dell\.gemini\antigravity\scratch\pipegraph\
├── index.html                   # Complete zero-dependency standalone interactive application
├── package.json                 # Project dependencies & scripts
├── vite.config.ts               # Vite bundler configuration
├── tsconfig.json                # TypeScript compiler configuration
├── tailwind.config.js           # Smart-city command center color theme configuration
├── README.md                    # Engineering documentation & manual
└── src/
    ├── types/
    │   └── index.ts             # Data models for nodes, pipes, anomalies, work orders
    ├── data/
    │   └── mockNetwork.ts       # 24-node municipal dataset across 5 urban zones
    ├── utils/
    │   └── physics.ts           # Hydraulic formulas, z-score engine, currency formatting
    ├── components/
    │   ├── Header.tsx           # Global search, zone filters, alert bell
    │   ├── Sidebar.tsx          # 8-view navigation sidebar
    │   ├── KPICards.tsx         # 6 Core command center KPIs
    │   ├── DigitalTwinMap.tsx   # Interactive SVG GIS network graph engine
    │   ├── PipeDetailDrawer.tsx # Right inspector drawer with live pressure slider
    │   ├── MathPressureAnalysis.tsx # Explainable AI physics formulation component
    │   ├── AnomalyTable.tsx     # Incident triage, acknowledge, resolve workflows
    │   ├── ContaminationView.tsx# Cross-network sewage ingestion & containment tracer
    │   ├── WorkOrdersView.tsx   # Kanban & List emergency dispatch board
    │   ├── AnalyticsView.tsx    # Water loss trends, NRW charts, CSV export
    │   ├── NetworkHealthView.tsx# Asset age profiles and material vulnerability
    │   ├── SettingsModal.tsx    # Physics calibration & tariff controls
    │   └── InjectAnomalyModal.tsx # Live synthetic incident injection sandbox
    ├── App.tsx                  # Main application container
    ├── main.tsx                 # React DOM mount point
    └── index.css                # Global styles and command center theme
```

---

## 🎯 Academic & Project Demonstration Walkthrough

When presenting PipeGraph to evaluators or stakeholders:
1. **Overview Dashboard:** Point out the 6 KPI cards, total network length (248.6 km), and the focal digital twin map. Note the `DEMO DATA / SIMULATION ACTIVE` badge ensuring academic integrity.
2. **Interactive Map:** Click on **`P-108`** (Critical Pipe Burst). Notice how the entire upstream line from Central WTP and downstream feeders light up with glowing lineage traces.
3. **Inspector Drawer:** Show the difference between modeled vs. measured telemetry. Drag the **Interactive Pressure Injector slider** from 3.7 bar down to 1.5 bar—watch the real-time $\Delta P$, $z$-score, and AI explanation update dynamically!
4. **AI Anomaly Detection:** Filter by "Critical" severity. Click **"Locate on Map"** to fly directly to an incident. Demonstrate acknowledging an alert or resolving it with an engineer closure note.
5. **AI Smart Dispatch:** Click **"Simulate AI Smart Dispatch"** in the top header. Watch the rule engine auto-allocate the nearest specialized crews (Alpha Rupture Crew or Hazmat Squad).
6. **Contamination Risks:** Navigate to the Contamination tab to explain back-siphonage risk where low pressure in potable pipe `P-127` intersects compromised sewer `WW-03`. Click **"Initiate Containment"** to simulate emergency chlorine boosting.
7. **Analytics & Reports:** Click **"Export Telemetry (CSV)"** to instantly download the complete telemetry dataset, or open **"Executive Briefing"** for a print-ready utility audit report.
8. **Settings & Physics:** Show how changing the municipal water tariff (₹/m³) or anomaly threshold ($\sigma$) instantly recalibrates all financial and diagnostic models across the network.

---

**Developed with precision for municipal water engineering excellence.**
