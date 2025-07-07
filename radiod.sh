#!/usr/bin/env bash

init() {
	mkdir -p ${XDG_RUNTIME_DIR}/radiod
	echo $$ >${XDG_RUNTIME_DIR}/radiod/radiod.pid
}

init
