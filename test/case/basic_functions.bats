export FAKR_UPDATR_LIBDIR="${PWD}/src/lib"

@test "version" {
	XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}" src/fakr-updatr.sh --version
}

@test "help" {
	XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}" src/fakr-updatr.sh --help
}
