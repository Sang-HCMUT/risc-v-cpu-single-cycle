🧠 **RISC-V 32-bit Single-Cycle CPU**

This project implements a simple 32-bit RISC-V CPU based on the RV32I instruction set architecture using a single-cycle datapath. Designed and simulated using SystemVerilog, the CPU is synthesized and tested on an FPGA platform.

---

✅ Features

- **Instruction Set**: RV32I (Base Integer Instruction Set)
- **Architecture**: Single-Cycle (all instructions executed in 1 clock cycle)
- **Design Language**: SystemVerilog
- **Target Platform**: FPGA (tested with IO interaction)
- **Simulation**: Functional simulation on Linux environment
- **Synthesis**: Timing optimized for FPGA deployment

---

📁 Project Structure


riscv-cpu-single-cycle/
├── src/        # SystemVerilog source files
├── testbench/  # Testbench files for simulation
├── scripts/    # Simulation & synthesis scripts
├── docs/       # Design documentation and block diagrams
└── README.md   # Project descriptionn

---

⚙️ How to Run

🔧 1. Simulation
Example with Icarus Verilog (or use your preferred simulator)
iverilog -o cpu_tb testbench/cpu_tb.v src/*.sv
vvp cpu_tb

🔩 2. Synthesis (on FPGA)
Open your FPGA tool (e.g., Quartus or Vivado)

Add all source files from src/

Run synthesis and place & route

Connect I/O peripherals to verify functionality

🎯 Goals

Practice RISC-V architecture fundamentals
Understand datapath & control unit design
Learn HDL synthesis & timing optimization
Build a base for multi-cycle or pipelined extensions



   
