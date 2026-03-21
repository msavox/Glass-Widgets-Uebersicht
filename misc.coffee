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
posTop = "710px"
posLeft = "15px"
widgetWidth = "320px"
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
labelColor = "rgba(255, 255, 255, 0.4)"
gpuColor = "#BF5AF2"
tempCpuColor = "#FF375F"
tempGpuColor = "#FF9500"
fanColor = "#32D74B"
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"
gaugeRadiusLarge = 32
gaugeCircumferenceLarge = 201
gaugeRadiusSmall = 24
gaugeCircumferenceSmall = 151
maxFanSpeed = 5600 

refreshFrequency: refreshRate
command: """
  usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%')
  echo "INTEGR ${usage:-0}%"
  data=$(sudo /usr/bin/powermetrics -n 1 -i 100 --samplers smc)
  t_cpu=$(echo "$data" | grep "CPU die temperature" | awk '{print $4}' | cut -d. -f1)
  t_gpu=$(echo "$data" | grep "GPU die temperature" | awk '{print $4}' | cut -d. -f1)
  echo "${t_cpu:-0} ${t_gpu:-0}"
  fan=$(echo "$data" | grep "Fan:" | awk '{print $2}' | cut -d. -f1)
  echo "${fan:-0}"
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
    <div class="box">
      <div class="circle-wrap">
        <svg>
          <circle class="bg" cx="35" cy="35" r="#{gaugeRadiusLarge}"></circle>
          <circle class="fg" id="tempC-f" cx="35" cy="35" r="#{gaugeRadiusLarge}" stroke="#{tempCpuColor}"></circle>
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
  <div class="pos-indicator" id="coords">T: 0 L: 0</div>
"""

# --- Logic ---
afterRender: (domEl) ->
  isLocked = localStorage.getItem('misc_locked') == 'true'
  savedTop = localStorage.getItem('misc_pos_top')
  savedLeft = localStorage.getItem('misc_pos_left')
  if savedTop and savedLeft
    domEl.style.top = savedTop
    domEl.style.left = savedLeft

  updateLockUI = ->
    $(domEl).toggleClass('locked', isLocked)
    $(domEl).find('#lock-toggle').text(if isLocked then '🔒' else '🔓')
  updateLockUI()

  $(domEl).find('#lock-toggle').on 'click', (e) ->
    isLocked = !isLocked
    localStorage.setItem('misc_locked', isLocked)
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
      localStorage.setItem('misc_pos_top', domEl.style.top)
      localStorage.setItem('misc_pos_left', domEl.style.left)
      $(document).off 'mousemove', mouseMoveHandler
      $(document).off 'mouseup', mouseUpHandler

update: (output, domEl) ->
  lines = output.split('\n')
  return if lines.length < 3
  c32 = 201
  c24 = 151
  gpuParts = lines[0].split(' ')
  gpuPct = if gpuParts.length > 1 then parseInt(gpuParts[1]) else 0
  $(domEl).find("#gpu-v").text("#{gpuPct}%")
  $(domEl).find("#gpu-f").css "stroke-dasharray", "#{(gpuPct/100)*c32} #{c32}"
  temps = lines[1].split(' ')
  tC = parseInt(temps[0]) || 0
  tG = parseInt(temps[1]) || 0
  $(domEl).find("#tempC-v").text(tC)
  $(domEl).find("#tempG-v").text(tG)
  $(domEl).find("#tempC-f").css "stroke-dasharray", "#{(Math.min(tC, 100)/100)*c32} #{c32}"
  $(domEl).find("#tempG-f").css "stroke-dasharray", "#{(Math.min(tG, 100)/100)*c24} #{c24}"
  fanVal = parseInt(lines[2]) || 0
  $(domEl).find("#fan-v").text(fanVal)
  fanPct = Math.min((fanVal / 5600) * c32, c32)
  $(domEl).find("#fan-f").css "stroke-dasharray", "#{fanPct} #{c32}"
