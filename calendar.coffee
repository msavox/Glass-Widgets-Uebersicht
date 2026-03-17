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
# Position and sizing
posTop = "20px"
posLeft = "185px"
widgetWidth = "150px"
widgetHeight = "160px"

# Visual styling
fontFamily = '-apple-system, "SF Pro Display", sans-serif'
mainColor = "#fff"
accentColor = "#FF375F" # Used for month header and today's highlight
thColor = "rgba(255, 255, 255, 0.4)" # Color for weekday headers

# Glassmorphism settings
bgColor = "rgba(255, 255, 255, 0.08)"
blurRadius = "25px"
borderRadius = "22px"
borderStyle = "1px solid rgba(255, 255, 255, 0.15)"
boxShadow = "0 20px 50px rgba(0,0,0,0.3)"

# Padding and spacing
padding = "15px"

# Typography
monthFontSize = "11px"
monthFontWeight = "800"
thFontSize = "8px"
thFontWeight = "700"
tdFontSize = "10px"
tdFontWeight = "500"

# Localization/Labels
monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
dayHeaders = ["M", "T", "W", "T", "F", "S", "S"]

# --- Refresh Frequency ---
# Refresh once per hour (3600000 ms)
refreshFrequency: 3600000

# Bash command to trigger the widget (not used for data, but required)
command: "date +%d:%m:%y"

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
  background: #{bgColor}
  
  /* Glassmorphism Effect */
  /* backdrop-filter applies a blur to the area behind the element, 
     creating the signature frosted glass look of macOS and iOS. */
  backdrop-filter: blur(#{blurRadius})
  -webkit-backdrop-filter: blur(#{blurRadius})
  border-radius: #{borderRadius}
  border: #{borderStyle}
  box-shadow: #{boxShadow}
  
  padding: #{padding}
  box-sizing: border-box

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
"""

# --- Render ---
# The render function returns the HTML structure of the widget.
render: -> """
  <div class="month" id="m-name"></div>
  <table>
    <thead>
      <tr>
        #{("<th>#{h}</th>" for h in dayHeaders).join('')}
      </tr>
    </thead>
    <tbody id="cal-body"></tbody>
  </table>
"""

# --- Update Logic ---
# The update function is called periodically to refresh the widget content.
update: (output, domEl) ->
  # Get current date details using JavaScript's Date object.
  d = new Date()
  
  # Update the month name header in the DOM.
  $(domEl).find('#m-name').text(monthNames[d.getMonth()])

  # Logic to calculate the layout of the calendar grid:
  
  # 1. Determine the first day of the current month.
  # .getDay() returns 0 for Sunday, 1 for Monday, etc.
  # We adjust it so that Monday is 0 and Sunday is 6 for our grid layout.
  first = new Date(d.getFullYear(), d.getMonth(), 1).getDay()
  first = if first == 0 then 6 else first - 1
  
  # 2. Calculate the total number of days in the current month.
  # Passing '0' as the day to the next month's constructor returns the last day of the current month.
  total = new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate()

  # 3. Clear and rebuild the calendar body (tbody) dynamically.
  tbody = $(domEl).find('#cal-body').empty()
  row = $("<tr>")
  
  # Append empty cells for days before the 1st of the month to align weekdays.
  row.append("<td></td>") for [0...first]

  # 4. Populate the days of the month.
  for day in [1..total]
    # If the current row is full (7 days), append it to the table and start a new row.
    if row.children().length == 7
      tbody.append(row)
      row = $("<tr>")
    
    cell = $("<td>").text(day).appendTo(row)
    
    # Highlight the current day with the 'today' CSS class.
    if day == d.getDate()
      cell.addClass('today')
      
  # 5. Append the final row to the table.
  tbody.append(row)
