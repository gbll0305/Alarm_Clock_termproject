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

// ���� ����� ���� ��ð� �ȵǾ��־ �ȳ���.
module mode_3( 
    input wire RESET,
    input wire ENABLE,
    input wire CLOCK_1ms,
    input wire CLOCK_1cs,
    input wire BTN_CENTER,
    output wire [6:0] SEG,
    output wire [3:0] ANODE
    );
    
    // ���� ���� ����
    wire [13:0] stopwatch_time; // ��ž��ġ �ð� ��
    reg stopwatch_enable = 0;  // ��ž��ġ Ȱ��ȭ ���ΰ�
    
    
    // ��ư ��ȣ�� ��ٿ�� ���� ����Ʈ �������� ����. ���� ���� ������ ��쿡�� ����.
    reg [3:0] btn_sync = 4'b0000;
    always @(posedge CLOCK_1ms) begin
        btn_sync <= {btn_sync[2:0], BTN_CENTER}; // ��ư ��ȣ�� Shift Register�� ����ȭ
    end
    wire btn_edge = (btn_sync[3:2] == 2'b01); // ��� ���� ����
    
    
    // ��ư ��� ���� ���� �� enable 1 -> 0 -> 1 .. �ٲٱ�.
    always @(posedge btn_edge) begin
        if (ENABLE) begin
            stopwatch_enable <= ~stopwatch_enable; // ��ư ���� �� ���
        end
    end
    
    
    // ��ž��ġ �� �þ�� ���
    stop_counter stopwatch_counter(
        .CLOCK_1cs(CLOCK_1cs),         // 1�� Ŭ�� �Է�
        .RESET(RESET),          // ���� �Է�
        .ENABLE(stopwatch_enable), // Enable�� 1�϶��� stopwtach_time�� �þ����.
        .count(stopwatch_time)  // ī���� ���
    );
    
    // 7-segment ���÷��� ���� - ��ž��ġ ���
    seven_segment_out_stop display_controller_stop (
        .CLOCK_1ms(CLOCK_1ms),
        .Time(stopwatch_time),        
        .SEVEN_SEG_OUT(SEG),
        .anodes(ANODE)
    );
    
    
endmodule
