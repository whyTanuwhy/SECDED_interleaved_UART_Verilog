`timescale 1ns / 1ps
    
module baud_counter#(
    parameter CLK_freq=100000000, //10^8 cycles/second 
    parameter BaudRate=9600)   //  bits/second
    (
    input wire clk,
    output reg tickx16=0
    );
    
    localparam cyclesperbit=CLK_freq/(16*BaudRate);  //cycles/bit 16x oversampling
    reg [$clog2(cyclesperbit)-1:0]count=0;  //no.of bits req to count to cyclesperbit
    always @(posedge clk)begin
        if(count==cyclesperbit-1)begin 
            count<=0;
            tickx16<=1'b1;
            end
        else begin
            count<=count+1;
            tickx16<=1'b0;
            end
        end
endmodule
