`timescale 1ps/1ps
module tb_dram;

   `include "1024Mb_ddr3_parameters.vh"
    reg 						clk_i;
    reg 						rst_i;
    reg						read;
    reg 						write;
    reg 		[ROW_BITS+COL_BITS+BA_BITS-1:0]	address;
    reg		[BL_MAX*DQ_BITS-1:0]		write_data;
    wire		[BL_MAX*DQ_BITS-1:0]		read_data;
    wire						ack;
    wire						stall;

    wire						rst_n;
    wire						clk_400M;
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
    wire        	[DQS_BITS-1:0]			dqs;
    wire        	[DQS_BITS-1:0]			dqs_n;
    wire                      			odt;
    wire        	[DQS_BITS-1:0]			tdqs_n;





dram_controller uut(
	clk_i,
	rst_i,
	read, 
	write,
	address,
	read_data,
	write_data,
	ack,
	busy,

        	rst_n,
        	clk_400M, 
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
        	dqs,
        	dqs_n,
        	odt
);


    ddr3 sdramddr3_0 (
        rst_n,
        clk_400M, 
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
        dqs,
        dqs_n,
        tdqs_n,
        odt
    );

always #1250 clk_i = ~clk_i;


initial begin
	integer i;
	clk_i = 0;
	rst_i = 1;
	write = 0;
	read = 0;
	address = 0;
	write_data = 0;
  	#10000
	rst_i = 0;
   	@(negedge busy);
	
	for (i=0; i < 10; i++) begin
		write = 1;
		write_data = {$urandom,$urandom,$urandom,$urandom};
		address =     {$urandom,$urandom};
   		@(posedge ack);
   		write = 0;
   		read = 1;
   		@(posedge ack);
   		$display("Read Data:\t%x\nWrite Data:\t%x", read_data, write_data);
	end   
	$display ("Done");
	$finish;	
end

endmodule

