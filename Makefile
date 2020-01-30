#########################################################################
# Arduino Makefile
#
# Requirements: Arduino version 1.5+ installed and in your $PATH
#
# Usage:
# export BOARD=arduino:avr:uno && PORT=/dev/ttyACM0
# make
# make upload
# make monitor
#
# Or uncomment a board/port below to always use a specific board for
# this project
#########################################################################

#BOARD = arduino:avr:diecimila:cpu=atmega328 # Arduino Duemilanove
#BOARD = arduino:avr:mega:cpu=atmega1280     # Arduino Mega
#BOARD = arduino:avr:uno                     # Arduino Uno
#BOARD = arduino:avr:nano:cpu=atmega328      # Arduino Nano

#BOARD = esp8266:esp8266:nodemcuv2:baud=460800                          # NodeMCU/ESP8266
#BOARD = esp32:esp32:esp32:CPUFreq=240,FlashMode=qio,UploadSpeed=921600 # ESP32

#PORT = /dev/ttyUSB0
#PORT = /dev/ttyACM0

#########################################################################

SKETCH_FILE   = $(shell ls -1 $(CURDIR)/*.ino | head -n1)
SKETCH_NAME   = $(shell basename $(SKETCH_FILE:.ino=))
MONITOR_SPEED = $(shell egrep 'Serial.begin\([0-9]+\)' $(SKETCH_FILE) | head -n1 | perl -pE 's/\D+//g')
BUILD_DIR     = /tmp/arduino-build-$(SKETCH_NAME)/

ifndef BOARD
$(error BOARD variable is not set, unable to continue)
endif

default: display_config
	arduino --verify --pref build.path=$(BUILD_DIR) --port $(PORT) --board $(BOARD) $(SKETCH_FILE)

upload: display_config
	arduino --upload --pref build.path=$(BUILD_DIR) --port $(PORT) --board $(BOARD) $(SKETCH_FILE)

monitor:
	screen $(PORT) $(MONITOR_SPEED)

binary: default
	@echo
	cp $(BUILD_DIR)/$(SKETCH_NAME).ino.bin $(CURDIR)/$(SKETCH_NAME).bin
	@echo
	@echo "Binary: $(CURDIR)/$(SKETCH_NAME).bin"

clean:
	$(RM) $(BUILD_DIR)

display_config:
	@echo "BOARD         : $(BOARD)"
	@echo "PORT          : $(PORT)"
	@echo "MONITOR SPEED : $(MONITOR_SPEED)"
	@echo "SKETCH NAME   : $(SKETCH_NAME)"
	@echo "SKETCH FILE   : $(SKETCH_FILE)"
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
