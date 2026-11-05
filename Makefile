CASE ?= tb1
.PHONY: test test-all
test:
	mkdir -p build/$(CASE)
	verilator --binary --timing -Wno-fatal --top-module testbed -D$(CASE) --Mdir build/$(CASE) rtl/core.v tests/sim_cells.sv tests/frame_tb.sv
	./build/$(CASE)/Vtestbed
test-all:
	@for n in tb1 tb2 tb3 tb4; do $(MAKE) test CASE=$$n || exit 1; done
