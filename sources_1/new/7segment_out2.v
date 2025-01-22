//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/14 19:25:46
// Design Name: 
// Module Name: 7segment_out
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


module seven_segment_out_stop ( //스탑워치에서 쓰이는.
    input wire CLOCK_1ms, // 1ms 클락 입력
    input wire [13:0] Time,         // 크기가 14bit라는 것을 강조.
    output reg [6:0] SEVEN_SEG_OUT,    // 출력은 4개의 7-segment
    output reg [3:0] anodes // 디스플레이 입력 핀
);

    // 각 자리 숫자를 저장하는 wire
    wire [3:0] seven_seg_1; // 천의 자리(맨 왼쪽)
    wire [3:0] seven_seg_2; // 백의 자리
    wire [3:0] seven_seg_3; // 십의 자리
    wire [3:0] seven_seg_4; // 일의 자리(맨 오른쪽)

    // 각 7-segment 디스플레이의 출력
    wire [6:0] seven_seg_1_out; // 맨 왼쪽. 아래서 case 쓰려 reg로.
    wire [6:0] seven_seg_2_out;
    wire [6:0] seven_seg_3_out;
    wire [6:0] seven_seg_4_out;

    // 자리 숫자 계산
    assign seven_seg_1 = Time/1000;           // 천의 자리
    assign seven_seg_2 = (Time%1000)/100;     // 백의 자리
    assign seven_seg_3 = (Time%100)/10;     // 십의 자리
    assign seven_seg_4 = Time%10;            // 일의 자리

    // seven_seg 할당 모듈 연결..
    SevenSegDecoder dec1 (.num(seven_seg_1), .out(seven_seg_1_out));
    SevenSegDecoder dec2 (.num(seven_seg_2), .out(seven_seg_2_out));
    SevenSegDecoder dec3 (.num(seven_seg_3), .out(seven_seg_3_out));
    SevenSegDecoder dec4 (.num(seven_seg_4), .out(seven_seg_4_out));

    // 1ms 클락에 따라 anode 바꿔가면서 7seg 출력해야함. 그냥 무한 반복하도록.
    reg [1:0] cur_display = 0; // 0~3까지 바꾸도록.
    
    always @(posedge CLOCK_1ms) begin
        cur_display <= cur_display+1; // clk따라 1씩 증가
    end
    
    // 계속 순환하면서 하나씩 불 들어오도록.
    always @(*) begin
        case (cur_display)
            2'd0: begin
                anodes = 4'b1110;  // 첫 번째 디스플레이 활성화 (AN3)
                SEVEN_SEG_OUT = seven_seg_1_out; //맨 왼쪽
            end
            2'd1: begin
                anodes = 4'b1101;  // 두 번째 디스플레이 활성화 (AN2)
                SEVEN_SEG_OUT = seven_seg_2_out; 
            end
            2'd2: begin
                anodes = 4'b1011;  // 세 번째 디스플레이 활성화 (AN1)
                SEVEN_SEG_OUT = seven_seg_3_out; 
            end
            2'd3: begin
                anodes = 4'b0111;  // 네 번째 디스플레이 활성화 (AN0)
                SEVEN_SEG_OUT = seven_seg_4_out; // 맨 오른쪽 
            end
            default: begin
                anodes = 4'b1111;  // 모든 디스플레이 OFF
                SEVEN_SEG_OUT = 7'b1111111; 
            end
        endcase
    end
endmodule
