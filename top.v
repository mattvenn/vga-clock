`default_nettype none
module top (
    input wire clk, 
    input wire reset_n,
    output wire hsync,
    output wire vsync,
    output wire r1,
    output wire r2,
    output wire g1,
    output wire g2,
    output wire b1,
    output wire b2
    );

reg [3:0] sec_u;
reg [2:0] sec_d;
reg [3:0] min_u;
reg [2:0] min_d;
reg [3:0] hrs_u;
reg [1:0] hrs_d;
    wire reset = !reset_n;

    always @(posedge px_clk) begin
        if(reset) begin
            sec_u <= 6;
            sec_d <= 5;
            min_u <= 8;
            min_d <= 3;
            hrs_u <= 9;
            hrs_d <= 1;
        end else begin
            if(sec_u == 10) begin
                sec_u <= 0;
                sec_d <= sec_d + 1;
            end
            if(sec_d == 6) begin
                sec_d <= 0;
                min_u <= min_u + 1;
            end
            if(min_u == 10) begin
                min_u <= 0;
                min_d <= min_d + 1;
            end
            if(min_d == 6) begin
                min_d <= 0;
                hrs_u <= hrs_u + 1;
            end
            if(hrs_u == 10) begin
                hrs_u <= 0;
                hrs_d <= hrs_d + 1;
            end
            if(hrs_d == 2 && hrs_u == 4) begin
                hrs_u <= 0;
                hrs_d <= 0;
            end
        end

        sec_counter <= sec_counter + 1;
        if(sec_counter > 31_500_000) begin
            sec_u <= sec_u + 1;
            sec_counter <= 0;
        end
    end

    reg [25:0] sec_counter = 0;

    // these are in blocks
    localparam OFFSET_Y_BLK = 0;
    localparam OFFSET_X_BLK = 1;
    localparam FONT_W = 3;
    localparam FONT_H = 5;
    localparam COLON = 10;
    localparam BLANK = 11;

    wire [9:0] x_px;          // X position for actual pixel.
    wire [9:0] y_px;          // Y position for actual pixel.

    wire [5:0] x_block = x_px >> 4;
    wire [5:0] y_block = y_px >> 4;

    wire activevideo;
    wire px_clk;
    VgaSyncGen vga_0 (.clk(clk), .hsync(hsync), .vsync(vsync), .x_px(x_px), .y_px(y_px), .activevideo(activevideo), .px_clk(px_clk));

    wire [2:0] font_out;
    wire [5:0] font_addr;
    fontROM font_0 (.clk(px_clk), .addr(font_addr), .dout(font_out));
    wire [5:0] digit_index;
    wire [3:0] number;
    wire [1:0] col_index;

    digit digit_0 (.clk(px_clk), .x_block(x_block), .y_block(y_block), .number(number), .digit_index(digit_index), .col_index(col_index));


    assign number     = x_block < FONT_W * 1 ? hrs_d :
                        x_block < FONT_W * 2 ? hrs_u :
                        x_block < FONT_W * 3 ? COLON :
                        x_block < FONT_W * 4 ? min_d :
                        x_block < FONT_W * 5 ? min_u :
                        x_block < FONT_W * 6 ? COLON :
                        x_block < FONT_W * 7 ? sec_d :
                        x_block < FONT_W * 8 ? sec_u :
                        BLANK;

   
    assign r1 = activevideo && draw;
    assign r2 = activevideo && draw && x_block > FONT_W * 2;
    assign g1 = activevideo && draw && x_block > FONT_W * 4;
    assign g2 = activevideo && draw && x_block > FONT_W * 5;
    assign b1 = activevideo && draw && x_block > FONT_W * 6;
    assign b2 = activevideo && draw && x_block > FONT_W * 7;

    assign font_addr = digit_index + y_block;
    reg draw = 0;
    always @(posedge px_clk) begin
        if(x_block < FONT_W * 9 && y_block < FONT_H)
            draw <= font_out[(FONT_W - 1) - col_index];
        else
            draw <= 0;
    end
endmodule
