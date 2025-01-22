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


module stop_counter( // 9999���� �����, 0.01�� Ŭ�� �ԷµǾ����.
    input wire CLOCK_1cs,            // 0.01�� Ŭ�� �Է�
    input wire RESET,          // ���� �Է�
    input wire ENABLE,              // Enable ��ȣ
    output reg [13:0] count    // ���� ī��Ʈ �� ���
    );
    
    initial begin
        count = 14'd0000; // �ʱⰪ ����
    end
    
    always @(posedge CLOCK_1cs or posedge RESET) begin
        if (RESET) begin
            count <= 14'd0; // ���� �� 0���� �ʱ�ȭ
        end else if (ENABLE) begin 
            if (count == 14'd9999) begin
                count <= 14'd0; // �ִ밪���� 0���� �ʱ�ȭ
            end else begin
                count <= count + 14'd1; // 1�� ����
            end
        end
    end
    
endmodule
