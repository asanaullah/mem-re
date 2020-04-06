//`define SIMULATION
`ifndef SIMULATION
module pll_100M_400M (input clk_i, output clk_o0 ,output clk_o1, output clk_o2, output clk_o3,output clk_o4,output locked);

wire clk_fb;


/*
PLLE2_ADV
 #(.BANDWIDTH            ("OPTIMIZED"),
   .COMPENSATION         ("ZHOLD"),
   .STARTUP_WAIT         ("FALSE"),
   .DIVCLK_DIVIDE        (1),
   .CLKFBOUT_MULT        (12),
   .CLKFBOUT_PHASE       (0.000),
   .CLKOUT0_DIVIDE       (6),
   .CLKOUT0_PHASE        (0.000),
   .CLKOUT0_DUTY_CYCLE   (0.500),
   .CLKOUT1_DIVIDE       (6),
   .CLKOUT1_PHASE        (45.000),
   .CLKOUT1_DUTY_CYCLE   (0.500),
   .CLKOUT2_DIVIDE       (3),
   .CLKOUT2_PHASE        (0.000),
   .CLKOUT2_DUTY_CYCLE   (0.500),
   .CLKOUT3_DIVIDE       (3),
   .CLKOUT3_PHASE        (180.000),
   .CLKOUT3_DUTY_CYCLE   (0.500),
   .CLKOUT4_DIVIDE       (3),
   .CLKOUT4_PHASE        (135.000),
   .CLKOUT4_DUTY_CYCLE   (0.500),
   .CLKIN1_PERIOD        (10.000))
 plle2_adv_inst
   // Output clocks
  (
   .CLKFBOUT            (clk_fb),
   .CLKOUT0             (clk_o0),
   .CLKOUT1             (clk_o1),
   .CLKOUT2             (clk_o2),
   .CLKOUT3             (clk_o3),
   .CLKOUT4             (clk_o4),
   .CLKOUT5             (),
    // Input clock control
   .CLKFBIN             (clk_fb),
   .CLKIN1              (clk_i),
   .CLKIN2              (1'b0),
    // Tied to always select the primary input clock
   .CLKINSEL            (1'b1),
   // Ports for dynamic reconfiguration
   .DADDR               (7'h0),
   .DCLK                (1'b0),
   .DEN                 (1'b0),
   .DI                  (16'h0),
   .DO                  (),
   .DRDY                (),
   .DWE                 (1'b0),
   // Other control and status signals
   .LOCKED              (locked),
   .PWRDWN              (1'b0),
   .RST                 (1'b0));

// Clock Monitor clock assigning
//--------------------------------------
// Output buffering
 //-----------------------------------
*/


 // Input buffering
  //------------------------------------



  // Clocking PRIMITIVE
  //------------------------------------

  // Instantiation of the MMCM PRIMITIVE
  //    * Unused inputs are tied off
  //    * Unused outputs are labeled unused


  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_clk_wiz_0;
  wire        clkfbout_buf_clk_wiz_0;
  wire        clkfboutb_unused;
    wire clkout0b_unused;
   wire clkout1b_unused;
   wire clkout3_unused;
   wire clkout3b_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;

  MMCME2_ADV
  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (8.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (4.000),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (4),
    .CLKOUT1_PHASE        (45.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKOUT2_DIVIDE       (2),
    .CLKOUT2_PHASE        (0.000),
    .CLKOUT2_DUTY_CYCLE   (0.500),
    .CLKOUT2_USE_FINE_PS  ("FALSE"),
    .CLKOUT4_DIVIDE       (2),
    .CLKOUT4_PHASE        (135.000),
    .CLKOUT4_DUTY_CYCLE   (0.500),
    .CLKOUT4_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (10.000))
  mmcm_adv_inst
    // Output clocks
   (
    .CLKFBOUT            (clkfbout_clk_wiz_0),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (clk_o0),
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (clk_o1),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clk_o2),
    .CLKOUT2B            (clk_o3),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (clk_o4),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
     // Input clock control
    .CLKFBIN             (clkfbout_clk_wiz_0),
    .CLKIN1              (clk_i),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    // Other control and status signals
    .LOCKED              (locked_int),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (1'b0));

  assign locked = locked_int;
// Clock Monitor clock assigning
//--------------------------------------
 // Output buffering
  //-----------------------------------




endmodule
`endif
