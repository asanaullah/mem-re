`timescale 1ps/1ps
//`define SIMULATION
module tb_dram
`ifndef SIMULATION
(i_clk, i_btn, read, write, invert, o_led,rst_n,clk_400M_p,clk_400M_n,cke,cs_n,ras_n,cas_n,we_n,ba,a,dm,dq,dqs_p,dqs_n,odt)
`endif
;


`include "1024Mb_ddr3_parameters.vh"
`ifdef SIMULATION  
    initial begin 
  	$dumpfile("debug.vcd");
  	$dumpvars(0,tb_dram);
    end
    reg 						i_clk;
    reg						rst_i;
    reg						read;
    reg 						write;
    reg 		[ROW_BITS+COL_BITS+BA_BITS-1:0]	address;
    reg		[BL_MAX*DQ_BITS-1:0]		write_data;
    wire		[BL_MAX*DQ_BITS-1:0]		read_data;
    wire						ack;
    wire						busy;

    wire						rst_n;
    wire						clk_400M_p;
    wire						clk_400M_n;
    wire						cke;
    wire						cs_n;
    wire						ras_n;
    wire						cas_n;
    wire						we_n;
    wire		[BA_BITS-1:0]  			ba;
    wire		[ADDR_BITS-1:0]			a;
    wire  	[DM_BITS-1:0]   			dm;
    wire        	[DQ_BITS-1:0] 			dq;
    wire        	[DQS_BITS-1:0]			dqs_p;
    wire        	[DQS_BITS-1:0]			dqs_n;
    wire                      			odt;
    wire        	[DQS_BITS-1:0]			tdqs_n;
`else
    input 						i_clk; 
    input 						i_btn; 
    output 		   [7:0] 		o_led;     
    output						rst_n;
    output						clk_400M_p;
    output                        clk_400M_n;
    output						cke;
    output						cs_n;
    output						ras_n;
    output						cas_n;
    output						we_n;
    output		[BA_BITS-1:0]  			ba;
    output		[ADDR_BITS-1:0]			a;
    output  	[DM_BITS-1:0]   			dm;
    inout        	[DQ_BITS-1:0] 			dq;
    inout        	[DQS_BITS-1:0]			dqs_p;
    inout        	[DQS_BITS-1:0]			dqs_n;
    output                      			odt;
    wire        	[DQS_BITS-1:0]			tdqs_n;
    wire 						rst_i = i_btn;
    input							read;
    input 						write;
    input                       invert;
    reg 		[ROW_BITS+COL_BITS+BA_BITS-1:0]	address;
    reg		[BL_MAX*DQ_BITS-1:0]		write_data;
    wire		[BL_MAX*DQ_BITS-1:0]		read_data;
    wire						ack;
    wire						busy;
`endif


wire [7:0] debug;
wire clk_400M_p_int;
wire clk_400M_n_int;
OBUFDS #(.IOSTANDARD("DEFAULT")) OBUFDS_inst (.O(clk_400M_p),.OB(clk_400M_n),.I(clk_400M_p_int));

wire dqs_en;
wire [DQS_BITS-1:0] dqs_out;
wire [DQS_BITS-1:0] dqs_tristate_in;
genvar i;
generate
   for (i=0; i<DQS_BITS; i=i+1) begin : tristate_dqs
      IOBUFDS io (.O(dqs_tristate_in[i]),.IO(dqs_p[i]), .IOB(dqs_n[i]), .I(dqs_out[i]),.T(~dqs_en));
   end
endgenerate


dram_controller uut(
	i_clk,
	rst_i,
	read, 
	write,
	address,
	read_data,
	write_data,
	ack,
	busy,
    rst_n,
    clk_400M_p_int, 
    cke, 
    cs_n, 
    ras_n, 
    cas_n, 
    we_n, 
    dm, 
    ba, 
    a, 
    dq, 
    dqs_out,
    dqs_en,
    dqs_tristate_in,
    odt,
    debug
);

`ifdef SIMULATION
    ddr3 sdramddr3_0 (
        rst_n,
        clk_400M_p, 
        clk_400M_n,
        cke, 
        cs_n, 
        ras_n, 
        cas_n, 
        we_n, 
        dm, 
        ba, 
        a, 
        dq, 
        dqs_p,
        dqs_n,
        tdqs_n,
        odt
    );
`endif

`ifdef SIMULATION
always #5000 i_clk = ~i_clk;
initial begin
	integer i;
	i_clk = 0;
	rst_i = 1;
	write = 0;
	read = 0;
	address = 0;
	write_data = 0;
  	#10000
	rst_i = 0;
   	@(negedge busy);
	
	for (i=0; i < 1; i++) begin
		write_data = {$urandom,$urandom,$urandom,$urandom};
		address =    {$urandom,$urandom};
		write = 1;
   		@(posedge ack);
   		write = 0;
   		read = 1;
   		@(posedge ack);
		read = 0;
   		$display("Read Data:\t%x\nWrite Data:\t%x", read_data, write_data);
	end   
	$display ("Done");
	$finish;
end
`else
reg				[BL_MAX*DQ_BITS-1:0]	read_buffer;
initial read_buffer = 0;
always @(posedge i_clk) begin		
	if (rst_i) begin
		write_data <= (invert) ? ~128'h92_15_35_24_40_89_5e_81_04_84_d6_09_31_f0_56_63 : 128'h92_15_35_24_40_89_5e_81_04_84_d6_09_31_f0_56_63;
		address <= {3'd3,13'h17e6,10'h188};
	end else begin
         read_buffer <= read_data; 
	end
end
assign o_led = read_buffer[24+:8];//debug;
`endif




endmodule

