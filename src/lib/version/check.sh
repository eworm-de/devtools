#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
[[ -z ${DEVTOOLS_INCLUDE_VERSION_CHECK_SH:-} ]] || return 0
DEVTOOLS_INCLUDE_VERSION_CHECK_SH=1

_DEVTOOLS_LIBRARY_DIR=${_DEVTOOLS_LIBRARY_DIR:-@pkgdatadir@}
# shellcheck source=src/lib/common.sh
source "${_DEVTOOLS_LIBRARY_DIR}"/lib/common.sh

source /usr/share/makepkg/util/message.sh

set -e

pkgctl_version_check_usage() {
	local -r COMMAND=${_DEVTOOLS_COMMAND:-${BASH_SOURCE[0]##*/}}
	cat <<- _EOF_
		Usage: ${COMMAND} [OPTIONS] [PKGBASE]...

		Uses nvchecker, a .nvchecker.toml file and the current PKGBUILD
		pkgver to check if there is a newer package version available.

		The current working directory is used if no PKGBASE is specified.

		OPTIONS
		    -h, --help          Show this help text

		EXAMPLES
		    $ ${COMMAND} neovim vim
_EOF_
}

pkgctl_version_check() {
	local path
	local pkgbases=()

	while (( $# )); do
		case $1 in
			-h|--help)
				pkgctl_version_check_usage
				exit 0
				;;
			--)
				shift
				break
				;;
			-*)
				die "invalid argument: %s" "$1"
				;;
			*)
				pkgbases=("$@")
				break
				;;
		esac
	done

	if ! command -v nvchecker &>/dev/null; then
		die "The \"$_DEVTOOLS_COMMAND\" command requires 'nvchecker'"
	fi

	# Check if used without pkgbases in a packaging directory
	if (( ${#pkgbases[@]} == 0 )); then
		if [[ -f PKGBUILD ]]; then
			pkgbases=(".")
		else
			pkgctl_version_check_usage
			exit 1
		fi
	fi

	for path in "${pkgbases[@]}"; do
		pushd "${path}" >/dev/null
		run_nvchecker "${path}"
		popd >/dev/null
	done
}

run_nvchecker() {
	local path=$1
	local pkgbase latest_version

	if [[ ! -f ".nvchecker.toml" || ! -f "PKGBUILD" ]]; then
		die "No .nvchecker.toml or PKGBUILD found for ${path}"
		exit 1
	fi

	# TODO: parse .SRCINFO file
	# shellcheck source=contrib/makepkg/PKGBUILD.proto
	. ./PKGBUILD
	pkgbase=${pkgbase:-$pkgname}

	latest_version=$(nvchecker -c .nvchecker.toml --logger json | jq --raw-output 'select( .version ) | .version')
	if (( $(vercmp "${latest_version}" "${pkgver}") > 0 )); then
		msg2 "New ${pkgbase} version ${latest_version} is available upstream"
	fi
}