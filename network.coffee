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
refreshRate = 1000

# Position and sizing
posTop = "860px"
posLeft = "15px"
widgetWidth = "320px"

# Visual styling
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
titleColor = "rgba(255, 255, 255, 0.5)"
labelColor = "rgba(255, 255, 255, 0.35)"
barBgColor = "rgba(0, 0, 0, 0.2)"

# Download Bar Colors
downColorStart = "#64D2FF"
downColorEnd = "#5AC8FA"

# Upload Bar Colors
upColorStart = "#FF9500"
upColorEnd = "#FFCC00"

# Glassmorphism settings
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"

# Smoothing Settings
# Number of samples to use for the moving average calculation.
movingAverageSamples = 5

# --- Configuration ---
refreshFrequency: refreshRate

# Bash command to execute the network monitoring script.
# The script 'network.sh' calculates data transfer rates by sampling interface statistics.
command: "Glass-Widgets/lib/network.sh"

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
  padding: 16px
  box-sizing: border-box
  box-shadow: #{boxShadow}

  .widget-title
    display: flex
    justify-content: space-between
    align-items: center
    font-size: 10px
    text-transform: uppercase
    font-weight: 800
    letter-spacing: 1px
    margin-bottom: 12px
    color: #{titleColor}

  .ssid-val
    text-transform: none
    font-size: 9px
    opacity: 0.8
    display: flex
    align-items: center
    gap: 4px
    font-weight: 600

  .stat-row
    margin-bottom: 12px

  .stat-row:last-child
    margin-bottom: 0

  .header-info
    display: flex
    justify-content: space-between
    align-items: flex-end
    margin-bottom: 6px

  .label
    font-size: 8px
    text-transform: uppercase
    font-weight: 800
    color: #{labelColor}

  .value-group
    display: flex
    align-items: baseline
    gap: 8px

  .value
    font-size: 11px
    font-weight: 700

  .max-info
    font-size: 7px
    font-weight: 800
    color: rgba(255, 255, 255, 0.25)
    text-transform: uppercase
    display: flex
    gap: 3px

  .max-val
    color: rgba(255, 255, 255, 0.4)

  .bar-bg
    width: 100%
    height: 6px
    background: #{barBgColor}
    border-radius: 10px
    overflow: hidden

  .bar-fill
    height: 100%
    border-radius: 10px
    transition: width 1.2s cubic-bezier(0.23, 1, 0.32, 1)

  .down-fill
    background: linear-gradient(90deg, #{downColorStart}, #{downColorEnd})
  
  .up-fill
    background: linear-gradient(90deg, #{upColorStart}, #{upColorEnd})
"""

# --- Render ---
# The render function returns the HTML structure of the widget.
render: -> """
  <div class="widget-title">
    <span>Network</span>
    <span class="ssid-val"><span id="ssid">Loading...</span> 📡</span>
  </div>

  <!-- Download Traffic Section -->
  <div class="stat-row">
    <div class="header-info">
      <span class="label">Download</span>
      <div class="value-group">
        <span class="value" id="down-val">0 KB/s</span>
        <div class="max-info">MAX <span class="max-val" id="down-max">0</span></div>
      </div>
    </div>
    <div class="bar-bg">
      <div class="bar-fill down-fill" id="down-bar" style="width: 0%"></div>
    </div>
  </div>

  <!-- Upload Traffic Section -->
  <div class="stat-row">
    <div class="header-info">
      <span class="label">Upload</span>
      <div class="value-group">
        <span class="value" id="up-val">0 KB/s</span>
        <div class="max-info">MAX <span class="max-val" id="up-max">0</span></div>
      </div>
    </div>
    <div class="bar-bg">
      <div class="bar-fill up-fill" id="up-bar" style="width: 0%"></div>
    </div>
  </div>
"""

# --- Update Logic ---
# The update function is called periodically to refresh the widget content.
update: (output, domEl) ->
  # Parse the output from the bash script (delimited by '^')
  lines = output.split "^"
  # Instantaneous values are doubled to convert from 0.5s sample to bytes per second
  rawDown = (Number(lines[0]) || 0) * 2
  rawUp = (Number(lines[1]) || 0) * 2
  ssidName = lines[2] || "Off"

  # Manage data history for smoothing using a Moving Average (MA)
  # This prevents the UI from flickering due to sharp bursts in network traffic.
  $el = $(domEl)
  historyDown = $el.data('hDown') || []
  historyUp = $el.data('hUp') || []

  # Add new sample and maintain the window size (movingAverageSamples)
  historyDown.push(rawDown)
  historyUp.push(rawUp)
  if historyDown.length > movingAverageSamples then historyDown.shift()
  if historyUp.length > movingAverageSamples then historyUp.shift()

  # Store the updated history back into the element's data
  $el.data('hDown', historyDown)
  $el.data('hUp', historyUp)

  # Calculate the average of the current sample window
  avg = (arr) -> arr.reduce(((a, b) -> a + b), 0) / arr.length
  downBytes = avg(historyDown)
  upBytes = avg(historyUp)

  # Track and store the maximum speed seen during this session for UI display
  mDown = $el.data('mDown') || 0
  mUp = $el.data('mUp') || 0
  if downBytes > mDown then mDown = downBytes; $el.data('mDown', mDown)
  if upBytes > mUp then mUp = upBytes; $el.data('mUp', mUp)

  # Global maximum used for scaling the progress bars dynamically
  maxSeen = $el.data('maxSeen') || (100 * 1024) # Default floor: 100 KB/s
  currentMax = Math.max(mDown, mUp)
  if currentMax > maxSeen
    maxSeen = currentMax
    $el.data('maxSeen', maxSeen)

  # Helper function to format bytes/s into human-readable strings (KB/s or MB/s)
  formatSpeed = (bytes) ->
    kb = bytes / 1024
    if kb > 1024
      mb = kb / 1024
      "#{mb.toFixed(1)} MB/s"
    else
      "#{kb.toFixed(1)} KB/s"

  # Calculate percentage fill for the bars based on the global maximum seen
  dPct = (downBytes / maxSeen) * 100
  uPct = (upBytes / maxSeen) * 100

  # Update DOM elements with calculated values
  $el.find("#down-val").text formatSpeed(downBytes)
  $el.find("#up-val").text formatSpeed(upBytes)
  $el.find("#down-max").text formatSpeed(mDown)
  $el.find("#up-max").text formatSpeed(mUp)
  $el.find("#ssid").text ssidName
  $el.find("#down-bar").css "width", "#{dPct}%"
  $el.find("#up-bar").css "width", "#{uPct}%"
