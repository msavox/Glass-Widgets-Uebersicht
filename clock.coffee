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
refreshRate = 5000

# Position and sizing
posTop = "20px"
posLeft = "15px"
widgetWidth = "150px"
widgetHeight = "160px"

# Visual styling
mainColor = "#fff"
labelFont = '"Snell Roundhand", cursive'
labelFontSize = "19px"
timeFont = '"DIN Condensed", sans-serif'
timeFontSize = "75px"

# Glassmorphism settings
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"

# Wave decoration settings
waveHeight = "60px"
waveOpacity = "0.4"
waveColor = "#ffffff"

# --- Configuration ---
refreshFrequency: refreshRate

# Bash command to get the current time in HH:MM format
# date +%H:%M returns the current hour and minute.
command: "date +%H:%M"

# --- Style ---
# The style section defines the visual appearance using CSS-in-JS (Stylus-like syntax).
style: """
  top: #{posTop}
  left: #{posLeft}
  width: #{widgetWidth}
  height: #{widgetHeight}
  position: relative
  overflow: hidden

  /* Glassmorphism Effect */
  /* backdrop-filter applies a blur to the area behind the element, 
     creating the signature frosted glass look of macOS and iOS. */
  background: #{bgColor}
  backdrop-filter: blur(#{blurRadius})
  -webkit-backdrop-filter: blur(#{blurRadius})
  border-radius: #{borderRadius}
  border: #{borderStyle}
  box-shadow: #{boxShadow}

  /* Layout */
  display: flex
  flex-direction: column
  justify-content: center
  align-items: center
  color: #{mainColor}
  -webkit-font-smoothing: antialiased

  /* Background Wave SVG */
  .wave-bg
    position: absolute
    bottom: 0
    left: 0
    width: 100%
    height: #{waveHeight}
    opacity: #{waveOpacity}
    z-index: 0
    pointer-events: none

  .label
    font-family: #{labelFont}
    font-size: #{labelFontSize}
    opacity: 0.8
    margin-bottom: 18px
    transform: rotate(-2deg)
    margin-top: -15px
    z-index: 1

  .time-box
    display: flex
    align-items: center
    justify-content: center
    font-family: #{timeFont}
    font-size: #{timeFontSize}
    font-weight: 600
    line-height: 0.8
    z-index: 1

  .dots
    display: inline-block
    transform: translateY(-14px)
    margin: 0 1px
    opacity: 0.8
"""

# --- Render ---
# The render function returns the HTML structure of the widget.
# It receives the 'output' from the shell command.
render: (output) ->
  # Split the "HH:MM" output into hours and minutes
  time = output.split(':')
  """
  <!-- Decorative SVG Wave -->
  <!-- This SVG creates a stylish wave at the bottom of the widget -->
  <svg class="wave-bg" viewBox="0 0 1440 320" preserveAspectRatio="none">
    <path fill="#{waveColor}" d="M0,160L48,176C96,192,192,224,288,224C384,224,480,192,576,165.3C672,139,768,117,864,128C960,139,1056,181,1152,197.3C1248,213,1344,203,1392,197.3L1440,192L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path>
  </svg>

  <div class="label">The Clock says...</div>
  <div class="time-box">
    <span>#{time[0]}</span>
    <span class="dots">:</span>
    <span>#{time[1]}</span>
  </div>
  """
