module test;

    reg clk = 0;
    reg reset_n = 0;
    localparam DAY = 60 * 60 * 60;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,test);
        # 2
        reset_n = 1;
        # DAY;
        $finish;
    end

    top top_0(.clk(clk), .reset_n(reset_n));
    always #1 clk = !clk;

endmodule
