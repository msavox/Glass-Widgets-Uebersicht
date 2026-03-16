# --- CONFIGURAZIONE ---
refreshFrequency: 600000 # 10 minuti

# Comando con coordinate di Como Centro
command: "curl -s 'https://api.open-meteo.com/v1/forecast?latitude=45.8081&longitude=9.0831&current=temperature_2m,relative_humidity_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&hourly=temperature_2m,weather_code&timezone=auto&forecast_days=1'"

style: """
  top: 195px
  left: 15px
  width: 320px
  height: 160px
  font-family: -apple-system, "SF Pro Display", sans-serif
  -webkit-font-smoothing: antialiased
  color: #fff

  background: rgba(255, 255, 255, 0.08)
  backdrop-filter: blur(25px)
  -webkit-backdrop-filter: blur(25px)
  border-radius: 22px
  border: 1px solid rgba(255, 255, 255, 0.15)
  box-shadow: 0 20px 50px rgba(0,0,0,0.3)
  padding: 16px // Ridotto leggermente per guadagnare spazio laterale
  box-sizing: border-box
  overflow: hidden // Blocca eventuali sbordamenti

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

  /* Previsioni Orarie - FIX DEFINITIVO SBORDAMENTO */
  .hourly-forecast
    display: flex
    justify-content: space-between
    border-top: 1px solid rgba(255,255,255,0.1)
    padding-top: 10px
    margin-top: 2px
    width: 100% // Assicura che la flexbox occupi tutto lo spazio interno
    box-sizing: border-box

  .hour-item
    display: flex
    flex-direction: column
    align-items: center
    justify-content: flex-end
    gap: 3px // Spazio verticale ridotto tra tempo/icona/temperatura
    width: 18% // Rende ogni colonna oraria proporzionale alla larghezza totale
    text-align: center

  .h-time
    font-size: 8px // Font orario leggermente ridotto
    font-weight: 700
    opacity: 0.6

  .h-icon
    font-size: 12px // Icona leggermente ridotta

  .h-temp
    font-size: 10px // Temperatura oraria leggermente ridotta
    font-weight: 700
"""

render: -> """
  <div class="container">
    <div class="top-row">
      <div class="main-meta">
        <div class="location">Como 📍</div>
        <div class="temp-main" id="curr-temp">--°</div>
        <div class="condition-text" id="weather-desc">Caricamento...</div>
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

update: (output, domEl) ->
  return if not output
  try
    data = JSON.parse(output)
    curr = data.current
    daily = data.daily
    hourly = data.hourly

    getWeather = (code) ->
      return ["☀️", "Sereno"] if code == 0
      return ["🌤️", "Poco Nuvoloso"] if code <= 3
      return ["🌫️", "Nebbia"] if code <= 48
      return ["🌦️", "Pioviggine"] if code <= 55
      return ["🌧️", "Pioggia"] if code <= 65
      return ["❄️", "Neve"] if code <= 77
      return ["⛈️", "Temporale"] if code >= 95
      return ["☁️", "Nuvoloso"]

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
    console.log("Errore parsing meteo", e)
