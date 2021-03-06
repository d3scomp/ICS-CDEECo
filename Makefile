# Binaries will be generated with this name (.elf, .bin, .hex, etc)
PROJ_ICS_NAME=ics
PROJ_VEHICLE_NAME=vehicle

BUILD_DIR=build
SRC_DIR=src
CDEECO_DIR=cdeeco
CDEECO_LIB=${CDEECO_DIR}/build/cdeeco++.a

DRIVERS_DIR=${CDEECO_DIR}/src/drivers
FREERTOS_DIR=${CDEECO_DIR}/FreeRTOS
CMSIS_DIR=${CDEECO_DIR}/STM32F4xx_DSP_StdPeriph_Lib/Libraries/CMSIS
CMSIS_DEVICE_DIR=${CMSIS_DIR}/Device/ST/STM32F4xx
PERIPH_DIR=${CDEECO_DIR}/STM32F4xx_DSP_StdPeriph_Lib/Libraries/STM32F4xx_StdPeriph_Driver

OPENOCD=openocd

# Example project
SRCS += ${SRC_DIR}/SpeedExchange.cpp
SRCS += ${SRC_DIR}/MrfRadio.cpp
SRCS += ${SRC_DIR}/ICSUtils.cpp

ICS_SRCS += ${SRCS}
ICS_SRCS += ${SRC_DIR}/ICS.cpp
ICS_SRCS += ${SRC_DIR}/ics_app.cpp

VEHICLE_SRCS += ${SRCS}
VEHICLE_SRCS += ${SRC_DIR}/Vehicle.cpp
VEHICLE_SRCS += ${SRC_DIR}/vehicle_app.cpp

# Normally you shouldn't need to change anything below this line!
#######################################################################################

CC=armv7m-hardfloat-eabi-gcc
CXX=armv7m-hardfloat-eabi-g++
OBJCOPY=armv7m-hardfloat-eabi-objcopy
SIZE=armv7m-hardfloat-eabi-size
AR=armv7m-hardfloat-eabi-ar

CFLAGS  = -mcpu=cortex-m4 -g -Os -Wall -pipe
CFLAGS += -mlittle-endian -mthumb -mthumb-interwork -mfloat-abi=hard -mfpu=fpv4-sp-d16 -MMD -MP -fsingle-precision-constant
CFLAGS += -I$(CDEECO_DIR)
CFLAGS += -I$(CDEECO_DIR)/src
CFLAGS += -I$(CDEECO_DIR)/src/wrappers
CFLAGS += -I$(DRIVERS_DIR)
CFLAGS += -I${CMSIS_DEVICE_DIR}/Include
CFLAGS += -I$(CMSIS_DIR)/Include
CFLAGS += -I$(PERIPH_DIR)/inc
CFLAGS += -I$(FREERTOS_DIR)/Source/include
CFLAGS += -I$(FREERTOS_DIR)/Source/portable/GCC/ARM_CM4F

# Setup hardware using defines
CFLAGS += -D USE_STDPERIPH_DRIVER -D STM32F40_41xxx -D HSI_VALUE=16000000ul -D HSE_VALUE=8000000ul

CPPFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti -std=c++1y

LDFLAGS = -T${CDEECO_DIR}/stm32_flash.ld -Wl,-Map,$(BUILD_DIR)/cdeeco++.map $(CFLAGS)

# Add startup file to build
ICS_OBJS = $(patsubst %.c,build/%.o,$(ICS_SRCS))
ICS_OBJS := $(patsubst %.cpp,build/%.o,$(ICS_OBJS))
ICS_OBJS := $(patsubst %.s,build/%.o,$(ICS_OBJS))

ICS_DEPS = $(patsubst %.c,build/%.d,$(ICS_SRCS))
ICS_DEPS := $(patsubst %.cpp,build/%.d,$(ICS_DEPS))
ICS_DEPS := $(patsubst %.s,,$(ICS_DEPS))

VEHICLE_OBJS = $(patsubst %.c,build/%.o,$(VEHICLE_SRCS))
VEHICLE_OBJS := $(patsubst %.cpp,build/%.o,$(VEHICLE_OBJS))
VEHICLE_OBJS := $(patsubst %.s,build/%.o,$(VEHICLE_OBJS))

VEHICLE_DEPS = $(patsubst %.c,build/%.d,$(VEHICLE_SRCS))
VEHICLE_DEPS := $(patsubst %.cpp,build/%.d,$(VEHICLE_DEPS))
VEHICLE_DEPS := $(patsubst %.s,,$(VEHICLE_DEPS))


build/%.o: %.c
	${CC} $(CFLAGS) -c -o "$@" "$<"

build/%.o: %.cpp
	${CXX} $(CPPFLAGS) -c -o "$@" "$<"

build/%.o: %.s
	${CC} $(CFLAGS) -c -o "$@" "$<"

build/%.dep: %.cpp
	${CXX} -M $(CPPFLAGS) "$<" > "$@"

.PHONY: init all

all: init $(BUILD_DIR)/$(PROJ_ICS_NAME).hex $(BUILD_DIR)/$(PROJ_VEHICLE_NAME).hex

init:
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)

${CDEECO_LIB}: 
	$(MAKE) -C ${CDEECO_DIR}
	
$(BUILD_DIR)/$(PROJ_ICS_NAME).elf: $(ICS_OBJS) ${CDEECO_LIB}
	$(CXX) $(LDFLAGS) -o "$@" $?
	
$(BUILD_DIR)/$(PROJ_VEHICLE_NAME).elf: $(VEHICLE_OBJS) ${CDEECO_LIB}
	$(CXX) $(LDFLAGS) -o "$@" $?

%.hex: %.elf
	${OBJCOPY} -O ihex "$<" "$@"
	${SIZE} --format=berkeley "$@"

clean:
	rm -rf build
	$(MAKE) -C ${CDEECO_DIR} clean
	
	
openocd:
	${OPENOCD} -f interface/stlink-v2.cfg -f target/stm32f4x_stlink.cfg

flash-ics: $(BUILD_DIR)/$(PROJ_ICS_NAME).hex
	${OPENOCD} -f board/stm32f4discovery.cfg -c "program $(BUILD_DIR)/$(PROJ_ICS_NAME).elf verify reset"
	
flash-vehicle: $(BUILD_DIR)/$(PROJ_VEHICLE_NAME).hex
	${OPENOCD} -f board/stm32f4discovery.cfg -c "program $(BUILD_DIR)/$(PROJ_VEHICLE_NAME).elf verify reset"

-include $(DEPS)