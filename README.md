# m68k-elf Toolset

Toolset for the Motorola 68000 for use with [SGDK](https://github.com/Stephane-D/SGDK) and other bare-metal environments. It includes the following components:

* GCC 14.2.0
* GDB 16.2
* Newlib 4.5.0.20241231

## Cloning

This repository uses submodules. To clone the repository use the command below.

`git clone --recursive https://github.com/iratahack/m68k-elf-gcc.git`

## Scripts

The build scripts in this repository are:

* crosstool-build.sh
  * Builds the toolset natively for Ubuntu 22.04 and Windows (mingw32)
    * Builds are performed using [crosstool-ng](https://github.com/crosstool-ng/crosstool-ng)

## Using with SGDK (Linux)

Integration with SGDK is not 100% seamless. Follow the steps below to integrate with SGDK.

* Extract the archive containing the m68k-elf development tools
* Setup your path to include `<installdir>/m68k-elf/bin` (extracted from the tool archive)
* Set the `PREFIX` environment variable to `m68k-elf-`
* Build sjasm and bintos
  * From the checked out repo.
  ```
  make -C tools/sjasm/src/
  cp tools/sjasm/src/sjasm bin/
  cmake -S tools/bintos/src -B tools/bintos/build
  cmake --build tools/bintos/build/
  cp tools/bintos/build/bintos bin/
  ```
  