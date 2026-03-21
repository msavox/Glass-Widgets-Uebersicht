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

refreshRate = 30000
targetDisks = 'Macintosh HD - Data|Bootcamp'
useBase10 = true
posTop = "370px"
posLeft = "15px"
widgetWidth = "320px"
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
nameColor = "#fff"
totalSizeBg = "rgba(255, 255, 255, 0.1)"
labelColor = "rgba(255, 255, 255, 0.35)"
barBgColor = "rgba(0, 0, 0, 0.2)"
barGradientStart = "#007AFF"
barGradientEnd = "#00C7FF"
alertGradientStart = "#FF3B30"
alertGradientEnd = "#FF7A5C"
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"

refreshFrequency: refreshRate
command: "df -#{if useBase10 then 'H' else 'h'} | grep '/dev/' | while read -r line; do fs=$(echo $line | awk '{print $1}'); name=$(diskutil info $fs | grep 'Volume Name' | awk '{print substr($0, index($0,$3))}'); echo $(echo $line | awk '{print $2, $3, $4, $5}') $(echo $name | awk '{print substr($0, index($0,$1))}'); done | grep -Ei '#{targetDisks}'"

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

  .low-space
    background: linear-gradient(90deg, #{alertGradientStart}, #{alertGradientEnd})

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
  <div id="storage-content"></div>
  <div class="pos-indicator" id="coords">T: 0 L: 0</div>
"""

# --- Logic ---
afterRender: (domEl) ->
  isLocked = localStorage.getItem('disk_locked') == 'true'
  savedTop = localStorage.getItem('disk_pos_top')
  savedLeft = localStorage.getItem('disk_pos_left')
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
    localStorage.setItem('disk_locked', isLocked)
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
      localStorage.setItem('disk_pos_top', domEl.style.top)
      localStorage.setItem('disk_pos_left', domEl.style.left)
      $(document).off 'mousemove', mouseMoveHandler
      $(document).off 'mouseup', mouseUpHandler

humanize: (sizeString) -> sizeString + 'B'

update: (output, domEl) ->
  disks = output.split('\n')
  html = ""
  for disk in disks
    args = disk.split(' ')
    continue if args.length < 5
    total = args[0]
    used  = args[1]
    free  = args[2]
    pctg  = args[3]
    name  = args[4..].join(' ')
    percentNum = parseInt(pctg.replace('%', ''))
    alertClass = if percentNum > 90 then "low-space" else ""
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
  $(domEl).find('#storage-content').html(html)
