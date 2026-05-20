// =============================================================
// MODULE   : clock_divider
// DESC     : Generates a one-cycle clock-enable pulse (ce_2s)
//            every 2 seconds from a 100 MHz input clock.
//            Also toggles led_hb every 2 s as a heartbeat.
// =============================================================
module clock_divider(
    input  wire  clk_100MHz,
    input  wire  reset,
    output reg   ce_2s,   // 1-cycle pulse every 2 seconds
    output reg   led_hb   // heartbeat LED (LD15)
);

    localparam MAX = 200_000_000;  // 100 MHz × 2 s
    reg [27:0] count;

    always @(posedge clk_100MHz or posedge reset) begin
        if (reset) begin
            count  <= 0;
            ce_2s  <= 0;
            led_hb <= 0;
        end else begin
            if (count >= MAX - 1) begin
                count  <= 0;
                ce_2s  <= 1;           // active for exactly 1 cycle
                led_hb <= ~led_hb;     // toggle heartbeat
            end else begin
                ce_2s  <= 0;
                count  <= count + 1;
            end
        end
    end

endmodule
