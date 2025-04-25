#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use File::Copy;

my $sv_file = $ARGV[0];

if (!defined $sv_file || !-e $sv_file) {
    die "Usage: perl generate_uvm.pl <module_file.sv>\n";
}

open(my $fh, '<', $sv_file) or die "Could not open file '$sv_file' $!";

my $module_name;
my @ports;

while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /module\s+(\w+)/) {
        $module_name = $1;
    }
    while ($line =~ /(input|output|inout)\s+(?:logic|bit)?\s*(\[.*?\])?\s*(\w+)/g) {
        push @ports, {
            dir => $1,
            width => $2 || '',
            name => $3
        };
    }
}

close $fh;

mkdir("output") unless -d "output";
copy($sv_file, "output/" . basename($sv_file));

sub write_file {
    my ($filename, $content) = @_;
    open my $out, '>', $filename or die "Cannot open $filename: $!";
    print $out $content;
    close $out;
}

sub generate_interface {
    my $fname = "output/${module_name}_if.sv";
    my $content = "interface ${module_name}_if();\n";
    foreach my $p (@ports) {
        $content .= "$p->{dir} logic $p->{width} $p->{name};\n";
    }
    $content .= "endinterface\n";
    write_file($fname, $content);
}

sub generate_seq_item {
    my $fname = "output/${module_name}_seq_item.sv";
    my $content = "class ${module_name}_seq_item extends uvm_sequence_item;\n";
    $content .= "  `uvm_object_utils(${module_name}_seq_item)\n";
    foreach my $p (@ports) {
        if ($p->{dir} eq 'input') {
            $content .= "  rand logic $p->{width} $p->{name};\n";
        }
    }
    $content .= "  function new(string name = \"\");\n    super.new(name);\n  endfunction\nendclass\n";
    write_file($fname, $content);
}

sub generate_driver {
    my $fname = "output/${module_name}_driver.sv";
    my $content = "class ${module_name}_driver extends uvm_driver#(${module_name}_seq_item);\n";
    $content .= "  `uvm_component_utils(${module_name}_driver)\n";
    $content .= "  virtual ${module_name}_if vif;\n";
    $content .= "  function new(string name, uvm_component parent);\n    super.new(name, parent);\n  endfunction\n";
    $content .= "  task run_phase(uvm_phase phase);\n    forever begin\n      ${module_name}_seq_item req;\n      seq_item_port.get_next_item(req);\n";
    foreach my $p (@ports) {
        if ($p->{dir} eq 'input') {
            $content .= "      vif.$p->{name} = req.$p->{name};\n";
        }
    }
    $content .= "      seq_item_port.item_done();\n    end\n  endtask\nendclass\n";
    write_file($fname, $content);
}

sub generate_monitor {
    my $fname = "output/${module_name}_monitor.sv";
    my $content = "class ${module_name}_monitor extends uvm_monitor;\n";
    $content .= "  `uvm_component_utils(${module_name}_monitor)\n";
    $content .= "  virtual ${module_name}_if vif;\n";
    $content .= "  function new(string name, uvm_component parent);\n    super.new(name, parent);\n  endfunction\nendclass\n";
    write_file($fname, $content);
}

sub generate_tb {
    my $fname = "output/${module_name}_tb.sv";
    my $content = "module ${module_name}_tb;\n  import uvm_pkg::*;\n  `include \"uvm_macros.svh\"\n\n  ${module_name}_if intf();\n  ${module_name} dut (/* connect ports */);\n\n  initial begin\n    run_test();\n  end\nendmodule\n";
    write_file($fname, $content);
}

sub generate_sequencer {
    my $fname = "output/${module_name}_sequencer.sv";
    my $content = "class ${module_name}_sequencer extends uvm_sequencer#(${module_name}_seq_item);\n";
    $content .= "  `uvm_component_utils(${module_name}_sequencer)\n";
    $content .= "  function new(string name, uvm_component parent);\n    super.new(name, parent);\n  endfunction\nendclass\n";
    write_file($fname, $content);
}

sub generate_agent {
    my $fname = "output/${module_name}_agent.sv";
    my $content = "class ${module_name}_agent extends uvm_agent;\n";
    $content .= "  `uvm_component_utils(${module_name}_agent)\n";
    $content .= "  ${module_name}_driver drv;\n  ${module_name}_monitor mon;\n  ${module_name}_sequencer seqr;\n\n  function new(string name, uvm_component parent);\n    super.new(name, parent);\n  endfunction\n\n  function void build_phase(uvm_phase phase);\n    super.build_phase(phase);\n    drv  = ${module_name}_driver::type_id::create(\"drv\", this);\n    mon  = ${module_name}_monitor::type_id::create(\"mon\", this);\n    seqr = ${module_name}_sequencer::type_id::create(\"seqr\", this);\n  endfunction\nendclass\n";
    write_file($fname, $content);
}

sub generate_env {
    my $fname = "output/${module_name}_env.sv";
    my $content = "class ${module_name}_env extends uvm_env;\n";
    $content .= "  `uvm_component_utils(${module_name}_env)\n";
    $content .= "  ${module_name}_agent agent;\n\n  function new(string name, uvm_component parent);\n    super.new(name, parent);\n  endfunction\n\n  function void build_phase(uvm_phase phase);\n    super.build_phase(phase);\n    agent = ${module_name}_agent::type_id::create(\"agent\", this);\n  endfunction\nendclass\n";
    write_file($fname, $content);
}

sub generate_test {
    my $fname = "output/${module_name}_test.sv";
    my $content = "class ${module_name}_test extends uvm_test;\n";
    $content .= "  `uvm_component_utils(${module_name}_test)\n";
    $content .= "  ${module_name}_env env;\n  ${module_name}_seq_item seq;\n\n  function new(string name, uvm_component parent);\n    super.new(name, parent);\n  endfunction\n\n  function void build_phase(uvm_phase phase);\n    super.build_phase(phase);\n    env = ${module_name}_env::type_id::create(\"env\", this);\n  endfunction\n\n  task run_phase(uvm_phase phase);\n    phase.raise_objection(this);\n    seq = ${module_name}_seq_item::type_id::create(\"seq\");\n    env.agent.seqr.start(seq);\n    #100;\n    phase.drop_objection(this);\n  endtask\nendclass\n";
    write_file($fname, $content);
}

# Generate all components
generate_interface();
generate_seq_item();
generate_driver();
generate_monitor();
generate_tb();
generate_sequencer();
generate_agent();
generate_env();
generate_test();

print "UVM files generated successfully in output/.\n";

