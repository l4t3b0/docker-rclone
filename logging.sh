quiet=0
col_reset="\033[0m"

col_blk='\033[0;30m'        # Black
col_red='\033[0;31m'          # Red
col_grn='\033[0;32m'        # Green
col_ylw='\033[0;33m'       # Yellow
col_blu='\033[0;34m'         # Blue
col_prl='\033[0;35m'       # Purple
col_cyn='\033[0;36m'         # Cyan
col_wht='\033[0;37m'        # White

col_onblk='\033[40m'       # Black
col_onred='\033[41m'         # Red
col_ongrn='\033[42m'       # Green
col_onylw='\033[43m'      # Yellow
col_onblu='\033[44m'        # Blue
col_onprl='\033[45m'      # Purple
col_oncyn='\033[46m'        # Cyan
col_onwht='\033[47m'       # White

out() {
  ((quiet)) && true || printf '%b\n' "$*";
}

debug() {
  out "🟢 DEBUG: $*" >&2
}

info() {
  out "ℹ️  ${col_blu}INFO${col_reset}: $*" >&2
}

error() {
  out "🚨 ${col_red}ERROR${col_reset}: $*" >&2
}

warn() {
  out "⚠️  ${col_ylw}WARN${col_reset}: $*" >&2
}

die() {
  out "💀 ${col_onred}EXIT${col_reset}: $*" >&2
  tput bel
}
