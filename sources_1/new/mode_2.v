`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2024 04:08:16 AM
// Design Name: 
// Module Name: mode_2
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

// push_button
`define CENTER 5'b00001
`define UP 5'b00010
`define LEFT 5'b00100
`define RIGHT 5'b01000
`define DOWN 5'b10000


module mode_2(
    input wire RESET,
    input wire ENABLE,
    input wire CLOCK_1ms,
    input wire CLOCK_1s,
    input wire [4:0] BTN,
    output reg [11:0] TIME_SET, // alarm time ��
    output wire [6:0] SEG,
    output wire [3:0] ANODE
    );
    
    // < �۵� ���� >
    // 1. ENABLE�� 0->1 �� �Ǹ� TIME_SET = 0 ���� �ʱ�ȭ
    // 2. BTN �Է� ���� �޾ƿ�. ��ٿ���� �����ϱ� ���� button[4:0]�� ���� ������.
    // 3. �Է� ��ȣ ó��. ENABLE=1�� ����
    //      select[1:0]���� �ٲ� ��ġ üũ. �¿��ư ������
    //      ���� ��ư ������ select ��ġ�� ����  600 60 10 1 ��ŭ �ø��� ����. 
    // 4. 7segment�� ȭ�� ����� ��ȣ ����
    //      �� �� select ��ȣ�� ���� ��ġ�� ��ȣ�� CLOCK_1s�� ���� 0,1 �����ư��鼭 ���
    
    
    // < local variables >
    reg [1:0] select;                   // ���õ� ��ġ
    reg [3:0] select_expanded;          // 4��Ʈ�� Ȯ��� select ��. ANODE�� ���ϱ� ����.
    
    reg [4:0] btn_sync_0, btn_sync_1;   // ��ư ����ȭ�� ��������
    reg [4:0] btn_debounced;            // ��ٿ�� �Ϸ�� ��ư ��
    wire [4:0] btn_edge;                // ��ư ��� ���� ���� ��ȣ
    
    wire [6:0] SEG_wire;                // wire Ÿ������ SEG �޾ƿ�. latch ���� 
    
    reg enable_d;                       // ENABLE�� ���� ���� ����
    wire enable_edge;                   // ENABLE�� posedge ����
    
    
    
    // 1. ENABLE ��� ���� ����
    always @(posedge CLOCK_1ms or posedge RESET) begin
        if (RESET) begin
            enable_d <= 1'b0;
        end else begin
            enable_d <= ENABLE; // ENABLE�� ���� ���¸� ����
        end
    end
    assign enable_edge = ENABLE & ~enable_d; // ENABLE�� ��� ���� ����
    
    
    // 2. ��ư ��ٿ�� ó��
    always @(posedge CLOCK_1ms or posedge RESET or posedge enable_edge) begin
        if (RESET) begin
            btn_sync_0 <= 5'b00000;
            btn_sync_1 <= 5'b00000;
            btn_debounced <= 5'b00000;
        end else if (enable_edge) begin
            btn_sync_0 <= 5'b00000;
            btn_sync_1 <= 5'b00000;
            btn_debounced <= 5'b00000;
        end else begin
            btn_sync_0 <= BTN;            // BTN �Է� ���� ����ȭ
            btn_sync_1 <= btn_sync_0;     // ù ��° ����ȭ ���� �� ��° �������Ϳ� ����
            btn_debounced <= btn_sync_1;  // ��ٿ�̵� ��ư �� ����
        end
    end
    // ��ư ��� ����(0 �� 1) ����
    assign btn_edge = btn_debounced & ~btn_sync_1; // ���簪�� ������ ���ؼ� ��� ���� ����
    
    
    
    // 3. TIME_SET �ʱ�ȭ �� ��ư �Է� ó��
    // posedge CLOCK_1ms or posedge RESET or posedge enable_edge
    always @(posedge CLOCK_1ms or posedge RESET or posedge enable_edge) begin
        if (RESET) begin
            // reset
            TIME_SET <= 12'b000000000000;
            select <= 2'b11;
            select_expanded <= 4'b0001;
            
        end else if (enable_edge) begin
            // ENABLE ��� �������� �ʱ�ȭ
            //TIME_SET <= 12'b000000000000;
            select <= 2'b11;
            select_expanded <= 4'b0001;
            
        end else if (ENABLE) begin
            // LEFT / RIGHT
            if (btn_edge[2]) begin // LEFT ��ư: select ����
                select <= (select == 2'b11) ? 2'b00 : select + 2'b01; // ���� �ʰ� �� wrap-around 
            end else if (btn_edge[3]) begin // RIGHT ��ư: select ����
                select <= (select == 2'b00) ? 2'b11 : select - 2'b01; // ���� �ʰ� �� wrap-around
            
            // UP / DOWN
            end else if (btn_edge[1]) begin         // UP ��ư
                if (TIME_SET <= 12'd3495) begin     // 1. 600�� ���ص� 4095�� ���� ����
                    case (select)
                        2'b00: TIME_SET <= TIME_SET + 12'd1;
                        2'b01: TIME_SET <= TIME_SET + 12'd10;
                        2'b10: TIME_SET <= TIME_SET + 12'd60;
                        2'b11: TIME_SET <= TIME_SET + 12'd600;
                    endcase
                    // 3600 �̻����� overflow => 0~3599 ����
                    if (TIME_SET >= 12'd3600) begin
                        TIME_SET <= TIME_SET - 12'd3600;
                    end
                end else begin                      // 2. 600�� ���ϸ� 4095�� ����
                    case (select)
                        2'b00: TIME_SET <= TIME_SET + 12'd1;
                        2'b01: TIME_SET <= TIME_SET + 12'd10;
                        2'b10: TIME_SET <= TIME_SET + 12'd60;
                        2'b11: TIME_SET <= TIME_SET - 12'd3000; // + 600 - 3600
                    endcase
                    // 3600 �̻����� overflow => 0~3599 ����
                    if (TIME_SET >= 12'd3600) begin
                        TIME_SET <= TIME_SET - 12'd3600;
                    end
                end
                
            end else if (btn_edge[4]) begin         // DOWN ��ư
                if (TIME_SET >= 12'd600) begin              // 1. 600�� ���� 0�� ����
                    case (select)
                        2'b00: TIME_SET <= TIME_SET - 12'd1;
                        2'b01: TIME_SET <= TIME_SET - 12'd10;
                        2'b10: TIME_SET <= TIME_SET - 12'd60;
                        2'b11: TIME_SET <= TIME_SET - 12'd600;
                    endcase
                end else if (TIME_SET >= 12'd60) begin      // 2. 600 ���� ����
                    case (select)
                        2'b00: TIME_SET <= TIME_SET - 12'd1;
                        2'b01: TIME_SET <= TIME_SET - 12'd10;
                        2'b10: TIME_SET <= TIME_SET - 12'd60;
                        2'b11: TIME_SET <= TIME_SET + 12'd3000; // -600+3600
                    endcase
                end else if (TIME_SET >= 12'd10) begin      // 3. 600 60 �� �� ����
                    case (select)
                        2'b00: TIME_SET <= TIME_SET - 12'd1;
                        2'b01: TIME_SET <= TIME_SET - 12'd10;
                        2'b10: TIME_SET <= TIME_SET + 12'd3540;
                        2'b11: TIME_SET <= TIME_SET + 12'd3000;
                    endcase
                end else if (TIME_SET >= 12'd1) begin       // 4. 600 60 10 �� �� ����
                    case (select)
                        2'b00: TIME_SET <= TIME_SET - 12'd1;
                        2'b01: TIME_SET <= TIME_SET + 12'd3590;
                        2'b10: TIME_SET <= TIME_SET + 12'd3540;
                        2'b11: TIME_SET <= TIME_SET + 12'd3000;
                    endcase
                end else begin                              // 5. 0. �� ���� ����
                    case (select)
                        2'b00: TIME_SET <= TIME_SET + 12'd3599;
                        2'b01: TIME_SET <= TIME_SET + 12'd3590;
                        2'b10: TIME_SET <= TIME_SET + 12'd3540;
                        2'b11: TIME_SET <= TIME_SET + 12'd3000;
                    endcase
                end
            end
            
            
            // select ���� 4��Ʈ�� Ȯ��
            // ANODE���� ���� ���ϱ� ���� one hot ���·� ����
            case (select)
                2'b00: select_expanded <= 4'b1000;
                2'b01: select_expanded <= 4'b0100;
                2'b10: select_expanded <= 4'b0010;
                2'b11: select_expanded <= 4'b0001;
            endcase
        end else begin
            // �ٸ� ��쿡�� �� ����
            TIME_SET <= TIME_SET;
            select <= select;
            select_expanded <= select_expanded;
        end
    end
    
    
    // 4. 7-segment ���÷��� ���� - �Ϲ� ���
    seven_segment_out_clk display_controller_set_alarm_time (
        .CLOCK_1ms(CLOCK_1ms),
        .Time(TIME_SET),
        .SEVEN_SEG_OUT(SEG_wire),
        .anodes(ANODE)
    );
    
    assign SEG = (select_expanded == ~ANODE) ? (SEG_wire | {7{~CLOCK_1s}}) : SEG_wire; // assign�� ���� ���� ���
    
endmodule
