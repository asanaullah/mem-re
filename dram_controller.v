module dram_controller(
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

   `include "1024Mb_ddr3_parameters.vh"


    input 						clk_i;
    input 						rst_i;
    input							read;
    input 						write;
    input 		[ROW_BITS+COL_BITS+BA_BITS-1:0]	address;
    input			[BL_MAX*DQ_BITS-1:0]		write_data;
    output reg		[BL_MAX*DQ_BITS-1:0]		read_data;
    output reg						ack;
    output reg						busy;

    output reg						rst_n;
    output						clk_400M;
    output						clk_400M_n;
    output reg						cke;
    output reg						cs_n;
    output reg						ras_n;
    output reg						cas_n;
    output reg						we_n;
    output reg		[BA_BITS-1:0]   			ba;
    output reg		[ADDR_BITS-1:0] 			a;
    output reg		[DM_BITS-1:0]   			dm;
    inout			[DQ_BITS-1:0] 			dq;
    inout			[DQS_BITS-1:0] 			dqs;
    inout			[DQS_BITS-1:0] 			dqs_n;
    output reg                       				odt;
    

// States
    reg [31:0] state;
    reg [31:0] prev_state;
    reg [31:0] cached_state;
    wire [31:0] STATE_POWERUP_0		=		32'd0;
    wire [31:0] STATE_POWERUP_1		=		32'd1;
    wire [31:0] STATE_LOADMODE_0		=		32'd2;
    wire [31:0] STATE_LOADMODE_1		=		32'd3;
    wire [31:0] STATE_LOADMODE_2		=		32'd4;
    wire [31:0] STATE_LOADMODE_3		=		32'd5;
    wire [31:0] STATE_REFRESH			=		32'd6;
    wire [31:0] STATE_PRECHARGE		=		32'd7;
    wire [31:0] STATE_ACTIVATE		=		32'd8;
    wire [31:0] STATE_WRITE			=		32'd9;
    wire [31:0] STATE_READ			=		32'd10;
    wire [31:0] STATE_ZQCALLIBRATION		=		32'd11;
    wire [31:0] STATE_NOP			=		32'd12;
    wire [31:0] STATE_DESELCT			=		32'd13;
    wire [31:0] STATE_POWERDOWN		=		32'd14;
    wire [31:0] STATE_IDLE			=		32'd15;
    wire [31:0] STATE_SET_ODT			=		32'd16;


// Mode Registers
    wire         [ADDR_BITS-1:0] mode_reg0 = {14'b0_0_000_1_0_000_1_0_00} | mr_wr<<9 |mr_cl<<2;   //Mode Register
    wire         [ADDR_BITS-1:0] mode_reg1 = 14'b0000010110;                                 //Extended Mode Register
    wire         [ADDR_BITS-1:0] mode_reg2 = {14'b00001000_000_000} | mr_cwl<<3;   //Extended Mode Register 2
    wire                  [3:0] cl       = {mode_reg0[2], mode_reg0[6:4]} + 4;              //CAS Latency
    wire                        bo       = mode_reg0[3];                    //Burst Order
    wire                   [31:0] bl	 = 32'd8;                                         //Burst Length
    
    wire                  [3:0] cwl      = mode_reg2[5:3] + 5;              //CAS Write Latency
    wire                  [3:0] al       = (mode_reg1[4:3] === 2'b00) ? 4'h0 : cl - mode_reg1[4:3]; //Additive Latency
    wire                  [4:0] rl       = cl + al;                         //Read Latency
    wire                  [4:0] wl       = cwl + al;                        //Write Latency

// IO Buffers
    reg		[BL_MAX*DQ_BITS+DQ_BITS-1:0] 		dq_in_buffer;
    reg		[(BL_MAX/2)*DQ_BITS-1:0] 		dq_out_buffer_0;
    reg		[(BL_MAX/2)*DQ_BITS-1:0] 		dq_out_buffer_1;
    reg		[ROW_BITS+COL_BITS-1:0]		a_buffer;
    reg		[BA_BITS-1:0]			ba_buffer;

// DQ and DQS
    reg                         dq_en;
    reg           [DM_BITS-1:0] dm_out;
    reg           [DQ_BITS-1:0] dq_out;
    reg                         dqs_en;
    reg          [DQS_BITS-1:0] dqs_out;
    assign dq   = dq_en ? dq_out : {DQ_BITS{1'bz}};
    assign dm   = dqs_en ?  dm_out : {DM_BITS{1'bz}};
    assign dqs  = dqs_en ? dqs_out : {DQS_BITS{1'bz}};
    assign dqs_n    = dqs_en ? ~dqs_out : {DQS_BITS{1'bz}};
 
    always @(*) dqs_out = #(125) {DQS_BITS{clk_400M}};
 
    always @(*) dq_out = (clk_i==1) ? dq_in_buffer[DQ_BITS-1:0] : dq_in_buffer[DQ_BITS+DQ_BITS-1:DQ_BITS];
  
    always @(posedge clk_400M) begin
	if (state == STATE_WRITE) begin
		if (state_change_counter <= (bl>>1)+32'd1)
			dqs_en <= 1'b1;
		else
			dqs_en <= 1'b0;
	end else
		dqs_en <= 0;
    end
    always @(posedge clk_400M) begin
	if (state == STATE_READ) begin
		if (state_change_counter < delay_read) begin
			dq_out_buffer_0		<=	dq_out_buffer_0 << (DQ_BITS);
			dq_out_buffer_0[DQ_BITS-1:0]	<=	dq;
		end
	end
    end  
    always @(posedge clk_400M_n) begin
	if (state == STATE_READ) begin
		if (state_change_counter < delay_read-32'd1) begin
			dq_out_buffer_1		<=	dq_out_buffer_1 << (DQ_BITS);
			dq_out_buffer_1[DQ_BITS-1:0]	<=	dq;
		end
	end
    end 
    
    
    
// Clock
    assign clk_400M = ~clk_i;
    assign clk_400M_n = clk_i;

// Functions
    function integer ceil;
	input number;
	real number;
	if (number > $rtoi(number))
		ceil = $rtoi(number) + 1;
	else
		ceil = number;
    endfunction

    function integer max;
	input arg1;
	input arg2;
	integer arg1;
	integer arg2;
	if (arg1 > arg2)
		max = arg1;
	else
		max = arg2;
    endfunction

// Timing Definitions
    real                        tck	 = 2500;
    wire                 [11:0] tccd     = TCCD;
    wire                 [11:0] tcke     = max(ceil(TCKE/tck), TCKE_TCK);
    wire                 [11:0] tckesr   = TCKESR_TCK;
    wire                 [11:0] tcksre   = max(ceil(TCKSRE/tck), TCKSRE_TCK);
    wire                 [11:0] tcksrx   = max(ceil(TCKSRX/tck), TCKSRX_TCK);
    wire                 [11:0] tcl_min  = min_cl(tck);
    wire                  [6:2] mr_cl    = (tcl_min - 4)<<2 | (tcl_min/12);
    wire                 [11:0] tcpded   = TCPDED;
    wire                 [11:0] tcwl_min = min_cwl(tck);
    wire                  [5:3] mr_cwl   = tcwl_min - 5;
    wire                 [11:0] tdllk    = TDLLK;
    wire                 [11:0] tfaw     = ceil(TFAW/tck);
    wire                 [11:0] tmod     = max(ceil(TMOD/tck), TMOD_TCK);
    wire                 [11:0] tmrd     = TMRD;
    wire                 [11:0] tras     = ceil(TRAS_MIN/tck);
    wire                 [11:0] trc      = ceil(TRC/tck);
    wire                 [11:0] trcd     = ceil(TRCD/tck);
    wire                 [11:0] trfc     = ceil(TRFC_MIN/tck);
    wire                 [11:0] trp      = ceil(TRP/tck);
    wire                 [11:0] trrd     = max(ceil(TRRD/tck), TRRD_TCK);
    wire                 [11:0] trtp     = max(ceil(TRTP/tck), TRTP_TCK);
    wire                 [11:0] twr      = ceil(TWR/tck);
    wire                 [11:0] twtr     = max(ceil(TWTR/tck), TWTR_TCK);
    wire                 [11:0] txp      = max(ceil(TXP/tck), TXP_TCK);
    wire                 [11:0] txpdll   = max(ceil(TXPDLL/tck), TXPDLL_TCK);
    wire                 [11:0] txpr     = max(ceil(TXPR/tck), TXPR_TCK);
    wire                 [11:0] txs      = max(ceil(TXS/tck), TXS_TCK);
    wire                 [11:0] txsdll   = TXSDLL;
    wire                 [11:0] tzqcs    = TZQCS;
    wire                 [11:0] tzqoper  = TZQOPER;
    wire                 [11:0] wr       = (twr < 8) ? twr : twr + twr%2;
    wire                 [11:9] mr_wr    = (twr < 8) ? (twr - 4) : twr>>1;
    wire 		     [31:0] tx_pr	 = 32'd1 + (TXPR/tck);

// Counters
   reg [31:0] state_change_counter;
   wire [31:0] delay_powerup_0		=	0;//32'd80000;
   wire [31:0] delay_powerup_1		=	0;//32'd200000;
   wire [31:0] delay_precharge		=	{20'd0 ,trp};	
   wire [31:0] delay_activate			= 	{20'd0, trcd};
   wire [31:0] delay_write			=	{20'd0,{{7'd0,wl} + 12'd4 + twtr}};
   wire [31:0] delay_read			=	{27'd0, rl} + (bl>>1) + 32'd1;
   wire [31:0] delay_load_mode		=	{20'd0, tmrd-12'd1};
   wire [31:0] delay_initialization_final	=	32'd512;
   wire [31:0] delay_powerup_final		=	tx_pr;
   wire [31:0] delay_write_0			=	{27'd0,wl} + (bl>>1) + 32'd1;

// Addressing
   wire   [COL_BITS-1:0] col		=	a_buffer[COL_BITS-1:0];		
   wire   [ADDR_BITS-1:0] atemp_0	=	col & 10'h3ff;         //a[ 9: 0] = COL[ 9: 0]
   wire   [ADDR_BITS-1:0] atemp_1	=	((col>>10) & 1'h1)<<11;//a[   11] = COL[   10]
   wire   [ADDR_BITS-1:0] atemp_2	=	(col>>11)<<13;         //a[ N:13] = COL[ N:11]

// State Machine
always @(posedge clk_i) begin

	if (rst_i) begin
		state 			<= 	STATE_POWERUP_0;
		prev_state 		<= 	STATE_POWERUP_0;
		cached_state		<=	STATE_POWERUP_0;
		state_change_counter 	<=	delay_powerup_0;
		rst_n   			<= 	1'b0;
		cke			<=	1'b0;
		cs_n			<=	1'b1;
		ras_n			<=	1'b1;
		cas_n   			<=	1'b1;
	        	we_n    			<=	1'b1;
	        	ba      			<=	{BA_BITS{1'bz}};
	       	a       			<=	{ADDR_BITS{1'bz}};
	        	odt	 		<=	1'b0;
	        	dq_en   			<=	1'b0;
	        	dqs_en  			<=	1'b0;
		dm_out			<=	{DM_BITS{1'bz}};
		ack			<=	1'b0;
		busy			<=	1'b1;
		dq_in_buffer		<= 	0;
		read_data 		<=	0;
	
	end else if (state == STATE_NOP) begin
		if (state_change_counter)
			state_change_counter		<=	state_change_counter - 32'd1;
		else begin
			state_change_counter		<=	(cached_state == STATE_WRITE) ?  delay_write_0  : ((cached_state == STATE_READ) ?  delay_read :0);
			state				<=	cached_state;
		end
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= 1'b0;


	end else if (state == STATE_POWERUP_0) begin
		if (state_change_counter) begin

			state_change_counter		<=	state_change_counter - 32'd1;
		end else begin
			state_change_counter		<=	delay_powerup_1;
			state				<=	STATE_POWERUP_1;
		end
		rst_n   <= 1'b0;
            	cke     <= 1'b0;
            	cs_n    <= 1'b1;


	end else if (state == STATE_POWERUP_1) begin
		if (state_change_counter)
			state_change_counter		<=	state_change_counter - 32'd1;
		else begin
			state_change_counter		<=	delay_powerup_final;
			state				<=	STATE_NOP;
			cached_state			<=	STATE_ZQCALLIBRATION;
		end
		rst_n   <= 1'b1;


	end else if (state == STATE_ZQCALLIBRATION) begin
		if (state_change_counter)
			state_change_counter		<=	state_change_counter - 32'd1;
		else begin
			state_change_counter		<=	delay_load_mode;
			state				<=	STATE_NOP; 	
			cached_state			<=	STATE_LOADMODE_3;
		end
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
             	we_n  <= 1'b0;
           	ba    <=  0;
            	a     <=  1<<10;


	end else if (state == STATE_LOADMODE_3) begin
		if (state_change_counter)
			state_change_counter		<=	state_change_counter - 32'd1;
		else begin
			state_change_counter		<=	delay_load_mode;
			state				<=	STATE_NOP;
			cached_state			<=	STATE_LOADMODE_2;
		end
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b0;
            	we_n  <= 1'b0;
            	ba    <= 3;
            	a     <= 0;	


	end else if (state == STATE_LOADMODE_2) begin
		if (state_change_counter)
			state_change_counter		<=	state_change_counter - 32'd1;
		else begin
			state_change_counter		<=	delay_load_mode;
			state				<=	STATE_NOP;
			cached_state			<=	STATE_LOADMODE_1;
		end
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b0;
            	we_n  <= 1'b0;
            	ba    <= 2;
            	a     <= mode_reg2;


	end else if (state == STATE_LOADMODE_1) begin
		if (state_change_counter)
			state_change_counter		<=	state_change_counter - 32'd1;
		else begin
			state_change_counter		<=	delay_load_mode;
			state				<=	STATE_NOP;
			cached_state			<=	STATE_LOADMODE_0;
		end
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b0;
            	we_n  <= 1'b0;
            	ba    <= 1;
            	a     <= mode_reg1;


	end else if (state == STATE_LOADMODE_0) begin
		if (state_change_counter)
			state_change_counter		<=	state_change_counter - 32'd1;
		else begin
			state_change_counter		<=	delay_initialization_final;
			state				<=	STATE_NOP;
			cached_state			<=	STATE_SET_ODT;
		end
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b0;
            	we_n  <= 1'b0;
            	ba    <= 0;
            	a     <= mode_reg0;


	end else if (state == STATE_SET_ODT) begin
		if (state_change_counter)
			state_change_counter		<=	state_change_counter - 32'd1;
		else begin
			state_change_counter		<=	10;
			state				<=	STATE_NOP;
			cached_state			<=	STATE_IDLE;
		end
		odt <= 1;


	end else if (state == STATE_IDLE) begin
		busy		<=	0;
		dq_in_buffer	<=	{write_data,{DQ_BITS{1'b0}}};	
		a_buffer	<=	address[ROW_BITS+COL_BITS-1:0];
		ba_buffer	<=	address[BA_BITS+ROW_BITS+COL_BITS-1:ROW_BITS+COL_BITS];	
		if (write) begin
			cached_state		<=	STATE_WRITE;
			state			<=	STATE_ACTIVATE;
			odt 			<=	1'b1;
		end else if (read) begin
			cached_state 		<= 	STATE_READ;	
			state			<=	STATE_ACTIVATE;
			odt			<=	1'b0;
		end


	end else if (state == STATE_ACTIVATE) begin
		busy <= 1;
		state_change_counter		<=	delay_activate;
		state				<=	STATE_NOP;
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b1;
            	we_n  <= 1'b1;
            	ba    <= ba_buffer;
            	a     <=  a_buffer[ROW_BITS+COL_BITS-1:COL_BITS];



	end else if (state == STATE_WRITE) begin	
		if (state_change_counter == delay_write_0) begin
			cke   <= 1'b1;
            		cs_n  <= 1'b0;
            		ras_n <= 1'b1;
            		cas_n <= 1'b0;
            		we_n  <= 1'b0;	
		end else begin
			cke   <= 1'b1;
            		cs_n  <= 1'b0;
            		ras_n <= 1'b1;
            		cas_n <= 1'b1;
           		we_n  <= 1'b1;
		end
            	ba    <= ba_buffer;
           	a     <= atemp_0 | atemp_1 | atemp_2;
		dm_out <= 0;
	
		if (state_change_counter  ==  (bl>>1)+32'd1) begin
			dq_en	<= 1'b1;
		end else if (state_change_counter  <=  (bl>>1)) begin
			dq_in_buffer <= (dq_in_buffer >> DQ_BITS*2);
		end

		if (state_change_counter)
			state_change_counter		<=	state_change_counter - 32'd1;
		else begin
            		dq_en  				<= 	1'b0;
			state				<=	STATE_NOP;
			cached_state			<=	STATE_PRECHARGE;
			prev_state			<=	STATE_WRITE;
			state_change_counter		<=	{20'd0, twr};
		end



	end else if (state == STATE_READ) begin	
		if (state_change_counter == delay_read) begin
			cke   <= 1'b1;
            		cs_n  <= 1'b0;
            		ras_n <= 1'b1;
            		cas_n <= 1'b0;
            		we_n  <= 1'b1;	
		end else begin
			cke   <= 1'b1;
            		cs_n  <= 1'b0;
            		ras_n <= 1'b1;
            		cas_n <= 1'b1;
           		we_n  <= 1'b1;
		end
            	ba    <= ba_buffer;
           	a     <= atemp_0 | atemp_1 | atemp_2;
	

		if (state_change_counter) begin
			state_change_counter	<=	state_change_counter - 32'd1;
		end else begin
			state			<=	STATE_PRECHARGE;
			prev_state		<=	STATE_READ;
			ack 			<= 	1'b1;
			read_data 		<= {dq_out_buffer_1[47:32],dq_out_buffer_0[47:32],dq_out_buffer_1[63:48],dq_out_buffer_0[63:48],dq_out_buffer_1[15:0],dq_out_buffer_0[15:0],dq_out_buffer_1[31:16],dq_out_buffer_0[31:16]};
		end
		

	end else if (state == STATE_PRECHARGE) begin
		state_change_counter		<=	delay_precharge;
		state				<=	STATE_NOP;
		cached_state			<=	STATE_IDLE;
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b1;
            	we_n  <= 1'b0;
            	ba    <= ba_buffer;
            	a     <= 0;
            	ack   <= 0;

	end
end


endmodule 




