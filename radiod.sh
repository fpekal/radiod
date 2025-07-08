#!%bash%

vol=80

stations=(
	"echo https://195.150.20.243/RMFMAXXX48"
	"echo https://rs6-krk2.rmfstream.pl/rmf_fm"
	"echo https://redir.atmcdn.pl/sc/o2/Eurozet/live/audio.livx"
	"echo https://n-11-24.dcs.redcdn.pl/sc/o2/Eurozet/live/antyradio.livx"
	"echo https://stream2.nadaje.com:8023/"
	"echo http://stream.radioluz.pl:8000/luzhifi.mp3"
	"%yt-dlp% -g https://www.youtube.com/watch?v=jfKfPfyJRdk"
)
curr_station=0

create_mpv() {
	mkfifo ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
	%mpv% --volume=${vol} --cache-secs=60 --input-ipc-server=${XDG_RUNTIME_DIR}/radiod/mpv-fifo --no-video $(eval "${stations[0]}") &>/dev/null &
}

volume_down() {
	vol=$(($vol - 2))
	echo "{\"command\": [\"set_property\", \"volume\", \"${vol}\"]}" | %socat% - ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
}

volume_up() {
	vol=$(($vol + 2))
	echo "{\"command\": [\"set_property\", \"volume\", \"${vol}\"]}" | %socat% - ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
}

pause_radio() {
	echo '{"command": ["set_property", "pause", true]}' | %socat% - ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
}

toggle_pause() {
	echo '{"command": ["get_property", "pause"]}' | %socat% - ${XDG_RUNTIME_DIR}/radiod/mpv-fifo |
		grep -q '"data":true' &&
		echo '{"command": ["set_property", "pause", false]}' | %socat% - ${XDG_RUNTIME_DIR}/radiod/mpv-fifo ||
		echo '{"command": ["set_property", "pause", true]}' | %socat% - ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
}

resume_radio() {
	echo '{"command": ["set_property", "pause", false]}' | %socat% - ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
}

change_station() {
	# Zwiększ indeks stacji i zawróć do początku, jeśli przekroczony
	curr_station=$(((curr_station + 1) % ${#stations[@]}))

	# Zatrzymaj poprzednie mpv (jeśli istnieje)
	if [ -e "${XDG_RUNTIME_DIR}/radiod/mpv-fifo" ]; then
		echo '{"command": ["quit"]}' | %socat% - "${XDG_RUNTIME_DIR}/radiod/mpv-fifo"
		sleep 0.2
	fi

	# Usuń starą kolejkę FIFO i utwórz nową
	rm -f ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
	mkfifo ${XDG_RUNTIME_DIR}/radiod/mpv-fifo

	# Pobierz URL stacji
	url=$(eval "${stations[$curr_station]}")

	# Uruchom mpv z nowym URL
	%mpv% --cache-secs=60 --input-ipc-server=${XDG_RUNTIME_DIR}/radiod/mpv-fifo --no-video "$url" &>/dev/null &

	# Ustaw aktualną głośność
	sleep 0.2
	echo "{\"command\": [\"set_property\", \"volume\", \"${vol}\"]}" | %socat% - ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
}

init() {
	mkdir -p ${XDG_RUNTIME_DIR}/radiod
	create_mpv
	mkfifo ${XDG_RUNTIME_DIR}/radiod/cmd
}

h_int() {
	rm -r ${XDG_RUNTIME_DIR}/radiod
	exit
}

daemon() {
	init

	trap h_int SIGINT

	while read -r line <"${XDG_RUNTIME_DIR}/radiod/cmd"; do
		case "$line" in
		next) change_station ;;
		volup) volume_up ;;
		voldown) volume_down ;;
		pause) pause_radio ;;
		resume) resume_radio ;;
		toggle) toggle_pause ;;
		*) echo "Unknown command: $line" ;;
		esac
	done
}

if [ "$1" == "daemon" ]; then daemon; fi

if [ "$1" == "down" ]; then
	echo "voldown" >${XDG_RUNTIME_DIR}/radiod/cmd
fi

if [ "$1" == "up" ]; then
	echo "volup" >${XDG_RUNTIME_DIR}/radiod/cmd
fi

if [ "$1" == "next" ]; then
	echo "next" >${XDG_RUNTIME_DIR}/radiod/cmd
fi

if [ "$1" == "pause" ]; then
	echo "pause" >${XDG_RUNTIME_DIR}/radiod/cmd
fi

if [ "$1" == "resume" ]; then
	echo "resume" >${XDG_RUNTIME_DIR}/radiod/cmd
fi

if [ "$1" == "toggle" ]; then
	echo "toggle" >${XDG_RUNTIME_DIR}/radiod/cmd
fi
