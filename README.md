#Project: Mem-Re
##Memory controllers for the Research community

###Objective
To develop HDL based memory controllers that are, to the GET (Greatest Extent Possible), i) open source, ii) FPGA vendor agnostic, iii) simple to modify, and iv) able to easily close timing after controller modifications. 

Note: Mem-Re is part of Project Morpheus, which is an effort to build an open source reconfigurable hardware operating system (analogous to Linux in the software world). 


###Why Greatest Extent Possible?
The design is likely to have some primitives, which are typically ASIC chips embedded within the FPGA fabric. Examples of these primitives include PLLs, SERDES units, DDR signalling, global clock buffers, phasers and tristate logic. These primitives are chip architecture specific, and can even differ across FPGAs from the same vendor. Use of the primitives is important for a number of reasons such as: 

High speed interfaces typically require the FPGA to operate at frequencies significantly higher than what the fabric can easily close timing for. While FPGA technologies have continued to improve and support faster internal clocks, so have the speeds of external interfaces since we consistently target higher performance to keep pace with growing requirements/constraints of workloads.  As a result, this disparity between frequencies was, is and will likely continue to be a problem for FPGAs. By using ASICs embedded within the FPGA fabric, we can offload the high frequency data path to the dedicated circuit and close timing. 

While HDL is a low level assembly-like language, it is still an abstraction of a physical circuit. And as with almost all abstractions, they trade off expressibility for programmability. As a result, there are certain circuits which cannot be effectively expressed within HDL; a shortcoming addressed through use of primitives. 

Even if a circuit is expresable and can be built in a stable manner within the FPGA fabric, if the primitive is common enough across FPGAs, it is usually a good idea to provide the option of using either the primitive or its HDL equivalent. This is because the latter would i) consume the already limited reconfigurable fabric (making it difficult to place and route designs), ii) unlikely achieve the same levels of performance, and iii) have a relatively higher energy cost. 


But that does not mean we will be defaulting to primitives. Our goal is to use as much basic HDL as possible and, in case a primitive is used, to provide appropriate interfaces and compilation flags so that it can be replaced with equivalent primitives/HDL (which are supported on the target chip). 

###Target Hardware

The initial memory we are targeting is the DDR3 controller due its simplicity versus the newer DDR4 and upcoming (at the time of writing) DDR5.

The initial board we are targeting is the Digilent Arty A35, which has a Xilinx 7-series chip. 

###Motivation






Some Links:

PLL and Differential Signalling demo using a fully open source toolchain for the Icestorm FPGA: https://github.com/mattvenn/fpga-lvds-ddr


DDR3 Memory Interface on Xilinx Zynq SOC – Free Software Compatible:
https://blog.elphel.com/2014/06/ddr3-memory-interface-on-xilinx-zynq-soc-free-software-compatible/


OpenArty Initial Effort (eventually used Xilinx MIG):
https://opencores.org/projects/wbddr3
