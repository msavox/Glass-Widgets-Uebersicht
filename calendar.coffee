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
posTop = "20px"
posLeft = "185px"
widgetWidth = "150px"
widgetHeight = "160px"
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
accentColor = "#FF375F"
thColor = "rgba(255, 255, 255, 0.4)"
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"
padding = "15px"
monthFontSize = "11px"
monthFontWeight = "800"
thFontSize = "8px"
thFontWeight = "700"
tdFontSize = "10px"
tdFontWeight = "500"
monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
dayHeaders = ["M", "T", "W", "T", "F", "S", "S"]

refreshFrequency: 3600000
command: "date +%d:%m:%y"

# --- Style ---
style: """
  top: #{posTop}
  left: #{posLeft}
  width: #{widgetWidth}
  height: #{widgetHeight}
  font-family: #{fontFamily}
  -webkit-font-smoothing: antialiased
  color: #{mainColor}
  background: #{bgColor}
  backdrop-filter: blur(#{blurRadius})
  -webkit-backdrop-filter: blur(#{blurRadius})
  border-radius: #{borderRadius}
  border: #{borderStyle}
  box-shadow: #{boxShadow}
  padding: #{padding}
  box-sizing: border-box
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

  .month
    color: #{accentColor}
    font-size: #{monthFontSize}
    font-weight: #{monthFontWeight}
    text-transform: uppercase
    margin-bottom: 8px
    letter-spacing: 0.5px

  table
    width: 100%
    border-collapse: collapse

  th
    font-size: #{thFontSize}
    font-weight: #{thFontWeight}
    color: #{thColor}
    padding-bottom: 4px

  td
    font-size: #{tdFontSize}
    text-align: center
    padding: 3px 0
    font-weight: #{tdFontWeight}

  .today
    background: #{accentColor}
    color: #{mainColor}
    border-radius: 50%
    font-weight: 800

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
  <div class="month" id="m-name"></div>
  <table>
    <thead>
      <tr>
        #{("<th>#{h}</th>" for h in dayHeaders).join('')}
      </tr>
    </thead>
    <tbody id="cal-body"></tbody>
  </table>
  <div class="pos-indicator" id="coords">T: 0 L: 0</div>
"""

# --- Logic ---
afterRender: (domEl) ->
  isLocked = localStorage.getItem('cal_locked') == 'true'
  savedTop = localStorage.getItem('cal_pos_top')
  savedLeft = localStorage.getItem('cal_pos_left')
  if savedTop and savedLeft
    domEl.style.top = savedTop
    domEl.style.left = savedLeft

  updateLockUI = ->
    $(domEl).toggleClass('locked', isLocked)
    $(domEl).find('#lock-toggle').text(if isLocked then '🔒' else '🔓')
  updateLockUI()

  $(domEl).find('#lock-toggle').on 'click', (e) ->
    isLocked = !isLocked
    localStorage.setItem('cal_locked', isLocked)
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
      localStorage.setItem('cal_pos_top', domEl.style.top)
      localStorage.setItem('cal_pos_left', domEl.style.left)
      $(document).off 'mousemove', mouseMoveHandler
      $(document).off 'mouseup', mouseUpHandler

update: (output, domEl) ->
  d = new Date()
  $(domEl).find('#m-name').text(monthNames[d.getMonth()])
  first = new Date(d.getFullYear(), d.getMonth(), 1).getDay()
  first = if first == 0 then 6 else first - 1
  total = new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate()
  tbody = $(domEl).find('#cal-body').empty()
  row = $("<tr>")
  row.append("<td></td>") for [0...first]
  for day in [1..total]
    if row.children().length == 7
      tbody.append(row)
      row = $("<tr>")
    cell = $("<td>").text(day).appendTo(row)
    if day == d.getDate()
      cell.addClass('today')
  tbody.append(row)
