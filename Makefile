# Binaries will be generated with this name (.elf, .bin, .hex, etc)
PROJ_ICS_NAME=ics
PROJ_VEHICLE_NAME=vehicle

BUILD_DIR=build
SRC_DIR=src
CDEECO_DIR=cdeeco

OPENOCD=openocd

# Example project
SRCS += ${SRC_DIR}/SpeedExchange.cpp
SRCS += ${SRC_DIR}/MrfRadio.cpp

ICS_SRCS += ${SRCS}
ICS_SRCS += ${SRC_DIR}/ICS.cpp
ICS_SRCS += ${SRC_DIR}/ics_app.cpp

VEHICLE_SRCS += ${SRCS}
VEHICLE_SRCS += ${SRC_DIR}/Vehicle.cpp
VEHICLE_SRCS += ${SRC_DIR}/vehicle_app.cpp

# System
SRCS +=	${SRC_DIR}/main.cpp

# Framework
SRCS += $(CDEECO_DIR)/Radio.cpp

# FreeRTOS wrappers
#SRCS += $(WRAPPERS_DIR)/FreeRTOSMutex.cpp
#SRCS += $(WRAPPERS_DIR)/FreeRTOSSemaphore.cpp
#SRCS += $(WRAPPERS_DIR)/FreeRTOSTask.cpp

# Drivers
#SRCS +=	${SRC_DIR}/drivers/LED.cpp
#SRCS +=	${SRC_DIR}/drivers/Timer.cpp
#SRCS += ${SRC_DIR}/drivers/Console.cpp
#SRCS += ${SRC_DIR}/drivers/UART.cpp
#SRCS += ${SRC_DIR}/drivers/stm32f4xx_it.cpp
#SRCS +=	${SRC_DIR}/drivers/system_stm32f4xx.c
#SRCS += ${SRC_DIR}/drivers/MRF24J40.cpp
#SRCS += ${SRC_DIR}/drivers/SHT1x.cpp
#SRCS += ${SRC_DIR}/drivers/Button.cpp
#SRCS += ${SRC_DIR}/drivers/GPS.cpp
#SRCS += ${SRC_DIR}/drivers/StopWatch.cpp

# STM32F4 code
#SRCS += ${CMSIS_DEVICE_DIR}/Source/Templates/system_stm32f4xx.c
#SRCS += ${CMSIS_DEVICE_DIR}/Source/Templates/TrueSTUDIO/startup_stm32f40xx.s
#SRCS +=	${PERIPH_DIR}/src/stm32f4xx_rcc.c
#SRCS +=	${PERIPH_DIR}/src/stm32f4xx_exti.c
#SRCS +=	${PERIPH_DIR}/src/stm32f4xx_gpio.c
#SRCS +=	${PERIPH_DIR}/src/stm32f4xx_syscfg.c
#SRCS +=	${PERIPH_DIR}/src/stm32f4xx_usart.c
#SRCS +=	${PERIPH_DIR}/src/stm32f4xx_spi.c
#SRCS +=	${PERIPH_DIR}/src/stm32f4xx_tim.c
#SRCS +=	${PERIPH_DIR}/src/misc.c

# FreeRTOS sources
#SRCS += $(FREERTOS_DIR)/Source/portable/MemMang/heap_3.c
#SRCS += $(FREERTOS_DIR)/Source/portable/GCC/ARM_CM4F/port.c
#SRCS += $(FREERTOS_DIR)/Source/list.c
#SRCS += $(FREERTOS_DIR)/Source/queue.c
#SRCS += $(FREERTOS_DIR)/Source/tasks.c
#SRCS += $(FREERTOS_DIR)/Source/timers.c

# Normally you shouldn't need to change anything below this line!
#######################################################################################

CC=armv7m-hardfloat-eabi-gcc
CXX=armv7m-hardfloat-eabi-g++
OBJCOPY=armv7m-hardfloat-eabi-objcopy
SIZE=armv7m-hardfloat-eabi-size
AR=armv7m-hardfloat-eabi-ar

