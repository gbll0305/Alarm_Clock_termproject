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


module clk_counter( // 3599���� �����, 1�� �ԷµǾ����.
    input wire CLOCK_1s,            // 1�� Ŭ�� �Է�
    input wire RESET,               // ���� �Է�
    input wire ENABLE,              // Enable ��ȣ
    input wire time_flows,          // �̰� 1�� �� �ð��� �帧
    input wire [11:0] SET_TIME,      // mode1���� �ٲ� �ð� 
    output reg [11:0] count         // ���� ī��Ʈ �� ���
    );
    
    initial begin
        count = 12'd0; // �⺻�� ����
    end // �̰� �־�� ó���� Z ���� �ƴ�.
    
    always @(posedge CLOCK_1s or posedge RESET) begin
        if (RESET) begin
            count <= 12'd0; // ���� �� 0���� �ʱ�ȭ
        end else if (~ENABLE) begin
            count <= SET_TIME; // ~ENABLE ������ �� = mode1�� �� => count�� SET_TIME�� ���������� ������Ʈ
        end else if (ENABLE && time_flows) begin    // mode1 �ƴ� && �ð� �귯�� ��
            if(count == 12'd3599) begin
                count <= 12'd0; // �ִ밪���� 0���� �ʱ�ȭ
            end else begin
                count <= count + 12'd1; // 1�� ����
            end
        end
    end
    
endmodule
