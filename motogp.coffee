#  ____ _                         __        ___     _             _
# / ___| | __ _ ___ ___           \ \      / (_) __| | __ _  ___| |_ ___
#| |  _| |/ _` / __/ __|  _____    \ \ /\ / /| |/ _` |/ _` |/ _ \ __/ __|
#| |_| | | (_| \__ \__ \ |_____|    \ V  V / | | (_| | (_| |  __/ |_ \__
# \____|_|\__,_|___/___/             \_/\_/  |_|\__,_|___/|___/|___/___/
#                                                     |___/
#
# Author:  Matteo Savoia | Version: 1.1.0 | Release: 2026
# ---------------------------------------------------------------------------

# MotoGP Season 2026 UUIDs
seasonUuid = "e88b4e43-2209-47aa-8e83-0e0b1cedde6e"
categories = 
  motogp: "e8c110ad-64aa-4e8e-8a86-f2f152f6a942"
  moto2:  "549640b8-fd9c-4245-acfd-60e4bc38b25c"
  moto3:  "954f7e65-2ef2-4423-b949-4961cc603e45"

# Next Race: Red Bull Grand Prix of The United States (2026-03-29)
nextRaceDate = "2026-03-29T21:00:00Z" # Assuming late afternoon race in Austin
nextRaceName = "GP of Americas 🇺🇸"

command: "curl -s 'https://api.motogp.pulselive.com/motogp/v1/results/standings?seasonUuid=#{seasonUuid}&categoryUuid=#{categories.motogp}'"

refreshFrequency: 3600000 # 1 hour for standings

style: """
  top: 20px
  left: 700px
  width: 320px
  font-family: -apple-system, "SF Pro Display", sans-serif
  color: #fff
  background: rgba(255, 255, 255, 0.08)
  backdrop-filter: blur(25px)
  -webkit-backdrop-filter: blur(25px)
  border-radius: 22px
  border: 1px solid rgba(255, 255, 255, 0.15)
  box-shadow: 0 20px 50px rgba(0,0,0,0.3)
  padding: 16px
  box-sizing: border-box
  cursor: grab
  pointer-events: auto
  display: flex
  flex-direction: column
  user-select: none

  &.locked
    cursor: default

  .lock-btn
    position: absolute
    top: 8px
    right: 12px
    font-size: 10px
    opacity: 0.2
    cursor: pointer
    z-index: 20

  .widget-header
    display: flex
    justify-content: space-between
    align-items: center
    margin-bottom: 12px

  .widget-title
    font-size: 9px
    text-transform: uppercase
    font-weight: 800
    letter-spacing: 1px
    color: rgba(255, 255, 255, 0.4)

  .standings-list
    display: flex
    flex-direction: column
    height: 235px /* Showing ~5 riders */
    overflow-y: auto
    pointer-events: auto
    margin-bottom: 10px

  .rider-item
    display: flex
    align-items: center
    padding: 8px 4px
    border-bottom: 1px solid rgba(255, 255, 255, 0.07)
    gap: 12px

  .rider-pos
    font-size: 11px
    font-weight: 800
    color: #FF375F
    min-width: 22px
    text-align: center

  .rider-info
    display: flex
    flex-direction: column
    flex-grow: 1

  .rider-name
    font-size: 12px
    font-weight: 600
    display: flex
    align-items: center
    gap: 5px

  .rider-number
    font-size: 9px
    font-weight: 800
    opacity: 0.4
    font-style: italic

  .rider-team
    font-size: 9px
    opacity: 0.5
    font-weight: 400
    white-space: nowrap
    overflow: hidden
    text-overflow: ellipsis
    max-width: 180px

  .rider-points
    font-size: 14px
    font-weight: 700
    min-width: 40px
    text-align: right
    color: #fff

  .category-buttons
    display: flex
    gap: 8px
    margin-bottom: 12px
    justify-content: center

  .cat-btn
    background: rgba(255, 255, 255, 0.05)
    border: 1px solid rgba(255, 255, 255, 0.1)
    color: rgba(255, 255, 255, 0.6)
    font-size: 9px
    padding: 4px 10px
    border-radius: 8px
    cursor: pointer
    transition: all 0.2s

  .cat-btn:hover
    background: rgba(255, 255, 255, 0.1)
    color: #fff

  .cat-btn.active
    background: #FF375F
    color: #fff
    border-color: #FF375F

  .countdown-container
    border-top: 1px solid rgba(255, 255, 255, 0.1)
    padding-top: 12px
    margin-top: 5px
    display: flex
    flex-direction: column
    align-items: center

  .countdown-label
    font-size: 8px
    text-transform: uppercase
    font-weight: 800
    letter-spacing: 0.5px
    color: rgba(255, 255, 255, 0.4)
    margin-bottom: 4px

  .countdown-timer
    font-size: 13px
    font-weight: 700
    font-variant-numeric: tabular-nums

  .status-msg
    font-size: 9px
    padding: 15px 10px
    opacity: 0.5
    text-align: center

  /* Scrollbar Style */
  .standings-list::-webkit-scrollbar
    width: 3px
  
  .standings-list::-webkit-scrollbar-track
    background: transparent
  
  .standings-list::-webkit-scrollbar-thumb
    background: rgba(255, 255, 255, 0.15)
    border-radius: 10px
"""

