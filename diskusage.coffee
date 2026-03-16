# --- CONFIGURAZIONE ---
targetDisks = 'Macintosh HD - Data|Bootcamp'
base10 = true

# --- LOGICA DI SISTEMA ---
command: "df -#{if base10 then 'H' else 'h'} | grep '/dev/' | while read -r line; do fs=$(echo $line | awk '{print $1}'); name=$(diskutil info $fs | grep 'Volume Name' | awk '{print substr($0, index($0,$3))}'); echo $(echo $line | awk '{print $2, $3, $4, $5}') $(echo $name | awk '{print substr($0, index($0,$1))}'); done | grep -Ei '#{targetDisks}'"

refreshFrequency: 30000

# --- STILE OTTIMIZZATO (ANTI-FLICKER) ---
style: """
  top: 380px
  left: 15px
  width: 270px
  font-family: -apple-system, "SF Pro Display", sans-serif
  -webkit-font-smoothing: antialiased
  color: #fff

  // SPOSTATO QUI: Lo stile del vetro ora è statico e non sparisce mai
  background: rgba(255, 255, 255, 0.08)
  backdrop-filter: blur(25px)
  -webkit-backdrop-filter: blur(25px)
  border-radius: 22px
  border: 1px solid rgba(255, 255, 255, 0.15)
  padding: 22px
  box-shadow: 0 20px 50px rgba(0,0,0,0.3)

  .container
    position: relative
    margin-bottom: 25px

  .container:last-child
    margin-bottom: 0

  .header
    display: flex
    justify-content: space-between
    align-items: center
    margin-bottom: 10px

  .name
    font-size: 14px
    font-weight: 700
    color: #fff

  .total-size
    font-size: 11px
    font-weight: 600
    color: rgba(255, 255, 255, 0.4)
    background: rgba(255, 255, 255, 0.1)
    padding: 2px 8px
    border-radius: 6px

  .stats-row
    display: flex
    justify-content: space-between
    margin-bottom: 12px

  .stat-box
    display: flex
    flex-direction: column

  .label
    font-size: 9px
    text-transform: uppercase
    font-weight: 800
    color: rgba(255, 255, 255, 0.35)
    margin-bottom: 3px

  .value
    font-size: 12px
    font-weight: 600

  .bar-bg
    width: 100%
    height: 8px
    background: rgba(0, 0, 0, 0.2)
    border-radius: 10px
    overflow: hidden

  .bar-fill
    height: 100%
    background: linear-gradient(90deg, #007AFF, #00C7FF)
    border-radius: 10px
    transition: width 1.5s cubic-bezier(0.23, 1, 0.32, 1)

  .low-space
    background: linear-gradient(90deg, #FF3B30, #FF7A5C)
"""

humanize: (sizeString) ->
  sizeString + 'B'

# Nota: non serve più il div "main-box" nel render perché lo stile è sulla radice
render: -> """
  <div id="storage-content"></div>
"""

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
          <div class="stat-box"><span class="label">Used</span><span class="value">#{@humanize(used)}</span></div>
          <div class="stat-box" style="text-align: center"><span class="label">Free</span><span class="value">#{@humanize(free)}</span></div>
          <div class="stat-box" style="text-align: right"><span class="label">Usage</span><span class="value">#{pctg}</span></div>
        </div>
        <div class="bar-bg"><div class="bar-fill #{alertClass}" style="width: #{pctg}"></div></div>
      </div>
    """

  # Aggiorniamo solo il contenuto interno, mantenendo il contenitore con il blur intatto
  $(domEl).html(html)
