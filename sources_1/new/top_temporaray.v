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
    input wire MCLK,                // 100MHz Ŭ�� �Է�
    input wire RESET,               // ���� �Է�
    //�߰��� ����ġ�� ��� ��ư
    input wire [3:0] mode,          // spdt ��ư (��� ����)
    input wire [4:0] push_button,   // ��ž��ġ ���� �� ��ư
    input wire [9:0] minigame_in,   // spdt ��ư (�̴ϰ��� �Է�)
    output reg [15:1] led,          // 15-12 / 11-2 / 1 / (led_always)
    output wire led_always,
    output wire [6:0] SEG,          // 7-segment ������ ���
    output wire [3:0] ANODE         // ���÷��� ���� �� 
);
    
    
 /////////////////////////////////////
 // ���� Ŭ����ȣ ����
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
        .CLOCK_2s(CLOCK_2s),   // �ʿ����� ������ �������� ����
        .RESET_OUT()
    );
/////////////////////////////////////
 
 //////////////////////////////////////
    // ���� ������ ����
    wire [11:0] clock_time; // 1�ʸ��� �����ϴ� �⺻ �ð� ��. stop��ġ�� ���κ����� �ص� ��.
    wire time_flows;        // ó������ time_flows��=0. mode1���� ���� �ð� ���� ���� 1. mode1 ���� reg�� ����. mode 0���� �Է�

    // ���� �� �� ������ wire�� �ؾ��Ѵ�..
    reg [11:0] alarm_time;          // alarm �ð��� �����ϴ� ����.
    wire [11:0] clock_time_set;     // mode1���� �ٲ� �ð�
//////////////////////////////////////    
    
 
 //////////////////////////////////////
  // ��� 1 �����ϰ� �ð��� ��� �帣�Բ� ����. ���� ��� �ȿ��� �Ѱ� ���� ������ ���� ��� �� �ٱ�����.
  
    // Enable ��ȣ
    wire enable_clock = ~mode[0]; // mode1(Ŭ�� ���� ���)������ disable.
    
    // clock ī��� ���(�� �þ��)
    clk_counter clock_counter(
        .CLOCK_1s(CLOCK_1s),            // 1�� Ŭ�� �Է�
        .RESET(RESET), 
        .ENABLE(enable_clock),          // ��� ���� Ȱ��ȭ ����. mode1�� ���� �� �帧
        .time_flows(time_flows),        // mode1���� �ð� ���� ���� �ð��� �귯�� ��
        .SET_TIME(clock_time_set),                // ��� 1���� ����� �ð� �ֱ�
        .count(clock_time)  // ī���� ���
    ); 
 //////////////////////////////////////
 
 
 //////////////////////////////////
 // 1�� LED�� ����Ʈ�� ��� �����ִ�. �׻� clock_1s ��ȣ�� ǥ��
    //assign led_always = RESET ? 1'b1 : CLOCK_1s;
    assign led_always = CLOCK_1s;
 /////////////////////////////////////
 
 
 
 /////////////////////////////////////
  // MODE0 (clock mode)
    wire [6:0] SEG_clk_mode_wire;   // �켱 �޾ƿ���, RESET�̸� 0 ���, �ƴϸ� SEG_clk_mode_wire ���
    wire [6:0] SEG_clk_mode;   // �Ϲ� ����� SEG ��� -> mode�� 0�϶��� �� �ƿ�ǲ�� �־��ָ� �Ǵ� ��.
    wire [3:0] ANODE_clk_mode; // �Ϲ� ����� ANODE ���
    
   // ���ȭ ���ʿ� ���� ª�Ƽ� ����.
   // 7-segment ���÷��� ���� - �Ϲ� ���
    seven_segment_out_clk display_controller_clk (
        .CLOCK_1ms(CLOCK_1ms),
        .Time(clock_time),           // �׽�Ʈ�� ����
        .SEVEN_SEG_OUT(SEG_clk_mode_wire),
        .anodes(ANODE_clk_mode)
    );
    
    assign SEG_clk_mode = (RESET) ? 7'b0000001 : SEG_clk_mode_wire;
/////////////////////////////////////




