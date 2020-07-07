`default_nettype none
module digit
    #(
    parameter DIGIT_INDEX_FILE = "digit_index.hex",
    parameter COL_INDEX_FILE = "col_index.hex"
    )
    (
    input wire clk,
    input wire reset,
    input wire [5:0] x_block,
    input wire [5:0] y_block,
    input wire [3:0] number,      // the number to display: [0->9: ]
    output reg [5:0] digit_index,
    output reg [1:0] col_index
    );
    
    localparam FONT_H = 5'd5;
    reg [5:0] digit_index_mem [0:11];
    reg [1:0] col_index_mem [0:26];

    initial begin
        if (DIGIT_INDEX_FILE) $readmemh(DIGIT_INDEX_FILE, digit_index_mem);
        if (COL_INDEX_FILE) $readmemh(COL_INDEX_FILE, col_index_mem);
    end

    always @(posedge clk) begin
        digit_index <= digit_index_mem[number];
        col_index <= col_index_mem[x_block];
    end
   
endmodule
