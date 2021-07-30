# Camera parallel interface (CPI)

this repo contains the the RTL of the uDMA Camera parallel interface, as well as a basic UVM testbench.

the interface supports 8bits and 10bits input data. 

2x8bits input data can be directly encoded to the RGB555 or RGB565 color space or written to the memory.

10bits data can be only acquired and written to the memory (2 10bits pixels per 32bit memory store, halfword aligned)

# Simulation

Bender is used to fetch the required dependencies.

To run a basic simulation follow these steps:

1. checkout all the dependencies with the `make checkout scripts` command and create the compile scripts
2. build the RTL with `make clean build`
3. optimize it, `make opt`
4. run the simulation with `make sim`
5. verify that neither ``UVM_ERRORS`` nor ``UVM_FATALS`` are reported in the modelsim console
