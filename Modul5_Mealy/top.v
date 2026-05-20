// =============================================================
// PROJECT  : FSM Mealy — 2-bit Up Counter with Carry Output
// BOARD    : Nexys A7-100T
// DESC     : Counts 0→1→2→3→0 when w=1, holds when w=0.
//            y = 1 (Mealy) ONLY when state=S3 AND w=1
//            (i.e., output fires on the overflow transition).
// CONTROLS : SW0 = input w  |  BTNC = step  |  BTND = Reset
// DISPLAY  : w[X] y[X] St[b1][b0]   (binary state on 7-seg)
// =============================================================
module top(
    input  wire        clk_100MHz,  // Pin E3
    input  wire        sw0,         // Pin J15  — input w
    input  wire        btnc,        // Pin N17  — manual step (Enter)
    input  wire        btnd,        // Pin P18  — Reset
    output wire        led_y,       // Pin H17  — LD0  (output y)
    output wire        led_hb,      // Pin V11  — LD15 (heartbeat)
    output wire [6:0]  seg,
    output wire [7:0]  an
);

    wire enter_p, rst_l, y;
    wire [1:0] st;

    // 1. Debounce Enter button (BTNC) — gives one-cycle pulse
    debouncer db_e (
        .clk       (clk_100MHz),
        .btn_in    (btnc),
        .btn_pulse (enter_p),
        .btn_level ()
    );

    // 2. Debounce Reset button (BTND) — gives stable level
    debouncer db_r (
        .clk       (clk_100MHz),
        .btn_in    (btnd),
        .btn_pulse (),
        .btn_level (rst_l)
    );

    // 3. Heartbeat LED (LD15 blinks every 2 s)
    clock_divider hb (
        .clk_100MHz (clk_100MHz),
        .reset      (rst_l),
        .ce_2s      (),
        .led_hb     (led_hb)
    );

    // 4. Mealy FSM — advances on each BTNC press
    fsm_mealy fsm (
        .clk           (clk_100MHz),
        .reset         (rst_l),
        .ce            (enter_p),
        .w             (sw0),
        .y             (y),
        .state_display (st)
    );

    // 5. 7-segment display
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