render: (output) -> """
  <div class="lock-btn" id="lock-toggle">🔓</div>
  <div class="widget-header">
    <span class="widget-title">🏁 Standings</span>
  </div>
  
  <div class="category-buttons">
    <div class="cat-btn active" data-cat="motogp">MotoGP</div>
    <div class="cat-btn" data-cat="moto2">Moto2</div>
    <div class="cat-btn" data-cat="moto3">Moto3</div>
  </div>

  <div id="standings-container" class="standings-list">
    <div class="status-msg">Loading...</div>
  </div>

  <div class="countdown-container">
    <div class="countdown-label" id="race-name">#{nextRaceName}</div>
    <div class="countdown-timer" id="timer">00d 00h 00m 00s</div>
  </div>
"""

update: (output, domEl) ->
  return unless output
  container = $(domEl).find('#standings-container')

  try
    data = JSON.parse(output)
    classification = data.classification

    if !classification or classification.length == 0
      container.html('<div class="status-msg">No standings data.</div>')
      return

    html = ""
    for entry in classification
      rider = entry.rider
      team = entry.team
      points = entry.points
      pos = entry.position
      
      continue unless rider and team

      nameParts = rider.full_name.split(' ')
      shortName = if nameParts.length > 1
        "#{nameParts[0][0]}. #{nameParts[nameParts.length - 1]}"
      else
        rider.full_name

      getFlag = (iso) ->
        return "" unless iso
        codePoints = (127397 + c.charCodeAt(0) for c in iso.toUpperCase())
        String.fromCodePoint(codePoints...)

      flag = getFlag(rider.country?.iso)

      html += """
        <div class='rider-item'>
          <div class='rider-pos'>#{pos}</div>
          <div class='rider-info'>
            <div class='rider-name'>
              <span>#{shortName}</span>
              <span class='rider-number'>##{rider.number or ''}</span>
              <span style='font-size: 10px;'>#{flag}</span>
            </div>
            <div class='rider-team'>#{team.name or 'Unknown'}</div>
          </div>
          <div class='rider-points'>#{points}</div>
        </div>
      """

    container.html(html)

  catch e
    container.html("<div class='status-msg'>Data Error.</div>")

afterRender: (domEl) ->
  @key = 'ms_motogp_universal'
  
  # Category switching
  $(domEl).find('.cat-btn').on 'click', (e) =>
    btn = $(e.target)
    cat = btn.data('cat')
    $(domEl).find('.cat-btn').removeClass('active')
    btn.addClass('active')
    
    catUuid = switch cat
      when 'motogp' then "e8c110ad-64aa-4e8e-8a86-f2f152f6a942"
      when 'moto2'  then "549640b8-fd9c-4245-acfd-60e4bc38b25c"
      when 'moto3'  then "954f7e65-2ef2-4423-b949-4961cc603e45"
    
    cmd = "curl -s 'https://api.motogp.pulselive.com/motogp/v1/results/standings?seasonUuid=e88b4e43-2209-47aa-8e83-0e0b1cedde6e&categoryUuid=#{catUuid}'"
    @run cmd, (err, output) =>
      @update(output, domEl) unless err

  # Countdown Timer
  target = new Date("2026-03-29T21:00:00Z").getTime()
  
  updateTimer = =>
    now = new Date().getTime()
    diff = target - now
    
    if diff < 0
      $(domEl).find('#timer').text("RACE DAY")
      return

    days = Math.floor(diff / (1000 * 60 * 60 * 24))
    hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    mins = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    secs = Math.floor((diff % (1000 * 60)) / 1000)
    
    $(domEl).find('#timer').text("#{days}d #{hours}h #{mins}m #{secs}s")

  setInterval updateTimer, 1000
  updateTimer()

  # Persistence logic
  $(domEl).css
    top: localStorage.getItem(@key + '_t') or '20px'
    left: localStorage.getItem(@key + '_l') or '700px'

  if localStorage.getItem(@key + '_locked') == 'true'
    $(domEl).addClass('locked').find('#lock-toggle').text('🔒')

  $(domEl).find('#lock-toggle').on 'click', (e) =>
    isLocked = $(domEl).toggleClass('locked').hasClass('locked')
    $(e.target).text(if isLocked then '🔒' else '🔓')
    localStorage.setItem(@key + '_locked', isLocked)

  # Drag & Drop
  $(domEl).on 'mousedown', (e) =>
    return if $(domEl).hasClass('locked')
    return if $(e.target).closest('.lock-btn, .standings-list, .cat-btn').length

    sX = e.clientX - domEl.offsetLeft
    sY = e.clientY - domEl.offsetTop
    $(document).on 'mousemove.motogp', (me) =>
      $(domEl).css { left: me.clientX - sX, top: me.clientY - sY }
    $(document).one 'mouseup', =>
      $(document).off 'mousemove.motogp'
      localStorage.setItem(@key + '_t', domEl.style.top)
      localStorage.setItem(@key + '_l', domEl.style.left)
