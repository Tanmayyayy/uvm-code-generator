#!/usr/bin/perl

use strict;
use warnings;

# Get the module name from the command line argument (passed from TCL script)
my $module_name = $ARGV[0];

# Check if the module name is provided
if (not defined $module_name) {
    die "Error: Module name must be provided as an argument.\n";
}

# Define the path to your Verilog file (using the module name)
my $module_file = "$module_name.sv";  # Assuming module file name matches module_name.sv

# Check if the Verilog file exists
if (!-e $module_file) {
    die "Cannot open file $module_file: No such file or directory\n";
}

# Create output directory based on module name
my $dir = "$module_name\_uvm";
mkdir $dir unless -d $dir;

# --- Sequence Item ---
open my $seq_item_fh, '>', "$dir/sequence_item_$module_name.sv" or die "Cannot open sequence item file: $!";
print $seq_item_fh << "SEQ_ITEM";
`ifndef SEQUENCE_ITEM_$module_name
`define SEQUENCE_ITEM_$module_name

class ${module_name}_seq_item extends uvm_sequence_item;
    `uvm_field_int(a, UVM_ALL_ON)
    `uvm_field_int(b, UVM_ALL_ON)
    `uvm_field_int(sum, UVM_ALL_ON)

    function new(string name = "");
        super.new(name);
    endfunction
endclass

`endif
SEQ_ITEM
close $seq_item_fh;

# --- Driver ---
open my $driver_fh, '>', "$dir/driver_$module_name.sv" or die "Cannot open driver file: $!";
print $driver_fh << "DRIVER";
`ifndef DRIVER_$module_name
`define DRIVER_$module_name

class ${module_name}_driver extends uvm_driver#(${module_name}_seq_item);
    `uvm_component_utils(${module_name}_driver)

    function new(string name = "");
        super.new(name);
    endfunction

    virtual task run();
        // Implement the driver logic here
    endtask
endclass

`endif
DRIVER
close $driver_fh;

# --- Monitor ---
open my $monitor_fh, '>', "$dir/monitor_$module_name.sv" or die "Cannot open monitor file: $!";
print $monitor_fh << "MONITOR";
`ifndef MONITOR_$module_name
`define MONITOR_$module_name

class ${module_name}_monitor extends uvm_monitor;
    `uvm_component_utils(${module_name}_monitor)

    function new(string name = "");
        super.new(name);
    endfunction

    virtual task run();
        // Implement the monitor logic here
    endtask
endclass

`endif
MONITOR
close $monitor_fh;

# --- Environment ---
open my $env_fh, '>', "$dir/env_$module_name.sv" or die "Cannot open environment file: $!";
print $env_fh << "ENV";
`ifndef ENV_$module_name
`define ENV_$module_name

class ${module_name}_env extends uvm_env;
    `uvm_component_utils(${module_name}_env)

    ${module_name}_driver driver;
    ${module_name}_monitor monitor;

    function new(string name = "");
        super.new(name);
    endfunction
endclass

`endif
ENV
close $env_fh;

# --- Agent ---
open my $agent_fh, '>', "$dir/agent_$module_name.sv" or die "Cannot open agent file: $!";
print $agent_fh << "AGENT";
`ifndef AGENT_$module_name
`define AGENT_$module_name

class ${module_name}_agent extends uvm_agent;
    `uvm_component_utils(${module_name}_agent)

    ${module_name}_driver driver;
    ${module_name}_monitor monitor;

    function new(string name = "");
        super.new(name);
    endfunction
endclass

`endif
AGENT
close $agent_fh;

# --- Test ---
open my $test_fh, '>', "$dir/test_$module_name.sv" or die "Cannot open test file: $!";
print $test_fh << "TEST";
`ifndef TEST_$module_name
`define TEST_$module_name

class ${module_name}_test extends uvm_test;
    `uvm_component_utils(${module_name}_test)

    ${module_name}_env env;

    function new(string name = "");
        super.new(name);
    endfunction

    virtual task run_phase(uvm_phase phase);
        // Implement the test logic here
    endtask
endclass

`endif
TEST
close $test_fh;

# --- Top Module ---
open my $top_fh, '>', "$dir/top_$module_name.sv" or die "Cannot open top module file: $!";
print $top_fh << "TOP";
`ifndef TOP_$module_name
`define TOP_$module_name

module top;
    logic clk;
    logic rst_n;
    logic [3:0] a, b;
    logic [3:0] sum;

    // Instantiate UVM environment and other components here
    // Example: ${module_name}_test test_inst;

endmodule

`endif
TOP
close $top_fh;

# --- UVM Agent Configuration File ---
open my $config_fh, '>', "$dir/config_$module_name.sv" or die "Cannot open agent config file: $!";
print $config_fh << "CONFIG";
`ifndef CONFIG_$module_name
`define CONFIG_$module_name

class ${module_name}_config extends uvm_config_db#(${module_name}_seq_item);
    `uvm_component_utils(${module_name}_config)

    function new(string name = "");
        super.new(name);
    endfunction

    // Define config options and methods to load them
endclass

`endif
CONFIG
close $config_fh;

# --- UVM Sequence Class ---
open my $seq_fh, '>', "$dir/sequence_$module_name.sv" or die "Cannot open sequence file: $!";
print $seq_fh << "SEQUENCE";
`ifndef SEQUENCE_$module_name
`define SEQUENCE_$module_name

class ${module_name}_sequence extends uvm_sequence#(${module_name}_seq_item);
    `uvm_component_utils(${module_name}_sequence)

    function new(string name = "");
        super.new(name);
    endfunction

    virtual task body();
        // Implement sequence body for generating stimulus
    endtask
endclass

`endif
SEQUENCE
close $seq_fh;

# Print completion message
print "UVM code generated in directory: $dir\n";
