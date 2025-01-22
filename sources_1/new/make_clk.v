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
    output reg CLOCK_1ms, // 1ms 주기 클럭, 7seg 출력에 이용
    output reg CLOCK_1cs,
    output reg CLOCK_1s,
    output reg CLOCK_2s,
    output reg RESET_OUT
    );
    
     reg [31:0] counter_1ms;
     reg [31:0] counter_1cs;
     reg [31:0] counter_1s;
     reg [31:0] counter_2s;
     
     reg rst_before;      // RESET_IN의 이전 상태 저장
    
    // posedge RESET_IN 사용이 불가해지는 이유. 
    //      rst에서 RESET_IN과 always내의 rst_before을 사용하기 때문에
    //      동작 관계가 모호해진다.
    always @(posedge MCLK) begin
        // RESET 하강엣지일때 전부 rising하는 동기화 만들려고 중간변수 설정.
        rst_before <= RESET_IN;
    end
    wire rst = (~RESET_IN & rst_before); // 하강 에지 감지
    
    
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
            // 0.001초 주기 (50MHz * 0.001s = 50,000 주기)
            if (counter_1ms == 32'd49999) begin
                counter_1ms <= 32'd0;
                CLOCK_1ms <= ~CLOCK_1ms;
            end else begin
                counter_1ms <= counter_1ms + 1;
            end
            
            // 0.01초 주기 (50MHz * 0.01s = 500,000 주기)
            if (counter_1cs == 32'd499999) begin
                counter_1cs <= 32'd0;
                CLOCK_1cs <= ~CLOCK_1cs;
            end else begin
                counter_1cs <= counter_1cs + 1;
            end

            // 1초 주기 (50MHz * 1s = 50,000,000 주기)
            if (counter_1s == 32'd49999999) begin
                counter_1s <= 32'd0;
                CLOCK_1s <= ~CLOCK_1s;
            end else begin
                counter_1s <= counter_1s + 1;
            end
            
//            // 2초 주기 (50MHz * 2s = 100,000,000 주기)
//            if (counter_2s == 32'd99999999) begin
//                counter_2s <= 32'd0;
//                CLOCK_2s <= ~CLOCK_2s;
//            end else begin
//                counter_2s <= counter_2s + 1;
//            end
            
            //////////////////////////////////////////
            // 2초 = 100,000,000 클럭
            // 1ms = 50,000 클럭
            // 2초 주기 카운터. 1ms(1), 1999ms(0) => 1 신호가 매우 짧음
            if (counter_2s == 32'd199999999) begin
                counter_2s <= 32'd0;
            end else begin
                counter_2s <= counter_2s + 1;
            end
        
            // 1ms 동안만 CLOCK_2s = 1, 나머지 1999ms 동안 CLOCK_2s = 0
            if (counter_2s < 32'd100000) begin
                CLOCK_2s <= 1'b1;  // 1ms 동안 1 (50,000 클럭)
            end else begin
                CLOCK_2s <= 1'b0;  // 나머지 1999ms 동안 0
            end
            /////////////////////////////////////////
            
        end
    end



endmodule