////////////////////////////////////////////
 // mode 1 (�ð� ���� ���)
    // �� ���� ��� ��ȣ�� �����ϴ� ���� wire
    wire [6:0] SEG_set_clk_mode;    // set time�� seg ���
    wire [3:0] ANODE_set_clk_mode;  // set time�� ANODE ���
    wire set_time_enable = mode[0]; // ��� 1�� ������ ���� �����ϵ��� ��ȣ�� ����
    
    // set clock time ���ȭ
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
 // mode 2 (�˶� �ð� ���� ���)
    // �� ���� ��� ��ȣ�� �����ϴ� ���� wire
    wire [6:0] SEG_set_alarm_mode;      // alarm time�� seg ���
    wire [3:0] ANODE_set_alarm_mode;    // alarm time�� ANODE ���
    wire set_alarm_enable = mode[1];    // ��� 2�� ������ ���� �����ϵ��� ��ȣ�� ����
    wire [11:0] alarm_time_wire;        // alarm time�� �޾ƿ��� wire ����
    
    // set clock time ���ȭ
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
 // mode 3 (��ž��ġ ���)
    // �� ���� ��� ��ȣ�� �����ϴ� ���� wire
    wire [6:0] SEG_stop_mode;  // ��ž��ġ ����� SEG ���
    wire [3:0] ANODE_stop_mode; // ��ž��ġ ����� ANODE ���
    wire set_stopwatch_enable = mode[2];
    
    // ��ž��ġ ���ȭ
    mode_3 stopwatch_mode (
        .RESET(RESET),
        .ENABLE(set_stopwatch_enable),
        .CLOCK_1ms(CLOCK_1ms),
        .CLOCK_1cs(CLOCK_1cs),
        .BTN_CENTER(push_button[0]), // center ��ư �ֱ�
        .SEG(SEG_stop_mode),
        .ANODE(ANODE_stop_mode)
    );
////////////////////////////////////////////



////////////////////////////////////////////
 // mode 4 (�˶� Ȱ��ȭ ��� minigame)
    // �� ���� ��� ��ȣ�� �����ϴ� ���� wire
    wire [6:0] SEG_minigame_mode;       // alarm time�� seg ���
    wire [3:0] ANODE_minigame_mode;     // alarm time�� ANODE ���
    wire set_minigame_enable = mode[3];     // ��� 4�� ������ ���� �����ϵ��� ��ȣ�� ����
    
    reg [1:0] minigame_activated;           // �̴ϰ��� ���¸� �޾ƿ� -> LED ����
    wire [1:0] minigame_activated_wire;
    
    reg [9:0] minigame_led;
    wire [9:0] minigame_led_wire;           // �̴ϰ��ӿ��� �� �� ��ġ �޾ƿ�
    
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
    
    // minigame ���� ������Ʈ
    // 00=���Ȱ��ȭ. 01=�˶�ON. 10=�δ������
    always @(posedge CLOCK_1ms) begin
        minigame_activated <= minigame_activated_wire;
    end
////////////////////////////////////////////



    
   

///////////////////////////////////////////////
//<�ƿ�ǲ ����>(��ǻ� ���� ������ ��� ���ư��� �ƿ�ǲ�� ���ϴ�)

// 7seg ����
    assign SEG   = (RESET) ? SEG_clk_mode                   :
                   (mode == `MODE0) ? SEG_clk_mode          :
                   (mode == `MODE1) ? SEG_set_clk_mode      :
                   (mode == `MODE2) ? SEG_set_alarm_mode    :
                   (mode == `MODE3) ? SEG_stop_mode         :
                   (minigame_activated == 2'b00) ? SEG_clk_mode : SEG_minigame_mode; 
                   // �˸� �� ������� mode0 �ð��� ǥ����. �˸��� ������� count ������ �����
                   
    assign ANODE = (RESET) ? ANODE_clk_mode                 :
                   (mode == `MODE0) ? ANODE_clk_mode        :
                   (mode == `MODE1) ? ANODE_set_clk_mode    :
                   (mode == `MODE2) ? ANODE_set_alarm_mode  :
                   (mode == `MODE3) ? ANODE_stop_mode       :
                   (minigame_activated == 2'b00) ? ANODE_clk_mode : ANODE_minigame_mode;
                   
//    assign dp =    (mode != `MODE4) ? 1'b0  :
//                   (minigame_activated == 2'b00) ? 1'b0 :
//                   (minigame_activated == 2'b01) ? ~CLOCK_1s : 1'b1;
                   

// LED ���� ���� (��忡 ���� LED �ѱ�)
always @(*) begin
    // ��� LED �ʱ�ȭ (��� ����)
    led = 16'b0;
    // ��忡 ���� Ư�� LED �ѱ�
    case (mode)
        `MODE1: led[15] = 1'b1; // mode1�� �� led[15] �ѱ�
        `MODE2: led[14] = 1'b1; // mode2�� �� led[14] �ѱ�
        `MODE3: led[13] = 1'b1; // mode3�� �� led[13] �ѱ�
        `MODE4: led[12] = 1'b1; // mode4�� �� led[12] �ѱ�
        default: led = 16'b0;   // �⺻������ ��� LED ����
    endcase
    
    if (mode == `MODE4) begin                           // mode 4 ����
        if (minigame_activated_wire == 2'b01) begin     // �˶� ������ ��)
            led[15:1] = {15{CLOCK_1s}};                //      clock ��ȣ�� ���߾� ����
        end else if (minigame_activated_wire == 2'b10) begin // ���� ��)
            led[11:2] = minigame_led_wire;             //      �̴ϰ��� led ����
        end
    end
    
end

///////////////////////////////////////////////

endmodule

