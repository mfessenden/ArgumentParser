TARGET_NAME         = argparser
BUILD_DIR           = .build
SRC_DIR             = $(ROOT_DIR)/Sources


.PHONY: all

all: clean build

clean:
	@swift build --clean

build:
	@swift build

release:
	@swift build -c release
	cp $(BUILD_DIR)/$(@F)/$(TARGET_NAME) $(HOME)/bin/$(TARGET_NAME)

