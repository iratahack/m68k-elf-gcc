# m68k-elf-gcc

GCC for the Motorola 68000 for use with [SGDK](https://github.com/Stephane-D/SGDK) and other bare-metal environments. Note, this buid does not include a C-library.

## Scripts

The build scripts in this repository are:

* build_gcc.sh
  * Used to build GCC on Ubuntu 22.04. The script first builds a native version of GCC for 68000 used to create target libraries when GCC is cross compiled for Windows (mingw32).
  * The output of this script are two tar-balls. One containing GCC for Ubuntu and one for Windows.
* build_gcc_mingw.sh
  * Used to build GCC natively in an msys2 (mingw32) environment on Windows.
  * The script will copy the needed DLL's into the GCC `bin` directory.

## Github Actions

Two github actions are available, one to run each script.

