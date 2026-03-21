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

refreshRate = 600000
latitude = "45.8081"
longitude = "9.0831"
locationName = "Como"
posTop = "195px"
posLeft = "15px"
widgetWidth = "320px"
widgetHeight = "160px"
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"

refreshFrequency: refreshRate
command: "curl -s 'https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m,relative_humidity_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&hourly=temperature_2m,weather_code&timezone=auto&forecast_days=1'"

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
  padding: 16px
  box-sizing: border-box
  overflow: hidden
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
    display: flex
    flex-direction: column
    justify-content: space-between
    height: 100%

  .top-row
    display: flex
    justify-content: space-between
    align-items: flex-start
    margin-bottom: 2px

  .main-meta
    display: flex
    flex-direction: column

  .location
    font-size: 13px
    font-weight: 700
    display: flex
    align-items: center
    gap: 3px
    letter-spacing: 0.3px

  .temp-main
    font-size: 48px
    font-weight: 300
    line-height: 1
    margin-top: 1px

  .condition-text
    font-size: 11px
    font-weight: 600
    opacity: 0.8
    margin-top: -1px

  .hi-lo
    font-size: 11px
    font-weight: 600
    text-align: right
    opacity: 0.9

  .hourly-forecast
    display: flex
    justify-content: space-between
    border-top: 1px solid rgba(255,255,255,0.1)
    padding-top: 10px
    margin-top: 2px
    width: 100%
    box-sizing: border-box

  .hour-item
    display: flex
    flex-direction: column
    align-items: center
    justify-content: flex-end
    gap: 3px
    width: 18%
    text-align: center

  .h-time
    font-size: 8px
    font-weight: 700
    opacity: 0.6

  .h-icon
    font-size: 12px

  .h-temp
    font-size: 10px
    font-weight: 700

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
  <div class="container">
    <div class="top-row">
      <div class="main-meta">
        <div class="location">#{locationName} 📍</div>
        <div class="temp-main" id="curr-temp">--°</div>
        <div class="condition-text" id="weather-desc">Loading...</div>
      </div>
      <div class="hi-lo">
        <div id="status-icon" style="font-size: 26px; margin-bottom: 6px;">☀️</div>
        <div>H:<span id="hi">--</span>° L:<span id="lo">--</span>°</div>
      </div>
    </div>
    <div class="hourly-forecast" id="hourly"></div>
  </div>
  <div class="pos-indicator" id="coords">T: 0 L: 0</div>
"""

# --- Logic ---
afterRender: (domEl) ->
  isLocked = localStorage.getItem('weather_locked') == 'true'
  savedTop = localStorage.getItem('weather_pos_top')
  savedLeft = localStorage.getItem('weather_pos_left')
  if savedTop and savedLeft
    domEl.style.top = savedTop
    domEl.style.left = savedLeft

  updateLockUI = ->
    $(domEl).toggleClass('locked', isLocked)
    $(domEl).find('#lock-toggle').text(if isLocked then '🔒' else '🔓')
  updateLockUI()

  $(domEl).find('#lock-toggle').on 'click', (e) ->
    isLocked = !isLocked
    localStorage.setItem('weather_locked', isLocked)
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
      localStorage.setItem('weather_pos_top', domEl.style.top)
      localStorage.setItem('weather_pos_left', domEl.style.left)
      $(document).off 'mousemove', mouseMoveHandler
      $(document).off 'mouseup', mouseUpHandler

update: (output, domEl) ->
  return if not output
  try
    data = JSON.parse(output)
    curr = data.current
    daily = data.daily
    hourly = data.hourly
    getWeather = (code) ->
      return ["☀️", "Clear"] if code == 0
      return ["🌤️", "Partly Cloudy"] if code <= 3
      return ["🌫️", "Fog"] if code <= 48
      return ["🌦️", "Drizzle"] if code <= 55
      return ["🌧️", "Rain"] if code <= 65
      return ["❄️", "Snow"] if code <= 77
      return ["⛈️", "Thunderstorm"] if code >= 95
      return ["☁️", "Cloudy"]
    [icon, desc] = getWeather(curr.weather_code)
    $(domEl).find('#curr-temp').text("#{Math.round(curr.temperature_2m)}°")
    $(domEl).find('#weather-desc').text(desc)
    $(domEl).find('#status-icon').text(icon)
    $(domEl).find('#hi').text(Math.round(daily.temperature_2m_max[0]))
    $(domEl).find('#lo').text(Math.round(daily.temperature_2m_min[0]))
    hourlyHtml = ""
    currentHour = new Date().getHours()
    for i in [1..5]
      idx = currentHour + i
      hTemp = Math.round(hourly.temperature_2m[idx])
      hCode = hourly.weather_code[idx]
      [hIcon, hDesc] = getWeather(hCode)
      timeLabel = if idx >= 24 then idx-24 else idx
      hourlyHtml += """
        <div class="hour-item">
          <span class="h-time">#{timeLabel}</span>
          <span class="h-icon">#{hIcon}</span>
          <span class="h-temp">#{hTemp}°</span>
        </div>
      """
    $(domEl).find('#hourly').html(hourlyHtml)
  catch e
    console.error("Weather data parsing error:", e)
