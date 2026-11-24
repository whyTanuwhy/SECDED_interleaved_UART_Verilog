`timescale 1ns / 1ps

module uart_tx(
    input clk,
    input reset,
    input tickx16,
    input tx_start,
    input [7:0]tx_data,
    output reg tx_out_wire,
    output reg tx_done
    );
    localparam IDLE=2'b00, START=2'b01, DATA=2'b10, STOP=2'b11;
    
    reg [1:0]state; 
    reg [3:0]tick_counter; 
    reg [2:0]bit_index_counter;
    reg [7:0]piso_shift_register;
    
    always@(posedge clk) begin
        if(reset)begin
            state<=IDLE;
            tick_counter<=4'b0;
            bit_index_counter<=3'b0;
            piso_shift_register<=8'b0;
            tx_out_wire<=1'b1;
            tx_done<=1'b0;          
            end
        else begin
            case(state)
                IDLE:begin
                    tx_done<=1'b0;
                    tx_out_wire<=1'b1;
                     if(tx_start==1'b1)begin
                        piso_shift_register<=tx_data;
                        tick_counter<=4'b0;
                        state<=START;
                    end
                    end
                START: begin 
                        tx_out_wire<=1'b0;
                        if(tickx16==1'b1)begin
                        if(tick_counter==4'b1111)begin
                            tick_counter<=4'b0;
                            bit_index_counter<=3'b0;
                            state<=DATA;
                            end
                            else begin tick_counter<=tick_counter+1; end
                        end                        
                      end  
                DATA:begin 
                        tx_out_wire<=piso_shift_register[bit_index_counter];
                        if(tickx16==1'b1)begin
                        if(tick_counter==4'b1111)begin
                            tick_counter<=4'b0;                          
                            if(bit_index_counter==3'b111)begin
                                bit_index_counter<=3'b0;
                                state<=STOP;
                                end
                                else begin bit_index_counter<=bit_index_counter+1;end
                            end
                            else begin tick_counter<=tick_counter+1; end
                        end
                        end
                STOP:begin tx_out_wire<=1'b1;
                        if(tickx16==1'b1)begin
                        if(tick_counter==4'b1111)begin  
                            tick_counter<=4'b0;
                            bit_index_counter<=3'b0;                    
                            tx_done<=1'b1;
                            state<=IDLE;
                            end
                            else begin tick_counter<=tick_counter+1; end
                        end
                    end
                default:state<=IDLE;
            endcase
          end
    end
endmodule
