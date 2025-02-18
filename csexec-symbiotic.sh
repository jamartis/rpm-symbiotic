#!/usr/bin/bash

usage() {
  cat << EOF
USAGE: $0 -s SYMBIOTIC_ARGS ARGV
1) Build the source with gllvm and CFLAGS internally used by Symbiotic and
   LDFLAGS='-Wl,--dynamic-linker=/usr/bin/csexec-loader'.
2) CSEXEC_WRAP_CMD=$'--skip-ld-linux\acsexec-symbiotic\a-l\aLOG_DIR\a-s\a--prp=memsafety' make check
3) Wait for some time.
4) ...
5) Profit!
EOF
}

[[ $# -eq 0 ]] && usage && exit 1

while getopts "l:s:h" opt; do
  case "$opt" in
    l)
      LOGDIR="$OPTARG"
      ;;
    s)
      SYMBIOTIC=($OPTARG)
      ;;
    h)
      usage && exit 0
      ;;
    *)
      usage && exit 1
      ;;
  esac
done

shift $((OPTIND - 1))
ARGV=("$@")

if [ -z "$LOGDIR" ]; then
  echo "-l LOGDIR option is mandatoty!"
  exit 1
fi

# Run!
get-bc "${ARGV[0]}" > /dev/null || exit 1
symbiotic "${SYMBIOTIC[@]}" --argv="'${ARGV[*]}'" "${ARGV[0]}.bc" \
  2> "$LOGDIR/pid-$$.err" > "$LOGDIR/pid-$$.out"

# Continue
exec $(csexec --print-ld-exec-cmd) "${ARGV[@]}"
