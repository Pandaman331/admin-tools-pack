#!/bin/bash

# --- Ustaw terminal, jeśli nie jest ustawiony lub jest "dumb"
if [[ -z "$TERM" || "$TERM" == "dumb" ]]; then
  export TERM=xterm-256color
fi

# --- Pułapka na wyjście (Ctrl+C itp), przywrócenie kursora i czyszczenie
trap 'tput cnorm; clear; exit' INT TERM EXIT

# --- Ukrycie kursora
tput civis

# --- Kolory
BLACK_BG='\033[40m'
GREEN_BG='\033[42m'
GREEN_FG='\033[32m'
BLACK_FG='\033[30m'
RESET='\033[0m'

# --- Opcje menu (nazwa::komenda)
MENU_ITEMS=(
  "System Info::neofetch"
  "Disk Usage::df -h | less"
  "Process Monitor::htop"
  "Exit::exit 0"
)

NUM_OPTIONS=${#MENU_ITEMS[@]}
SELECTED=0
TITLE=" Admin Tools Pack "

# --- Pobierz rozmiar terminala, ustaw domyślne, jeśli puste
rows=$(tput lines)
cols=$(tput cols)
rows=${rows:-24}
cols=${cols:-80}

box_width=50
box_height=$((NUM_OPTIONS + 6))

top=$(( (rows - box_height) / 2 ))
left=$(( (cols - box_width) / 2 ))

# --- Zapobiegaj ujemnym wartościom
(( top < 0 )) && top=0
(( left < 0 )) && left=0

# --- Funkcje pomocnicze
get_label() {
  local str="$1"
  echo "${str%%::*}"
}

get_action() {
  local str="$1"
  echo "${str#*::}"
}

# --- Rysowanie statycznego tła i ramki
draw_static() {
  # Czyszczenie i czarne tło całego ekranu
  printf "${BLACK_BG}"
  for ((i=0; i<rows; i++)); do
    printf "%${cols}s\n" " "
  done
  printf "${RESET}"

  # Zielone tło w ramce
  for ((i=0; i<box_height; i++)); do
    tput cup $((top + i)) $left
    printf "${GREEN_BG}%${box_width}s${RESET}" " "
  done

  # Ramka (zielone pionowe linie, czarne znaki brzegowe)
  for ((i=0; i<box_height; i++)); do
    tput cup $((top + i)) $left
    printf "${BLACK_BG}${GREEN_FG}│${RESET}${GREEN_BG}"
    tput cup $((top + i)) $((left + box_width - 1))
    printf "${BLACK_BG}${GREEN_FG}│${RESET}${GREEN_BG}"
  done

  # Górna i dolna krawędź ramki
  tput cup $top $left
  printf "${BLACK_BG}${GREEN_FG}╭"
  for ((i=0; i<box_width-2; i++)); do printf "─"; done
  printf "╮${RESET}"

  tput cup $((top + box_height - 1)) $left
  printf "${BLACK_BG}${GREEN_FG}╰"
  for ((i=0; i<box_width-2; i++)); do printf "─"; done
  printf "╯${RESET}"

  # Tytuł na górze
  tput cup $top $((left + 2))
  printf "${BLACK_BG}${GREEN_FG}%s${RESET}" "$TITLE"
}

# --- Rysowanie dynamicznych opcji menu
draw_menu() {
  for ((i=0; i<NUM_OPTIONS; i++)); do
    local label=$(get_label "${MENU_ITEMS[i]}")
    tput cup $((top + 2 + i)) $((left + 4))
    if [[ $i -eq $SELECTED ]]; then
      printf "${BLACK_BG}${GREEN_FG}> %s${RESET}" "$label"
    else
      printf "${GREEN_BG}${BLACK_FG}  %s${RESET}" "$label"
    fi
  done
}

# --- Czytanie klawisza (obsługa strzałek i Enter/TAB)
read_key() {
  IFS= read -rsn1 key 2>/dev/null >&2
  if [[ $key == $'\x1b' ]]; then
    read -rsn2 key 2>/dev/null
    echo "$key"
  else
    echo "$key"
  fi
}

# --- Start programu
clear
draw_static

while true; do
  draw_menu
  key=$(read_key)

  case "$key" in
    '[A')  # strzałka w górę
      ((SELECTED--))
      (( SELECTED < 0 )) && SELECTED=$((NUM_OPTIONS - 1))
      ;;
    '[B')  # strzałka w dół
      ((SELECTED++))
      (( SELECTED >= NUM_OPTIONS )) && SELECTED=0
      ;;
    $'\t'|$'\n')  # TAB lub ENTER zatwierdza wybór
      clear
      tput cnorm
      action=$(get_action "${MENU_ITEMS[SELECTED]}")
      eval "$action"
      read -p "Press enter to return..."
      clear
      tput civis
      draw_static
      ;;
  esac
done
