`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/15 01:25:08
// Design Name: 
// Module Name: clk_counter
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


module stop_counter( // 9999에서 재시작, 0.01초 클락 입력되어야함.
    input wire CLOCK_1cs,            // 0.01초 클락 입력
    input wire RESET,          // 리셋 입력
    input wire ENABLE,              // Enable 신호
    output reg [13:0] count    // 현재 카운트 값 출력
    );
    
    initial begin
        count = 14'd0000; // 초기값 설정
    end
    
    always @(posedge CLOCK_1cs or posedge RESET) begin
        if (RESET) begin
            count <= 14'd0; // 리셋 시 0으로 초기화
        end else if (ENABLE) begin 
            if (count == 14'd9999) begin
                count <= 14'd0; // 최대값에서 0으로 초기화
            end else begin
                count <= count + 14'd1; // 1씩 증가
            end
        end
    end
    
endmodule
