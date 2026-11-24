`timescale 1ns / 1ps

module uart_rx(
    input clk,
    input reset,
    input tickx16,
    input rx_wire,
    output reg [7:0]rx_data,
    output reg rx_done
    );
    localparam IDLE=2'b00, START=2'b01, DATA=2'b10, STOP=2'b11;
    
    reg [1:0]state; 
    reg [3:0]tick_counter; 
    reg [2:0]bit_index_counter;
    reg [7:0]sipo_shift_register;
    
    always@(posedge clk) begin
        if(reset)begin
            state<=IDLE;
            tick_counter<=4'b0;
            bit_index_counter<=3'b0;
            sipo_shift_register<=8'b0;
            rx_data<=8'b0;
            rx_done<=1'b0;          
            end
        else begin
            case(state)
                IDLE:begin
                    rx_done<=1'b0;
                     if(rx_wire==1'b0)begin
                        //rx_data<=sipo_shift_register; no need for this right?
                        tick_counter<=4'b0;
                        state<=START;
                    end
                    end
                START: begin 
                        if(tickx16==1'b1)begin
                        if(tick_counter==4'b0111)begin //count till 7 so that we to get 0.5t
                            if(rx_wire==1'b0)begin
                                tick_counter<=4'b0;
                                bit_index_counter<=3'b0;
                                state<=DATA;
                            end
                            else begin //in case of glitch where at 0.5t its not 0 
                                tick_counter<=4'b0;
                                state<=IDLE;
                                end
                            end
                            else begin tick_counter<=tick_counter+1; end
                        end                        
                      end  
                DATA:begin 
                        if(tickx16==1'b1)begin
                        if(tick_counter==4'b1111)begin
                            tick_counter<=4'b0;
                            sipo_shift_register[bit_index_counter]<=rx_wire;                          
                            if(bit_index_counter==3'b111)begin
                                bit_index_counter<=3'b0;
                                state<=STOP;
                                end
                                else begin bit_index_counter<=bit_index_counter+1;end
                            end
                            else begin tick_counter<=tick_counter+1; end
                        end
                        end
                STOP:begin
                        if(tickx16==1'b1)begin
                        if(tick_counter==4'b1111)begin  
                            tick_counter<=4'b0;
                            bit_index_counter<=3'b0;  
                            rx_data<=sipo_shift_register;                  
                            rx_done<=1'b1;
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
