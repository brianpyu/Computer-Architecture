# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./PipelinedCPU.sv"
vlog "./regfile.sv"
vlog "./mux32_1.sv"
vlog "./decoder_5to32.sv"
vlog "./carryLookahead_adder.sv"
vlog "./datamem.sv"
vlog "./instructmem.sv"
vlog "./math.sv"
vlog "./alu.sv"
vlog "./D_FF.sv"
vlog "./control.sv"
vlog "./setFlags.sv"
vlog "./updateRegFile.sv"
vlog "./updatePC.sv"
vlog "./ForwardingUnit.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work PipelinedCPU_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
