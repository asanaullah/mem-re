//`define SIMULATION
`ifndef SIMULATION
module pll_100M_400M (input clk_i, output clk_o0 ,output clk_o1, output clk_o2, output locked);

wire clk_fb;
wire clk_fb_buf;

wire clk_o0_buf;
wire clk_o1_buf;
wire clk_o2_buf;


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
   .CLKOUT1_PHASE        (180.000),
   .CLKOUT1_DUTY_CYCLE   (0.500),
   .CLKOUT2_DIVIDE       (6),
   .CLKOUT2_PHASE        (135.000),
   .CLKOUT2_DUTY_CYCLE   (0.500),
   .CLKIN1_PERIOD        (10.000))
 plle2_adv_inst
  (
   .CLKFBOUT            (clk_fb_buf),
   .CLKOUT0             (clk_o0_buf),
   .CLKOUT1             (clk_o1_buf),
   .CLKOUT2             (clk_o2_buf),
   .CLKOUT3             (),
   .CLKOUT4             (),
   .CLKOUT5             (),
   .CLKFBIN             (clk_fb),
   .CLKIN1              (clk_i),
   .CLKIN2              (1'b0),
   .CLKINSEL            (1'b1),
   .DADDR               (7'h0),
   .DCLK                (1'b0),
   .DEN                 (1'b0),
   .DI                  (16'h0),
   .DO                  (),
   .DRDY                (),
   .DWE                 (1'b0),
   .LOCKED              (locked),
   .PWRDWN              (1'b0),
   .RST                 (1'b0));

// Clock Monitor clock assigning
//--------------------------------------
// Output buffering
 //-----------------------------------

 BUFG clkfb_buf
  (.O (clk_fb),
   .I (clk_fb_buf));



 BUFG clko0_buf
  (.O   (clk_o0),
   .I   (clk_o0_buf));


 BUFG clko1_buf
  (.O   (clk_o1),
   .I   (clk_o1_buf));

 BUFG clko2_buf
  (.O   (clk_o2),
   .I   (clk_o2_buf));

endmodule
`endif
