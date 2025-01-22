`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/14 22:27:49
// Design Name: 
// Module Name: top_temporaray
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

///////////////////////
//constant
// mode
`define MODE0 4'b0000
`define MODE1 4'b0001
`define MODE2 4'b0010
`define MODE3 4'b0100
`define MODE4 4'b1000

// push_button
`define CENTER 5'b00001
`define UP 5'b00010
`define LEFT 5'b00100
`define RIGHT 5'b01000
`define DOWN 5'b10000
////////////////////////



module Main_clock (
    input wire MCLK,                // 100MHz 클럭 입력
    input wire RESET,               // 리셋 입력
    //추가한 스위치랑 가운데 버튼
    input wire [3:0] mode,          // spdt 버튼 (모드 선택)
    input wire [4:0] push_button,   // 스탑워치 제어 등 버튼
    input wire [9:0] minigame_in,   // spdt 버튼 (미니게임 입력)
    output reg [15:1] led,          // 15-12 / 11-2 / 1 / (led_always)
    output wire led_always,
    output wire [6:0] SEG,          // 7-segment 데이터 출력
    output wire [3:0] ANODE         // 디스플레이 선택 핀 
);
    
    
 /////////////////////////////////////
 // 전역 클럭신호 생성
    wire CLOCK_1ms;
    wire CLOCK_1s;
    wire CLOCK_2s;
    wire CLOCK_1cs;

    make_clk clock_generator (
        .MCLK(MCLK),
        .RESET_IN(RESET),
        .CLOCK_1ms(CLOCK_1ms),
        .CLOCK_1cs(CLOCK_1cs),
        .CLOCK_1s(CLOCK_1s),
        .CLOCK_2s(CLOCK_2s),   // 필요하지 않으면 연결하지 않음
        .RESET_OUT()
    );
/////////////////////////////////////
 
 //////////////////////////////////////
    // 전역 변수들 선언
    wire [11:0] clock_time; // 1초마다 증가하는 기본 시계 값. stop워치는 내부변수로 해도 됨.
    wire time_flows;        // 처음에는 time_flows가=0. mode1에서 최초 시간 설정 이후 1. mode1 내부 reg에 연결. mode 0으로 입력

    // 위에 둘 다 무조건 wire로 해야한대..
    reg [11:0] alarm_time;          // alarm 시간을 저장하는 변수.
    wire [11:0] clock_time_set;     // mode1에서 바뀐 시간
//////////////////////////////////////    
    
 
 //////////////////////////////////////
  // 모드 1 제외하고 시간이 계속 흐르게끔 설정. 하위 모듈 안에서 켜고 끄고를 제어할 수가 없어서 맨 바깥에서.
  
    // Enable 신호
    wire enable_clock = ~mode[0]; // mode1(클락 세팅 모드)에서만 disable.
    
    // clock 카운딩 모듈(초 늘어나는)
    clk_counter clock_counter(
        .CLOCK_1s(CLOCK_1s),            // 1초 클럭 입력
        .RESET(RESET), 
        .ENABLE(enable_clock),          // 모드 따라 활성화 여부. mode1일 때는 안 흐름
        .time_flows(time_flows),        // mode1에서 시간 설정 이후 시간이 흘러야 함
        .SET_TIME(clock_time_set),                // 모드 1에서 변경된 시간 넣기
        .count(clock_time)  // 카운터 출력
    ); 
 //////////////////////////////////////
 
 
 //////////////////////////////////
 // 1초 LED는 디폴트로 계속 켜져있다. 항상 clock_1s 신호를 표시
    //assign led_always = RESET ? 1'b1 : CLOCK_1s;
    assign led_always = CLOCK_1s;
 /////////////////////////////////////
 
 
 
 /////////////////////////////////////
  // MODE0 (clock mode)
    wire [6:0] SEG_clk_mode_wire;   // 우선 받아오고, RESET이면 0 출력, 아니면 SEG_clk_mode_wire 출력
    wire [6:0] SEG_clk_mode;   // 일반 모드의 SEG 출력 -> mode가 0일때는 이 아웃풋만 넣어주면 되는 거.
    wire [3:0] ANODE_clk_mode; // 일반 모드의 ANODE 출력
    
   // 모듈화 할필요 없이 짧아서 안함.
   // 7-segment 디스플레이 제어 - 일반 모드
    seven_segment_out_clk display_controller_clk (
        .CLOCK_1ms(CLOCK_1ms),
        .Time(clock_time),           // 테스트할 숫자
        .SEVEN_SEG_OUT(SEG_clk_mode_wire),
        .anodes(ANODE_clk_mode)
    );
    
    assign SEG_clk_mode = (RESET) ? 7'b0000001 : SEG_clk_mode_wire;
/////////////////////////////////////




////////////////////////////////////////////
 // mode 1 (시간 설정 모드)
    // 두 개의 출력 신호를 저장하는 내부 wire
    wire [6:0] SEG_set_clk_mode;    // set time의 seg 출력
    wire [3:0] ANODE_set_clk_mode;  // set time의 ANODE 출력
    wire set_time_enable = mode[0]; // 모드 1이 켜졌을 때만 동작하도록 신호를 보냄
    
    // set clock time 모듈화
    mode_1 set_clock_time (
        .RESET(RESET),
        .ENABLE(set_time_enable),
        .CLOCK_1ms(CLOCK_1ms),
        .CLOCK_1s(CLOCK_1s),
        .TIME_CURR(clock_time),
        .BTN(push_button),
        .TIME_SET(clock_time_set),
        .time_flows(time_flows),
        .SEG(SEG_set_clk_mode),
        .ANODE(ANODE_set_clk_mode)
    );
////////////////////////////////////////////


////////////////////////////////////////////
 // mode 2 (알람 시각 설정 모드)
    // 두 개의 출력 신호를 저장하는 내부 wire
    wire [6:0] SEG_set_alarm_mode;      // alarm time의 seg 출력
    wire [3:0] ANODE_set_alarm_mode;    // alarm time의 ANODE 출력
    wire set_alarm_enable = mode[1];    // 모드 2이 켜졌을 때만 동작하도록 신호를 보냄
    wire [11:0] alarm_time_wire;        // alarm time을 받아오는 wire 정의
    
    // set clock time 모듈화
    mode_2 set_alarm_time (
        .RESET(RESET),
        .ENABLE(set_alarm_enable),
        .CLOCK_1ms(CLOCK_1ms),
        .CLOCK_1s(CLOCK_1s),
        .BTN(push_button),
        .TIME_SET(alarm_time_wire),
        .SEG(SEG_set_alarm_mode),
        .ANODE(ANODE_set_alarm_mode)
    );
    
    always @(posedge CLOCK_1ms) begin
        alarm_time <= alarm_time_wire;
    end
////////////////////////////////////////////


//////////////////////////////////////////
 // mode 3 (스탑워치 모드)
    // 두 개의 출력 신호를 저장하는 내부 wire
    wire [6:0] SEG_stop_mode;  // 스탑워치 모드의 SEG 출력
    wire [3:0] ANODE_stop_mode; // 스탑워치 모드의 ANODE 출력
    wire set_stopwatch_enable = mode[2];
    
    // 스탑워치 모듈화
    mode_3 stopwatch_mode (
        .RESET(RESET),
        .ENABLE(set_stopwatch_enable),
        .CLOCK_1ms(CLOCK_1ms),
        .CLOCK_1cs(CLOCK_1cs),
        .BTN_CENTER(push_button[0]), // center 버튼 넣기
        .SEG(SEG_stop_mode),
        .ANODE(ANODE_stop_mode)
    );
////////////////////////////////////////////



////////////////////////////////////////////
 // mode 4 (알람 활성화 모드 minigame)
    // 두 개의 출력 신호를 저장하는 내부 wire
    wire [6:0] SEG_minigame_mode;       // alarm time의 seg 출력
    wire [3:0] ANODE_minigame_mode;     // alarm time의 ANODE 출력
    wire set_minigame_enable = mode[3];     // 모드 4가 켜졌을 때만 동작하도록 신호를 보냄
    
    reg [1:0] minigame_activated;           // 미니게임 상태를 받아옴 -> LED 점멸
    wire [1:0] minigame_activated_wire;
    
    reg [9:0] minigame_led;
    wire [9:0] minigame_led_wire;           // 미니게임에서 불 켤 위치 받아옴
    
    mode_4 minigame_mode (
        .RESET(RESET),
        .ENABLE(set_minigame_enable),
        .CLOCK_1ms(CLOCK_1ms),
        .CLOCK_1s(CLOCK_1s),
        .CLOCK_2s(CLOCK_2s),
        .current_time(clock_time),
        .alarm_time(alarm_time),
        .spdt(minigame_in),
        .push_button_center(push_button[0]),
        .minigame_activated(minigame_activated_wire),
        .LED(minigame_led_wire),
        .SEG(SEG_minigame_mode),
        .ANODE(ANODE_minigame_mode)
    );
    
    // minigame 상태 업데이트
    // 00=모드활성화. 01=알람ON. 10=두더지잡기
    always @(posedge CLOCK_1ms) begin
        minigame_activated <= minigame_activated_wire;
    end
////////////////////////////////////////////



    
   

///////////////////////////////////////////////
//<아웃풋 제어>(사실상 내부 로직은 계속 돌아가고 아웃풋만 변하는)

// 7seg 제어
    assign SEG   = (RESET) ? SEG_clk_mode                   :
                   (mode == `MODE0) ? SEG_clk_mode          :
                   (mode == `MODE1) ? SEG_set_clk_mode      :
                   (mode == `MODE2) ? SEG_set_alarm_mode    :
                   (mode == `MODE3) ? SEG_stop_mode         :
                   (minigame_activated == 2'b00) ? SEG_clk_mode : SEG_minigame_mode; 
                   // 알림 안 울렸으면 mode0 시간을 표시함. 알림이 울렸으면 count 개수를 출력함
                   
    assign ANODE = (RESET) ? ANODE_clk_mode                 :
                   (mode == `MODE0) ? ANODE_clk_mode        :
                   (mode == `MODE1) ? ANODE_set_clk_mode    :
                   (mode == `MODE2) ? ANODE_set_alarm_mode  :
                   (mode == `MODE3) ? ANODE_stop_mode       :
                   (minigame_activated == 2'b00) ? ANODE_clk_mode : ANODE_minigame_mode;
                   
//    assign dp =    (mode != `MODE4) ? 1'b0  :
//                   (minigame_activated == 2'b00) ? 1'b0 :
//                   (minigame_activated == 2'b01) ? ~CLOCK_1s : 1'b1;
                   

// LED 상태 제어 (모드에 따라 LED 켜기)
always @(*) begin
    // 모든 LED 초기화 (모두 꺼짐)
    led = 16'b0;
    // 모드에 따라 특정 LED 켜기
    case (mode)
        `MODE1: led[15] = 1'b1; // mode1일 때 led[15] 켜기
        `MODE2: led[14] = 1'b1; // mode2일 때 led[14] 켜기
        `MODE3: led[13] = 1'b1; // mode3일 때 led[13] 켜기
        `MODE4: led[12] = 1'b1; // mode4일 때 led[12] 켜기
        default: led = 16'b0;   // 기본적으로 모든 LED 꺼짐
    endcase
    
    if (mode == `MODE4) begin                           // mode 4 에서
        if (minigame_activated_wire == 2'b01) begin     // 알람 켜졌을 때)
            led[15:1] = {15{CLOCK_1s}};                //      clock 신호에 맞추어 점멸
        end else if (minigame_activated_wire == 2'b10) begin // 게임 중)
            led[11:2] = minigame_led_wire;             //      미니게임 led 켜줌
        end
    end
    
end

///////////////////////////////////////////////

endmodule

