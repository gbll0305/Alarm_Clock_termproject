`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 11:02:05 AM
// Design Name: 
// Module Name: count_ones
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module count_ones_10bit (
        input  [9:0] data_in,
        output [3:0] one_count
    );
    
    integer i;
    reg [3:0] count;

    always @(*) begin
        count = 4'd0;
        for (i = 0; i < 10; i = i + 1) begin
            if (data_in[i] == 1'b1) count = count + 1;
        end
    end

    assign one_count = count;
    
endmodule