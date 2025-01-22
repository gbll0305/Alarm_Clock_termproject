`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2024 08:00:59 PM
// Design Name: clock
// Module Name: make_clk
// Project Name: termProject_clock
// Target Devices: 
// Tool Versions: 
// Description: gemerate the clock signal 0.01s, 1s, 2s
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module make_clk(
    input MCLK,
    input RESET_IN,
    output reg CLOCK_1ms, // 1ms �ֱ� Ŭ��, 7seg ��¿� �̿�
    output reg CLOCK_1cs,
    output reg CLOCK_1s,
    output reg CLOCK_2s,
    output reg RESET_OUT
    );
    
     reg [31:0] counter_1ms;
     reg [31:0] counter_1cs;
     reg [31:0] counter_1s;
     reg [31:0] counter_2s;
     
     reg rst_before;      // RESET_IN�� ���� ���� ����
    
    // posedge RESET_IN ����� �Ұ������� ����. 
    //      rst���� RESET_IN�� always���� rst_before�� ����ϱ� ������
    //      ���� ���谡 ��ȣ������.
    always @(posedge MCLK) begin
        // RESET �ϰ������϶� ���� rising�ϴ� ����ȭ ������� �߰����� ����.
        rst_before <= RESET_IN;
    end
    wire rst = (~RESET_IN & rst_before); // �ϰ� ���� ����
    
    
    // CLOCK signal
    always @(posedge MCLK or posedge RESET_IN) begin
        // reset
        if (rst) begin
            counter_1ms <= 32'd0;
            counter_1cs <= 32'd0;
            counter_1s <= 32'd0;
            counter_2s <= 32'd0;
            
            CLOCK_1ms <= 1'b0;
            CLOCK_1cs <= 1'b0;
            CLOCK_1s <= 1'b0;
            CLOCK_2s <= 1'b0;
        end
        if (RESET_IN) begin
            //counter_1ms <= 32'd0;
            counter_1cs <= 32'd0;
            //counter_1s <= 32'd0;
            counter_2s <= 32'd0;
            
            //CLOCK_1ms <= 1'b0;
            CLOCK_1cs <= 1'b0;
            //CLOCK_1s <= 1'b0;
            CLOCK_2s <= 1'b0;
        end
        else begin
            // 0.001�� �ֱ� (50MHz * 0.001s = 50,000 �ֱ�)
            if (counter_1ms == 32'd49999) begin
                counter_1ms <= 32'd0;
                CLOCK_1ms <= ~CLOCK_1ms;
            end else begin
                counter_1ms <= counter_1ms + 1;
            end
            
            // 0.01�� �ֱ� (50MHz * 0.01s = 500,000 �ֱ�)
            if (counter_1cs == 32'd499999) begin
                counter_1cs <= 32'd0;
                CLOCK_1cs <= ~CLOCK_1cs;
            end else begin
                counter_1cs <= counter_1cs + 1;
            end

            // 1�� �ֱ� (50MHz * 1s = 50,000,000 �ֱ�)
            if (counter_1s == 32'd49999999) begin
                counter_1s <= 32'd0;
                CLOCK_1s <= ~CLOCK_1s;
            end else begin
                counter_1s <= counter_1s + 1;
            end
            
//            // 2�� �ֱ� (50MHz * 2s = 100,000,000 �ֱ�)
//            if (counter_2s == 32'd99999999) begin
//                counter_2s <= 32'd0;
//                CLOCK_2s <= ~CLOCK_2s;
//            end else begin
//                counter_2s <= counter_2s + 1;
//            end
            
            //////////////////////////////////////////
            // 2�� = 100,000,000 Ŭ��
            // 1ms = 50,000 Ŭ��
            // 2�� �ֱ� ī����. 1ms(1), 1999ms(0) => 1 ��ȣ�� �ſ� ª��
            if (counter_2s == 32'd199999999) begin
                counter_2s <= 32'd0;
            end else begin
                counter_2s <= counter_2s + 1;
            end
        
            // 1ms ���ȸ� CLOCK_2s = 1, ������ 1999ms ���� CLOCK_2s = 0
            if (counter_2s < 32'd100000) begin
                CLOCK_2s <= 1'b1;  // 1ms ���� 1 (50,000 Ŭ��)
            end else begin
                CLOCK_2s <= 1'b0;  // ������ 1999ms ���� 0
            end
            /////////////////////////////////////////
            
        end
    end



endmodule
