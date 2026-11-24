`timescale 1ns / 1ps

module SECDED_Encoder(
    input wire [4:1] D,
    output wire [7:0] E
    );
    wire P0,P1,P2,P3;
    assign P1=D[1]^D[2]^D[4];
    assign P2=D[1]^D[3]^D[4];
    assign P3=D[2]^D[3]^D[4];
    assign P0=D[4]^D[3]^D[2]^D[1]^P1^P2^P3;
    assign E={D[4],D[3],D[2],P3,D[1],P2,P1,P0};
    
endmodule
