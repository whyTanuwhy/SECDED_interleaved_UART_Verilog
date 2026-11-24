`timescale 1ns / 1ps

module top#(parameter CLK_freq=100000000,parameter BaudRate=9600)(
    input clk,
    input reset,
    input twobyte_start,
    input [3:0]data_nibble1_in,
    input [3:0]data_nibble2_in,
    input uart_rx_wire,
    output uart_tx_wire,
    output twobytes_done,
    output reg [3:0]data_nibble1_out,
    output reg [3:0]data_nibble2_out,
    output twobytes_received,
    output reg doubleerror1,
    output reg doubleerror2
    );
    wire tickx16;
    //tx
    wire [7:0]codeword1_sent,codeword2_sent;
    wire [7:0]tx_firstbyte,tx_secondbyte;
    wire tx_start,tx_done;
    wire [7:0]tx_data;
    //rx
    wire [7:0]rx_data;
    wire rx_done;
    wire [7:0]rx_firstbyte,rx_secondbyte;
    wire [7:0]codeword1_received,codeword2_received;
    wire [3:0]dec1_out,dec2_out;
    wire dec1_de,dec2_de;

    baud_counter #(
        .CLK_freq(CLK_freq),
        .BaudRate(BaudRate)
    ) baud_gen (
        .clk(clk),
        .tickx16(tickx16)
    );

    //tx pathway- nibble to enc to interleaver to fsm that sends two bytes which are then sent through uart tx
    SECDED_Encoder enc1 (.D(data_nibble1_in), .E(codeword1_sent));
    SECDED_Encoder enc2 (.D(data_nibble2_in), .E(codeword2_sent));

    interleaver_8bitsx2 interleaver (
        .a(codeword1_sent),
        .b(codeword2_sent),
        .tx_interleaved_0to3(tx_firstbyte),
        .tx_interleaved_4to7(tx_secondbyte)
    );

    twobytes_tx_fsm tx_fsm (
        .clk(clk),
        .reset(reset),
        .twobytes_start(twobyte_start),
        .firstbyte(tx_firstbyte),
        .secondbyte(tx_secondbyte),
        .tx_done(tx_done),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .twobytes_done(twobytes_done)
    );

    uart_tx tx (
        .clk(clk),
        .reset(reset),
        .tickx16(tickx16),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_out_wire(uart_tx_wire),
        .tx_done(tx_done)
    );

    // rx pathway- rx gets 1byte at a time throguh uart then fsm after waiting for 2nd byte
    // sends two bytes to deinterleaver whcih seperates the codewords then decoder decodes both seperately
    uart_rx rx (
        .clk(clk),
        .reset(reset),
        .tickx16(tickx16),
        .rx_wire(uart_rx_wire),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    twobytes_rx_fsm rx_fsm (
        .clk(clk),
        .reset(reset),
        .rx_done(rx_done),
        .rx_data(rx_data),
        .firstbyte(rx_firstbyte),
        .secondbyte(rx_secondbyte),
        .twobytes_received(twobytes_received)
    );

    deinterleaver_16bits_tohalf deinterleaver (
        .a(rx_firstbyte),
        .b(rx_secondbyte),
        .codeword1(codeword1_received),
        .codeword2(codeword2_received)
    );

    SECDED_Decoder dec1 (
        .E(codeword1_received),
        .S(),
        .paritycheck(),
        .Ecorrected(),
        .Dout(dec1_out),
        .doubleerror(dec1_de)
    );

    SECDED_Decoder dec2 (
        .E(codeword2_received),
        .S(),
        .paritycheck(),
        .Ecorrected(),
        .Dout(dec2_out),
        .doubleerror(dec2_de)
    );

    // latch decoded outputs and flags only when both bytes have arrived
    always @(posedge clk) begin
        if (reset) begin
            data_nibble1_out <= 4'b0000;
            data_nibble2_out <= 4'b0000;
            doubleerror1 <= 1'b0;
            doubleerror2 <= 1'b0;
        end else if (twobytes_received) begin
            data_nibble1_out <= dec1_out;
            data_nibble2_out <= dec2_out;
            doubleerror1 <= dec1_de;
            doubleerror2 <= dec2_de;
        end
    end

endmodule