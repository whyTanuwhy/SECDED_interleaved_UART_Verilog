`timescale 1ns / 1ps

module SECDED_Decoder(
    input wire [7:0] E,
    output reg [2:0] S,
    output reg paritycheck,
    output reg [7:0] Ecorrected,
    output reg [3:0]Dout,
    output reg doubleerror=0
    );
    reg S1,S2,S3;
    always@(*) begin
    S1=E[1]^E[3]^E[5]^E[7];
    S2=E[2]^E[3]^E[6]^E[7];
    S3=E[4]^E[5]^E[6]^E[7];
    S={S3,S2,S1};
    paritycheck=E[0]^E[1]^E[2]^E[3]^E[4]^E[5]^E[6]^E[7];
    doubleerror=0;
    Ecorrected=E;
    Dout={E[7],E[6],E[5],E[3]};
    if(paritycheck==1'b1)begin
        if(S!=3'b000)begin
        Ecorrected[S]=~E[S];
        Dout={Ecorrected[7],Ecorrected[6],Ecorrected[5],Ecorrected[3]};
        end
        else begin //parity bit was flipped  
        Ecorrected[0]=~E[0];
        end
    end
    else begin  
        if(S!=3'b000)begin //double error detcted
        doubleerror=1;
        end
        else begin //no error, ig i dont have to do anything as i have already assigned Ecorrected=E and Dout
        end
    end   
    end  
endmodule
