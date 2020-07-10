module test;

    reg clk = 0;
    reg px_clk = 0;
    reg reset_n = 0;
    localparam DAY = 60 * 60 * 60;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);
        # 4
        reset_n = 1;
        # DAY;
        $finish;
    end

    top top_0(.clk(clk), .reset_n(reset_n));
    assign top_0.vga_0.px_clk = px_clk;
    always #4 clk = !clk;
    always #1 px_clk = !px_clk;

endmodule
