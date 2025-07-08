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
	echo $$ >${XDG_RUNTIME_DIR}/radiod/radiod.pid
}

h_int() {
	rm -r ${XDG_RUNTIME_DIR}/radiod
	exit
}

daemon() {
	init

	trap h_int SIGINT
	trap volume_down SIGUSR1
	trap volume_up SIGUSR2

	while true; do sleep 0.1; done
}

if [ "$1" == "daemon" ]; then daemon; fi

if [ "$1" == "down" ]; then
	kill -SIGUSR1 $(cat /run/user/1000/radiod/radiod.pid)
fi

if [ "$1" == "up" ]; then
	kill -SIGUSR2 $(cat /run/user/1000/radiod/radiod.pid)
fi
