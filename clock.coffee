# Frequenza di aggiornamento (1 secondo)
refreshFrequency: 1000

# Comando pulito
command: "date +%H:%M"

style: """
  top: 20px
  left: 15px
  width: 150px
  height: 160px

  /* Effetto Vetro */
  background: rgba(255, 255, 255, 0.08)
  backdrop-filter: blur(25px)
  -webkit-backdrop-filter: blur(25px)
  border-radius: 22px
  border: 1px solid rgba(255, 255, 255, 0.15)
  box-shadow: 0 20px 50px rgba(0,0,0,0.3)

  /* Centratura */
  display: flex
  justify-content: center
  align-items: center

  /* Font */
  font-family: -apple-system, "SF Pro Display", sans-serif
  -webkit-font-smoothing: antialiased
  color: #fff

  .time
    font-size: 50px
    font-weight: 600
    letter-spacing: -2px
    opacity: 0.9
    font-variant-numeric: tabular-nums
"""

# Render super semplice: prende l'output e lo butta dentro il div
render: (output) -> """
  <div class="time">#{output}</div>
"""
