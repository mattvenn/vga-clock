#PACKAGE = tq144:4k
#DEVICE = hx8k
#PIN_DEF = 8k.pcf
SHELL := /bin/bash # Use bash syntax
SEED = 10
PROJECT = vga_clock
PI_ADDR = pi@fpga.local
FOMU_FLASH = ~/fomu-flash/fomu-flash

DEVICE = up5k
PIN_DEF = icebreaker.pcf
PACKAGE = sg48

PWM_WIDTH = 6

all: $(PROJECT).bin

BUILD_DIR = ./
SOURCES = digit.v VgaSyncGen.v fontROM.v top.v

# $@ The file name of the target of the rule.rule
# $< first pre requisite
# $^ names of all preerquisites

# rules for building the json
%.json: $(SOURCES)
#	yosys -l yosys.log -p 'synth_ice40 -chparam PWM_WIDTH $(PWM_WIDTH) -top top -json $(PROJECT).json' $(SOURCES)
	yosys -l yosys.log -p 'synth_ice40 -top top -json $(PROJECT).json' $(SOURCES)

%.asc: %.json $(ICEBREAKER_PIN_DEF) 
	nextpnr-ice40 -l nextpnr.log --seed $(SEED) --freq 20 --package $(PACKAGE) --$(DEVICE) --asc $@ --pcf $(PIN_DEF) --json $<

gui: $(PROJECT).json $(ICEBREAKER_PIN_DEF) 
	nextpnr-ice40 --gui -l nextpnr.log --seed $(SEED) --freq 20 --package $(PACKAGE) --$(DEVICE) --asc $(PROJECT).asc --pcf $(PIN_DEF) --json $(PROJECT).json

# bin, for programming
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.asc
	icepack $< $@

#prog-fpga: $(BUILD_DIR)/$(PROJECT).bin
#	scp $< $(PI_ADDR):/tmp/$(PROJECT).bin
#	ssh $(PI_ADDR) "sudo $(FOMU_FLASH) -f /tmp/$(PROJECT).bin"
#
#prog-flash: $(BUILD_DIR)/$(PROJECT).bin
#	scp $< $(PI_ADDR):/tmp/$(PROJECT).bin
#	ssh $(PI_ADDR) "sudo $(FOMU_FLASH) -w /tmp/$(PROJECT).bin; sudo $(FOMU_FLASH) -r"

prog: $(PROJECT).bin
	iceprog $<

debug:
	iverilog -o test.out  $(SOURCES) top_tb.v -DDEBUG
	vvp test.out -fst
	gtkwave test.vcd test.gtkw

debug-digit:
	iverilog -o digit.out  digit.v digit_tb.v -DDEBUG
	vvp digit.out -fst
	gtkwave digit.vcd digit.gtkw

clean:
	rm -f ${PROJECT}.json ${PROJECT}.asc ${PROJECT}.bin *log

#secondary needed or make will remove useful intermediate files
.SECONDARY:
.PHONY: all clean
