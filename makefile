
VPATH = src/
BUILD_DIR = build
SOURCE = src


your_sorter: $(BUILD_DIR) $(BUILD_DIR)/read.o $(BUILD_DIR)/asmsort.o
	ld $(BUILD_DIR)/read.o -o your_sorter

$(BUILD_DIR)/asmsort.o: $(SOURCE)/asmsort.asm
	as $(SOURCE)/asmsort.asm -o $(BUILD_DIR)/asmsort.o

$(BUILD_DIR)/read.o: $(SOURCE)/read.asm
	as $(SOURCE)/read.asm -o $(BUILD_DIR)/read.o

$(BUILD_DIR)/stringtoint.o: $(SOURCE)/stringtoint.asm
	as $(SOURCE)/stringtoint.asm -o $(BUILD_DIR)/stringtoint.o

$(BUILD_DIR):
	test -d $(BUILD_DIR) || mkdir $(BUILD_DIR)

