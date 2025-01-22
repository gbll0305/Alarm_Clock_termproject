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


module clk_counter( // 3599에서 재시작, 1초 입력되어야함.
    input wire CLOCK_1s,            // 1초 클락 입력
    input wire RESET,               // 리셋 입력
    input wire ENABLE,              // Enable 신호
    input wire time_flows,          // 이게 1일 때 시간이 흐름
    input wire [11:0] SET_TIME,      // mode1에서 바뀐 시간 
    output reg [11:0] count         // 현재 카운트 값 출력
    );
    
    initial begin
        count = 12'd0; // 기본값 설정
    end // 이거 있어야 처음에 Z 상태 아님.
    
    always @(posedge CLOCK_1s or posedge RESET) begin
        if (RESET) begin
            count <= 12'd0; // 리셋 시 0으로 초기화
        end else if (~ENABLE) begin
            count <= SET_TIME; // ~ENABLE 상태일 때 = mode1일 때 => count를 SET_TIME로 지속적으로 업데이트
        end else if (ENABLE && time_flows) begin    // mode1 아님 && 시간 흘러야 함
            if(count == 12'd3599) begin
                count <= 12'd0; // 최대값에서 0으로 초기화
            end else begin
                count <= count + 12'd1; // 1씩 증가
            end
        end
    end
    
endmodule
