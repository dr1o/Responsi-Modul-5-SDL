// =============================================================
// MODULE   : fsm_mealy
// FSM TYPE : Mealy  (output depends on current state AND input)
// FUNCTION : 2-bit Up Counter with Overflow / Carry output
//
// ── CONCEPT ────────────────────────────────────────────────
//   • w = 0 : hold current state (no count)
//   • w = 1 : advance to next state (count up)
//   • y = 1 : ONLY when (state = S3) AND (w = 1)
//             (carry fires exactly on the S3→S0 transition)
//   This proves Mealy: y depends on BOTH state and w.
//   Compare with Moore where y would be 1 throughout S3.
//
// ── STATE DIAGRAM ──────────────────────────────────────────
//
//              RESET
//                │
//                ▼
//           ┌─────────┐
//     w=0/0 │   S0    │ w=1/0
//      ┌───►│  cnt=0  │──────────────────────────────────┐
//      │    └─────────┘                                  │
//      │         │ w=1/0                                 │
//      │         ▼                                       ▼
//      │    ┌─────────┐ w=1/0  ┌─────────┐ w=1/0  ┌─────────┐
//      │    │   S1    │───────►│   S2    │───────►│   S3    │
//      │    │  cnt=1  │◄───────│  cnt=2  │◄───────│  cnt=3  │
//      │    └─────────┘ w=0/0  └─────────┘ w=0/0  └─────────┘
//      │    (w=0: self-loop)              (w=0: self-loop)│
//      │                                            w=1/1 │  ← y=1 HERE
//      └────────────────────────────────────────────────── ┘
//
// ── TRUTH TABLE ────────────────────────────────────────────
//   State  │ Next State   │  Output y
//  (Q2 Q1) │ w=0  │ w=1  │ w=0 │ w=1
//  ────────┼──────┼──────┼─────┼─────
//  S0  00  │  S0  │  S1  │  0  │  0
//  S1  01  │  S1  │  S2  │  0  │  0
//  S2  10  │  S2  │  S3  │  0  │  0
//  S3  11  │  S3  │  S0  │  0  │  1  ← Mealy output!
//
// ── K-MAP Q2next (minterms: W Q2 Q1) ───────────────────────
//          W=0  W=1
//  Q2Q1=00:  0    0
//  Q2Q1=01:  0    1   ┐ group A: w·Q̄2·Q1
//  Q2Q1=11:  1    0   ┐ group B: w̄·Q2  (with 10)
//  Q2Q1=10:  1    1   ┘ group C: Q2·Q̄1 (with 10)
//
//  Q2next = w̄·Q2 + Q2·Q̄1 + w·Q̄2·Q1
//
// ── K-MAP Q1next ───────────────────────────────────────────
//          W=0  W=1
//  Q2Q1=00:  0    1   ┐ group A: w·Q̄1
//  Q2Q1=01:  1    0   ┐ group B: w̄·Q1
//  Q2Q1=11:  1    0   ┘
//  Q2Q1=10:  0    1   ┘ (wraps to 00 row)
//
//  Q1next = w̄·Q1 + w·Q̄1  =  w ⊕ Q1
//
// ── OUTPUT ─────────────────────────────────────────────────
//  y = w·Q2·Q1   (Mealy: needs both state=11 and input w=1)
// =============================================================
module fsm_mealy(
    input  wire        clk,
    input  wire        reset,
    input  wire        ce,            // pulse from debounced BTNC
    input  wire        w,             // input from SW0
    output reg         y,             // Mealy output
    output wire [1:0]  state_display
);

    parameter S0 = 2'b00,
              S1 = 2'b01,
              S2 = 2'b10,
              S3 = 2'b11;

    reg [1:0] curr, next;

    assign state_display = curr;

    // ── Sequential: state register ──────────────────────────
    always @(posedge clk or posedge reset) begin
        if (reset)    curr <= S0;
        else if (ce)  curr <= next;
    end

    // ── Combinational: next-state + output logic ────────────
    always @(*) begin
        next = curr;    // default: hold
        y    = 1'b0;    // default output = 0

        case (curr)
            S0: begin
                next = (w) ? S1 : S0;
                y    = 1'b0;                // no overflow from S0
            end
            S1: begin
                next = (w) ? S2 : S1;
                y    = 1'b0;
            end
            S2: begin
                next = (w) ? S3 : S2;
                y    = 1'b0;
            end
            S3: begin
                if (w) begin
                    next = S0;
                    y    = 1'b1;  // MEALY: carry fires ONLY here (S3 + w=1)
                end else begin
                    next = S3;
                    y    = 1'b0;  // holding at S3 with w=0 → no carry
                end
            end
            default: next = S0;
        endcase
    end

endmodule
