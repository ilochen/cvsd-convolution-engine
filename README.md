# Streaming convolution engine

This NTU CVSD project accepts four unsigned image bytes per transfer, decodes convolution settings embedded in the pixels’ least significant bits, and writes up to four addressed output pixels in parallel. The 64 × 64 image is distributed across eight 512 × 8 banks. The control sequence loads the image, loads signed filter weights, executes convolution, then signals completion.

## Datapath

Each of the four processing elements computes a 3 × 3 dot product with nine pipelined multipliers. Border selectors inject zeros when a tap falls outside the frame. Separate addresses for the outer bank groups accommodate window crossings. The signed sum is scaled, rounded using bit 6, clamped below at zero and above at 255. The barcode selects stride and dilation; special output transfers report the decoded settings before filter loading.

## Run the RTL

Install Verilator 5 with a C++ toolchain and GNU Make. From the repository root:

```sh
make test CASE=tb1
make test-all
```

The four supplied regression cases cover stride/dilation combinations (1,1), (1,2), (2,1), and (2,2). Each case sends the original image and weights and compares every output address against its golden frame, 4,096 pixels at stride 1 or 1,024 at stride 2. A timeout, data mismatch or interface violation fails the test.

## Files

- `rtl/core.v` contains the submitted controller, bank mapping, PE array and PE arithmetic.
- `tests/frame_tb.sv` adapts the supplied testbench for portable RTL simulation. `tests/PATTERNS/` contains the four vectors it uses.
- `tests/sim_cells.sv` supplies independently written functional SRAM and registered multiplier models. They support behavioral simulation; physical timing and power require authorized technology views.
- `constraints/interface.sdc` records the 3.4 ns target and I/O assumptions. Select the appropriate operating corner and library in your authorized synthesis environment.

All four golden frames and protocol checks passed locally under Verilator 5.052. These runs establish functional behavior for the supplied cases only. The historical submission lists a 3.4 ns clock period; this is distinct from a new timing signoff.
