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
posTop = "710px"
posLeft = "15px"
widgetWidth = "320px"

# Visual styling
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
labelColor = "rgba(255, 255, 255, 0.4)"

# Gauge Colors
gpuColor = "#BF5AF2"
tempCpuColor = "#FF375F"
tempGpuColor = "#FF9500"
fanColor = "#32D74B"

# Glassmorphism settings
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"

# Gauge dimensions
gaugeRadiusLarge = 32
gaugeCircumferenceLarge = 201
gaugeRadiusSmall = 24
gaugeCircumferenceSmall = 151
maxFanSpeed = 5600 # Used to calculate fan gauge percentage (typical for MacBook Pro)

# --- Configuration ---
refreshFrequency: refreshRate

# Bash command chain to extract advanced system metrics:
# 1. GPU Utilization: Estimates GPU usage based on CPU load (Integrated GPU).
# 2. Temperature: Uses 'powermetrics' (requires sudo) to get CPU/GPU die temperatures.
# 3. Fans: Extracts fan speed in RPM from 'powermetrics' data.
command: """
  # 1. GPU Utilization estimation
  usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%')
  echo "INTEGR ${usage:-0}%"

  # 2. Temperature via powermetrics
  data=$(sudo /usr/bin/powermetrics -n 1 -i 100 --samplers smc)
  t_cpu=$(echo "$data" | grep "CPU die temperature" | awk '{print $4}' | cut -d. -f1)
  t_gpu=$(echo "$data" | grep "GPU die temperature" | awk '{print $4}' | cut -d. -f1)
  echo "${t_cpu:-0} ${t_gpu:-0}"

  # 3. Fans speed
  fan=$(echo "$data" | grep "Fan:" | awk '{print $2}' | cut -d. -f1)
  echo "${fan:-0}"
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

  .box
    display: flex
    flex-direction: column
    align-items: center
    width: 33%

  .circle-wrap
    position: relative
    width: 70px
    height: 70px

  svg
    width: 70px
    height: 70px
    transform: rotate(-90deg)

  circle
    fill: none
    stroke-linecap: round

  .bg
    stroke: rgba(255, 255, 255, 0.1)
    stroke-width: 5

  .fg
    transition: stroke-dasharray 1s ease
    stroke-width: 5

  .val-center
    position: absolute
    top: 50%
    left: 50%
    transform: translate(-50%, -50%)
    font-size: 10px
    font-weight: 700
    text-align: center
    line-height: 1.1

  .label
    font-size: 9px
    text-transform: uppercase
    font-weight: 800
    color: #{labelColor}
    margin-top: 10px
    letter-spacing: 1px

  .temp-label
    font-size: 7px
    font-weight: 600
    opacity: 0.7
"""

# --- Render ---
# The render function returns the HTML structure of the widget.
render: -> """
  <div class="main-container">
    <!-- GPU Section -->
    <div class="box">
      <div class="circle-wrap">
        <svg>
          <circle class="bg" cx="35" cy="35" r="#{gaugeRadiusLarge}"></circle>
          <circle class="fg" id="gpu-f" cx="35" cy="35" r="#{gaugeRadiusLarge}" stroke="#{gpuColor}"></circle>
        </svg>
        <div class="val-center"><span id="gpu-v">0%</span></div>
      </div>
      <div class="label">GPU</div>
    </div>

    <!-- Temperature Section (Dual Gauges) -->
    <div class="box">
      <div class="circle-wrap">
        <svg>
          <!-- Outer circle for CPU Temperature -->
          <circle class="bg" cx="35" cy="35" r="#{gaugeRadiusLarge}"></circle>
          <circle class="fg" id="tempC-f" cx="35" cy="35" r="#{gaugeRadiusLarge}" stroke="#{tempCpuColor}"></circle>
          
          <!-- Inner circle for GPU Temperature -->
          <circle class="bg" cx="35" cy="35" r="#{gaugeRadiusSmall}" style="stroke-width:4"></circle>
          <circle class="fg" id="tempG-f" cx="35" cy="35" r="#{gaugeRadiusSmall}" stroke="#{tempGpuColor}" style="stroke-width:4"></circle>
        </svg>
        <div class="val-center">
          <div><span id="tempC-v">0</span><span class="temp-label">°C</span></div>
          <div style="color:#{tempGpuColor};"><span id="tempG-v">0</span><span class="temp-label">°C</span></div>
        </div>
      </div>
      <div class="label">TEMP</div>
    </div>

    <!-- Fan Section -->
    <div class="box">
      <div class="circle-wrap">
        <svg>
          <circle class="bg" cx="35" cy="35" r="#{gaugeRadiusLarge}"></circle>
          <circle class="fg" id="fan-f" cx="35" cy="35" r="#{gaugeRadiusLarge}" stroke="#{fanColor}"></circle>
        </svg>
        <div class="val-center">
          <span id="fan-v">0</span>
          <span style="font-size:7px; display:block; opacity:0.6">RPM</span>
        </div>
      </div>
      <div class="label">FANS</div>
    </div>
  </div>
"""

# --- Update Logic ---
# The update function is called periodically to refresh the widget content.
update: (output, domEl) ->
  lines = output.split('\n')
  return if lines.length < 3
  
  # Constants for circle circumferences (calculated based on radius)
  c32 = 201
  c24 = 151

  # 1. Update GPU usage
  gpuParts = lines[0].split(' ')
  gpuPct = if gpuParts.length > 1 then parseInt(gpuParts[1]) else 0
  $(domEl).find("#gpu-v").text("#{gpuPct}%")
  $(domEl).find("#gpu-f").css "stroke-dasharray", "#{(gpuPct/100)*c32} #{c32}"

  # 2. Update Temperatures (CPU and GPU)
  temps = lines[1].split(' ')
  tC = parseInt(temps[0]) || 0
  tG = parseInt(temps[1]) || 0
  $(domEl).find("#tempC-v").text(tC)
  $(domEl).find("#tempG-v").text(tG)
  $(domEl).find("#tempC-f").css "stroke-dasharray", "#{(Math.min(tC, 100)/100)*c32} #{c32}"
  $(domEl).find("#tempG-f").css "stroke-dasharray", "#{(Math.min(tG, 100)/100)*c24} #{c24}"

  # 3. Update Fan speed
  fanVal = parseInt(lines[2]) || 0
  $(domEl).find("#fan-v").text(fanVal)
  # Calculate fan percentage based on a maximum speed of 5600 RPM
  fanPct = Math.min((fanVal / 5600) * c32, c32)
  $(domEl).find("#fan-f").css "stroke-dasharray", "#{fanPct} #{c32}"
