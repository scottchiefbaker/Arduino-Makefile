# Arduino Makefile

Arduino `Makefile` to simplify testing and uploading code at the CLI

## Requirements

Arduino version 1.5+ installed and in your `$PATH`

## Installation

Place this `Makefile` in your sketch directory

## Configuration

`export BOARD=arduino:avr:uno && PORT=/dev/ttyACM0`

or

Edit the `Makefile` itself and configure the `BOARD` and `PORT` options

## Usage

1. Verify code compiles: `make`
2. Upload to board: `make upload`
3. Open serial monitor: `make monitor`

## Troubleshooting

Verify your code compiles and uploads via the official Arduino IDE. This `Makefile` is a wrapper around the command line interface of the official Arduino IDE. If it doesn't work in the IDE it won't work with this `Makefile`.
