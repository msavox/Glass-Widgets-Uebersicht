# --- CONFIGURAZIONE ---
refreshFrequency: 2000

# Comando per CPU, RAM (Usata/Totale) e BATTERIA
command: """
  top -l 1 -n 0 | awk '/CPU usage/ {print $3 + $5 "%"}';
  used_ram=$(vm_stat | awk '/Pages active/ {print $3}' | sed 's/\\.//');
  total_ram=$(sysctl hw.memsize | awk '{print $2}');
  echo "$used_ram $total_ram";
  pmset -g batt | awk '{for(i=1;i<=NF;i++) if($i~/[0-9]+%/) print $i}' | head -1 | tr -d '%;'
"""

# --- STILE (VERSIONE FINALE BILANCIATA) ---
style: """
  top: 625px
  left: 15px
  width: 270px
  font-family: -apple-system, "SF Pro Display", sans-serif
  -webkit-font-smoothing: antialiased
  color: #fff

  background: rgba(255, 255, 255, 0.08)
  backdrop-filter: blur(25px)
  -webkit-backdrop-filter: blur(25px)
  border-radius: 22px
  border: 1px solid rgba(255, 255, 255, 0.15)
  padding: 22px
  box-shadow: 0 20px 50px rgba(0,0,0,0.3)

  .main-container
    display: flex
    justify-content: space-between
    align-items: center

  .chart-box
    display: flex
    flex-direction: column
    align-items: center
    position: relative
    flex: 1

  .label
    font-size: 10px // Mantenuto più grande (chiesto prima)
    text-transform: uppercase
    font-weight: 800
    color: rgba(255, 255, 255, 0.5)
    margin-top: 12px
    letter-spacing: 1.2px

  svg
    width: 85px
    height: 85px
    transform: rotate(-90deg)

  circle
    fill: none
    stroke-width: 8
    stroke-linecap: round

  .bg-circle
    stroke: rgba(255, 255, 255, 0.1)

  .fg-circle
    transition: stroke-dasharray 1s ease-in-out
    stroke-dasharray: 0 238

  #cpu-circle { stroke: #34C759; }
  #ram-circle { stroke: #32D74B; }
  #bat-circle { stroke: #FFCC00; }

  .percentage
    position: absolute
    top: 42.5px
    left: 50%
    transform: translate(-50%, -50%)
    font-size: 12px // RIPRISTINATO COME PRIMA
    font-weight: 700
    text-align: center
    line-height: 1

  .sub-val
    display: block
    font-size: 8px // Mantenuto più grande per i GB
    font-weight: 600
    color: rgba(255, 255, 255, 0.6)
    margin-top: 2px
"""

render: -> """
  <div class="main-container">
    <div class="chart-box">
      <div class="percentage">
        <span id="cpu-val">0%</span>
      </div>
      <svg><circle class="bg-circle" cx="42.5" cy="42.5" r="38"></circle><circle class="fg-circle" id="cpu-circle" cx="42.5" cy="42.5" r="38"></circle></svg>
      <div class="label">CPU</div>
    </div>

    <div class="chart-box">
      <div class="percentage">
        <span id="ram-val">0%</span>
        <span class="sub-val" id="ram-gb">0/0G</span>
      </div>
      <svg><circle class="bg-circle" cx="42.5" cy="42.5" r="38"></circle><circle class="fg-circle" id="ram-circle" cx="42.5" cy="42.5" r="38"></circle></svg>
      <div class="label">RAM</div>
    </div>

    <div class="chart-box">
      <div class="percentage">
        <span id="bat-val">0%</span>
      </div>
      <svg><circle class="bg-circle" cx="42.5" cy="42.5" r="38"></circle><circle class="fg-circle" id="bat-circle" cx="42.5" cy="42.5" r="38"></circle></svg>
      <div class="label">BATT</div>
    </div>
  </div>
"""

update: (output, domEl) ->
  values = output.split('\n')
  return unless values.length >= 3

  updateGauge = (idCircle, idVal, pct) ->
    circumference = 238
    offset = circumference - (pct / 100) * circumference
    $(domEl).find("##{idCircle}").css 'stroke-dasharray', "#{circumference - offset} #{circumference}"
    $(domEl).find("##{idVal}").text("#{Math.round(pct)}%")

  # 1. CPU
  cpuPct = parseFloat(values[0]) || 0
  updateGauge('cpu-circle', 'cpu-val', cpuPct)

  # 2. RAM
  ramData = values[1].split(' ')
  if ramData.length == 2
    usedGB = (parseFloat(ramData[0]) * 4096) / 1073741824
    totalGB = parseFloat(ramData[1]) / 1073741824
    ramPct = (usedGB / totalGB) * 100

    updateGauge('ram-circle', 'ram-val', ramPct)
    $(domEl).find("#ram-gb").text("#{usedGB.toFixed(1)}/#{Math.round(totalGB)}G")

  # 3. Batteria
  batPct = parseFloat(values[2]) || 0
  updateGauge('bat-circle', 'bat-val', batPct)
