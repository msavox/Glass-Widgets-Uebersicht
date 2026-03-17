#   ____ _                         __        ___     _            _       
#  / ___| | __ _ ___ ___           \ \      / (_) __| | __ _  ___| |_ ___ 
# | |  _| |/ _` / __/ __|  _____    \ \ /\ / /| |/ _` |/ _` |/ _ \ __/ __|
# | |_| | | (_| \__ \__ \ |_____|    \ V  V / | | (_| | (_| |  __/ |_ \__ \
#  \____|_|\__,_|___/___/             \_/\_/  |_|\__,_|\__, |\___|\__|___/
#                                                      |___/              
#
# Author:  Matteo Savoia
# Version: 1.0
# Release: 2026
# ---------------------------------------------------------------------------

# --- Parameters Section ---
# Refresh Frequency (in milliseconds)
refreshRate = 2000

# Position and sizing
posTop = "560px"
posLeft = "15px"
widgetWidth = "320px"

# Visual styling
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
labelColor = "rgba(255, 255, 255, 0.4)"
subValColor = "rgba(255, 255, 255, 0.6)"

# Gauge Colors
cpuColor = "#34C759"
ramColor = "#32D74B"
batColor = "#FFCC00"

# Glassmorphism settings
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"

# Gauge dimensions
gaugeSize = "70px"
gaugeRadius = 32
# The circumference of the gauge circle (2 * PI * R)
gaugeCircumference = 201 

# --- Configuration ---
refreshFrequency: refreshRate

# Bash command chain to extract system metrics:
# 1. CPU Usage: Uses 'top' to get a snapshot and 'awk' to sum user and system percentage.
# 2. RAM Usage: Uses 'vm_stat' for active pages and 'sysctl' for total memory.
# 3. Battery: Uses 'pmset' to get battery level and extracts the percentage.
command: """
  top -l 1 -n 0 | awk '/CPU usage/ {print $3 + $5 "%"}';
  used_ram=$(vm_stat | awk '/Pages active/ {print $3}' | sed 's/\\.//');
  total_ram=$(sysctl hw.memsize | awk '{print $2}');
  echo "$used_ram $total_ram";
  pmset -g batt | awk '{for(i=1;i<=NF;i++) if($i~/[0-9]+%/) print $i}' | head -1 | tr -d '%;'
"""

# --- Style ---
# The style section defines the visual appearance using CSS-in-JS (Stylus-like syntax).
style: """
  top: #{posTop}
  left: #{posLeft}
  width: #{widgetWidth}
  font-family: #{fontFamily}
  -webkit-font-smoothing: antialiased
  color: #{mainColor}

  /* Glassmorphism Effect */
  /* backdrop-filter applies a blur to the area behind the element, 
     creating the signature frosted glass look. */
  background: #{bgColor}
  backdrop-filter: blur(#{blurRadius})
  -webkit-backdrop-filter: blur(#{blurRadius})
  border-radius: #{borderRadius}
  border: #{borderStyle}
  padding: 20px
  box-sizing: border-box
  box-shadow: #{boxShadow}

  .main-container
    display: flex
    justify-content: space-between
    align-items: center

  .chart-box
    display: flex
    flex-direction: column
    align-items: center
    position: relative
    width: 33%

  .label
    font-size: 9px
    text-transform: uppercase
    font-weight: 800
    color: #{labelColor}
    margin-top: 10px
    letter-spacing: 1px

  svg
    width: #{gaugeSize}
    height: #{gaugeSize}
    transform: rotate(-90deg)

  circle
    fill: none
    stroke-width: 5
    stroke-linecap: round

  .bg-circle
    stroke: rgba(255, 255, 255, 0.1)

  .fg-circle
    transition: stroke-dasharray 1s ease-in-out
    stroke-dasharray: 0 #{gaugeCircumference}

  #cpu-circle { stroke: #{cpuColor}; }
  #ram-circle { stroke: #{ramColor}; }
  #bat-circle { stroke: #{batColor}; }

  .percentage
    position: absolute
    top: 35px
    left: 50%
    transform: translate(-50%, -50%)
    font-size: 10px
    font-weight: 700
    text-align: center
    line-height: 1.1

  .sub-val
    display: block
    font-size: 7px
    font-weight: 600
    color: #{subValColor}
    margin-top: 1px
"""

# --- Render ---
# The render function returns the HTML structure of the widget.
render: -> """
  <div class="main-container">
    <!-- CPU Gauge -->
    <div class="chart-box">
      <div class="percentage">
        <span id="cpu-val">0%</span>
      </div>
      <svg>
        <circle class="bg-circle" cx="35" cy="35" r="#{gaugeRadius}"></circle>
        <circle class="fg-circle" id="cpu-circle" cx="35" cy="35" r="#{gaugeRadius}"></circle>
      </svg>
      <div class="label">CPU</div>
    </div>

    <!-- RAM Gauge -->
    <div class="chart-box">
      <div class="percentage">
        <span id="ram-val">0%</span>
        <span class="sub-val" id="ram-gb">0/0G</span>
      </div>
      <svg>
        <circle class="bg-circle" cx="35" cy="35" r="#{gaugeRadius}"></circle>
        <circle class="fg-circle" id="ram-circle" cx="35" cy="35" r="#{gaugeRadius}"></circle>
      </svg>
      <div class="label">RAM</div>
    </div>

    <!-- Battery Gauge -->
    <div class="chart-box">
      <div class="percentage">
        <span id="bat-val">0%</span>
      </div>
      <svg>
        <circle class="bg-circle" cx="35" cy="35" r="#{gaugeRadius}"></circle>
        <circle class="fg-circle" id="bat-circle" cx="35" cy="35" r="#{gaugeRadius}"></circle>
      </svg>
      <div class="label">BATT</div>
    </div>
  </div>
"""

# --- Update Logic ---
# The update function is called periodically to refresh the widget content.
update: (output, domEl) ->
  values = output.split('\n')
  return unless values.length >= 3

  # Internal function to update the circular gauge stroke-dasharray based on percentage.
  # The stroke-dasharray property is used to create the progress ring effect.
  updateGauge = (idCircle, idVal, pct) ->
    circumference = 201
    # Calculate the visible part of the circle (stroke-dasharray)
    offset = circumference - (pct / 100) * circumference
    $(domEl).find("##{idCircle}").css 'stroke-dasharray', "#{circumference - offset} #{circumference}"
    $(domEl).find("##{idVal}").text("#{Math.round(pct)}%")

  # 1. CPU Usage
  cpuPct = parseFloat(values[0]) || 0
  updateGauge('cpu-circle', 'cpu-val', cpuPct)

  # 2. RAM Usage
  ramData = values[1].split(' ')
  if ramData.length == 2
    # Convert active pages to GB (Page size is typically 4096 bytes)
    # 1 GB = 1024 * 1024 * 1024 bytes
    usedGB = (parseFloat(ramData[0]) * 4096) / 1073741824
    totalGB = parseFloat(ramData[1]) / 1073741824
    ramPct = (usedGB / totalGB) * 100

    updateGauge('ram-circle', 'ram-val', ramPct)
    $(domEl).find("#ram-gb").text("#{usedGB.toFixed(1)}/#{Math.round(totalGB)}G")

  # 3. Battery Level
  batPct = parseFloat(values[2]) || 0
  updateGauge('bat-circle', 'bat-val', batPct)
