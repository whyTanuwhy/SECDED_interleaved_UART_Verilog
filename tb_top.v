`timescale 1ns / 1ps

module tb_top;

    reg clk = 0;
    reg reset = 1;
    reg twobyte_start = 0;
    reg [3:0] data_nibble1_in = 4'b0;
    reg [3:0] data_nibble2_in = 4'b0;

    wire uart_tx_wire;
    reg [9:0] error_pattern = 10'b0000000000;
    reg error_inject = 1'b0;
    wire uart_rx_wire = uart_tx_wire ^ error_inject; // adding errors

    wire twobytes_done;
    wire [3:0] data_nibble1_out;
    wire [3:0] data_nibble2_out;
    wire twobytes_received;
    wire doubleerror1, doubleerror2;
    integer i;
    always #5 clk = ~clk; // clk time period is 10ns so freq=100Mhz (1/10^-8) as that is my baud counter's freq

    top uut(
        .clk(clk),
        .reset(reset),
        .twobyte_start(twobyte_start),
        .data_nibble1_in(data_nibble1_in),
        .data_nibble2_in(data_nibble2_in),
        .uart_rx_wire(uart_rx_wire),
        .uart_tx_wire(uart_tx_wire),
        .twobytes_done(twobytes_done),
        .data_nibble1_out(data_nibble1_out),
        .data_nibble2_out(data_nibble2_out),
        .twobytes_received(twobytes_received),
        .doubleerror1(doubleerror1),
        .doubleerror2(doubleerror2)
    );

    initial begin
        // we hold reset=1 and then do reset=0 so that all our fsm start at IDLE
        #100;
        reset = 0;
        #100;

        // test 1- sending two nibbles with no errors
        error_inject = 1'b0;
        data_nibble1_in = 4'b1010;
        data_nibble2_in = 4'b1100;
        @(posedge clk) twobyte_start = 1;
        @(posedge clk) twobyte_start = 0;

        @(posedge twobytes_done); // waits until receiver gets both bytes (sent by tx which sends 0.5t after rx sends twobytes_received)
        #20;
        if (data_nibble1_out == 4'b1010 && data_nibble2_out == 4'b1100 && !doubleerror1 && !doubleerror2)
            $display("test 1 pass (clean)- out1=%b out2=%b", data_nibble1_out, data_nibble2_out);
        else
            $display("test 1 fail (clean)- out1=%b out2=%b", data_nibble1_out, data_nibble2_out);

        #20000; // just for padding

        // test 2- adding a two bit adjacent burst error on the uart wire (bit 7 and bit 6 -> b[3] and a[3])
        data_nibble1_in = 4'b0110;
        data_nibble2_in = 4'b1001;
        @(posedge clk) twobyte_start = 1;
        @(posedge clk) twobyte_start = 0;

        @(negedge uart_tx_wire);        // waiting for START bit's falling edge
        error_pattern = 10'b0110000000; // {stop, bit7-bit0, start}
        for (i = 0; i < 10; i = i + 1) begin
            error_inject = error_pattern[i];
            repeat (16) @(posedge uut.tickx16); // waits 1 uart bit
        end
        error_inject = 1'b0;

        @(posedge twobytes_done);
        #20;
        if (data_nibble1_out == 4'b0110 && data_nibble2_out == 4'b1001 && !doubleerror1 && !doubleerror2)
            $display("test 2 pass (2 bit burst corrected)- out1=%b out2=%b", data_nibble1_out, data_nibble2_out);
        else
            $display("test 2 fail - out1=%b out2=%b doubleerror=%b%b", data_nibble1_out, data_nibble2_out, doubleerror1, doubleerror2);

        #20000;

        // test 3- adding two bit errors in the same codeword (bit 7 and bit 5 -> b[3] data bit and b[2] parity bit)
        data_nibble1_in = 4'b1101;
        data_nibble2_in = 4'b0011;
        @(posedge clk) twobyte_start = 1;
        @(posedge clk) twobyte_start = 0;

        @(negedge uart_tx_wire);        // waiting for START bit's falling edge
        error_pattern = 10'b0101000000; // {stop, bit7-bit0, start}
        for (i = 0; i < 10; i = i + 1) begin
            error_inject = error_pattern[i];
            repeat (16) @(posedge uut.tickx16); // waits 1 uart bit
        end
        error_inject = 1'b0;

        @(posedge twobytes_done);
        #20;
        if (data_nibble1_out == 4'b1101 && !doubleerror1 && doubleerror2)
            $display("test 3 pass (double error detected)- out1=%b out2=%b doubleerror=%b%b", data_nibble1_out, data_nibble2_out, doubleerror1, doubleerror2);
        else
            $display("test 3 fail - out1=%b out2=%b doubleerror=%b%b", data_nibble1_out, data_nibble2_out, doubleerror1, doubleerror2);

        #1000000;
        $finish;
    end
endmodule