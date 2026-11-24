`timescale 1ns / 1ps

module interleaver_8bitsx2(
    input [7:0]a, //codeword1
    input [7:0]b, //codeword 2
    output [7:0]tx_interleaved_0to3,
    output [7:0]tx_interleaved_4to7
    );
    assign tx_interleaved_0to3={b[3],a[3],b[2],a[2],b[1],a[1],b[0],a[0]};
    assign tx_interleaved_4to7={b[7],a[7],b[6],a[6],b[5],a[5],b[4],a[4]};
endmodule
