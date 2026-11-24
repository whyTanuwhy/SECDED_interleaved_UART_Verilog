`timescale 1ns / 1ps

module twobytes_rx_fsm(
    input clk,
    input reset,
    input rx_done,
    input [7:0]rx_data,
    output reg [7:0]firstbyte,
    output reg [7:0]secondbyte,
    output reg twobytes_received
    );
    localparam RX1STBYTE=1'b0, RX2NDBYTE=1'b1;
    reg state;
    
    always@(posedge clk)begin
        if(reset)begin
            firstbyte<=8'b0;
            secondbyte<=8'b0;
            twobytes_received<=1'b0;
            state<=RX1STBYTE;
            end
            else begin 
                twobytes_received<=1'b0;
                case(state)
                    RX1STBYTE:
                        if(rx_done==1'b1)begin
                            firstbyte<=rx_data;
                            state<=RX2NDBYTE;
                            end
                    RX2NDBYTE:
                        if(rx_done==1'b1)begin  
                            secondbyte<=rx_data;
                            twobytes_received<=1'b1;
                            state<=RX1STBYTE;
                            end
                    default:state<=RX1STBYTE;
                    endcase
                    end
                    end
endmodule
