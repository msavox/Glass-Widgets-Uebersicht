#  ____ _                         __        ___     _             _
# / ___| | __ _ ___ ___           \ \      / (_) __| | __ _  ___| |_ ___
#| |  _| |/ _` / __/ __|  _____    \ \ /\ / /| |/ _` |/ _` |/ _ \ __/ __|
#| |_| | | (_| \__ \__ \ |_____|    \ V  V / | | (_| | (_| |  __/ |_ \__
# \____|_|\__,_|___/___/             \_/\_/  |_|\__,_|___/|___/|___/___/
#                                                     |___/
#
# Author:  Matteo Savoia | Version: 2.4.6 | Release: 2026
# ---------------------------------------------------------------------------

command: "curl -sL 'https://news.google.com/rss'"

refreshFrequency: 300000

style: """
  top: 20px
  left: 690px
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

  .lang-select
    background: rgba(255, 255, 255, 0.1)
    border: none
    color: #fff
    font-size: 9px
    border-radius: 4px
    outline: none
    cursor: pointer
    padding: 1px 4px

  .news-list
    display: flex
    flex-direction: column
    max-height: 400px
    overflow-y: auto
    pointer-events: auto

  .news-item
    display: flex
    gap: 10px
    padding: 8px 4px
    border-bottom: 1px solid rgba(255, 255, 255, 0.07)
    color: inherit
    border-radius: 6px
    cursor: pointer
    pointer-events: auto

  .news-item:hover
    background: rgba(255, 255, 255, 0.1)

  .news-index
    font-size: 9px
    font-weight: 800
    color: #FF375F
    min-width: 15px

  .news-title
    font-size: 11px
    font-weight: 500
    line-height: 1.3
    opacity: 0.9

  .status-msg
    font-size: 9px
    padding: 15px 10px
    opacity: 0.5
    text-align: center

  .widget-footer
    margin-top: 10px
    padding-top: 8px
    border-top: 1px solid rgba(255, 255, 255, 0.07)
    display: flex
    justify-content: center
    gap: 10px

  .btn
    background: rgba(255,255,255,0.05)
    border: none
    color: rgba(255, 255, 255, 0.5)
    font-size: 9px
    padding: 5px 12px
    border-radius: 6px
    cursor: pointer
"""

render: (output) -> """
  <div class="lock-btn" id="lock-toggle">🔓</div>
  <div class="widget-header">
    <span class="widget-title">🌍 News</span>
    <select class="lang-select" id="lang-picker">
      <option value="auto">Auto (IP)</option>
      <option value="it">Italian</option>
      <option value="de">German</option>
      <option value="en">English</option>
    </select>
  </div>
  <div id="news-container" class="news-list">
    <div class="status-msg">Fetching feed...</div>
  </div>
  <div class="widget-footer">
    <button class="btn" id="btn-prev">Prev</button>
    <button class="btn" id="btn-next">Next</button>
  </div>
"""

update: (output, domEl) ->
  return unless output
  @rawOutput = output
  @offset ?= 0

  container = $(domEl).find('#news-container')
  xmlString = output.replace(/^[^<]*/, '').trim()

  try
    parser = new DOMParser()
    doc = parser.parseFromString(xmlString, "text/xml")
    allItems = doc.getElementsByTagName('item')

    if allItems.length == 0
      container.html('<div class="status-msg">No news found.</div>')
      return

    itemsArray = Array.from(allItems)
    subset = itemsArray.slice(@offset, @offset + 10)

    html = ""
    for item, i in subset
      title = item.getElementsByTagName('title')[0]?.textContent or "Unknown"
      cleanTitle = title.replace(/\s+-\s+[^-]+$/, '')
      link = item.getElementsByTagName('link')[0]?.textContent or "#"

      html += "<div class='news-item' data-url='#{link}'>
                <span class='news-index'>#{@offset + i + 1}</span>
                <div class='news-title'>#{cleanTitle}</div>
              </div>"

    container.html(html)
    container.find('.news-item').off('click').on 'click', (e) =>
      @run "open '#{$(e.currentTarget).data('url')}'"

  catch e
    container.html("<div class='status-msg'>Feed Error.</div>")

afterRender: (domEl) ->
  @key = 'ms_news_universal'

  # Load saved preference
  savedLang = localStorage.getItem(@key + '_lang') or 'auto'
  $(domEl).find('#lang-picker').val(savedLang)

  # Language picker logic
  $(domEl).find('#lang-picker').on 'change', (e) =>
    newLang = $(e.target).val()
    localStorage.setItem(@key + '_lang', newLang)
    @offset = 0 # Reset pagination on language change

    baseUrl = "https://news.google.com/rss"
    if newLang == 'it'
      finalCmd = "curl -sL '#{baseUrl}?hl=it&gl=IT&ceid=IT:it'"
    else if newLang == 'de'
      finalCmd = "curl -sL '#{baseUrl}?hl=de-AT&gl=AT&ceid=AT:de'"
    else if newLang == 'en'
      finalCmd = "curl -sL '#{baseUrl}?hl=en-US&gl=US&ceid=US:en'"
    else
      finalCmd = "curl -sL -H 'Accept-Language: it,de,en;q=0.9' '#{baseUrl}'"

    @run finalCmd, (err, output) =>
      @update(output, domEl) unless err

  # Persistence logic
  $(domEl).css
    top: localStorage.getItem(@key + '_t') or '20px'
    left: localStorage.getItem(@key + '_l') or '690px'

  if localStorage.getItem(@key + '_locked') == 'true'
    $(domEl).addClass('locked').find('#lock-toggle').text('🔒')

  $(domEl).find('#lock-toggle').on 'click', (e) =>
    isLocked = $(domEl).toggleClass('locked').hasClass('locked')
    $(e.target).text(if isLocked then '🔒' else '🔓')
    localStorage.setItem(@key + '_locked', isLocked)

  $(domEl).find('#btn-next').on 'click', =>
    @offset = (@offset or 0) + 10
    @update(@rawOutput, domEl)

  $(domEl).find('#btn-prev').on 'click', =>
    @offset = Math.max(0, (@offset or 0) - 10)
    @update(@rawOutput, domEl)

  # Drag & Drop
  $(domEl).on 'mousedown', (e) =>
    return if $(domEl).hasClass('locked') or $(e.target).closest('button, .news-item, select').length
    sX = e.clientX - domEl.offsetLeft
    sY = e.clientY - domEl.offsetTop
    $(document).on 'mousemove.news', (me) =>
      $(domEl).css { left: me.clientX - sX, top: me.clientY - sY }
    $(document).one 'mouseup', =>
      $(document).off 'mousemove.news'
      localStorage.setItem(@key + '_t', domEl.style.top)
      localStorage.setItem(@key + '_l', domEl.style.left)
