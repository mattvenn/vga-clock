PDK_ROOT=/home/matt/work/asic-workshop/pdks/
OPEN_LANE=/home/matt/work/asic-workshop/openlane
DESIGN=$(OPEN_LANE)/designs/vga_clock/runs/25-09_11-50/results/magic/vga_clock.gds

docker:
	docker run -it -v $(OPEN_LANE):/openLANE_flow -v $(PDK_ROOT):$(PDK_ROOT) -e PDK_ROOT=$(PDK_ROOT) -u $(id -u $USER):$(id -g $USER) openlane:rc2
	echo "now run ./flow.tcl -design vga_clock"

magic:
	magic -rcfile $(PDK_ROOT)/sky130A/libs.tech/magic/sky130A.magicrc $(DESIGN)
	echo "now ctrl+i outside the design to select all, then x to expand"

klayout:
	klayout -l $(PDK_ROOT)/open_pdks/sky130/klayout/sky130.lyp $(DESIGN)
