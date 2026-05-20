// =============================================================
// MODULE   : debouncer
// DESC     : Hardware debouncer with ~10 ms filter window.
//            btn_level — steady level output (used for Reset)
//            btn_pulse — single-cycle rising-edge pulse
// =============================================================
module debouncer(
    input  wire  clk,
    input  wire  btn_in,
    output reg   btn_pulse,
    output reg   btn_level
);

    reg [19:0] count;
    reg        btn_stable;
    reg        btn_sync_0, btn_sync_1;
    reg        btn_prev;

    always @(posedge clk) begin
        // Two-stage synchroniser (prevents metastability)
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0;

        // Debounce: count how long input differs from stable value
        if (btn_sync_1 == btn_stable) begin
            count <= 0;
        end else begin
            count <= count + 1;
            if (count == 20'd1_000_000) begin   // ~10 ms at 100 MHz
                btn_stable <= btn_sync_1;
            end
        end

        btn_level <= btn_stable;
        btn_prev  <= btn_stable;
        btn_pulse <= (btn_stable && !btn_prev);  // rising-edge pulse
    end

endmodule
