# **Project Mem-Re**
SDRAM **Mem**ory controllers for the **Re**search community
Current Version: 0.3.0
## Objective
To develop HDL based SDRAM memory controllers that are, to the greatest extent possible, i) open source, ii) FPGA vendor agnostic, iii) simple to modify, and iv) able to easily close timing after controller modifications. 

**Note:** Mem-Re is part of **Project Morpheus**, which is an effort to build an open source reconfigurable hardware operating system (analogous to Linux in the software world). 


### Why to the greatest extent possible and not fully open source or portable etc?
The design is likely to have some primitives, which are typically proprietary ASIC chips embedded within the FPGA fabric. Examples of these primitives include PLLs, SERDES units, DDR signalling, global clock buffers, phasers and tristate logic. These primitives are chip architecture specific, and can even differ across FPGAs from the same vendor. Use of the primitives is important for a number of reasons such as: 

1. High speed interfaces typically require the FPGA to operate at frequencies significantly higher than what the fabric can easily close timing for. While FPGA technologies have continued to improve and support faster internal clocks, so have the speeds of external interfaces since we consistently target higher performance to keep pace with growing requirements/constraints of workloads.  As a result, this disparity between frequencies was, is and will likely continue to be a problem for FPGAs. By using ASICs embedded within the FPGA fabric, we can offload the high frequency data path to the dedicated circuit and close timing. 

2. While HDL is a low level assembly-like language, it is still an abstraction of a physical circuit. And as with almost all abstractions, they trade off expressibility for programmability. As a result, there are certain circuits which cannot be effectively expressed within HDL; a shortcoming addressed through use of primitives. 

3. Even if a circuit is expresable and can be built in a stable manner within the FPGA fabric, if the primitive is common enough across FPGAs, it is usually a good idea to provide the option of using either the primitive or its HDL equivalent. This is because the latter would i) consume the already limited reconfigurable fabric (making it difficult to place and route designs), ii) unlikely achieve the same levels of performance, and iii) have a relatively higher energy cost. 

### What will constitute as the greatest extent possible?
Our goal is to:
1. Use **as much basic HDL as possible**. Anything that doesn’t deal with clock generation or a high frequency DDR data path will likely be HDL code.
2. **Provide loose circuit coupling, appropriate interfaces and compilation flags** for facilitating users in replacing primitives in the default design with equivalent circuits. 

3. **Minimize, but not completely eliminate, code reuse**. Striking the right balance between redundancy and lines-of-code is important for ensuring a design is both readable and easy to modify - High code reuse can sometimes make modifications difficult since a change affects all instantiations of the circuit, and not just the target part of the controller. 

4. Provide any constraints that help **reduce the effort of closing timing**, provided that the constraints are applicable, with little or no modifications, to most FPGA chips. 


## Motivation
1. **Proprietary IP blocks** only allow a limited number of parameters to be tuned.  As a result, the controller is typically not application specific. To get something that is tuned to a particular application, we either build a custom controller from scratch, or build wrappers for the vendor IP block - neither of which is an efficient approach.  Moreover, even when dealing with general explorations, such as system level research into memory controllers, we hit the same roadblocks since low level access to the data and control paths is typically not possible. Finally, there is the cost of these IP blocks.  

2. **Open source memory controllers** typically suffer from multiple drawbacks. For example, typically these controllers: i) can be difficult to read and understand, ii) are built with a large number of source files and complex hierarchies that substantially increase any effort to modify and/or debug the design,  iii) have only been tested in simulation, iv) lack one or more core features, v) have poor out of box performance and/or resource usage, vi) are not vendor agnostic, and vii) are accompanied with little or no documentation.

3. Through **community** centric growth, we can bridge the gap between proprietary and open source hardware, while simultaneously addressing drawbacks shared by both - similar to how it has been done in the software world. Thus, this project does not aim to provide the best possible solution, but rather aims to provide an efficient and effective platform which enables developers to collaborate towards innovation that outperforms the state of the art. 

## Target Hardware

The initial memory we are targeting is the DDR3 controller due its simplicity versus the newer DDR4 and upcoming (at the time of writing) DDR5.

The initial board we are targeting is the Digilent Arty A35, which has a Xilinx 7-series chip. 

We will be using Verilog HDL in the design. 


## Some Links:

[PLL and Differential Signalling demo using a fully open source toolchain for the Icestorm FPGA](https://github.com/mattvenn/fpga-lvds-ddr)

[DDR3 Memory Interface on Xilinx Zynq SOC – Free Software Compatible](
https://blog.elphel.com/2014/06/ddr3-memory-interface-on-xilinx-zynq-soc-free-software-compatible/)

[OpenArty Initial Effort (eventually used Xilinx MIG)](https://opencores.org/projects/wbddr3)



