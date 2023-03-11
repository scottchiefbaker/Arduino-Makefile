# Arduino Makefile

Arduino `Makefile` to simplify testing and uploading Arduino sketches from the command line.

## Requirements

[ArduinoCLI](https://arduino.github.io/arduino-cli/) installed and in your `$PATH`.

## Installation

Place this `Makefile` in your sketch directory.

## Configuration

`export BOARD=arduino:avr:uno && export PORT=/dev/ttyACM0`

or

Edit the `Makefile` itself and configure the `BOARD` and `PORT` options.

## Usage

1. Verify code compiles: `make`
2. Upload to board: `make upload`
3. Open serial monitor: `make monitor`

## Troubleshooting

Verify your code compiles and uploads via the ArduinoIDE. Next verify that it works with the ArduinoCLI. If it does not work with the vanilla `arduino-cli` it will not work with this `Makefile`.
