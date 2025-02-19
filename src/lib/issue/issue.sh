#!/hint/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

[[ -z ${DEVTOOLS_INCLUDE_ISSUE_SH:-} ]] || return 0
DEVTOOLS_INCLUDE_ISSUE_SH=1

_DEVTOOLS_LIBRARY_DIR=${_DEVTOOLS_LIBRARY_DIR:-@pkgdatadir@}

set -eo pipefail


pkgctl_issue_usage() {
	local -r COMMAND=${_DEVTOOLS_COMMAND:-${BASH_SOURCE[0]##*/}}
	cat <<- _EOF_
		Usage: ${COMMAND} [COMMAND] [OPTIONS]

		Work with GitLab packaging issues.

		COMMANDS
		    close     Close an issue
		    comment   Comment on an issue
		    create    Create a new issue
		    edit      Edit and modify an issue
		    list      List project or group issues
		    move      Move an issue to another project
		    reopen    Reopen a closed issue
		    view      Display information about an issue

		OPTIONS
		    -h, --help    Show this help text

		EXAMPLES
		    $ ${COMMAND} list libfoo libbar
		    $ ${COMMAND} view 4
_EOF_
}

pkgctl_issue() {
	if (( $# < 1 )); then
		pkgctl_issue_usage
		exit 0
	fi

	# option checking
	while (( $# )); do
		case $1 in
			-h|--help)
				pkgctl_issue_usage
				exit 0
				;;
			close)
				_DEVTOOLS_COMMAND+=" $1"
				shift
				# shellcheck source=src/lib/issue/close.sh
				source "${_DEVTOOLS_LIBRARY_DIR}"/lib/issue/close.sh
				pkgctl_issue_close "$@"
				exit 0
				;;
			create)
				_DEVTOOLS_COMMAND+=" $1"
				shift
				# shellcheck source=src/lib/issue/create.sh
				source "${_DEVTOOLS_LIBRARY_DIR}"/lib/issue/create.sh
				pkgctl_issue_create "$@"
				exit 0
				;;
			edit|update)
				_DEVTOOLS_COMMAND+=" $1"
				shift
				# shellcheck source=src/lib/issue/edit.sh
				source "${_DEVTOOLS_LIBRARY_DIR}"/lib/issue/edit.sh
				pkgctl_issue_edit "$@"
				exit 0
				;;
			list)
				_DEVTOOLS_COMMAND+=" $1"
				shift
				# shellcheck source=src/lib/issue/list.sh
				source "${_DEVTOOLS_LIBRARY_DIR}"/lib/issue/list.sh
				pkgctl_issue_list "$@"
				exit 0
				;;
			comment|note)
				_DEVTOOLS_COMMAND+=" $1"
				shift
				# shellcheck source=src/lib/issue/comment.sh
				source "${_DEVTOOLS_LIBRARY_DIR}"/lib/issue/comment.sh
				pkgctl_issue_comment "$@"
				exit 0
				;;
			move)
				_DEVTOOLS_COMMAND+=" $1"
				shift
				# shellcheck source=src/lib/issue/move.sh
				source "${_DEVTOOLS_LIBRARY_DIR}"/lib/issue/move.sh
				pkgctl_issue_move "$@"
				exit 0
				;;
			reopen)
				_DEVTOOLS_COMMAND+=" $1"
				shift
				# shellcheck source=src/lib/issue/reopen.sh
				source "${_DEVTOOLS_LIBRARY_DIR}"/lib/issue/reopen.sh
				pkgctl_issue_reopen "$@"
				exit 0
				;;
			view)
				_DEVTOOLS_COMMAND+=" $1"
				shift
				# shellcheck source=src/lib/issue/view.sh
				source "${_DEVTOOLS_LIBRARY_DIR}"/lib/issue/view.sh
				pkgctl_issue_view "$@"
				exit 0
				;;
			-*)
				die "invalid argument: %s" "$1"
				;;
			*)
				die "invalid command: %s" "$1"
				;;
		esac
	done
}
