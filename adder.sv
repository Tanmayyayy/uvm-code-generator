module adder (
    input logic clk,
    input logic rst_n,
    input logic [3:0] a,
    input logic [3:0] b,
    output logic [3:0] sum
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            sum <= 4'b0;
        else
            sum <= a + b;
    end

endmodule

