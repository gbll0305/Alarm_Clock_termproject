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
    output reg [11:0] TIME_SET, // alarm time 임
    output wire [6:0] SEG,
    output wire [3:0] ANODE
    );
    
    // < 작동 순서 >
    // 1. ENABLE이 0->1 이 되면 TIME_SET = 0 으로 초기화
    // 2. BTN 입력 값을 받아옴. 디바운싱을 방지하기 위해 button[4:0]에 따로 저장함.
    // 3. 입력 신호 처리. ENABLE=1일 떄만
    //      select[1:0]으로 바꿀 위치 체크. 좌우버튼 눌리면
    //      상하 버튼 눌리면 select 위치에 따라  600 60 10 1 만큼 올리고 내림. 
    // 4. 7segment로 화면 출력할 신호 만듦
    //      이 때 select 신호와 같은 위치의 신호는 CLOCK_1s에 따라 0,1 번갈아가면서 출력
    
    
    // < local variables >
    reg [1:0] select;                   // 선택된 위치
    reg [3:0] select_expanded;          // 4비트로 확장된 select 값. ANODE와 비교하기 위해.
    
    reg [4:0] btn_sync_0, btn_sync_1;   // 버튼 동기화용 레지스터
    reg [4:0] btn_debounced;            // 디바운싱 완료된 버튼 값
    wire [4:0] btn_edge;                // 버튼 상승 에지 감지 신호
    
    wire [6:0] SEG_wire;                // wire 타입으로 SEG 받아옴. latch 방지 
    
    reg enable_d;                       // ENABLE의 이전 상태 저장
    wire enable_edge;                   // ENABLE의 posedge 검출
    
    
    
    // 1. ENABLE 상승 에지 감지
    always @(posedge CLOCK_1ms or posedge RESET) begin
        if (RESET) begin
            enable_d <= 1'b0;
        end else begin
            enable_d <= ENABLE; // ENABLE의 이전 상태를 저장
        end
    end
    assign enable_edge = ENABLE & ~enable_d; // ENABLE의 상승 에지 검출
    
    
    // 2. 버튼 디바운싱 처리
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
            btn_sync_0 <= BTN;            // BTN 입력 값을 동기화
            btn_sync_1 <= btn_sync_0;     // 첫 번째 동기화 값을 두 번째 레지스터에 저장
            btn_debounced <= btn_sync_1;  // 디바운싱된 버튼 값 저장
        end
    end
    // 버튼 상승 에지(0 → 1) 감지
    assign btn_edge = btn_debounced & ~btn_sync_1; // 현재값과 이전값 비교해서 상승 에지 검출
    
    
    
    // 3. TIME_SET 초기화 및 버튼 입력 처리
    // posedge CLOCK_1ms or posedge RESET or posedge enable_edge
    always @(posedge CLOCK_1ms or posedge RESET or posedge enable_edge) begin
        if (RESET) begin
            // reset
            TIME_SET <= 12'b000000000000;
            select <= 2'b11;
            select_expanded <= 4'b0001;
            
        end else if (enable_edge) begin
            // ENABLE 상승 에지에서 초기화
            //TIME_SET <= 12'b000000000000;
            select <= 2'b11;
            select_expanded <= 4'b0001;
            
        end else if (ENABLE) begin
            // LEFT / RIGHT
            if (btn_edge[2]) begin // LEFT 버튼: select 증가
                select <= (select == 2'b11) ? 2'b00 : select + 2'b01; // 범위 초과 시 wrap-around 
            end else if (btn_edge[3]) begin // RIGHT 버튼: select 감소
                select <= (select == 2'b00) ? 2'b11 : select - 2'b01; // 범위 초과 시 wrap-around
            
            // UP / DOWN
            end else if (btn_edge[1]) begin         // UP 버튼
                if (TIME_SET <= 12'd3495) begin     // 1. 600을 더해도 4095가 넘지 않음
                    case (select)
                        2'b00: TIME_SET <= TIME_SET + 12'd1;
                        2'b01: TIME_SET <= TIME_SET + 12'd10;
                        2'b10: TIME_SET <= TIME_SET + 12'd60;
                        2'b11: TIME_SET <= TIME_SET + 12'd600;
                    endcase
                    // 3600 이상으로 overflow => 0~3599 범위
                    if (TIME_SET >= 12'd3600) begin
                        TIME_SET <= TIME_SET - 12'd3600;
                    end
                end else begin                      // 2. 600을 더하면 4095가 넘음
                    case (select)
                        2'b00: TIME_SET <= TIME_SET + 12'd1;
                        2'b01: TIME_SET <= TIME_SET + 12'd10;
                        2'b10: TIME_SET <= TIME_SET + 12'd60;
                        2'b11: TIME_SET <= TIME_SET - 12'd3000; // + 600 - 3600
                    endcase
                    // 3600 이상으로 overflow => 0~3599 범위
                    if (TIME_SET >= 12'd3600) begin
                        TIME_SET <= TIME_SET - 12'd3600;
                    end
                end
                
            end else if (btn_edge[4]) begin         // DOWN 버튼
                if (TIME_SET >= 12'd600) begin              // 1. 600을 빼도 0이 넘음
                    case (select)
                        2'b00: TIME_SET <= TIME_SET - 12'd1;
                        2'b01: TIME_SET <= TIME_SET - 12'd10;
                        2'b10: TIME_SET <= TIME_SET - 12'd60;
                        2'b11: TIME_SET <= TIME_SET - 12'd600;
                    endcase
                end else if (TIME_SET >= 12'd60) begin      // 2. 600 빼면 음수
                    case (select)
                        2'b00: TIME_SET <= TIME_SET - 12'd1;
                        2'b01: TIME_SET <= TIME_SET - 12'd10;
                        2'b10: TIME_SET <= TIME_SET - 12'd60;
                        2'b11: TIME_SET <= TIME_SET + 12'd3000; // -600+3600
                    endcase
                end else if (TIME_SET >= 12'd10) begin      // 3. 600 60 뺄 때 음수
                    case (select)
                        2'b00: TIME_SET <= TIME_SET - 12'd1;
                        2'b01: TIME_SET <= TIME_SET - 12'd10;
                        2'b10: TIME_SET <= TIME_SET + 12'd3540;
                        2'b11: TIME_SET <= TIME_SET + 12'd3000;
                    endcase
                end else if (TIME_SET >= 12'd1) begin       // 4. 600 60 10 뺄 떄 음수
                    case (select)
                        2'b00: TIME_SET <= TIME_SET - 12'd1;
                        2'b01: TIME_SET <= TIME_SET + 12'd3590;
                        2'b10: TIME_SET <= TIME_SET + 12'd3540;
                        2'b11: TIME_SET <= TIME_SET + 12'd3000;
                    endcase
                end else begin                              // 5. 0. 뭘 빼도 음수
                    case (select)
                        2'b00: TIME_SET <= TIME_SET + 12'd3599;
                        2'b01: TIME_SET <= TIME_SET + 12'd3590;
                        2'b10: TIME_SET <= TIME_SET + 12'd3540;
                        2'b11: TIME_SET <= TIME_SET + 12'd3000;
                    endcase
                end
            end
            
            
            // select 값을 4비트로 확장
            // ANODE와의 값을 비교하기 위해 one hot 형태로 변경
            case (select)
                2'b00: select_expanded <= 4'b1000;
                2'b01: select_expanded <= 4'b0100;
                2'b10: select_expanded <= 4'b0010;
                2'b11: select_expanded <= 4'b0001;
            endcase
        end else begin
            // 다른 경우에도 값 유지
            TIME_SET <= TIME_SET;
            select <= select;
            select_expanded <= select_expanded;
        end
    end
    
    
    // 4. 7-segment 디스플레이 제어 - 일반 모드
    seven_segment_out_clk display_controller_set_alarm_time (
        .CLOCK_1ms(CLOCK_1ms),
        .Time(TIME_SET),
        .SEVEN_SEG_OUT(SEG_wire),
        .anodes(ANODE)
    );
    
    assign SEG = (select_expanded == ~ANODE) ? (SEG_wire | {7{~CLOCK_1s}}) : SEG_wire; // assign을 통해 최종 출력
    
endmodule
