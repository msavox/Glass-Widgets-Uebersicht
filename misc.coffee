# --- CONFIGURAZIONE ---
refreshFrequency: 2000

command: """
  # 1. GPU Utilization
  usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%')
  echo "INTEGR ${usage:-0}%"

  # 2. Temperature via powermetrics
  data=$(sudo /usr/bin/powermetrics -n 1 -i 100 --samplers smc)
  t_cpu=$(echo "$data" | grep "CPU die temperature" | awk '{print $4}' | cut -d. -f1)
  t_gpu=$(echo "$data" | grep "GPU die temperature" | awk '{print $4}' | cut -d. -f1)
  echo "${t_cpu:-0} ${t_gpu:-0}"

  # 3. Fans
  fan=$(echo "$data" | grep "Fan:" | awk '{print $2}' | cut -d. -f1)
  echo "${fan:-0}"
"""

style: """
  top: 800px
  left: 15px
  width: 315px
  font-family: -apple-system, "SF Pro Display", sans-serif
  -webkit-font-smoothing: antialiased
  color: #fff
  background: rgba(255, 255, 255, 0.08)
  backdrop-filter: blur(25px)
  -webkit-backdrop-filter: blur(25px)
  border-radius: 22px
  border: 1px solid rgba(255, 255, 255, 0.15)
  padding: 20px
  box-sizing: border-box

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
    color: rgba(255, 255, 255, 0.4)
    margin-top: 10px
    letter-spacing: 1px

  .temp-label
    font-size: 7px
    font-weight: 600
    opacity: 0.7
"""

render: -> """
  <div class="main-container">
    <div class="box">
      <div class="circle-wrap">
        <svg><circle class="bg" cx="35" cy="35" r="32"></circle><circle class="fg" id="gpu-f" cx="35" cy="35" r="32" stroke="#BF5AF2"></circle></svg>
        <div class="val-center"><span id="gpu-v">0%</span></div>
      </div>
      <div class="label">GPU</div>
    </div>

    <div class="box">
      <div class="circle-wrap">
        <svg>
          <circle class="bg" cx="35" cy="35" r="32"></circle>
          <circle class="fg" id="tempC-f" cx="35" cy="35" r="32" stroke="#FF375F"></circle>
          <circle class="bg" cx="35" cy="35" r="24" style="stroke-width:4"></circle>
          <circle class="fg" id="tempG-f" cx="35" cy="35" r="24" stroke="#FF9500" style="stroke-width:4"></circle>
        </svg>
        <div class="val-center">
          <div><span id="tempC-v">0</span><span class="temp-label">°C</span></div>
          <div style="color:#FF9500;"><span id="tempG-v">0</span><span class="temp-label">°C</span></div>
        </div>
      </div>
      <div class="label">TEMP</div>
    </div>

    <div class="box">
      <div class="circle-wrap">
        <svg><circle class="bg" cx="35" cy="35" r="32"></circle><circle class="fg" id="fan-f" cx="35" cy="35" r="32" stroke="#32D74B"></circle></svg>
        <div class="val-center"><span id="fan-v">0</span><span style="font-size:7px; display:block; opacity:0.6">RPM</span></div>
      </div>
      <div class="label">FANS</div>
    </div>
  </div>
"""

update: (output, domEl) ->
  lines = output.split('\n')
  return if lines.length < 3
  c32 = 201; c24 = 151

  # GPU
  gpuPct = parseInt(lines[0].split(' ')[1]) || 0
  $(domEl).find("#gpu-v").text("#{gpuPct}%")
  $(domEl).find("#gpu-f").css "stroke-dasharray", "#{(gpuPct/100)*c32} #{c32}"

  # TEMPERATURES (CPU e GPU)
  temps = lines[1].split(' ')
  tC = parseInt(temps[0]) || 0; tG = parseInt(temps[1]) || 0
  $(domEl).find("#tempC-v").text(tC)
  $(domEl).find("#tempG-v").text(tG)
  $(domEl).find("#tempC-f").css "stroke-dasharray", "#{(tC/100)*c32} #{c32}"
  $(domEl).find("#tempG-f").css "stroke-dasharray", "#{(tG/100)*c24} #{c24}"

  # FANS
  fanVal = parseInt(lines[2]) || 0
  $(domEl).find("#fan-v").text(fanVal)
  $(domEl).find("#fan-f").css "stroke-dasharray", "#{Math.min((fanVal/5600)*c32, c32)} #{c32}"
