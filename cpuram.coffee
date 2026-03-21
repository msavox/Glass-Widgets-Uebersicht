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

refreshRate = 2000
posTop = "560px"
posLeft = "15px"
widgetWidth = "320px"
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
labelColor = "rgba(255, 255, 255, 0.4)"
subValColor = "rgba(255, 255, 255, 0.6)"
cpuColor = "#34C759"
ramColor = "#32D74B"
batColor = "#FFCC00"
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"
gaugeSize = "70px"
gaugeRadius = 32
gaugeCircumference = 201 

refreshFrequency: refreshRate
command: """
  top -l 1 -n 0 | awk '/CPU usage/ {print $3 + $5 "%"}';
  used_ram=$(vm_stat | awk '/Pages active/ {print $3}' | sed 's/\\.//');
  total_ram=$(sysctl hw.memsize | awk '{print $2}');
  echo "$used_ram $total_ram";
  pmset -g batt | awk '{for(i=1;i<=NF;i++) if($i~/[0-9]+%/) print $i}' | head -1 | tr -d '%;'
"""

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
  padding: 20px
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
  <div class="main-container">
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
  <div class="pos-indicator" id="coords">T: 0 L: 0</div>
"""

# --- Logic ---
afterRender: (domEl) ->
  isLocked = localStorage.getItem('cpuram_locked') == 'true'
  savedTop = localStorage.getItem('cpuram_pos_top')
  savedLeft = localStorage.getItem('cpuram_pos_left')
  if savedTop and savedLeft
    domEl.style.top = savedTop
    domEl.style.left = savedLeft

  updateLockUI = ->
    $(domEl).toggleClass('locked', isLocked)
    $(domEl).find('#lock-toggle').text(if isLocked then '🔒' else '🔓')
  updateLockUI()

  $(domEl).find('#lock-toggle').on 'click', (e) ->
    isLocked = !isLocked
    localStorage.setItem('cpuram_locked', isLocked)
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
      localStorage.setItem('cpuram_pos_top', domEl.style.top)
      localStorage.setItem('cpuram_pos_left', domEl.style.left)
      $(document).off 'mousemove', mouseMoveHandler
      $(document).off 'mouseup', mouseUpHandler

update: (output, domEl) ->
  values = output.split('\n')
  return unless values.length >= 3
  updateGauge = (idCircle, idVal, pct) ->
    circumference = 201
    offset = circumference - (pct / 100) * circumference
    $(domEl).find("##{idCircle}").css 'stroke-dasharray', "#{circumference - offset} #{circumference}"
    $(domEl).find("##{idVal}").text("#{Math.round(pct)}%")
  cpuPct = parseFloat(values[0]) || 0
  updateGauge('cpu-circle', 'cpu-val', cpuPct)
  ramData = values[1].split(' ')
  if ramData.length == 2
    usedGB = (parseFloat(ramData[0]) * 4096) / 1073741824
    totalGB = parseFloat(ramData[1]) / 1073741824
    ramPct = (usedGB / totalGB) * 100
    updateGauge('ram-circle', 'ram-val', ramPct)
    $(domEl).find("#ram-gb").text("#{usedGB.toFixed(1)}/#{Math.round(totalGB)}G")
  batPct = parseFloat(values[2]) || 0
  updateGauge('bat-circle', 'bat-val', batPct)