# For some reason -O2 generates wrong code for interrupts. At least the USER_BUTTON interrupt handler get called twice
CFLAGS  = -mcpu=cortex-m4 -g -Og -Wall -pipe
CFLAGS += -mlittle-endian -mthumb -mthumb-interwork -mfloat-abi=hard -mfpu=fpv4-sp-d16 -MMD -MP -fsingle-precision-constant
CFLAGS += -I$(CDEECO_DIR)/src
CFLAGS += -I$(CDEECO_DIR)/src/wrappers
#CFLAGS += -I$(SRC_DIR)
#CFLAGS += -I$(DRIVERS_DIR)
#CFLAGS += -I${CMSIS_DEVICE_DIR}/Include
#CFLAGS += -I$(CMSIS_DIR)/Include
#CFLAGS += -I$(PERIPH_DIR)/inc
#CFLAGS += -I$(FREERTOS_DIR)/Source/include
#CFLAGS += -I$(FREERTOS_DIR)/Source/portable/GCC/ARM_CM4F

# Setup hardware using defines
CFLAGS += -D USE_STDPERIPH_DRIVER -D STM32F40_41xxx -D HSI_VALUE=16000000ul -D HSE_VALUE=8000000ul

CPPFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti -std=c++1y

LDFLAGS = -Tstm32_flash.ld -Wl,-Map,$(BUILD_DIR)/cdeeco++.map $(CFLAGS)

# Add startup file to build
OBJS = $(patsubst %.c,build/%.o,$(SRCS))
OBJS := $(patsubst %.cpp,build/%.o,$(OBJS))
OBJS := $(patsubst %.s,build/%.o,$(OBJS))

DEPS = $(patsubst %.c,build/%.d,$(SRCS))
DEPS := $(patsubst %.cpp,build/%.d,$(DEPS))
DEPS := $(patsubst %.s,,$(DEPS))

EXAMPLE_OBJS = $(patsubst %.c,build/%.o,$(EXAMPLE_SRCS))
EXAMPLE_OBJS := $(patsubst %.cpp,build/%.o,$(EXAMPLE_OBJS))
EXAMPLE_OBJS := $(patsubst %.s,build/%.o,$(EXAMPLE_OBJS))

EXAMPLE_DEPS = $(patsubst %.c,build/%.d,$(EXAMPLE_SRCS))
EXAMPLE_DEPS := $(patsubst %.cpp,build/%.d,$(EXAMPLE_DEPS))
EXAMPLE_DEPS := $(patsubst %.s,,$(EXAMPLE_DEPS))


build/%.o: %.c
	${CC} $(CFLAGS) -c -o "$@" "$<"

build/%.o: %.cpp
	${CXX} $(CPPFLAGS) -c -o "$@" "$<"

build/%.o: %.s
	${CC} $(CFLAGS) -c -o "$@" "$<"

build/%.dep: %.cpp
	${CXX} -M $(CPPFLAGS) "$<" > "$@"

.PHONY: init all

all: init $(BUILD_DIR)/$(PROJ_NAME).a $(BUILD_DIR)/$(PROJ_EXAMPLE_NAME).hex

init:
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)/drivers
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)/cdeeco
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)/wrappers
	mkdir -p $(BUILD_DIR)/$(EXAMPLE_SRC_DIR)
	mkdir -p $(BUILD_DIR)/$(PERIPH_DIR)/src
	mkdir -p $(BUILD_DIR)/$(FREERTOS_DIR)/Source
	mkdir -p $(BUILD_DIR)/$(FREERTOS_DIR)/Source/portable/MemMang
	mkdir -p $(BUILD_DIR)/$(FREERTOS_DIR)/Source/portable/GCC/ARM_CM4F
	mkdir -p ${BUILD_DIR}/$(CMSIS_DEVICE_DIR)/Source/Templates/TrueSTUDIO

$(BUILD_DIR)/$(PROJ_NAME).a: $(OBJS)
	${AR} cr "$@" $(OBJS)
	
$(BUILD_DIR)/$(PROJ_EXAMPLE_NAME).elf: $(EXAMPLE_OBJS)
	$(CXX) $(LDFLAGS) -o "$@" $(EXAMPLE_OBJS) $(BUILD_DIR)/$(PROJ_NAME).a

$(BUILD_DIR)/$(PROJ_EXAMPLE_NAME).hex: $(BUILD_DIR)/$(PROJ_EXAMPLE_NAME).elf
	${OBJCOPY} -O ihex "$<" "$@"
	${SIZE} --format=berkeley "$@"

clean:
	rm -rf build
	
openocd:
	${OPENOCD} -f interface/stlink-v2.cfg -f target/stm32f4x_stlink.cfg

flash: $(BUILD_DIR)/$(PROJ_EXAMPLE_NAME).hex
	${OPENOCD} -f board/stm32f4discovery.cfg -c "program $(BUILD_DIR)/$(PROJ_EXAMPLE_NAME).elf verify reset"

-include $(DEPS)