#   ____ _                         __        ___     _            _       
#  / ___| | __ _ ___ ___           \ \      / (_) __| | __ _  ___| |_ ___ 
# | |  _| |/ _` / __/ __|  _____    \ \ /\ / /| |/ _` |/ _` |/ _ \ __/ __|
# | |_| | | (_| \__ \__ \ |_____|    \ V  V / | | (_| | (_| |  __/ |_ \__ \
#  \____|_|\__,_|___/___/             \_/\_/  |_|\__,_|\__, |\___|\__|___/
#                                                      |___/              
#
# Author:  Matteo Savoia
# Version: 1.5 (Lockable Draggable)
# Release: 2026
# ---------------------------------------------------------------------------

refreshRate = 1000
posTop = "920px"
posLeft = "20px"
widgetWidth = "320px"
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
titleColor = "rgba(255, 255, 255, 0.5)"
labelColor = "rgba(255, 255, 255, 0.35)"
barBgColor = "rgba(0, 0, 0, 0.2)"
downColorStart = "#64D2FF"
downColorEnd = "#5AC8FA"
upColorStart = "#FF9500"
upColorEnd = "#FFCC00"
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"
movingAverageSamples = 5

refreshFrequency: refreshRate
command: "Glass-Widgets/lib/network.sh"

# --- Style ---
style: """
  top: #{posTop}
  left: #{posLeft}
  width: #{widgetWidth}
  font-family: #{fontFamily}
  -webkit-font-smoothing: antialiased
  color: #{mainColor}
  background: #{bgColor}
  backdrop-filter: blur(#{blurRadius})
  -webkit-backdrop-filter: blur(#{blurRadius})
  border-radius: #{borderRadius}
  border: #{borderStyle}
  padding: 16px
  box-sizing: border-box
  box-shadow: #{boxShadow}
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

  .pos-indicator
    position: absolute
    bottom: -25px
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

  .dragging .pos-indicator
    opacity: 1
"""

# --- Render ---
render: -> """
  <div class="lock-btn" id="lock-toggle">🔓</div>
  <div class="widget-title">
    <span>Network</span>
    <span class="ssid-val"><span id="ssid">Loading...</span> 📡</span>
  </div>
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
  <div class="pos-indicator" id="coords">T: 0 L: 0</div>
"""

# --- Logic ---
afterRender: (domEl) ->
  isLocked = localStorage.getItem('net_locked') == 'true'
  savedTop = localStorage.getItem('net_pos_top')
  savedLeft = localStorage.getItem('net_pos_left')
  if savedTop and savedLeft
    domEl.style.top = savedTop
    domEl.style.left = savedLeft

  updateLockUI = ->
    $(domEl).toggleClass('locked', isLocked)
    $(domEl).find('#lock-toggle').text(if isLocked then '🔒' else '🔓')
  updateLockUI()

  $(domEl).find('#lock-toggle').on 'click', (e) ->
    isLocked = !isLocked
    localStorage.setItem('net_locked', isLocked)
    updateLockUI()
    e.stopPropagation()

  isDragging = false
  startX = 0
  startY = 0

  $(domEl).on 'mousedown', (e) ->
    return if isLocked or $(e.target).hasClass('lock-btn')
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
      localStorage.setItem('net_pos_top', domEl.style.top)
      localStorage.setItem('net_pos_left', domEl.style.left)
      $(document).off 'mousemove', mouseMoveHandler
      $(document).off 'mouseup', mouseUpHandler

update: (output, domEl) ->
  lines = output.split "^"
  rawDown = (Number(lines[0]) || 0) * 2
  rawUp = (Number(lines[1]) || 0) * 2
  ssidName = lines[2] || "Off"
  $el = $(domEl)
  historyDown = $el.data('hDown') || []
  historyUp = $el.data('hUp') || []
  historyDown.push(rawDown)
  historyUp.push(rawUp)
  if historyDown.length > movingAverageSamples then historyDown.shift()
  if historyUp.length > movingAverageSamples then historyUp.shift()
  $el.data('hDown', historyDown)
  $el.data('hUp', historyUp)
  avg = (arr) -> arr.reduce(((a, b) -> a + b), 0) / arr.length
  downBytes = avg(historyDown)
  upBytes = avg(historyUp)
  mDown = $el.data('mDown') || 0
  mUp = $el.data('mUp') || 0
  if downBytes > mDown then mDown = downBytes; $el.data('mDown', mDown)
  if upBytes > mUp then mUp = upBytes; $el.data('mUp', mUp)
  maxSeen = $el.data('maxSeen') || (100 * 1024)
  currentMax = Math.max(mDown, mUp)
  if currentMax > maxSeen
    maxSeen = currentMax
    $el.data('maxSeen', maxSeen)
  formatSpeed = (bytes) ->
    kb = bytes / 1024
    if kb > 1024 then mb = kb / 1024; "#{mb.toFixed(1)} MB/s" else "#{kb.toFixed(1)} KB/s"
  dPct = (downBytes / maxSeen) * 100
  uPct = (upBytes / maxSeen) * 100
  $el.find("#down-val").text formatSpeed(downBytes)
  $el.find("#up-val").text formatSpeed(upBytes)
  $el.find("#down-max").text formatSpeed(mDown)
  $el.find("#up-max").text formatSpeed(mUp)
  $el.find("#ssid").text ssidName
  $el.find("#down-bar").css "width", "#{dPct}%"
  $el.find("#up-bar").css "width", "#{uPct}%"
