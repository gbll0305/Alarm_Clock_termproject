`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/14 20:25:52
// Design Name: 
// Module Name: SevenSegDecoder
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


module SevenSegDecoder(
    input wire [3:0] num,
    output reg [6:0] out // 7seg
    );
    
     always @(*) begin
        case (num)
            4'd0: out = 7'b0000001; // 0, abcdefg
            4'd1: out = 7'b1001111; // 1
            4'd2: out = 7'b0010010; // 2
            4'd3: out = 7'b0000110; // 3
            4'd4: out = 7'b1001100; // 4
            4'd5: out = 7'b0100100; // 5
            4'd6: out = 7'b0100000; // 6
            4'd7: out = 7'b0001111; // 7
            4'd8: out = 7'b0000000; // 8
            4'd9: out = 7'b0000100; // 9
            default: out = 7'b1111111; //      
        endcase
    end
    
endmodule
