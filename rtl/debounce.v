`default_nettype none
module debounce 
#(
    parameter hist_len = 8
)(
    input wire clk,
    input wire clk_en,
    input wire button,
    output reg debounced
);

    reg [hist_len-1:0] button_hist = 0;

    always@(posedge clk) 
        if(clk_en) begin
            button_hist <= {button_hist[hist_len-2:0], button };

            if(&button_hist) 
               debounced <= 1;
            else if(button_hist == 0)
               debounced <= 0;
        end

    `ifdef FORMAL
        default clocking @(posedge clk); endclocking
        default disable iff (!clk_en);
        assert property (button[*hist_len] |=> ##1 (debounced == $past(button, 2)));
        cover property (##1 $rose(debounced));
    `endif
endmodule
