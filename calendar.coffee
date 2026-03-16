refreshFrequency: 3600000

command: "date +%d:%m:%y"

style: """
  top: 20px
  left: 185px
  width: 150px
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
  padding: 15px
  box-sizing: border-box

  .month
    color: #FF375F
    font-size: 11px
    font-weight: 800
    text-transform: uppercase
    margin-bottom: 8px
    letter-spacing: 0.5px

  table
    width: 100%
    border-collapse: collapse

  th
    font-size: 8px
    font-weight: 700
    color: rgba(255, 255, 255, 0.4)
    padding-bottom: 4px

  td
    font-size: 10px
    text-align: center
    padding: 3px 0
    font-weight: 500

  .today
    background: #FF375F
    color: #fff
    border-radius: 50%
    font-weight: 800
"""

render: -> """
  <div class="month" id="m-name"></div>
  <table>
    <thead><tr><th>M</th><th>T</th><th>W</th><th>T</th><th>F</th><th>S</th><th>S</th></tr></thead>
    <tbody id="cal-body"></tbody>
  </table>
"""

update: (output, domEl) ->
  d = new Date()
  mNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  $(domEl).find('#m-name').text(mNames[d.getMonth()])

  first = new Date(d.getFullYear(), d.getMonth(), 1).getDay()
  first = if first == 0 then 6 else first - 1
  total = new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate()

  tbody = $(domEl).find('#cal-body').empty()
  row = $("<tr>")
  row.append("<td></td>") for [0...first]

  for day in [1..total]
    row = $("<tr>").appendTo(tbody) if row.children().length == 7
    cell = $("<td>").text(day).appendTo(row)
    cell.addClass('today') if day == d.getDate()
  tbody.append(row)
