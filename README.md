# sv-sort-system
An 8×8-byte Bubble-Sort Execution Unit in SystemVerilog: datapath, controller FSM, top-level integration, and self-checking testbenches.
# sv-sort-system

This repository contains a fully synthesizable SystemVerilog implementation of an 8×8-byte Bubble-Sort execution unit, exactly following the provided architectural diagram. It includes:

- **`datapath.sv`**  
  Registers A/B, address counters, comparator, zero detectors, and memory write-back logic.

- **`controller.sv`**  
  Mealy/Moore FSM implementing the nested‐loop compare-and-swap sequence per the ASM chart.

- **`ram8.sv`**  
  A simple single-port 8×8-byte RAM with initialization for simulation.

- **`top.sv`**  
  Glue logic instantiating datapath, controller, and RAM; exposes `clk`, `rst`, `s`, and `done`.

- **`tb_datapath.sv`**  
  Self-checking testbench for the datapath: verifies loads, comparison, zero flags, and write-back.

- **`tb_controller.sv`**  
  FSM testbench: exercises both swap and no-swap paths with `$monitor` of all control signals.

- **`tb_sort.sv`**  
  End-to-end testbench: initializes the RAM, pulses `s`, waits for `done`, and prints sorted results.

### How to run

1. **Compile** all `.sv` files together, with Xilinx Vivado:
   ```bash
   vlog datapath.sv controller.sv ram8.sv top.sv tb_datapath.sv tb_controller.sv tb_sort.sv
   vsim tb_sort
   run -all
