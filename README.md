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

## Using with SGDK

Integration with SGDK is not 100% seamless. Follow the steps below to integrate with SGDK.

* Extract the archive containing the m68k-elf development tools
* Setup your path to include `SGDK/bin` and `<installdir>/m68k-elf/bin` (extracted from the tool archive)
* Remove the existing tool binaries from the `SGDK` directory listed below
```
bin/ar.exe bin/as.exe bin/cc1.exe bin/cpp.exe bin/gcc.exe bin/gdb.exe bin/ld.exe bin/libgcc_s_dw2-1.dll bin/libgmp-10.dll bin/libiconv-2.dll bin/liblto_plugin-0.dll bin/libmpc-3.dll bin/libmpfr-4.dll bin/lto-wrapper.exe bin/lto1.exe bin/nm.exe bin/objcopy.exe bin/objdump.exe bin/size.exe lib/libgcc.a
```
* Set the `PREFIX` environment variable to `m68k-elf-`
