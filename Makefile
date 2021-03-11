TARGET_EXEC = program.elf
CC = arm-none-eabi-gcc
CFLAGS = -O0 -g3 -ggdb -c -mcpu=cortex-m0plus -Wextra -Wall -Werror -I include -Wno-unused-variable -Wno-unused-parameter
LDFLAGS = -Tlink.x -nostartfiles
BUILD_DIR = ./build
SRC_DIRS := ./src
SRCS := $(shell find $(SRC_DIRS) -name *.c -or -name *.S)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)


$(BUILD_DIR)/$(TARGET_EXEC): $(OBJS) link.x
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.S.o: %.S
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@


.PHONY: clean flash debugger gdb

clean:
	rm -rf build/

flash: $(BUILD_DIR)/$(TARGET_EXEC)
	cargo flash --chip HT32F52352_48LQFP --elf $(BUILD_DIR)/$(TARGET_EXEC)

debugger:
	cargo embed

gdb:
	gdb --command=debug.gdb $(BUILD_DIR)/$(TARGET_EXEC)

