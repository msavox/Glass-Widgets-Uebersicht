#   ____ _                         __        ___     _            _       
#  / ___| | __ _ ___ ___           \ \      / (_) __| | __ _  ___| |_ ___ 
# | |  _| |/ _` / __/ __|  _____    \ \ /\ / /| |/ _` |/ _` |/ _ \ __/ __|
# | |_| | | (_| \__ \__ \ |_____|    \ V  V / | | (_| | (_| |  __/ |_ \__ \
#  \____|_|\__,_|___/___/             \_/\_/  |_|\__,_|\__, |\___|\__|___/
#                                                      |___/              
#
# Author:  Matteo Savoia
# Version: 1.6 (Photo Widget - Resizable & Draggable)
# Release: 2026
# ---------------------------------------------------------------------------

# --- Parameters Section ---
posTop = "380px"
posLeft = "15px"
widgetWidth = "320px"
widgetHeight = "160px"
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"
padding = "10px"

command: "ls Glass-Widgets/current_photo.jpg 2>/dev/null || echo 'NOT_FOUND'"
refreshFrequency: 60000 

# --- Style ---
style: """
  top: #{posTop}
  left: #{posLeft}
  width: #{widgetWidth}
  height: #{widgetHeight}
  background: #{bgColor}
  backdrop-filter: blur(#{blurRadius})
  -webkit-backdrop-filter: blur(#{blurRadius})
  border-radius: #{borderRadius}
  border: #{borderStyle}
  box-shadow: #{boxShadow}
  padding: #{padding}
  box-sizing: border-box
  overflow: hidden
  cursor: grab
  user-select: none
  pointer-events: auto
  display: flex
  justify-content: center
  align-items: center
  min-width: 80px
  min-height: 80px

  &.locked
    cursor: default

  .btn-container
    position: absolute
    top: 8px
    right: 12px
    display: flex
    gap: 8px
    z-index: 10
    opacity: 0.15
    transition: opacity 0.2s

  &:hover .btn-container
    opacity: 1

  .icon-btn
    font-size: 12px
    cursor: pointer
    color: white
    text-shadow: 0 1px 3px rgba(0,0,0,0.5)

  #photo-display
    width: 100%
    height: 100%
    object-fit: cover
    border-radius: #{parseInt(borderRadius) - 10}px
    pointer-events: none

  .placeholder
    font-family: -apple-system, sans-serif
    color: rgba(255,255,255,0.4)
    font-size: 11px
    text-align: center
    text-transform: uppercase
    letter-spacing: 1px
    font-weight: 700

  .resize-handle
    position: absolute
    bottom: 0
    right: 0
    width: 20px
    height: 20px
    cursor: nwse-resize
    z-index: 20
    background: linear-gradient(135deg, transparent 70%, rgba(255,255,255,0.2) 70%)
    border-bottom-right-radius: #{borderRadius}

  &.locked .resize-handle
    display: none

  .pos-indicator
    position: absolute
    bottom: 10px
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
    z-index: 30

  .dragging .pos-indicator, .resizing .pos-indicator
    opacity: 1
"""

# --- Render ---
render: -> """
  <div class="btn-container">
    <div class="icon-btn" id="pick-photo">•••</div>
    <div class="icon-btn" id="lock-toggle">🔓</div>
  </div>
  <img id="photo-display" style="display:none;">
  <div class="placeholder" id="no-photo">Click ••• to set a photo</div>
  <div class="resize-handle" id="resizer"></div>
  <div class="pos-indicator" id="coords">T: 0 L: 0</div>
"""

