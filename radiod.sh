#!/usr/bin/env bash

vol=100

create_mpv() {
	mkfifo ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
	mpv --input-ipc-server=${XDG_RUNTIME_DIR}/radiod/mpv-fifo --no-video $(yt-dlp -g https://www.youtube.com/watch?v=jfKfPfyJRdk) &>/dev/null &
}

volume_down() {
	vol=$(($vol - 2))
	echo "{\"command\": [\"set_property\", \"volume\", \"${vol}\"]}" | socat - ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
}

volume_up() {
	vol=$(($vol + 2))
	echo "{\"command\": [\"set_property\", \"volume\", \"${vol}\"]}" | socat - ${XDG_RUNTIME_DIR}/radiod/mpv-fifo
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
