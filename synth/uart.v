module uart (CLK,RST,BUSY,ACK,ADDRESS,WRITE,READ,WRITE_DATA,READ_DATA,UART_T,UART_R, state);
parameter DATAW = 32;
parameter ADDRW = 32;

parameter NUM_DATA_BYTES = DATAW>>3;
parameter NUM_ADDR_BYTES = (ADDRW>>3)+32'd1; // address usually > 24 and < 32 so ceiling the result. replace at instantiation if needed.

input CLK;
input RST;
input BUSY;
input ACK;
output WRITE;
output reg READ;
output reg [DATAW-1:0] WRITE_DATA;
input [DATAW-1:0] READ_DATA;
output reg [ADDRW-1:0] ADDRESS;
input UART_R;
output UART_T;

reg [DATAW-1:0] read_buffer;
reg [31:0] addr_buffer;

wire [7:0] CMD_READ = 8'd48;
wire [7:0] CMD_WRITE = 8'd49;
wire [7:0] CMD_BUSY_CHECK = 8'd50;


output reg [7:0] state;
wire [7:0] STATE_IDLE = 32'd16;
wire [7:0] STATE_GET_WRITE_ADDRESS = 32'd1;
wire [7:0] STATE_GET_WRITE_DATA = 32'd2;
wire [7:0] STATE_SET_WRITE = 32'd8;
wire [7:0] STATE_WAIT_WRITE_ACK = 32'd3;
wire [7:0] STATE_GET_READ_ADDRESS = 32'd4;
wire [7:0] STATE_SET_READ_DATA = 32'd5;
wire [7:0] STATE_WAIT_READ_ACK = 32'd6;
wire [7:0] STATE_SET_ADDRESS = 32'd7;
wire [7:0] STATE_READ_NOP = 32'd9;
wire [7:0] STATE_NEW_LINE = 32'd10;
wire [7:0] STATE_CR = 32'd11;

reg [2:0] address_shift_counter;
reg [4:0] data_shift_counter;


reg tx_trigger;
wire rx_trigger;
wire done;
wire active;
reg [7:0] tx_byte;
wire [7:0] rx_byte;


assign WRITE = (state == STATE_SET_WRITE);

wire clk_200M;

        pll_100M_400M  pl(.clk_i(CLK), .clk_o0(clk_200M));
        
always @(posedge clk_200M) begin
    if (RST) begin
        state <= STATE_IDLE;
        tx_trigger <= 0;
        tx_byte <= 0;
        address_shift_counter <= 0;
        data_shift_counter <= 0;
        read_buffer <= 0;
        addr_buffer <= 0;
        READ <= 0;
        WRITE_DATA <= 0;
        ADDRESS <= 0;
        
     end else if (tx_trigger) begin
        tx_trigger <= 0;
        
     end else if (active) begin
        // wait for transmission to finish 
        
     end else if (BUSY && (state == STATE_IDLE)) begin
        if (rx_trigger && (rx_byte == CMD_BUSY_CHECK)) begin
            tx_byte <= 8'd49;
            tx_trigger <= 1'b1;
        end
        
     end else if (state == STATE_IDLE) begin
        address_shift_counter <= 0;
        data_shift_counter <= 0;
        addr_buffer <= 0;
        if (rx_trigger) begin
            if (rx_byte == CMD_BUSY_CHECK) begin
                tx_byte <= 8'd48;
                tx_trigger <= 1'b1;
            end else if (rx_byte == CMD_WRITE) begin
                state <= STATE_GET_WRITE_ADDRESS;
            end else if (rx_byte == CMD_READ) begin
                state <= STATE_GET_READ_ADDRESS;
            end
        end
        
      end else if (state == STATE_GET_WRITE_ADDRESS) begin
            if (rx_trigger) begin
                addr_buffer <= {rx_byte,addr_buffer [31:8]};
                address_shift_counter <= address_shift_counter + 3'd1;
            end
            state <= (address_shift_counter >= NUM_ADDR_BYTES) ? STATE_GET_WRITE_DATA  : STATE_GET_WRITE_ADDRESS;
            ADDRESS <= addr_buffer[ADDRW-1:0];
            
       end else if (state == STATE_GET_WRITE_DATA) begin
            address_shift_counter <= 0;
            if (rx_trigger) begin
                WRITE_DATA <= {rx_byte,WRITE_DATA[DATAW-1:8]};
                data_shift_counter <= data_shift_counter + 5'd1;
            end
            state <= (data_shift_counter >= NUM_DATA_BYTES) ? STATE_SET_WRITE  : STATE_GET_WRITE_DATA;
            
            
            
            
            
            
       end else if (state == STATE_SET_WRITE) begin
            state <= STATE_WAIT_WRITE_ACK;
                            
                    
       end else if (state == STATE_WAIT_WRITE_ACK) begin
            data_shift_counter <= 0;
            if (ACK) begin
                state <= STATE_SET_ADDRESS;
            end 
            
       end else if (state == STATE_GET_READ_ADDRESS) begin
            if (rx_trigger) begin
                addr_buffer <= {rx_byte,addr_buffer [31:8]};
                address_shift_counter <= address_shift_counter + 3'd1;
            end
            state <= (address_shift_counter >= NUM_ADDR_BYTES) ? STATE_WAIT_READ_ACK  : STATE_GET_READ_ADDRESS;
            READ <=  (address_shift_counter >= NUM_ADDR_BYTES) ? 1'b1  : 1'b0;
            ADDRESS <= addr_buffer[ADDRW-1:0];
                                     
        end else if (state == STATE_WAIT_READ_ACK) begin
            READ <= 0;
            data_shift_counter <= 0;
            address_shift_counter <= 0;
            if (ACK) begin
                state <= STATE_READ_NOP;
            end  
            
        end else if (state == STATE_READ_NOP) begin
            read_buffer <= READ_DATA;
            state <= STATE_SET_READ_DATA;
            
        end else if (state == STATE_SET_READ_DATA) begin
            data_shift_counter <= data_shift_counter + 5'd1;
            tx_byte <= read_buffer[7:0];
            tx_trigger <= 1'b1;
            read_buffer <= read_buffer >> 8;
            state <= (data_shift_counter >= (NUM_DATA_BYTES-32'd1)) ? STATE_SET_ADDRESS  : STATE_SET_READ_DATA;
 
        end else if (state == STATE_SET_ADDRESS) begin
            address_shift_counter <= address_shift_counter + 3'd1;
            tx_byte <= addr_buffer[7:0];
            tx_trigger <= 1'b1;
            addr_buffer <= addr_buffer >> 8;
            state <= (address_shift_counter >= (NUM_ADDR_BYTES-32'd1)) ? STATE_NEW_LINE  : STATE_SET_ADDRESS;
            
       end else if (state == STATE_NEW_LINE) begin
                        tx_byte <= 8'd10;
                        tx_trigger <= 1'b1;
                        state <= STATE_CR;  
                              
       end else if (state == STATE_CR) begin
                        tx_byte <= 8'd13;
                        tx_trigger <= 1'b1;
                        state <= STATE_IDLE;        

        end
     end




uart_tx  utx
  (
   .i_Clock(clk_200M),
   .i_Tx_DV(tx_trigger),
   .i_Tx_Byte(tx_byte),   
   .o_Tx_Active(active),
   .o_Tx_Serial(UART_T),
   .o_Tx_Done(done)
   );
 
  
  
uart_rx utr 
  (
   .i_Clock(clk_200M),
   .i_Rx_Serial(UART_R),
   .o_Rx_DV(rx_trigger),
   . o_Rx_Byte(rx_byte)
   );
   
   
endmodule
   