// =============================================================
// MODULE   : display
// DESC     : Multiplexed 8-digit 7-segment driver.
//            Shows:  w[X]  y[X]  S t [b1][b0]
//            Where [b1][b0] = current state in binary.
//
//  Digit# : 7    6    5    4    3    2    1    0
//  Shows  : 'w'  w    'y'  y    'S'  't'  MSB  LSB
//                val       val            st   st
// =============================================================
module display(
    input  wire        clk,
    input  wire        w_in,
    input  wire        y_out,
    input  wire [1:0]  state,
    output reg  [6:0]  seg,
    output reg  [7:0]  an
);

    // 7-segment patterns (active-low cathodes, CA-CG = seg[6:0])
    // Segment order: g f e d c b a  → seg[6:0]
    localparam
        SEG_0 = 7'b1000000,  // 0
        SEG_1 = 7'b1111001,  // 1
        SEG_2 = 7'b0100100,  // 2
        SEG_3 = 7'b0110000,  // 3
        SEG_W = 7'b1100011,  // w  (segments c,d,e,g lit)
        SEG_Y = 7'b0010001,  // y
        SEG_S = 7'b0010010,  // S
        SEG_T = 7'b0000111,  // t
        SEG_OFF = 7'b1111111; // blank

    reg [16:0] scan;
    wire [2:0] sel = scan[16:14];  // 3-bit mux select (0-7)

    // Refresh counter (~760 Hz per digit at 100 MHz)
    always @(posedge clk) scan <= scan + 1;

    always @(*) begin
        an      = 8'b11111111;  // all off (active-low)
        an[sel] = 1'b0;         // enable selected digit

        case (sel)
            3'd7: seg = SEG_W;                          // 'w' label
            3'd6: seg = (w_in)  ? SEG_1 : SEG_0;       // w value
            3'd5: seg = SEG_Y;                          // 'y' label
            3'd4: seg = (y_out) ? SEG_1 : SEG_0;       // y value
            3'd3: seg = SEG_S;                          // 'S'
            3'd2: seg = SEG_T;                          // 't'
            3'd1: seg = (state[1]) ? SEG_1 : SEG_0;    // state MSB (binary)
            3'd0: seg = (state[0]) ? SEG_1 : SEG_0;    // state LSB (binary)
            default: seg = SEG_OFF;
        endcase
    end

endmodule
