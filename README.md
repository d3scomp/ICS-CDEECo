# Intelligent crossroad system

This repository contains sources of the ICS (Intelligent Crossroad System) case study. The sources are based on the inhouse developed CDEECo (realtime C based implementation of Dependable Emergent Ensembles of Components), and OMNeT++(well estabilished network simulator). Main puropose of this project is to show how ICS maps into DEECo Ensembles and Component with respect to realtime CDEECo implementation. Further the network simulation manifests the feasibility of such system in terms of reliability and timing requirements.

## Repository content

<dl>
    <dt>cdeeco</dt>
    <dd>Link to CDEECo library sources</dd>

    <dt>network-simulation</dt>
    <dd>Link to repository containing network simulation in OMNeT++</dd>
    
    <dt>src</dt>
    <dd>Draft of the ICS implementation</dd>    
</dl>

## Supported hardware

The application is an embedded software running on nonPC hardware. Currently the build system is tailored for [STM32F4](http://www.st.com/web/en/catalog/mmc/FM141/SC1169/SS1577?sc=stm32f4) board. With some effort the application and CDEECo library can be ported to any hardware supported by [FreeRTOS](http://www.freertos.org/) system. Thus the application can be ported to large number of well known embedded CPUs.

## Building sources

The build system is based on Makefiles. Top level makefile is exdpected to submerge int ocdeeco library and then build the ICS and Vehicle applications.

### Necessary tools
Unfortunatelly these tools are not easy to obtain as binaries. A custom compiled version was used for development. It was obtained on [Gentoo](https://www.gentoo.org/) based system using crossdev script:

$ crossdev --target armv7m-hardfloat-eabi --ex-gcc --ex-gdb

Hopefuly as the addoption of new C++ features advances, standard toolchains will get the encessary support. These is the brief list of required versions. For mor detailed description see README for CDEECo library.

- armv7m-hardfloat-eabi-g++ with C++ 1y support
- binutils >= 2.24-r3
- newlib >= 2.1.0
- openocd >= 0.9.0

### How to compile

it might be necessary to slightly modify makefiles in in case that tollchain and openocd is located in some unexpected location. Once the tools are in place the compilation process requires just one command to be executed in project root:

$ make

NOTE: Currently only single threaded building is supported.

### What is the output

If everything goes well with building two application binaries should be created. The binaries ale also automaticaly dumped as hex files that can be flashed into development board using openocd.

Run this to flash ics application:

$ make flash-ics

Run this to flash vehicle application:

$ make flash-vehicle