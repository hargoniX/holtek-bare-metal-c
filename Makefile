TARGET_EXEC = program.elf
CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld
CFLAGS = -c -g -mcpu=cortex-m0plus -Wextra -Wall -Werror
LDFLAGS = -Tlink.x
BUILD_DIR = ./build
SRC_DIRS := ./src
SRCS := $(shell find $(SRC_DIRS) -name *.c)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)


$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS)
	$(LD) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@


.PHONY: clean flash debugger gdb

clean:
	rm -rf build/

flash:
	cargo flash --chip HT32F52352_48LQFP --elf $(BUILD_DIR)/$(TARGET_EXEC)

debugger:
	cargo embed

gdb:
	gdb --command=debug.gdb $(BUILD_DIR)/$(TARGET_EXEC)

