`timescale 1ns / 1ps

module deinterleaver_16bits_tohalf(
    input [7:0]a,//rx_interleaved_0to3 
    input [7:0]b,//rx_interleaved_4to7
    output [7:0]codeword1, 
    output [7:0]codeword2
    );
    assign codeword1={b[6],b[4],b[2],b[0],a[6],a[4],a[2],a[0]};
    assign codeword2={b[7],b[5],b[3],b[1],a[7],a[5],a[3],a[1]};
endmodule

