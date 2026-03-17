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
refreshRate = 30000

# Target disks to display (Regex pattern)
targetDisks = 'Macintosh HD - Data|Bootcamp'
# Whether to use Base-10 (H) or Base-2 (h) for disk sizes
useBase10 = true

# Position and sizing
posTop = "370px"
posLeft = "15px"
widgetWidth = "320px"

# Visual styling
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
nameColor = "#fff"
totalSizeBg = "rgba(255, 255, 255, 0.1)"
labelColor = "rgba(255, 255, 255, 0.35)"
barBgColor = "rgba(0, 0, 0, 0.2)"

# Progress Bar Colors
barGradientStart = "#007AFF"
barGradientEnd = "#00C7FF"
alertGradientStart = "#FF3B30"
alertGradientEnd = "#FF7A5C"

# Glassmorphism settings
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"

# --- Configuration ---
refreshFrequency: refreshRate

# Bash command chain to monitor disk usage:
# 1. 'df' gets disk space information from the file system.
# 2. 'grep' filters for physical devices (starting with /dev/).
# 3. 'diskutil info' retrieves the friendly Volume Name for each device.
# 4. Final 'grep' filters the results based on the 'targetDisks' parameter.
command: "df -#{if useBase10 then 'H' else 'h'} | grep '/dev/' | while read -r line; do fs=$(echo $line | awk '{print $1}'); name=$(diskutil info $fs | grep 'Volume Name' | awk '{print substr($0, index($0,$3))}'); echo $(echo $line | awk '{print $2, $3, $4, $5}') $(echo $name | awk '{print substr($0, index($0,$1))}'); done | grep -Ei '#{targetDisks}'"

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

  .container
    position: relative
    margin-bottom: 18px

  .container:last-child
    margin-bottom: 0

  .header
    display: flex
    justify-content: space-between
    align-items: center
    margin-bottom: 6px

  .name
    font-size: 13px
    font-weight: 700
    color: #{nameColor}

  .total-size
    font-size: 10px
    font-weight: 600
    color: rgba(255, 255, 255, 0.4)
    background: #{totalSizeBg}
    padding: 1px 6px
    border-radius: 6px

  .stats-row
    display: flex
    justify-content: space-between
    margin-bottom: 8px

  .stat-box
    display: flex
    flex-direction: column

  .label
    font-size: 8px
    text-transform: uppercase
    font-weight: 800
    color: #{labelColor}
    margin-bottom: 2px

  .value
    font-size: 11px
    font-weight: 600

  .bar-bg
    width: 100%
    height: 6px
    background: #{barBgColor}
    border-radius: 10px
    overflow: hidden

  .bar-fill
    height: 100%
    background: linear-gradient(90deg, #{barGradientStart}, #{barGradientEnd})
    border-radius: 10px
    transition: width 1.5s cubic-bezier(0.23, 1, 0.32, 1)

  /* Low space alert style (Usage > 90%) */
  .low-space
    background: linear-gradient(90deg, #{alertGradientStart}, #{alertGradientEnd})
"""

# --- Helper Functions ---
# Append 'B' to the size string for a more readable format (e.g., 500GB).
humanize: (sizeString) ->
  sizeString + 'B'

# --- Render ---
# The render function returns the initial HTML structure.
render: -> """
  <div id="storage-content"></div>
"""

# --- Update Logic ---
# The update function is called periodically to refresh the widget content.
update: (output, domEl) ->
  disks = output.split('\n')
  html = ""

  for disk in disks
    args = disk.split(' ')
    # Skip empty lines or malformed output
    continue if args.length < 5

    # Extract metrics from command output
    total = args[0]
    used  = args[1]
    free  = args[2]
    pctg  = args[3]
    name  = args[4..].join(' ')

    # Determine if we should show a "low space" alert (Usage > 90%)
    percentNum = parseInt(pctg.replace('%', ''))
    alertClass = if percentNum > 90 then "low-space" else ""

    # Build the HTML structure for each disk dynamically
    html += """
      <div class="container">
        <div class="header">
          <span class="name">#{name}</span>
          <span class="total-size">#{@humanize(total)}</span>
        </div>
        <div class="stats-row">
          <div class="stat-box">
            <span class="label">Used</span>
            <span class="value">#{@humanize(used)}</span>
          </div>
          <div class="stat-box" style="text-align: center">
            <span class="label">Free</span>
            <span class="value">#{@humanize(free)}</span>
          </div>
          <div class="stat-box" style="text-align: right">
            <span class="label">Usage</span>
            <span class="value">#{pctg}</span>
          </div>
        </div>
        <div class="bar-bg">
          <div class="bar-fill #{alertClass}" style="width: #{pctg}"></div>
        </div>
      </div>
    """

  # Update the widget's internal content while keeping the main container styles intact.
  $(domEl).html(html)