# --- Logic ---
afterRender: (domEl) ->
  $dom = $(domEl)
  $img = $dom.find('#photo-display')
  $placeholder = $dom.find('#no-photo')

  KEY_POS_T = 'photo_pos_top'
  KEY_POS_L = 'photo_pos_left'
  KEY_WIDTH = 'photo_width'
  KEY_HEIGHT = 'photo_height'
  KEY_LOCKED = 'photo_locked'

  # Restore State
  if localStorage.getItem(KEY_POS_T) then domEl.style.top = localStorage.getItem(KEY_POS_T)
  if localStorage.getItem(KEY_POS_L) then domEl.style.left = localStorage.getItem(KEY_POS_L)
  if localStorage.getItem(KEY_WIDTH) then domEl.style.width = localStorage.getItem(KEY_WIDTH)
  if localStorage.getItem(KEY_HEIGHT) then domEl.style.height = localStorage.getItem(KEY_HEIGHT)

  isLocked = localStorage.getItem(KEY_LOCKED) == 'true'

  updateLockUI = ->
    $dom.toggleClass('locked', isLocked)
    $dom.find('#lock-toggle').text(if isLocked then '🔒' else '🔓')
  updateLockUI()

  $dom.find('#lock-toggle').on 'click', (e) ->
    isLocked = !isLocked
    localStorage.setItem(KEY_LOCKED, isLocked)
    updateLockUI()
    e.stopPropagation()

  # Native Picker
  $dom.find('#pick-photo').on 'click', (e) =>
    e.stopPropagation()
    script = "osascript -e 'POSIX path of (choose file with prompt \"Select Photo\" of type {\"public.image\"})' 2>/dev/null"
    @run script, (err, path) =>
      if !err and path
        srcPath = path.trim()
        destPath = "Glass-Widgets/current_photo.jpg"
        @run "cp \"#{srcPath}\" \"#{destPath}\"", (err2) =>
          if !err2
            $img.attr('src', "#{destPath}?#{new Date().getTime()}").show()
            $placeholder.hide()

  # DRAG & RESIZE LOGIC
  isDragging = false
  isResizing = false
  startX = 0; startY = 0
  startW = 0; startH = 0

  $dom.on 'mousedown', (e) ->
    return if isLocked or $(e.target).hasClass('icon-btn')
    
    if $(e.target).attr('id') == 'resizer'
      isResizing = true
      $dom.addClass('resizing')
      startX = e.clientX
      startY = e.clientY
      startW = domEl.offsetWidth
      startH = domEl.offsetHeight
    else
      isDragging = true
      $dom.addClass('dragging')
      domEl.style.cursor = 'grabbing'
      startX = e.clientX - domEl.offsetLeft
      startY = e.clientY - domEl.offsetTop

    $(document).on 'mousemove', mouseMoveHandler
    $(document).on 'mouseup', mouseUpHandler

  mouseMoveHandler = (e) ->
    if isResizing
      newW = startW + (e.clientX - startX)
      newH = startH + (e.clientY - startY)
      domEl.style.width = "#{newW}px"
      domEl.style.height = "#{newH}px"
      $dom.find('#coords').text("W: #{newW} H: #{newH}")
    
    else if isDragging
      newTop = (e.clientY - startY) + 'px'
      newLeft = (e.clientX - startX) + 'px'
      domEl.style.top = newTop
      domEl.style.left = newLeft
      $dom.find('#coords').text("T: #{newTop} L: #{newLeft}")

  mouseUpHandler = ->
    if isResizing
      localStorage.setItem(KEY_WIDTH, domEl.style.width)
      localStorage.setItem(KEY_HEIGHT, domEl.style.height)
      isResizing = false
      $dom.removeClass('resizing')
    
    if isDragging
      localStorage.setItem(KEY_POS_T, domEl.style.top)
      localStorage.setItem(KEY_POS_L, domEl.style.left)
      isDragging = false
      $dom.removeClass('dragging')
      domEl.style.cursor = if isLocked then 'default' else 'grab'

    $(document).off 'mousemove', mouseMoveHandler
    $(document).off 'mouseup', mouseUpHandler

update: (output, domEl) ->
  if output.trim() != "NOT_FOUND"
    $(domEl).find('#photo-display').attr('src', "Glass-Widgets/current_photo.jpg?#{new Date().getTime()}").show()
    $(domEl).find('#no-photo').hide()
