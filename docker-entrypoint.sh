#!/usr/bin/env bash
set -euo pipefail

if ! [ -e index.php -a -e inc/class_core.php ]; then
	echo >&2 "MyBB not found in $PWD - copying now..."
	if [ "$(ls -A)" ]; then
		echo >&2 "WARNING: $PWD is not empty - press Ctrl+C now if this is an error!"
		( set -x; ls -A; sleep 10 )
	fi
	git clone -b develop/1.9 https://github.com/mybb/mybb $PWD
	echo >&2 "Complete! MyBB ${MYBB_VERSION} has been successfully cloned to $PWD"
fi

exec "$@"
