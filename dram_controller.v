//`define SIMULATION

module dram_controller(
	clk,
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

   `include "1024Mb_ddr3_parameters.vh"


    input 						                clk;
    input 						                rst_i;
    input						                 read;
    input 						                write;
    input 		[ROW_BITS+COL_BITS+BA_BITS-1:0]	address;
    input			[BL_MAX*DQ_BITS-1:0]		write_data;
    output reg		[BL_MAX*DQ_BITS-1:0]		read_data;
    output reg						ack;
    output reg						busy;

    output reg						rst_n;
    output						clk_400M;
    output reg						cke;
    output reg						cs_n;
    output reg						ras_n;
    output reg						cas_n;
    output reg						we_n;
    output reg		[BA_BITS-1:0]   			ba;
    output reg		[ADDR_BITS-1:0] 			a;
    output 			[DM_BITS-1:0]   			dm;
    inout			[DQ_BITS-1:0] 			dq;
    output reg			[DQS_BITS-1:0] 			dqs_out;
    output  reg                   		               dqs_en;
    input			[DQS_BITS-1:0] 			dqs_tristate_in;
    output reg                       				odt;
    output [7:0]						debug;
  	
 

// Clocks
	wire [1:0] locked;	
	wire clkfb;
 	wire dqs_clk;
	wire clk_i;
	wire clk_400M_n = clk_i;
        pll_100M_400M  pl(clk, clk_i, clk_400M ,dqs_clk, locked[0]);

	
// States
    reg [5:0] state;
    reg [5:0] prev_state;
    reg [5:0] cached_state;
    wire [5:0] STATE_POWERUP_0			=		6'd0;
    wire [5:0] STATE_POWERUP_1			=		6'd6;
    wire [5:0] STATE_LOADMODE_0			=		6'd2;
    wire [5:0] STATE_LOADMODE_1			=		6'd3;
    wire [5:0] STATE_LOADMODE_2			=		6'd4;
    wire [5:0] STATE_LOADMODE_3			=		6'd5;
    wire [5:0] STATE_REFRESH			=		6'd1;
    wire [5:0] STATE_PRECHARGE			=		6'd7;
    wire [5:0] STATE_NOP			=		6'd8;
    wire [5:0] STATE_WRITE			=		6'd9;
    wire [5:0] STATE_READ			=		6'd10;
    wire [5:0] STATE_ZQCALLIBRATION		=		6'd11;
    wire [5:0] STATE_ACTIVATE			=		6'd12;
    wire [5:0] STATE_DESELCT			=		6'd13;
    wire [5:0] STATE_POWERDOWN			=		6'd14;
    wire [5:0] STATE_SET_ODT			=		6'd15;
    wire [5:0] STATE_IDLE            		=       	6'd16;
    wire [5:0] STATE_POWERUP_1_NOP		=		6'd17;
    wire [5:0] STATE_ZQCALLIBRATION_NOP		=		6'd18;
    wire [5:0] STATE_LOADMODE_3_NOP		=		6'd19;
    wire [5:0] STATE_LOADMODE_2_NOP		=		6'd20;
    wire [5:0] STATE_LOADMODE_1_NOP		=		6'd21;
    wire [5:0] STATE_LOADMODE_0_NOP		=		6'd22;
    wire [5:0] STATE_SET_ODT_NOP		=		6'd23;
    wire [5:0] STATE_WRITE_ACTIVATE_NOP		=		6'd24;
    wire [5:0] STATE_WRITE_NOP			=		6'd25;
    wire [5:0] STATE_READ_ACTIVATE_NOP		=		6'd26;
    wire [5:0] STATE_READ_NOP			=		6'd27;
    wire [5:0] STATE_PRECHARGE_NOP		=		6'd28;
    wire [5:0] STATE_REFRESH_NOP		=		6'd29;
    wire [5:0] STATE_WRITE_ACTIVATE		=		6'd30;
    wire [5:0] STATE_READ_ACTIVATE		=		6'd31;




// IO Buffers
    reg		[BL_MAX*DQ_BITS+DQ_BITS-1:0] 		dq_write_buffer;
    reg		[(BL_MAX/2)*DQ_BITS-1:0] 		dq_read_buffer_0;
    reg		[(BL_MAX/2)*DQ_BITS-1:0] 		dq_read_buffer_1;
    reg		[ROW_BITS+COL_BITS-1:0]			a_buffer;
    reg		[BA_BITS-1:0]				ba_buffer;

// DQ and DQS
    reg                         dq_en;
    reg           [DM_BITS-1:0] dm_out;
    wire           [DQ_BITS-1:0] dq_out;
    assign dm = dm_out;

        genvar i;
	wire [DQ_BITS-1:0] dq_tristate_out;
	
	generate
    	for (i=0; i<DQ_BITS; i=i+1) begin : dq_primitives
   	   IOBUF io (.O(dq_tristate_out[i]),.IO(dq[i]), .I(dq_out[i]),.T(~dq_en));
	   ODDR2 oddr_i2 (.Q(dq_out[i]), .C0(clk_400M_n), .C1(clk_400M), .R(1'b0),.S(1'b0), .D0(dq_write_buffer[i]), .D1(dq_write_buffer[i+DQ_BITS]));
   	end
	endgenerate

        always @(*) dqs_out = {DQS_BITS{dqs_clk}};

	always @(posedge dqs_tristate_in[0]) begin
			dq_read_buffer_0		<=	dq_read_buffer_0 << (DQ_BITS);
			dq_read_buffer_0[DQ_BITS-1:0]	<=	dq_tristate_out;
    	end
	
   	always @(negedge dqs_tristate_in[0]) begin
			
				dq_read_buffer_1		<=	dq_read_buffer_1 << (DQ_BITS);
				dq_read_buffer_1[DQ_BITS-1:0]	<=	dq_tristate_out;
    	end 


    	always @(posedge clk) begin
		if (state == STATE_WRITE_NOP) begin
			if (otc_write <= (bl>>1)+32'd1)
				dqs_en <= 1'b1;
			else
				dqs_en <= 1'b0;
		end else
			dqs_en <= 0;
    	end	
 
    

// Functions
    function integer ceil;
	input number;
	integer number;
		ceil = number + 1;
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
    integer              tck	 =2500;
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
    wire 		 [31:0] tx_pr	 = 32'd1 + (TXPR/tck);

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

// Refresh
   wire [31:0] refresh_threshold		=	{20'd0,trfc} + 32'd10;
   reg  [31:0] refresh_counter; 

// Addressing
   wire   [COL_BITS-1:0] col		=	a_buffer[COL_BITS-1:0];		
   wire   [ADDR_BITS-1:0] atemp_0	=	col & 10'h3ff;         //a[ 9: 0] = COL[ 9: 0]
   wire   [ADDR_BITS-1:0] atemp_1	=	((col>>10) & 1'h1)<<11;//a[   11] = COL[   10]
   wire   [ADDR_BITS-1:0] atemp_2	=	(col>>11)<<13;         //a[ N:13] = COL[ N:11]
   wire   [ROW_BITS-1:0] row 		=	address[ROW_BITS+COL_BITS-1:COL_BITS];



// Change State Logic: Delays, One Time Counters and Change State Triggers

   wire [31:0] delay_powerup_0		=	32'd40000;
   wire [31:0] delay_powerup_1		=	32'd100000;
   wire [31:0] delay_precharge		=	{20'd0 ,trp}>>2;	
   wire [31:0] delay_activate			=  	{20'd0, trcd}>>2;
   wire [31:0] delay_write			=	{20'd0,{{7'd0,wl} + 12'd4 + twtr}}>>2;
   wire [31:0] delay_read			=	({27'd0, rl} + (bl>>1) + 32'd1)>>2;
   wire [31:0] delay_load_mode			=	({20'd0, tmrd-12'd1} + 32'd1)>>2;
   wire [31:0] delay_initialization_final	=	(32'd512)>>2;
   wire [31:0] delay_powerup_final		=	(tx_pr)>>1;
   wire [31:0] delay_write_0			=	({27'd0,wl}  + (bl>>1) + 32'd1)>>2;
   wire [31:0] delay_refresh			=	{20'd0,trfc}>>2;


   reg [31:0] otc_powerup_0;
   reg [31:0] otc_powerup_1;
   reg [31:0] otc_powerup_1_nop;
   reg [31:0] otc_zq;
   reg [31:0] otc_loadmode3;
   reg [31:0] otc_loadmode2;
   reg [31:0] otc_loadmode1;
   reg [31:0] otc_loadmode0;
   reg [31:0] otc_setodt;
   reg [31:0] otc_write_act;
   reg [31:0] otc_write;
   reg [31:0] otc_read_activate;
   reg [31:0] otc_read;
   reg [31:0] otc_precharge;
   reg [31:0] otc_refresh;


   wire change_powerup_0_state = (otc_powerup_0) ? 0 : 1;
   wire change_powerup_1_state = (otc_powerup_1) ? 0 : 1;
   wire change_powerup_1_nop_state = (otc_powerup_1_nop) ? 0 : 1;
   wire change_zqcallibration_nop_state = (otc_zq) ? 0 : 1;
   wire change_loadmode_3_nop_state = (otc_loadmode3) ? 0 : 1;
   wire change_loadmode_2_nop_state = (otc_loadmode2) ? 0 : 1;
   wire change_loadmode_1_nop_state = (otc_loadmode1) ? 0 : 1;
   wire change_loadmode_0_nop_state = (otc_loadmode0) ? 0 : 1;
   wire change_set_odt_nop_state = (otc_setodt) ? 0 : 1;
   wire change_write_activate_nop_state = (otc_write_act) ? 0 : 1;
   wire change_read_activate_nop_state = (otc_read_activate) ? 0 : 1;
   wire change_write_nop_state = (otc_write) ? 0 : 1;
   wire change_precharge_nop_state = (otc_precharge) ? 0 : 1;
   wire change_read_nop_state = (otc_read) ? 0 : 1;
   wire change_refresh_nop_state = (otc_refresh) ? 0 : 1;


always @(posedge clk) begin
	otc_powerup_0		<=	((state == STATE_POWERUP_0) && !rst_i) 	? otc_powerup_0 	- (otc_powerup_0      ? 32'd1 : 32'd0) 		: delay_powerup_0;
	otc_powerup_1		<=	(state == STATE_POWERUP_1) 		? otc_powerup_1 	- (otc_powerup_1      ? 32'd1 : 32'd0) 		: delay_powerup_1;
	otc_powerup_1_nop	<=	(state == STATE_POWERUP_1_NOP) 		? otc_powerup_1_nop 	- (otc_powerup_1_nop  ? 32'd1 : 32'd0) 		: delay_powerup_final;
	otc_zq			<=	(state == STATE_ZQCALLIBRATION_NOP) 	? otc_zq 		- (otc_zq ? 32'd1 : 32'd0) 			: delay_load_mode;
	otc_loadmode3		<=	(state == STATE_LOADMODE_3_NOP) 	? otc_loadmode3 	- (otc_loadmode3  ? 32'd1 : 32'd0) 		: delay_load_mode;
	otc_loadmode2		<=	(state == STATE_LOADMODE_2_NOP) 	? otc_loadmode2 	- (otc_loadmode2  ? 32'd1 : 32'd0) 		: delay_load_mode;
	otc_loadmode1		<=	(state == STATE_LOADMODE_1_NOP) 	? otc_loadmode1 	- (otc_loadmode1  ? 32'd1 : 32'd0) 		: delay_load_mode;
	otc_loadmode0		<=	(state == STATE_LOADMODE_0_NOP) 	? otc_loadmode0 	- (otc_loadmode0  ? 32'd1 : 32'd0) 		: delay_initialization_final;
	otc_setodt		<=	(state == STATE_SET_ODT_NOP) 		? otc_setodt 		- (otc_setodt  ? 32'd1 : 32'd0) 		: 32'd5;
	otc_write_act		<=	(state == STATE_WRITE_ACTIVATE_NOP) 	? otc_write_act 	- (otc_write_act  ? 32'd1 : 32'd0) 		: delay_activate;
	otc_write		<=	(state == STATE_WRITE_NOP) 		? otc_write 		- (otc_write  ? 32'd1 : 32'd0) 			: delay_write_0 + 32'd2;
	otc_read_activate	<=	(state == STATE_READ_ACTIVATE_NOP) 	? otc_read_activate 	- (otc_read_activate  ? 32'd1 : 32'd0) 		: delay_activate;
	otc_read		<=	(state == STATE_READ_NOP) 		? otc_read 		- (otc_read  ? 32'd1 : 32'd0) 			: delay_read + 32'd1;
	otc_precharge		<=	(state == STATE_PRECHARGE_NOP) 		? otc_precharge 	- (otc_precharge  ? 32'd1 : 32'd0) 		: delay_precharge + 32'd1;
	otc_refresh		<=	(state == STATE_REFRESH_NOP) 		? otc_refresh 		- (otc_refresh  ? 32'd1 : 32'd0) 		: delay_refresh;
end


reg [3:0] dq_counter;

always @(posedge clk_400M) begin
	if (state != STATE_WRITE_NOP)
		dq_counter <= 9;
	else
		dq_counter <= dq_counter - ((dq_counter)? 3'd1 : 3'd0);
end

// State Machine
always @(posedge clk_i) begin
//	refresh_counter <= (refresh_counter) ?  refresh_counter - 32'd1 : refresh_counter; 
	if (rst_i || ~locked[0]) begin
		state 			<= 	STATE_POWERUP_0;
		rst_n   		<= 	1'b0;
		cke			<=	1'b0;
		cs_n			<=	1'b1;
		ras_n			<=	1'b1;
		cas_n  			<=	1'b1;
	        we_n   			<=	1'b1;
	        ba     			<=	{BA_BITS{1'bz}};
	       	a      			<=	{ADDR_BITS{1'bz}};
	        odt	 		<=	1'b0;
	        dq_en   		<=	1'b0;
		dm_out			<=	{DM_BITS{1'bz}};
		ack			<=	1'b0;
		busy			<=	1'b1;
		dq_write_buffer		<= 	0;
		read_data 		<=	0;
//		refresh_counter		<=	0;
		
	end else if (state == STATE_POWERUP_0) begin
       		state <= (change_powerup_0_state) ? STATE_POWERUP_1 : STATE_POWERUP_0;
		rst_n <= 1'b0;
            	cke <= 1'b0;
            	cs_n <= 1'b1;
	
	end else if (state == STATE_POWERUP_1) begin
		state <= STATE_POWERUP_1_NOP; 
		rst_n <= 1'b1;
		state <= (change_powerup_1_state) ? STATE_POWERUP_1_NOP : STATE_POWERUP_1;

	end else if (state == STATE_POWERUP_1_NOP) begin
		state <= (change_powerup_1_nop_state) ? STATE_ZQCALLIBRATION : STATE_POWERUP_1_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= 1'b0;

	end else if (state == STATE_ZQCALLIBRATION) begin
		state <= STATE_ZQCALLIBRATION_NOP; 	
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
             	we_n  <= 1'b0;
           	ba    <=  0;
            	a     <=  1<<10;
		
	end else if (state == STATE_ZQCALLIBRATION_NOP) begin
		state <= (change_zqcallibration_nop_state) ? STATE_LOADMODE_3 : STATE_ZQCALLIBRATION_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= 1'b0;

	end else if (state == STATE_LOADMODE_3) begin
		state <= STATE_LOADMODE_3_NOP;
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b0;
            	we_n  <= 1'b0;
            	ba    <= 3;
            	a     <= 0;	
	
	end else if (state == STATE_LOADMODE_3_NOP) begin
		state <= (change_loadmode_3_nop_state) ? STATE_LOADMODE_2 : STATE_LOADMODE_3_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= 1'b0;

	end else if (state == STATE_LOADMODE_2) begin
		state <= STATE_LOADMODE_2_NOP;
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b0;
            	we_n  <= 1'b0;
            	ba    <= 2;
            	a     <= mode_reg2;
	
	end else if (state == STATE_LOADMODE_2_NOP) begin
		state <= (change_loadmode_2_nop_state) ? STATE_LOADMODE_1 : STATE_LOADMODE_2_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= 1'b0;

	end else if (state == STATE_LOADMODE_1) begin
		state <= STATE_LOADMODE_1_NOP;
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b0;
            	we_n  <= 1'b0;
            	ba    <= 1;
            	a     <= mode_reg1;
	
	end else if (state == STATE_LOADMODE_1_NOP) begin
		state <= (change_loadmode_1_nop_state) ? STATE_LOADMODE_0 : STATE_LOADMODE_1_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= 1'b0;

	end else if (state == STATE_LOADMODE_0) begin
		state <= STATE_LOADMODE_0_NOP;
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b0;
            	we_n  <= 1'b0;
            	ba    <= 0;
            	a     <= mode_reg0;
	
	end else if (state == STATE_LOADMODE_0_NOP) begin
		state <= (change_loadmode_0_nop_state) ? STATE_SET_ODT : STATE_LOADMODE_0_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= 1'b0;

	end else if (state == STATE_SET_ODT) begin
		state <= STATE_SET_ODT_NOP;
		odt <= 1;

	end else if (state == STATE_SET_ODT_NOP) begin
		state <= (change_set_odt_nop_state) ? STATE_IDLE : STATE_SET_ODT_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= 1'b0;

	end else if (state == STATE_IDLE) begin
		busy		<=	0;
		ack = 0;
		dq_write_buffer	<=	{write_data,{DQ_BITS{1'b0}}};	
		a_buffer	<=	address[ROW_BITS+COL_BITS-1:0];
		ba_buffer	<=	address[BA_BITS+ROW_BITS+COL_BITS-1:ROW_BITS+COL_BITS];
		if (write) begin
			state			<=	STATE_WRITE_ACTIVATE;
			odt 			<=	1'b1; 
			dq_en			<=	1'b1;
		end else if (read) begin
			state			<=	STATE_READ_ACTIVATE;
			odt			<=	1'b0;
			dq_en			<=	1'b0;
		end

	end else if (state == STATE_WRITE_ACTIVATE) begin
		busy <= 1;
		state <= STATE_WRITE_ACTIVATE_NOP ;
		cke   <= 1'b1;
        	cs_n  <= 1'b0;
        	ras_n <= 1'b0;
        	cas_n <= 1'b1;
        	we_n  <= 1'b1;
        	ba    <= ba_buffer;
       		a     <=  a_buffer[ROW_BITS+COL_BITS-1:COL_BITS];

	end else if (state == STATE_WRITE_ACTIVATE_NOP) begin
		state <= (change_write_activate_nop_state) ? STATE_WRITE : STATE_WRITE_ACTIVATE_NOP;		
		cke   <= 1'b1;
       		cs_n  <= 1'b0;
        	ras_n <= 1'b1;
        	cas_n <= 1'b1;
        	we_n  <= 1'b1;

	end else if (state == STATE_WRITE) begin	
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b0;
            	we_n  <= 1'b0;	
		ba   <= ba_buffer;
           	a     <= atemp_0 | atemp_1 | atemp_2;
		dm_out <= 0;	
		state <= STATE_WRITE_NOP;
		dq_en <= 1'b1;

	end else if (state == STATE_WRITE_NOP) begin
		state <=(change_write_nop_state) ? STATE_PRECHARGE : STATE_WRITE_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= (change_write_nop_state) ? 1'b1 : ack;      	
		dq_write_buffer <= (dq_counter  == 0) ?  (dq_write_buffer >> DQ_BITS*2) : dq_write_buffer;

	end else if (state == STATE_READ_ACTIVATE) begin
		busy <= 1;
		state <= STATE_READ_ACTIVATE_NOP;
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b1;
            	we_n  <= 1'b1;
            	ba    <= ba_buffer;
            	a     <=  a_buffer[ROW_BITS+COL_BITS-1:COL_BITS];

	end else if (state == STATE_READ_ACTIVATE_NOP) begin
		state <= (change_read_activate_nop_state) ? STATE_READ : STATE_READ_ACTIVATE_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;

	end else if (state == STATE_READ) begin	
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b0;
            	we_n  <= 1'b1;	
		state <= STATE_READ_NOP;
		ba    <= ba_buffer;
           	a     <= atemp_0 | atemp_1 | atemp_2;

	end else if (state == STATE_READ_NOP) begin
		state <= (change_read_nop_state) ? STATE_PRECHARGE : STATE_READ_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= (change_read_nop_state) ? 1'b1 : ack;      	
		read_data  <=	 {dq_read_buffer_1,dq_read_buffer_0};
            	
	end else if (state == STATE_PRECHARGE) begin
		state <= STATE_PRECHARGE_NOP;
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b1;
            	we_n  <= 1'b0;
            	ba    <= ba_buffer;
            	a     <= 0;
            	ack   <= 0;
 	
	end else if (state == STATE_PRECHARGE_NOP) begin
		state <= (change_precharge_nop_state) ? STATE_IDLE : STATE_PRECHARGE_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= 1'b0;      	
            	
	end else if (state == STATE_REFRESH) begin
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b0;
            	cas_n <= 1'b0;
            	we_n  <= 1'b1;
		state <= STATE_REFRESH_NOP; 	
	
	end else if (state == STATE_REFRESH_NOP) begin
		state <= (change_refresh_nop_state) ? STATE_IDLE : STATE_REFRESH_NOP;		
		cke   <= 1'b1;
            	cs_n  <= 1'b0;
            	ras_n <= 1'b1;
            	cas_n <= 1'b1;
           	we_n  <= 1'b1;
           	ack   <= 1'b0;
	end
end


// Debug output
assign debug = (rst_i) ? 8'b10101010 : {2'd0,state}; 



endmodule 

`ifdef SIMULATION
module ODDR2 (output Q, input C0, input C1, input R, input S, input D0, input D1);
	assign Q = (C0) ? D0 : D1;
endmodule


module IOBUF (output O, inout IO, input I, input T);
	assign O = IO;
	assign IO = (T) ? 1'bz : I;
endmodule


module pll_100M_400M (input clk, output reg clk_i, output reg clk_400M, output reg dqs_clk, output locked);

assign locked = 1;
initial begin
	clk_400M = 0;
	clk_i = 1;
end
always #1250 clk_i = ~clk_i;
always #1250 clk_400M = ~clk_400M;
always @(clk_400M)  dqs_clk = #(125) clk_400M; 
endmodule



module OBUFDS (input I, output O, output OB);
	parameter IOSTANDARD = "DEFAULT";
	assign O = I;
	assign OB = ~I;
endmodule


module IOBUFDS (output O, inout IO, inout IOB, input I, input T);
	assign O = IO;
	assign IO = (T) ? 1'bz : I;
	assign IOB = (T) ? 1'bz : ~I;
endmodule
`endif








