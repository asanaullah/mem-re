# **Project Mem-Re**
 **Mem**ory controllers for the **Re**search community

## Objective
To develop HDL based memory controllers that are, to the greatest extent possible, i) open source, ii) FPGA vendor agnostic, iii) simple to modify, and iv) able to easily close timing after controller modifications. 

**Note:** Mem-Re is part of **Project Morpheus**, which is an effort to build an open source reconfigurable hardware operating system (analogous to Linux in the software world). 


### Why to the greatest extent possible and not fully open source or portable etc?
The design is likely to have some primitives, which are typically proprietary ASIC chips embedded within the FPGA fabric. Examples of these primitives include PLLs, SERDES units, DDR signalling, global clock buffers, phasers and tristate logic. These primitives are chip architecture specific, and can even differ across FPGAs from the same vendor. Use of the primitives is important for a number of reasons such as: 

1. High speed interfaces typically require the FPGA to operate at frequencies significantly higher than what the fabric can easily close timing for. While FPGA technologies have continued to improve and support faster internal clocks, so have the speeds of external interfaces since we consistently target higher performance to keep pace with growing requirements/constraints of workloads.  As a result, this disparity between frequencies was, is and will likely continue to be a problem for FPGAs. By using ASICs embedded within the FPGA fabric, we can offload the high frequency data path to the dedicated circuit and close timing. 

2. While HDL is a low level assembly-like language, it is still an abstraction of a physical circuit. And as with almost all abstractions, they trade off expressibility for programmability. As a result, there are certain circuits which cannot be effectively expressed within HDL; a shortcoming addressed through use of primitives. 

3. Even if a circuit is expresable and can be built in a stable manner within the FPGA fabric, if the primitive is common enough across FPGAs, it is usually a good idea to provide the option of using either the primitive or its HDL equivalent. This is because the latter would i) consume the already limited reconfigurable fabric (making it difficult to place and route designs), ii) unlikely achieve the same levels of performance, and iii) have a relatively higher energy cost. 

### What will constitute as the greatest extent possible?
Our goal is to:
1. Use as much basic HDL as possible. Anything that doesn’t deal with clock generation or a high frequency DDR data path will likely be HDL code.
2. Provide loose coupling, appropriate interfaces and compilation flags for facilitating users in replacing primitives in the default design with equivalent circuits. 

3. Minimizing, but not completely eliminating, code reuse. Striking the right balance between redundancy and lines-of-code is important for ensuring a design is both readable and easy to modify - High code reuse can sometimes make modifications difficult since a change affects all instantiations of the circuit, and not just the target part of the controller. 


## Motivation


## Target Hardware

The initial memory we are targeting is the DDR3 controller due its simplicity versus the newer DDR4 and upcoming (at the time of writing) DDR5.

The initial board we are targeting is the Digilent Arty A35, which has a Xilinx 7-series chip. 


## Progress

- [x] a
- [ ] b
- [ ] b

## Some Links:

[PLL and Differential Signalling demo using a fully open source toolchain for the Icestorm FPGA](https://github.com/mattvenn/fpga-lvds-ddr)

[DDR3 Memory Interface on Xilinx Zynq SOC – Free Software Compatible](
https://blog.elphel.com/2014/06/ddr3-memory-interface-on-xilinx-zynq-soc-free-software-compatible/)

[OpenArty Initial Effort (eventually used Xilinx MIG)](https://opencores.org/projects/wbddr3)



