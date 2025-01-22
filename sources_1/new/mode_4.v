`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 09:19:21 AM
// Design Name: 
// Module Name: mode_4
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

module mode_4(
        input wire RESET,
        input wire ENABLE,                      // mode4 -> 1
        input wire CLOCK_1ms,
        input wire CLOCK_1s,
        input wire CLOCK_2s,
        input wire [11:0] current_time,
        input wire [11:0] alarm_time,
        input wire [9:0] spdt,                  // 9 -> 0 ����
        input wire push_button_center,
        output reg [1:0] minigame_activated,    // 00=Ȱ��ȭ 01=�˶� �︲ 10=�̴ϰ��ӻ���
        output reg [9:0] LED,                   // 9 -> 0 ����
        output wire [6:0] SEG,
        output wire [3:0] ANODE
    );
    
    // < local variables >
    reg [7:0] random_led;               // ���� LED ���. ���� ������. %10 �ؼ� �����
    reg [11:0] count;                   // ���� ī��� ����. 7segment�� ����ϱ� ���� 12��Ʈ
    wire [3:0] num_spdt;                // ���ÿ� �Էµ� spdt �Է��� ������ ��. 
    wire [6:0] SEG_wire;
    
    reg [3:0] btn_sync = 4'b0000;       // button debouncing
    reg enable_d;                       // ENABLE�� ���� ���� ����
    wire enable_edge;                   // ENABLE�� posedge ����
    reg clock_2s_d;                     // clock_2s�� posedge ����
    wire clock_2s_edge;
    
    reg [1:0] flag;
            // < �δ�����⿡�� �Է��� �޾Ҵ� �� Ȯ���ϴ� flag >
            // ùbit = clock�� 1�ΰ�? / �ι�°bit = spdt�Է��� �־��°�?
            // if (CLOCK_2s) ����
            //      00 �̸� ���� -> 10���� �ٲ�
            //      01 �̸� ok -> 10���� �ٲ�
            // if (ENABLE) ����
            // �켱 ù ��Ʈ 0���� �ٲ��� = 00
            //      ���� spdt �Է��� �־���
            //          2�� ���ÿ� �Է��� => 01 + �̹� ������
            //          1���� �Է���(Ʋ������ �´���) => 01 + ���� ����
            //      spdt �Է��� ������ 00 �״����
    
    
    // ENABLE ��� ���� ���, CLOCK_2s ��� ���� ���. ��ư ��ٿ�� ó��
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // 1. ENABLE ��� ���� ����
    always @(posedge CLOCK_1ms or posedge RESET) begin
        if (RESET) begin
            enable_d <= 1'b0;
        end else begin
            enable_d <= ENABLE; // ENABLE�� ���� ���¸� ����
        end
    end
    assign enable_edge = ENABLE & ~enable_d; // ENABLE�� ��� ���� ����
    
    // 2. CLOCK_2s ��� ���� ����
    always @(posedge CLOCK_1ms or posedge RESET) begin
        if (RESET) begin
            clock_2s_d <= 1'b0;
        end else begin
            clock_2s_d <= CLOCK_2s; // ENABLE�� ���� ���¸� ����
        end
    end
    assign clock_2s_edge = CLOCK_2s & ~clock_2s_d; // ENABLE�� ��� ���� ����
    
    // 3. ��ư ��ٿ�� ó��
    always @(posedge CLOCK_1ms or posedge RESET or posedge enable_edge) begin
        if (RESET) begin
            btn_sync = 4'b0000;
        end else if (enable_edge) begin
            btn_sync = 4'b0000;
        end else begin
            btn_sync <= {btn_sync[2:0], push_button_center}; // ��ư ��ȣ�� Shift Register�� ����ȭ
        end
    end
    wire btn_edge = (btn_sync[3:2] == 2'b01); // ��� ���� ����
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    
    // 4. ���� LED ���� (LFSR ���)
    wire [7:0] lfsr_next;
    assign lfsr_next = {random_led[6:0], random_led[7] ^ random_led[5] ^ random_led[4] ^ random_led[3]};
    
    always @(posedge CLOCK_1ms or posedge RESET or posedge enable_edge) begin
        if (RESET || enable_edge) begin
            random_led <= 8'b00000001; // �ʱⰪ (���� �Ǵ� enable_edge �߻� ��)
        end else begin
            random_led <= lfsr_next; // ���� LFSR ������ ������Ʈ
        end
    end
    
    
    // spdt �Է��� ������ ���� ���
    count_ones_10bit count_num_spdt (
        .data_in(spdt),         // 10bit
        .one_count(num_spdt)    // 4bit
    );
    
    // 5. �˶� ON/OFF �� �̴ϰ��� ����
    // posedge CLOCK_2s
    always @(posedge CLOCK_1ms or posedge RESET or posedge enable_edge or posedge clock_2s_edge) begin
        if (RESET) begin
            minigame_activated <= 2'b00;
            LED <= 10'b0;
            count <= 12'b000000000000;
            flag <= 2'b01;
            
         end else if (enable_edge) begin
            // ENABLE ��� �������� �ʱ�ȭ
            minigame_activated <= 2'b00;
            LED <= 10'b0;
            count <= 12'b000000000000;
            flag <= 2'b01;
            
        end else begin
            if (ENABLE) begin
                
                if (minigame_activated == 2'b00 && current_time == alarm_time) begin
                // �˶� ON: minigame_activated == 2'b00 && ���� �ð� == �˶� �ð�
                    minigame_activated <= 2'b01;
                    
                end else if (minigame_activated == 2'b01) begin
                    // �˶��� �︮�� ������ �� ��ư ������ ���� ����
                    if (btn_edge || push_button_center) begin
                        minigame_activated <= 2'b10;
                        flag <= 2'b01; // flag �ʱ�ȭ
                    end
                
                end else if (minigame_activated == 2'b10) begin
                // �̴ϰ��� ����
                // if ()
                // 1. 2���� rising edge �� ��   => led�� �ٲ�
                //      ���� flag=00=����ġ�� �� �÷���  =>  count0���� ���ư�
                // 2. spdt != 0 (spdt �Է� ����)
                //      spdt�� 1�� �������� ��          => count 0 ���� ���ư�. led ��
                //      led != 0 && led == spdt                     => count �ø���, led ��
                //      led != 0 && led != spdt         => ���� �� count 0���� ���ư�. led ��
                // 3. count == 3                            => ��� reg �ʱ�ȭ �ϰ� 00 ���� ���ư�
                
                    if (count >= 12'd3) begin
                    // count == 3   => ��� reg �ʱ�ȭ �ϰ� 00 ���� ���ư�
                        minigame_activated <= 2'b00;
                        LED <= 10'b0;
                        count <= 12'b000000000000;
                        flag <= 2'b01;
                        
                    end else if (clock_2s_edge || CLOCK_2s) begin   // debug : clock_2s�� 1ms ���ȸ� 1�� �����ϵ��� �ٲ�
                    // 2���� rising edge ���� random���� led update
                        if (flag == 2'b00) begin
                            count <= 12'b000000000000;
                        end
                        LED = (10'b1 << (random_led % 8'd10));
                        flag = 2'b10;
                        
                    end else if (spdt != 10'b0000000000) begin
                    // spdt �Է��� ������ ��.
                        flag <= 2'b01;
                        if (num_spdt > 4'd1) begin
                        // �������� spdt �Է��� �߻������Ƿ� count�� 0���� ���ư�
                            LED <= 10'b0000000000;
                            count <= 12'b000000000000;
                        end else if ( LED != 10'b0000000000) begin
                        // led�� �������� ��
                            if (spdt == LED) begin
                                // �������ϱ� 1 ����
                                count <= count + 12'b000000000001;
                                LED <= 10'b0000000000;
                            end else begin
                                // Ʋ�����ϱ� 0
                                count <= 12'b000000000000;
                                LED <= 10'b0000000000;
                            end
                        end
                        
                    end else begin
                        // 2�� Ŭ���� ���� ���� = led ������Ʈ ���°� �ƴѵ� ��ư�� �� ����
                        flag[1] <= 1'b0;
                    end
                
                end else begin  // minigame_activate�� ���� �̻��� �� �ʱ�ȭ ��Ŵ
                    minigame_activated <= 2'b00;
                    LED <= 10'b0;
                    count <= 12'b000000000000;
                end
                
            end // ENABLE
            
        end
    end   
    
    
    // 6. 7-segment ���÷��� ���� - �Ϲ� ���
    seven_segment_out_clk display_controller_minigame (
        .CLOCK_1ms(CLOCK_1ms),
        .Time(count),
        .SEVEN_SEG_OUT(SEG_wire),
        .anodes(ANODE)
    );
    assign SEG = (minigame_activated == 2'b01) ? ({7{~CLOCK_1s}}) : SEG_wire; // 01 �� ���� ����. �ƴϸ� count

endmodule
