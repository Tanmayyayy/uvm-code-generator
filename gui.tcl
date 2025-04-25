package require Tk
wm title . "UVM Generator GUI"

label .l -text "Select your .sv module file:"
pack .l

button .b1 -text "Browse .sv File" -command {
    global filePath
    set filePath [tk_getOpenFile -filetypes {{"SystemVerilog Files" {.sv}}}]
    if {$filePath ne ""} {
        .status configure -text "Selected: $filePath"
    }
}
pack .b1

button .b2 -text "Generate UVM Files" -command {
    global filePath
    if {$filePath eq ""} {
        tk_messageBox -message "Please select a .sv file first!" -icon warning
    } else {
        # Use the Perl command as you intended, assuming perl is in PATH
        set result [exec perl generate_uvm.pl $filePath]
        tk_messageBox -message "Generation complete! Check the output folder." -icon info
    }
}
pack .b2

label .status -text "No file selected"
pack .status
