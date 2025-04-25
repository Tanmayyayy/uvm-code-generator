# 🛠️ UVM Code Generator

This project is an **automated UVM (Universal Verification Methodology) testbench generator** built using **Perl and TCL**. It automates the creation of a simulation-ready UVM testbench for any given **SystemVerilog (.sv)** RTL module.

---

## 🚀 Features

- ✅ Generates full UVM testbench structure:
  - Sequence item
  - Driver, Monitor, Sequencer
  - Agent, Environment, and Test
  - Interface and Top module
- ✅ TCL GUI for user-friendly automation
- ✅ Simulation-ready output for **ModelSim**
- ✅ Compatible with any SystemVerilog module
- ✅ Supports UVM 1.2-based flow

---

## 🔄 Workflow

1. **Place Your RTL Module**
   - Copy your `.sv` file (e.g., `adder.sv`) into the `rtl/` directory.

2. **Set Up UVM Package (Required)**
   - Ensure the `uvm-1.2` package is available in your working directory or accessible path.
   - You can download UVM 1.2 from:  
     👉 https://accellera.org/downloads/standards/uvm
   - Recommended structure:
     ```
     uvm_code_generator/
     ├── uvm-1.2/
     │   └── src/
     │       └── uvm_pkg.sv
     ```

3. **Launch GUI**
   - Use Vivado (or any TCL-compatible tool) to run:
     ```
     vivado -mode gui -source run_gui.tcl
     ```

4. **Generate Testbench**
   - Choose the input `.sv` file and generate UVM components using the GUI.
   - Output files will be saved inside the `tb/` directory.

5. **Run Simulation**
   - Open **ModelSim**, and simulate using the generated `run.do` script:
     ```sh
     vsim -do run.do
     ```

---

## 📁 Folder Structure

