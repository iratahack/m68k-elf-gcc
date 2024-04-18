# m68k-elf Toolset

Toolset for the Motorola 68000 for use with [SGDK](https://github.com/Stephane-D/SGDK) and other bare-metal environments. It includes the following components:

* GCC 13.2.0
* GDB 13.2
* Newlib 4.3.0.20230120

## Cloning

This repository uses submodules. To clone the repository use the command below.

`git clone --recursive https://github.com/iratahack/m68k-elf-gcc.git`

## Scripts

The build scripts in this repository are:

* crosstool-build.sh
  * Builds the toolset natively for Ubuntu 22.04 and Windows (mingw32)
    * Builds are performed using [crosstool-ng](https://github.com/crosstool-ng/crosstool-ng)

## Using with SGDK

Integration with SGDK is not 100% seamless. Follow the steps below to integrate with SGDK.

* Extract the archive containing the m68k-elf development tools
* Setup your path to include `<installdir>/m68k-elf/bin` (extracted from the tool archive)
* Remove the existing tool binaries from the `SGDK` directory listed below
```
bin/ar.exe bin/as.exe bin/cc1.exe bin/cpp.exe bin/gcc.exe bin/gdb.exe bin/ld.exe bin/libgcc_s_dw2-1.dll bin/libgmp-10.dll bin/libiconv-2.dll bin/liblto_plugin-0.dll bin/libmpc-3.dll bin/libmpfr-4.dll bin/lto-wrapper.exe bin/lto1.exe bin/nm.exe bin/objcopy.exe bin/objdump.exe bin/size.exe lib/libgcc.a
```
* Set the `PREFIX` environment variable to `m68k-elf-`
* Copy [these](https://github.com/iratahack/m68k-elf-gcc/tree/develop/SGDK) files to your `SGDK` directory
