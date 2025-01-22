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
        input wire [9:0] spdt,                  // 9 -> 0 순서
        input wire push_button_center,
        output reg [1:0] minigame_activated,    // 00=활성화 01=알람 울림 10=미니게임상태
        output reg [9:0] LED,                   // 9 -> 0 순서
        output wire [6:0] SEG,
        output wire [3:0] ANODE
    );
    
    // < local variables >
    reg [7:0] random_led;               // 랜덤 LED 출력. 난수 생성기. %10 해서 사용함
    reg [11:0] count;                   // 성공 카운드 개수. 7segment를 사용하기 위해 12비트
    wire [3:0] num_spdt;                // 동시에 입력된 spdt 입력의 개수를 셈. 
    wire [6:0] SEG_wire;
    
    reg [3:0] btn_sync = 4'b0000;       // button debouncing
    reg enable_d;                       // ENABLE의 이전 상태 저장
    wire enable_edge;                   // ENABLE의 posedge 검출
    reg clock_2s_d;                     // clock_2s의 posedge 검출
    wire clock_2s_edge;
    
    reg [1:0] flag;
            // < 두더지잡기에서 입력을 받았는 지 확인하는 flag >
            // 첫bit = clock이 1인가? / 두번째bit = spdt입력이 있었는가?
            // if (CLOCK_2s) 에서
            //      00 이면 감점 -> 10으로 바뀜
            //      01 이면 ok -> 10으로 바뀜
            // if (ENABLE) 에서
            // 우선 첫 비트 0으로 바꿔줌 = 00
            //      만약 spdt 입력이 있었다
            //          2개 동시에 입력함 => 01 + 이미 감점됨
            //          1개만 입력함(틀리던가 맞던가) => 01 + 점수 오름
            //      spdt 입력이 없으면 00 그대로임
    
    
    // ENABLE 상승 엣지 계산, CLOCK_2s 상승 엣지 계산. 버튼 디바운싱 처리
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // 1. ENABLE 상승 에지 감지
    always @(posedge CLOCK_1ms or posedge RESET) begin
        if (RESET) begin
            enable_d <= 1'b0;
        end else begin
            enable_d <= ENABLE; // ENABLE의 이전 상태를 저장
        end
    end
    assign enable_edge = ENABLE & ~enable_d; // ENABLE의 상승 에지 검출
    
    // 2. CLOCK_2s 상승 에지 감지
    always @(posedge CLOCK_1ms or posedge RESET) begin
        if (RESET) begin
            clock_2s_d <= 1'b0;
        end else begin
            clock_2s_d <= CLOCK_2s; // ENABLE의 이전 상태를 저장
        end
    end
    assign clock_2s_edge = CLOCK_2s & ~clock_2s_d; // ENABLE의 상승 에지 검출
    
    // 3. 버튼 디바운싱 처리
    always @(posedge CLOCK_1ms or posedge RESET or posedge enable_edge) begin
        if (RESET) begin
            btn_sync = 4'b0000;
        end else if (enable_edge) begin
            btn_sync = 4'b0000;
        end else begin
            btn_sync <= {btn_sync[2:0], push_button_center}; // 버튼 신호를 Shift Register로 동기화
        end
    end
    wire btn_edge = (btn_sync[3:2] == 2'b01); // 상승 엣지 감지
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    
    // 4. 랜덤 LED 생성 (LFSR 기반)
    wire [7:0] lfsr_next;
    assign lfsr_next = {random_led[6:0], random_led[7] ^ random_led[5] ^ random_led[4] ^ random_led[3]};
    
    always @(posedge CLOCK_1ms or posedge RESET or posedge enable_edge) begin
        if (RESET || enable_edge) begin
            random_led <= 8'b00000001; // 초기값 (리셋 또는 enable_edge 발생 시)
        end else begin
            random_led <= lfsr_next; // 다음 LFSR 값으로 업데이트
        end
    end
    
    
    // spdt 입력의 개수를 세는 모듈
    count_ones_10bit count_num_spdt (
        .data_in(spdt),         // 10bit
        .one_count(num_spdt)    // 4bit
    );
    
    // 5. 알람 ON/OFF 및 미니게임 로직
    // posedge CLOCK_2s
    always @(posedge CLOCK_1ms or posedge RESET or posedge enable_edge or posedge clock_2s_edge) begin
        if (RESET) begin
            minigame_activated <= 2'b00;
            LED <= 10'b0;
            count <= 12'b000000000000;
            flag <= 2'b01;
            
         end else if (enable_edge) begin
            // ENABLE 상승 에지에서 초기화
            minigame_activated <= 2'b00;
            LED <= 10'b0;
            count <= 12'b000000000000;
            flag <= 2'b01;
            
        end else begin
            if (ENABLE) begin
                
                if (minigame_activated == 2'b00 && current_time == alarm_time) begin
                // 알람 ON: minigame_activated == 2'b00 && 현재 시각 == 알람 시각
                    minigame_activated <= 2'b01;
                    
                end else if (minigame_activated == 2'b01) begin
                    // 알람이 울리는 상태일 때 버튼 눌리면 게임 시작
                    if (btn_edge || push_button_center) begin
                        minigame_activated <= 2'b10;
                        flag <= 2'b01; // flag 초기화
                    end
                
                end else if (minigame_activated == 2'b10) begin
                // 미니게임 진행
                // if ()
                // 1. 2초의 rising edge 일 때   => led를 바꿈
                //      만약 flag=00=스위치를 안 올렸음  =>  count0으로 돌아감
                // 2. spdt != 0 (spdt 입력 상태)
                //      spdt에 1이 여러개일 때          => count 0 으로 돌아감. led 끔
                //      led != 0 && led == spdt                     => count 올리고, led 끔
                //      led != 0 && led != spdt         => 실패 시 count 0으로 돌아감. led 끔
                // 3. count == 3                            => 모든 reg 초기화 하고 00 으로 돌아감
                
                    if (count >= 12'd3) begin
                    // count == 3   => 모든 reg 초기화 하고 00 으로 돌아감
                        minigame_activated <= 2'b00;
                        LED <= 10'b0;
                        count <= 12'b000000000000;
                        flag <= 2'b01;
                        
                    end else if (clock_2s_edge || CLOCK_2s) begin   // debug : clock_2s를 1ms 동안만 1을 유지하도록 바꿈
                    // 2초의 rising edge 에서 random으로 led update
                        if (flag == 2'b00) begin
                            count <= 12'b000000000000;
                        end
                        LED = (10'b1 << (random_led % 8'd10));
                        flag = 2'b10;
                        
                    end else if (spdt != 10'b0000000000) begin
                    // spdt 입력이 들어왔을 때.
                        flag <= 2'b01;
                        if (num_spdt > 4'd1) begin
                        // 여러개의 spdt 입력이 발생했으므로 count가 0으로 돌아감
                            LED <= 10'b0000000000;
                            count <= 12'b000000000000;
                        end else if ( LED != 10'b0000000000) begin
                        // led가 켜져있을 때
                            if (spdt == LED) begin
                                // 맞췄으니까 1 더함
                                count <= count + 12'b000000000001;
                                LED <= 10'b0000000000;
                            end else begin
                                // 틀렸으니까 0
                                count <= 12'b000000000000;
                                LED <= 10'b0000000000;
                            end
                        end
                        
                    end else begin
                        // 2초 클락이 들어온 상태 = led 업데이트 상태가 아닌데 버튼이 안 눌림
                        flag[1] <= 1'b0;
                    end
                
                end else begin  // minigame_activate가 뭔가 이상할 때 초기화 시킴
                    minigame_activated <= 2'b00;
                    LED <= 10'b0;
                    count <= 12'b000000000000;
                end
                
            end // ENABLE
            
        end
    end   
    
    
    // 6. 7-segment 디스플레이 제어 - 일반 모드
    seven_segment_out_clk display_controller_minigame (
        .CLOCK_1ms(CLOCK_1ms),
        .Time(count),
        .SEVEN_SEG_OUT(SEG_wire),
        .anodes(ANODE)
    );
    assign SEG = (minigame_activated == 2'b01) ? ({7{~CLOCK_1s}}) : SEG_wire; // 01 일 때는 점멸. 아니면 count

endmodule
