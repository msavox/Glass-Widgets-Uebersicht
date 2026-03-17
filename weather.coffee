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
# Refresh Frequency (in milliseconds) - 10 minutes
refreshRate = 600000

# Geographic location for weather data (Como, Italy)
latitude = "45.8081"
longitude = "9.0831"
locationName = "Como"

# Position and sizing
posTop = "195px"
posLeft = "15px"
widgetWidth = "320px"
widgetHeight = "160px"

# Visual styling
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"

# Glassmorphism settings
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"

# --- Configuration ---
refreshFrequency: refreshRate

# Bash command to fetch weather data from Open-Meteo API.
# It requests current temperature, humidity, weather codes, daily max/min, and hourly forecasts.
command: "curl -s 'https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m,relative_humidity_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&hourly=temperature_2m,weather_code&timezone=auto&forecast_days=1'"

# --- Style ---
# The style section defines the visual appearance using CSS-in-JS (Stylus-like syntax).
style: """
  top: #{posTop}
  left: #{posLeft}
  width: #{widgetWidth}
  height: #{widgetHeight}
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
  box-shadow: #{boxShadow}
  padding: 16px
  box-sizing: border-box
  overflow: hidden

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

  /* Hourly Forecast Section */
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
"""

# --- Render ---
# The render function returns the HTML structure of the widget.
render: -> """
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

    <div class="hourly-forecast" id="hourly">
    </div>
  </div>
"""

# --- Update Logic ---
# The update function is called periodically to refresh the widget content.
update: (output, domEl) ->
  return if not output
  try
    data = JSON.parse(output)
    curr = data.current
    daily = data.daily
    hourly = data.hourly

    # Helper function to map WMO weather codes to icons and English descriptions.
    # Reference: https://open-meteo.com/en/docs
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

    # Update main weather information in the DOM
    $(domEl).find('#curr-temp').text("#{Math.round(curr.temperature_2m)}°")
    $(domEl).find('#weather-desc').text(desc)
    $(domEl).find('#status-icon').text(icon)
    $(domEl).find('#hi').text(Math.round(daily.temperature_2m_max[0]))
    $(domEl).find('#lo').text(Math.round(daily.temperature_2m_min[0]))

    # Generate hourly forecast for the next 5 hours dynamically
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
