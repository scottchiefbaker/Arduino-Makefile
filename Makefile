#########################################################################
# Arduino Makefile
# https://github.com/scottchiefbaker/Arduino-Makefile
#
# Requirements: arduino-cli installed and in your $PATH
#
# Usage:
# export BOARD=arduino:avr:uno && export PORT=/dev/ttyACM0
# make
# make upload
# make monitor
#
# Or uncomment a board/port below to always use a specific board for
# this project. Alernately you can use a 'board.mk' file to specify
# a board for this project. See board.mk.sample for details
#########################################################################

#BOARD = arduino:avr:diecimila:cpu=atmega328                            # Arduino Duemilanove
#BOARD = arduino:avr:mega:cpu=atmega1280                                # Arduino Mega
#BOARD = arduino:avr:uno                                                # Arduino Uno
#BOARD = arduino:avr:nano:cpu=atmega328                                 # Arduino Nano
#BOARD = esp8266:esp8266:nodemcuv2:baud=460800                          # NodeMCU/ESP8266
#BOARD = esp8266:esp8266:d1_mini:baud=921600                            # Wemos D1 Mini
#BOARD = esp32:esp32:esp32:CPUFreq=240,FlashMode=qio,UploadSpeed=921600 # ESP32

PORT ?= /dev/ttyUSB0
#PORT = /dev/ttyACM0

# For WebOTA: https://github.com/scottchiefbaker/ESP-WebOTA
WEBOTA_URL ?= http://192.168.5.114:8080/webota

#########################################################################

# If there is a board.mk use the variables from that for this project
-include board.mk

SKETCH_FILE   = $(shell find $(CURDIR) -name "*.ino" -type f | sort | head -n1)
SKETCH_DIR    = $(shell dirname $(SKETCH_FILE))
SKETCH_NAME   = $(shell basename $(SKETCH_FILE:.ino=))
MONITOR_SPEED = $(shell grep -P 'Serial.begin\([0-9]+\)' $(SKETCH_FILE) | head -n1 | grep -Po '\d+' | head -n1)
BUILD_DIR     = /tmp/arduino-build-$(SKETCH_NAME)/
BINARY        = $(CURDIR)/$(SKETCH_NAME).bin

# If the SKETCH_FILE == ""
ifeq ($(SKETCH_FILE),)
$(error No sketch found to compile. Sketch file should end in .ino and be in the same directory as Makefile)
endif

# If there is no BOARD set at all
ifndef BOARD
$(error BOARD variable is not set, unable to continue)
endif

# If there is no PORT set at all
ifndef PORT
$(error PORT variable is not set, unable to continue)
endif

###################################################################################
###################################################################################

default: display_config
	arduino-cli compile --fqbn $(BOARD) --port $(PORT) $(SKETCH_DIR) --export-binaries --output-dir $(BUILD_DIR)

upload: display_config
	arduino-cli compile --fqbn $(BOARD) --port $(PORT) $(SKETCH_DIR) --upload

monitor:
	screen $(PORT) $(MONITOR_SPEED)

binary: default
	@echo
	cp $(BUILD_DIR)/$(SKETCH_NAME).ino.bin $(CURDIR)/$(SKETCH_NAME).bin
	@echo
	@echo "Binary: $(BINARY)"

webota_upload: binary
	curl -F "file=@$(BINARY)" $(WEBOTA_URL)

clean:
#	Make sure BUILD_DIR is not an empty string, and then remove it
	test -n "$(BUILD_DIR)" && $(RM) -r $(BUILD_DIR)
	$(RM) $(BINARY)

display_config:
	@echo "BOARD         : $(BOARD)"
	@echo "PORT          : $(PORT)"
	@echo "MONITOR SPEED : $(MONITOR_SPEED)"
	@echo "SKETCH NAME   : $(SKETCH_NAME)"
	@echo "SKETCH FILE   : $(SKETCH_FILE)"
#	@echo "SKETCH DIR    : $(SKETCH_DIR)"
	@echo

#########################################################################
# SPIFFS stuff is for NodeMCU
#########################################################################

MKSPIFFS    = $(shell find ~/.ardui* -type f -name mkspiffs | head -n1)
ESPTOOL     = $(shell find ~/.ardui* -type f -name esptool | head -n1)
ESPTOOL26   = $(shell find ~/.ardui* -type f -name esptool.py | head -n1)
DATADIR     = $(CURDIR)/data/
SPIFFS_IMG  = /tmp/$(SKETCH_NAME).spiffs
# Should be 1028096,  2076672, or  3125248 (1MB, 2MB, or 3MB)
SPIFFS_SIZE = 1028096
# Should be 0x300000 for 1MB, 0x200000 for 2MB, or 0x100000 for 3MB
SPIFFS_ADDR = 0x300000

spiffs:
	@echo Building SPIFFS image
	$(MKSPIFFS) -c $(DATADIR) --page 256 --block 8192 -s $(SPIFFS_SIZE) $(SPIFFS_IMG)
	#$(ESPTOOL) -cd nodemcu -cb 460800 -cp $(PORT) -ca $(SPIFFS_ADDR) -cf $(SPIFFS_IMG)
	$(ESPTOOL26) --baud 460800 --port $(PORT) write_flash $(SPIFFS_ADDR) $(SPIFFS_IMG)
