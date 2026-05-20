// =============================================================
// PROJECT  : FSM Moore — "010" Sequence Detector
// BOARD    : Nexys A7-100T
// DESC     : Detects the input pattern "0-1-0".
//            y = 1 (Moore) only when current state = S3.
//            State advances automatically every 2 seconds.
// CONTROLS : SW0 = input w  |  BTND = Reset  |  LD0 = y
// DISPLAY  : w[X] y[X] St[b1][b0]   (binary state on 7-seg)
// =============================================================
module top(
    input  wire        clk_100MHz,  // Pin E3
    input  wire        sw0,         // Pin J15  — input w
    input  wire        btnd,        // Pin P18  — Reset
    output wire        led_y,       // Pin H17  — LD0  (output y)
    output wire        led_hb,      // Pin V11  — LD15 (heartbeat)
    output wire [6:0]  seg,         // Cathodes a-g
    output wire [7:0]  an           // Anodes AN0-AN7
);

    wire rst, ce_2s, y;
    wire [1:0] st;

    // 1. Debounce the BTND reset button
    debouncer db_r (
        .clk      (clk_100MHz),
        .btn_in   (btnd),
        .btn_pulse (),
        .btn_level (rst)
    );

    // 2. Auto-advance FSM every 2 seconds (heartbeat on LD15)
    clock_divider div (
        .clk_100MHz (clk_100MHz),
        .reset      (rst),
        .ce_2s      (ce_2s),
        .led_hb     (led_hb)
    );

    // 3. Moore FSM logic
    fsm_moore fsm (
        .clk           (clk_100MHz),
        .reset         (rst),
        .ce            (ce_2s),
        .w             (sw0),
        .y             (y),
        .state_display (st)
    );

    // 4. 7-segment display: "w[X] y[X] St[b1][b0]"
    display disp (
        .clk   (clk_100MHz),
        .w_in  (sw0),
        .y_out (y),
        .state (st),
        .seg   (seg),
        .an    (an)
    );

    assign led_y = y;

endmodule
