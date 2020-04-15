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

The initial board we are targeting is the Digilent Arty A35, which has a Xilinx 7-series chip. While the [Nextpnr](https://github.com/daveshah1/nextpnr-xilinx) flow does support this chip, we will be using Vivado (free for this chip) for initial development in order to reduce the debugging effort timeframes. Once we have a working design, we will use it to test the open source tools to determine if they can meet the required performance/timing.

We will be using Verilog HDL in the design.

## Before We Start Coding

### What is a DDR3 controller?

![alt text](https://github.com/asanaullah/mem-re/images/simple_FSM.png "Simple DDR3 Controller FSM")


### Challenges

-Frequency
-Precision (Phases)
-Feedback


### Picking a starting point





### Detailed DDR3 controller states


![alt text](https://github.com/asanaullah/mem-re/images/micron_FSM.png "Micron Testbench Based DDR3 Controller FSM")





### FPGA-DDR3 I/O signals






## And We Begin…
### Version 0.0.1



### Version 0.1.0

#### 3/18 Update 
* Implemented design but state machine unstable at 400MHz (stable at 100MHz). 
* V-1 was working in simulation. 
* V-1 has a single clock (400MHz), single state machine design. 

#### 3/20 Update 
* Tested PLL, DDR and tristate primitives. 
  * Attempt to find manually optimize to reduce critical paths
  * state machine is still unstable at 400MHz. 
* Revised goal is to get it working at a dual frequency (100/400 MHz). 

### Version 0.2

#### 3/23 Update 
* Implemented V-2 where the state machine is driven at 100MHz
* Data output signalling is done at a higher frequency. 
* State machine is now stable and does not glitch.
* Still having difficulties with routing design and generating 400MHz clock.

#### 3/25 Update
* New approach: Try running at 100M/200M
* Verify state machine sequence
* Data will likely be corrupted 
* Tested with manual read/write inputs and a 3 level sanity check 
1. read, write, read
2. read, write, read, reset design, reprogram board, read, write, read
3. read, write, read, power cycle board, reprogram board, read, write, read 
* Results showed that state machine sequence is good.

**Updated git repo**

### Version 0.3

#### 3/27 Update 
* Implemented V-3 with 200M/400M clock and separation of state machine seq/comb logic
* Compromise
  * more code in multiple places now needs to be updated
  * But design is more stable, easier to understand, and timing is easier to visualize
* Real time verification of 100M, 200M and 400M clocks.
* Switched from PLL to Multi mode clock manager (recommended for user clocks).
* Wrote UART based software runtime for better testing.
* V-3 working in Xilinx’s own behavioral simulation. 
* However, still some bugs with reads and writes

#### 3/30 Update
* Bug fixing a data alignment problem. 
* Improved ack/busy signalling.

#### 4/1 Update
* Bugfixes for the host interface - ended up running the UART controller at 200MHz for simplicity and reliability.  Added in extra states for more stability in interfacing the controller logic. 
* Bugfixes for the software runtime - reduced complexity of script for more reliable testing.  

#### 4/3 Update
* Bugfixes to the host interface and software runtime helped reliably test the design
* Some manual optimizations done to reduce slack and failing endpoints.
* Design working! Am able to do 26 writes to different rows on each bank (8x26 today) and then read them afterwards.
* Validated with the three step sanity check approach outlined in the 3/25 update
* Limitations: 
  * requires two write operations before it can be read
    * Otherwise only every alternating byte in the word gets updated
    * Likely due to lack of timing closure
  * Write alignment turned off currently to reduce complexity and eliminate source of error
    * Lowest 2 bytes of write data copied throughout the word
  * Only works for certain rows
    * The simulation model used to build the design is generic (12 vs 13 pins),  and so this limitation will likely require updating the addressing logic.
  * two reads required
    * First shows data from the previous transaction. Second shows the correct one. 
    * Likely a bug in the host interface logic since LEDs show the correct value on the first read. 
  * Timing not closed - unpredictable results when modified

**Updated git repo**

#### 4/6 Update
* Mapped design to yosys+nextpnr
* Nextpnr Xilinx only supports PLL and ISERDES units
* Requires updating the constraints file
* Initially just tested PLL
* Unsuccessful
  * Unpredictable circuit behavior if generated freq > 200 MHz or if phase shift requested. 
  * Able to generate 200M and 400M clocks by cascading two PLLs
  * Inefficient approach
    * PLL is a very limited resource. 
  * Loading the clocks (e.g. inverting the clock) causes the circuit to behave unpredictably. 
* Attempted to port design to Genesys 2 board
  * Timing closure successful
  * However board does not respond
  * Likely due to the addressing logic
  * Put this on the stack for when we focus on the portability aspect of the design.

#### 4/8 Update
* Explored use of the SERDES units
* Located on the same bank as the IO pads
* Can substantially improve timing
* However, are not well documented
* Goal is to create a SERDES+wrapper module so that the current control logic/signalling does not need to be modified.
* Currently strobe pins from the DRAM (dqs) are used to clock the read shift registers directly at positive and negative edges. 
* Another goal is to document the SERDES units ourselves. 

#### 4/10 Update
* Attempted to close timing without SERDES unit
* More manual optimizations
  * Ran Xilinx timing wizard
  * Manually floorplanned design
  * Added multi-cycle exceptions
  * Added double buffering for the read data
    * Some improvements if the right clock is used for the second buffer (currently 200MHz)
* Conclusion: The 7-series architecture makes it difficult to do this without using the SERDES primitives. 
  * For example, the strobe IO pad is located half a chip away from the global clock buffers.
  * Poor placement prevents strobe from being treated as a clock.
  * Likely unable to use the dedicated clock network. 





## Some Links

[PLL and Differential Signalling demo using a fully open source toolchain for the Icestorm FPGA](https://github.com/mattvenn/fpga-lvds-ddr)

[DDR3 Memory Interface on Xilinx Zynq SOC – Free Software Compatible](
https://blog.elphel.com/2014/06/ddr3-memory-interface-on-xilinx-zynq-soc-free-software-compatible/)

[OpenArty Initial Effort (eventually used Xilinx MIG)](https://opencores.org/projects/wbddr3)


[Nextpnr-Xilinx](https://github.com/daveshah1/nextpnr-xilinx)
