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


module seven_segment_out_clk (
    input wire CLOCK_1ms, // 1ms Ŭ�� �Է�
    input wire [11:0] Time,         // ũ�Ⱑ 12bit��� ���� ����. �迭�� �ƴ϶�.
    output reg [6:0] SEVEN_SEG_OUT,    // ����� 4���� 7-segment������ �� ���÷��� �Է� �ɿ� ���� �ϳ��� 7seg�� ������.
    output reg [3:0] anodes // ���÷��� �Է� ��
);

    // �� �ڸ� ���ڸ� �����ϴ� wire
    wire [3:0] seven_seg_1; // õ�� �ڸ�(�� ����)
    wire [3:0] seven_seg_2; // ���� �ڸ�
    wire [3:0] seven_seg_3; // ���� �ڸ�
    wire [3:0] seven_seg_4; // ���� �ڸ�(�� ������)

    // �� 7-segment ���÷����� ���
    wire [6:0] seven_seg_1_out; // �� ����. �Ʒ��� case ���� reg��.
    wire [6:0] seven_seg_2_out;
    wire [6:0] seven_seg_3_out;
    wire [6:0] seven_seg_4_out;

    // �ڸ� ���� ���
    assign seven_seg_1 = Time/600;           // õ�� �ڸ�
    assign seven_seg_2 = (Time/60)%10;     // ���� �ڸ�
    assign seven_seg_3 = (Time%60)/10;     // ���� �ڸ�
    assign seven_seg_4 = Time%10;            // ���� �ڸ�

    // seven_seg �Ҵ� ��� ����..
    SevenSegDecoder dec1 (.num(seven_seg_1), .out(seven_seg_1_out));
    SevenSegDecoder dec2 (.num(seven_seg_2), .out(seven_seg_2_out));
    SevenSegDecoder dec3 (.num(seven_seg_3), .out(seven_seg_3_out));
    SevenSegDecoder dec4 (.num(seven_seg_4), .out(seven_seg_4_out));

    
    // ���� ��� ����
    //assign SEVEN_SEG_OUT = {seven_seg_1_out, seven_seg_2_out, seven_seg_3_out, seven_seg_4_out};
    // �ʿ� ������.. 
    
    // 1ms Ŭ���� ���� anode �ٲ㰡�鼭 7seg ����ؾ���. �׳� ���� �ݺ��ϵ���.
    reg [1:0] cur_display = 0; // 0~3���� �ٲٵ���.
    
    always @(posedge CLOCK_1ms) begin
        cur_display <= cur_display+1; // clk���� 1�� ����
    end
    
    // ��� ��ȯ�ϸ鼭 �ϳ��� �� ��������.
    always @(*) begin
        case (cur_display)
            2'd0: begin
                anodes = 4'b1110;  // ù ��° ���÷��� Ȱ��ȭ (AN3)
                SEVEN_SEG_OUT = seven_seg_1_out; //�� ����
            end
            2'd1: begin
                anodes = 4'b1101;  // �� ��° ���÷��� Ȱ��ȭ (AN2)
                SEVEN_SEG_OUT = seven_seg_2_out; 
            end
            2'd2: begin
                anodes = 4'b1011;  // �� ��° ���÷��� Ȱ��ȭ (AN1)
                SEVEN_SEG_OUT = seven_seg_3_out; 
            end
            2'd3: begin
                anodes = 4'b0111;  // �� ��° ���÷��� Ȱ��ȭ (AN0)
                SEVEN_SEG_OUT = seven_seg_4_out; // �� ������ 
            end
            default: begin
                anodes = 4'b1111;  // ��� ���÷��� OFF
                SEVEN_SEG_OUT = 7'b1111111; 
            end
        endcase
    end
endmodule

