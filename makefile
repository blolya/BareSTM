#driver dir
DRIVER = ./driver

# path to STM32F103 standard peripheral library
STD_PERIPH_LIBS ?= $(DRIVER)/STM32F10x_StdPeriph_Lib_V3.5.0

# debug path
DEBUG = ./debug

# config files
CONFIGS = ./config

# list of source files
SOURCES  = ./src/main.c
SOURCES += $(STD_PERIPH_LIBS)/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/system_stm32f10x.c
SOURCES += $(STD_PERIPH_LIBS)/Libraries/STM32F10x_StdPeriph_Driver/src/stm32f10x_rcc.c
SOURCES += $(STD_PERIPH_LIBS)/Libraries/STM32F10x_StdPeriph_Driver/src/stm32f10x_gpio.c
SOURCES += $(STD_PERIPH_LIBS)/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/TrueSTUDIO/startup_stm32f10x_md.s

# name for output binary files
PROJECT ?= $(shell basename $(CURDIR))

# compiler, objcopy (should be in PATH)
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

# path to st-flash (or should be specified in PATH)
ST_FLASH ?= st-flash

# specify compiler flags
CFLAGS  = -g -O2 -Wall
CFLAGS += -T$(STD_PERIPH_LIBS)/Project/STM32F10x_StdPeriph_Template/TrueSTUDIO/STM3210B-EVAL/stm32_flash.ld
CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -DSTM32F10X_MD -DUSE_STDPERIPH_DRIVER
CFLAGS += -Wl,--gc-sections
CFLAGS += -I.
CFLAGS += -I$(STD_PERIPH_LIBS)/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/
CFLAGS += -I$(STD_PERIPH_LIBS)/Libraries/CMSIS/CM3/CoreSupport
CFLAGS += -I$(STD_PERIPH_LIBS)/Libraries/STM32F10x_StdPeriph_Driver/inc
CFLAGS += -I$(CONFIGS)

OBJS = $(SOURCES:.c=.o)

all: $(DEBUG) $(DRIVER) $(DEBUG)/$(PROJECT).elf

# compile
$(DEBUG)/$(PROJECT).elf: $(SOURCES)
	$(CC) $(CFLAGS) $^ -o $@
	$(OBJCOPY) -O ihex $(DEBUG)/$(PROJECT).elf $(DEBUG)/$(PROJECT).hex
	$(OBJCOPY) -O binary $(DEBUG)/$(PROJECT).elf $(DEBUG)/$(PROJECT).bin

# create debug directory
debug:
	mkdir -p $@
# create driver directory
driver:
	mkdir -p $@

# remove binary files
clear:
	rm $(DEBUG)/*.bin $(DEBUG)/*.elf $(DEBUG)/*.hex

erase:
	$(ST_FLASH) erase

# flash
flash:
	$(ST_FLASH) write $(DEBUG)/$(PROJECT).bin 0x08000000
