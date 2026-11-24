`timescale 1ns / 1ps

module twobytes_tx_fsm(
    input clk,
    input reset,
    input twobytes_start,
    input [7:0]firstbyte,
    input [7:0]secondbyte,
    input tx_done,
    output reg tx_start,
    output reg [7:0]tx_data,
    output reg twobytes_done
    );
    localparam IDLE=2'b00, SEND1STBYTE=2'b01, SEND2NDBYTE=2'b10; 
    reg [1:0]state;
    reg [7:0]secondbyte_buffer; //it saves 2nd byte while first is being sent
    
    always@(posedge clk)begin
        if(reset)begin
            tx_start<=1'b0;
            tx_data<=8'b0;
            twobytes_done<=1'b0;
            state<=IDLE;
          end
        else begin 
            case(state)
                IDLE:begin
                 tx_data<=8'b0;
                 tx_start <= 1'b0;
                 twobytes_done<=1'b0;
                 if(twobytes_start==1'b1)begin
                    tx_data<=firstbyte;
                    secondbyte_buffer<=secondbyte;
                    tx_start<=1'b1;
                    state<=SEND1STBYTE;
                    end
                    end 
                SEND1STBYTE:begin 
                    tx_start <= 1'b0;
                    if(tx_done==1'b1)begin
                        tx_data<=secondbyte_buffer;
                        tx_start<=1'b1;
                        state<=SEND2NDBYTE;
                        end
                        end
                 SEND2NDBYTE:begin
                    tx_start <= 1'b0;
                    if(tx_done==1'b1)begin
                        twobytes_done<=1'b1;
                        state<=IDLE;
                        end
                       end
                 default:state<=IDLE;
                 endcase
                 end
                 end 
    
    
endmodule
