#   ____ _                         __        ___     _            _       
#  / ___| | __ _ ___ ___           \ \      / (_) __| | __ _  ___| |_ ___ 
# | |  _| |/ _` / __/ __|  _____    \ \ /\ / /| |/ _` |/ _` |/ _ \ __/ __|
# | |_| | | (_| \__ \__ \ |_____|    \ V  V / | | (_| | (_| |  __/ |_ \__ \
#  \____|_|\__,_|___/___/             \_/\_/  |_|\__,_|\__, |\___|\__|___/
#                                                      |___/              
#
# Author:  Matteo Savoia
# Version: 1.5.2 (Surgical Update)
# Release: 2026
# ---------------------------------------------------------------------------

refreshRate = 5000
posTop = "20px"
posLeft = "20px"
widgetWidth = "150px"
widgetHeight = "160px"
mainColor = "#fff"
labelFont = '"Snell Roundhand", cursive'
labelFontSize = "19px"
timeFont = '"DIN Condensed", sans-serif'
timeFontSize = "75px"
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"
waveHeight = "60px"
waveOpacity = "0.4"
waveColor = "#ffffff"

refreshFrequency: refreshRate
command: "date +%H:%M"

# --- Style ---
style: """
  top: #{posTop}
  left: #{posLeft}
  width: #{widgetWidth}
  height: #{widgetHeight}
  position: relative
  overflow: hidden
  background: #{bgColor}
  backdrop-filter: blur(#{blurRadius})
  -webkit-backdrop-filter: blur(#{blurRadius})
  border-radius: #{borderRadius}
  border: #{borderStyle}
  box-shadow: #{boxShadow}
  display: flex
  flex-direction: column
  justify-content: center
  align-items: center
  color: #{mainColor}
  -webkit-font-smoothing: antialiased
  cursor: grab
  user-select: none
  pointer-events: auto

  &.locked
    cursor: default

  .lock-btn
    position: absolute
    top: 8px
    right: 12px
    font-size: 10px
    opacity: 0.15
    cursor: pointer
    transition: opacity 0.2s
    z-index: 10
  
  .lock-btn:hover
    opacity: 1

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

  .pos-indicator
    position: absolute
    bottom: 5px
    left: 50%
    transform: translateX(-50%)
    background: rgba(0,0,0,0.6)
    color: white
    font-size: 8px
    padding: 2px 8px
    border-radius: 10px
    opacity: 0
    transition: opacity 0.3s
    pointer-events: none
    z-index: 10

  .dragging .pos-indicator
    opacity: 1
"""

# --- Render ---
render: -> """
  <div class="lock-btn" id="lock-toggle">🔓</div>
  <svg class="wave-bg" viewBox="0 0 1440 320" preserveAspectRatio="none">
    <path fill="#{waveColor}" d="M0,160L48,176C96,192,192,224,288,224C384,224,480,192,576,165.3C672,139,768,117,864,128C960,139,1056,181,1152,197.3C1248,213,1344,203,1392,197.3L1440,192L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path>
  </svg>
  <div class="label">The Clock says...</div>
  <div class="time-box">
    <span id="h-val">00</span>
    <span class="dots">:</span>
    <span id="m-val">00</span>
  </div>
  <div class="pos-indicator" id="coords">T: 0 L: 0</div>
"""

# --- Logic ---
afterRender: (domEl) ->
  KEY_POS_T = 'clock_pos_top'
  KEY_POS_L = 'clock_pos_left'
  KEY_LOCKED = 'clock_locked'

  savedTop = localStorage.getItem(KEY_POS_T)
  savedLeft = localStorage.getItem(KEY_POS_L)
  isLocked = localStorage.getItem(KEY_LOCKED) == 'true'

  if savedTop and savedLeft
    domEl.style.top = savedTop
    domEl.style.left = savedLeft

  updateLockUI = ->
    $(domEl).toggleClass('locked', isLocked)
    $(domEl).find('#lock-toggle').text(if isLocked then '🔒' else '🔓')
    domEl.style.cursor = if isLocked then 'default' else 'grab'
  updateLockUI()

  $(domEl).on 'click', '#lock-toggle', (e) ->
    isLocked = !isLocked
    localStorage.setItem(KEY_LOCKED, isLocked)
    updateLockUI()
    e.stopPropagation()

  isDragging = false
  startX = 0
  startY = 0

  $(domEl).on 'mousedown', (e) ->
    return if isLocked or $(e.target).closest('#lock-toggle').length > 0
    isDragging = true
    $(domEl).addClass('dragging')
    domEl.style.cursor = 'grabbing'
    startX = e.clientX - domEl.offsetLeft
    startY = e.clientY - domEl.offsetTop
    $(document).on 'mousemove', mouseMoveHandler
    $(document).on 'mouseup', mouseUpHandler

  mouseMoveHandler = (e) ->
    if isDragging
      newTop = (e.clientY - startY) + 'px'
      newLeft = (e.clientX - startX) + 'px'
      domEl.style.top = newTop
      domEl.style.left = newLeft
      $(domEl).find('#coords').text("T: #{newTop} L: #{newLeft}")

  mouseUpHandler = ->
    if isDragging
      isDragging = false
      $(domEl).removeClass('dragging')
      domEl.style.cursor = if isLocked then 'default' else 'grab'
      localStorage.setItem(KEY_POS_T, domEl.style.top)
      localStorage.setItem(KEY_POS_L, domEl.style.left)
      $(document).off 'mousemove', mouseMoveHandler
      $(document).off 'mouseup', mouseUpHandler

update: (output, domEl) ->
  time = output.split(':')
  return if time.length < 2
  $(domEl).find('#h-val').text(time[0])
  $(domEl).find('#m-val').text(time[1])
