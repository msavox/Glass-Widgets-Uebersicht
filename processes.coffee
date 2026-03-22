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

# --- Parameters Section ---
refreshRate = 4000
posTop = "660px"
posLeft = "360px"
widgetWidth = "320px"

# Visual styling
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
labelColor = "rgba(255, 255, 255, 0.4)"
barBgColor = "rgba(255, 255, 255, 0.1)"
cpuBarColor = "#34C759" 

# Glassmorphism settings
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"

# --- Configuration ---
refreshFrequency: refreshRate
command: "sysctl -n hw.ncpu; top -l 2 -n 6 -stats command,cpu,mem -o cpu | tail -n 6 | awk '{print $2, $3, $1}'"

# --- Style ---
style: """
  top: #{posTop}
  left: #{posLeft}
  width: #{widgetWidth}
  font-family: #{fontFamily}
  -webkit-font-smoothing: antialiased
  color: #{mainColor}
  user-select: none
  pointer-events: auto
  cursor: grab

  background: #{bgColor}
  backdrop-filter: blur(#{blurRadius})
  -webkit-backdrop-filter: blur(#{blurRadius})
  border-radius: #{borderRadius}
  border: #{borderStyle}
  padding: 16px
  box-sizing: border-box
  box-shadow: #{boxShadow}

  &.locked
    cursor: default

  .lock-btn
    position: absolute
    top: 8px
    right: 12px
    font-size: 10px
    opacity: 0.2
    cursor: pointer
    transition: opacity 0.2s
    z-index: 10
  
  .lock-btn:hover
    opacity: 1

  .header
    display: grid
    grid-template-columns: 1fr 42px 42px 42px
    align-items: center
    margin-bottom: 12px
    padding-bottom: 8px
    border-bottom: 1px solid rgba(255,255,255,0.1)

  .title
    font-size: 9px
    text-transform: uppercase
    font-weight: 800
    color: #{labelColor}
    letter-spacing: 0.5px

  .process-list
    display: flex
    flex-direction: column
    gap: 10px

  .process-item
    display: grid
    grid-template-columns: 1fr 42px 42px 42px
    align-items: center
    font-size: 10px
    font-weight: 500

  .name
    white-space: nowrap
    overflow: hidden
    text-overflow: ellipsis
    padding-right: 8px
    opacity: 0.9

  .val
    text-align: right
    font-variant-numeric: tabular-nums
    font-weight: 700

  .core-val
    color: #{cpuBarColor}

  .tot-val
    color: #64D2FF

  .mem-val
    opacity: 0.6

  .bar-container
    grid-column: 1 / span 4
    height: 2px
    background: #{barBgColor}
    border-radius: 1px
    margin-top: 4px
    overflow: hidden

  .bar-fill
    height: 100%
    background: #{cpuBarColor}
    transition: width 0.5s ease-out
    
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
  <div class="header">
    <div class="title">Process</div>
    <div class="title" style="text-align: right;">Core</div>
    <div class="title" style="text-align: right;">Sys%</div>
    <div class="title" style="text-align: right;">Mem</div>
  </div>
  <div class="process-list" id="proc-list"></div>
  <div class="pos-indicator" id="coords">T: 0 L: 0</div>
"""

# --- Dragging & Locking Logic ---
afterRender: (domEl) ->
  # Load saved state
  isLocked = localStorage.getItem('proc_locked') == 'true'
  savedTop = localStorage.getItem('proc_pos_top')
  savedLeft = localStorage.getItem('proc_pos_left')
  
  # Apply position
  if savedTop and savedLeft
    domEl.style.top = savedTop
    domEl.style.left = savedLeft

  # Apply lock UI
  updateLockUI = ->
    $(domEl).toggleClass('locked', isLocked)
    $(domEl).find('#lock-toggle').text(if isLocked then '🔒' else '🔓')
  
  updateLockUI()

  # Toggle Lock
  $(domEl).find('#lock-toggle').on 'click', (e) ->
    isLocked = !isLocked
    localStorage.setItem('proc_locked', isLocked)
    updateLockUI()
    e.stopPropagation()

  # Drag Logic
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
      localStorage.setItem('proc_pos_top', domEl.style.top)
      localStorage.setItem('proc_pos_left', domEl.style.left)
      $(document).off 'mousemove', mouseMoveHandler
      $(document).off 'mouseup', mouseUpHandler

# --- Update Logic ---
update: (output, domEl) ->
  return unless output
  try
    lines = output.split('\n')
    numCores = parseInt(lines[0]) || 1
    processLines = lines.slice(1).filter (line) -> line.trim().length > 0
    
    html = ""
    for line in processLines
      parts = line.trim().split(/\s+/)
      continue if parts.length < 3
      cpuPerCore = parts[0].replace(/[^0-9.]/g, '')
      mem = parts[1]
      name = parts[2]
      cpuNum = parseFloat(cpuPerCore) || 0
      sysCpu = (cpuNum / numCores).toFixed(1)
      barWidth = Math.min(cpuNum, 100)
      
      html += """
        <div class="process-item">
          <div class="name">#{name}</div>
          <div class="val core-val">#{cpuNum}%</div>
          <div class="val tot-val">#{sysCpu}%</div>
          <div class="val mem-val">#{mem}</div>
          <div class="bar-container">
            <div class="bar-fill" style="width: #{barWidth}%"></div>
          </div>
        </div>
      """
    $(domEl).find('#proc-list').html(html)
  catch e
    console.error("Processes widget error:", e)
