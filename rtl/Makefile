#PACKAGE = tq144:4k
#DEVICE = hx8k
#PIN_DEF = 8k.pcf
SHELL := /bin/bash # Use bash syntax
SEED = 10
PROJECT = vga_clock
PI_ADDR = pi@fpga.local
FOMU_FLASH = ~/fomu-flash/fomu-flash
LOG_LUTS = ~/work/fpga/logLUTs/logLUTs.py 

DEVICE = up5k
PIN_DEF = icebreaker.pcf
PACKAGE = sg48

# target freq for vga panel
FREQ = 31.5

all: $(LISTINGS) $(PROJECT).bin

BUILD_DIR = ./
SOURCES = digit.v VgaSyncGen.v fontROM.v button_pulse.v vga_clock.v top.v

# $@ The file name of the target of the rule.rule
# $< first pre requisite
# $^ names of all preerquisites
LISTINGS = digit_index.hex col_index.hex

CFLAGS = -O3 -Iobj_dir -I/usr/share/verilator/include

LDFLAGS = -lSDL2 -lSDL2_image

logluts:
	$(LOG_LUTS) --add-commit --git ../

plotluts::
	$(LOG_LUTS) --plot --git ../

$(LISTINGS): ./gen_indexes.py
	python3 ./gen_indexes.py

# rules for building the json
%.json: $(SOURCES) $(LISTINGS)
	yosys -l yosys.log -DSYNTH -p 'synth_ice40 -top top -json $(PROJECT).json' $(SOURCES)

%.asc: %.json $(ICEBREAKER_PIN_DEF) 
	nextpnr-ice40 -l nextpnr.log --seed $(SEED) --freq $(FREQ) --package $(PACKAGE) --$(DEVICE) --asc $@ --pcf $(PIN_DEF) --json $<

gui: $(PROJECT).json $(ICEBREAKER_PIN_DEF) 
	nextpnr-ice40 --gui -l nextpnr.log --seed $(SEED) --freq $(FREQ) --package $(PACKAGE) --$(DEVICE) --asc $(PROJECT).asc --pcf $(PIN_DEF) --json $(PROJECT).json

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

gl-debug:
	echo $(PDK_PATH)
	iverilog -o test.out -DSIM -DFUNCTIONAL -DDEBUG -I $(PDK_ROOT)/sky130A/ vga_clock.lvs.powered.v top_gl_tb.v
	vvp test.out -fst

debug-digit:
	iverilog -o digit.out  digit.v digit_tb.v -DDEBUG
	vvp digit.out -fst
	gtkwave digit.vcd digit.gtkw

obj_dir/Vvga_clock.h : $(SOURCES) $(LISTINGS) ../sim/fb_verilator.cpp
	verilator --cc vga_clock.v --exe ../sim/fb_verilator.cpp -CFLAGS "$(CFLAGS)" -LDFLAGS "$(LDFLAGS)"

verilator: obj_dir/Vvga_clock.h
	cd obj_dir && make -f Vvga_clock.mk

clean:
	rm -f ${PROJECT}.json ${PROJECT}.asc ${PROJECT}.bin *log $(LISTINGS)
	rm -rf obj_dir

#secondary needed or make will remove useful intermediate files
.SECONDARY:
.PHONY: all clean
