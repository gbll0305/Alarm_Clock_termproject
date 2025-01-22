`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/15 14:36:39
// Design Name: 
// Module Name: mode_3
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

// 리셋 기능은 따로 명시가 안되어있어서 안넣음.
module mode_3( 
    input wire RESET,
    input wire ENABLE,
    input wire CLOCK_1ms,
    input wire CLOCK_1cs,
    input wire BTN_CENTER,
    output wire [6:0] SEG,
    output wire [3:0] ANODE
    );
    
    // 내부 변수 선언
    wire [13:0] stopwatch_time; // 스탑워치 시간 값
    reg stopwatch_enable = 0;  // 스탑워치 활성화 여부값
    
    
    // 버튼 신호를 디바운싱 위한 시프트 레지스터 로직. 일정 값이 유지될 경우에만 인지.
    reg [3:0] btn_sync = 4'b0000;
    always @(posedge CLOCK_1ms) begin
        btn_sync <= {btn_sync[2:0], BTN_CENTER}; // 버튼 신호를 Shift Register로 동기화
    end
    wire btn_edge = (btn_sync[3:2] == 2'b01); // 상승 엣지 감지
    
    
    // 버튼 상승 엣지 감지 및 enable 1 -> 0 -> 1 .. 바꾸기.
    always @(posedge btn_edge) begin
        if (ENABLE) begin
            stopwatch_enable <= ~stopwatch_enable; // 버튼 눌림 시 토글
        end
    end
    
    
    // 스탑워치 초 늘어나는 모듈
    stop_counter stopwatch_counter(
        .CLOCK_1cs(CLOCK_1cs),         // 1초 클럭 입력
        .RESET(RESET),          // 리셋 입력
        .ENABLE(stopwatch_enable), // Enable이 1일때만 stopwtach_time이 늘어나도록.
        .count(stopwatch_time)  // 카운터 출력
    );
    
    // 7-segment 디스플레이 제어 - 스탑워치 모드
    seven_segment_out_stop display_controller_stop (
        .CLOCK_1ms(CLOCK_1ms),
        .Time(stopwatch_time),        
        .SEVEN_SEG_OUT(SEG),
        .anodes(ANODE)
    );
    
    
endmodule
