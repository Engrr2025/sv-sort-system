`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2025 02:54:13 AM
// Design Name: 
// Module Name: controller
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


module controller #(
    parameter K = 8
)(
    input        clk,
    input        rst,
    input        s,      // start
    input        AgtB,
    input        zi,
    input        zj,
    output reg   EA,
    output reg   EB,
    output reg   Li,
    output reg   Ei,
    output reg   Lj,
    output reg   Ej,
    output reg   Csel,
    output reg   WE,
    output reg   Bout,
    output reg   done
);
    // state encoding
    typedef enum logic [3:0] {
        S0,  // reset i, wait s=1
        S1,  // A?M[i]; j?i+1
        S2,  // B?M[j]
        S3,  // compare A,B
        S4,  // write M[i] = B
        S5,  // write M[j] = A
        S6,  // reload A?M[i] after swap OR skip
        S7,  // increment j or finish inner
        S8   // increment i or finish
    } state_t;
    state_t state, next;

    // state register
    always @(posedge clk or posedge rst) begin
        if (rst) state <= S0;
        else      state <= next;
    end

    // next-state & outputs
    always @* begin
        // defaults
        EA = 0; EB = 0; Li = 0; Ei = 0; Lj = 0; Ej = 0;
        Csel = 0; WE = 0; Bout = 0; done = 0;
        case (state)
            //---------------------------------------------
            S0: begin
                Li    = 1;  // i?0
                if (s) next = S1;
                else   next = S0;
            end
            //---------------------------------------------
            S1: begin
                EA    = 1;  // A?M[i]
                Csel  = 0;  // addr = i
                Lj    = 1;  // j?i+1
                next  = S2;
            end
            //---------------------------------------------
            S2: begin
                EB    = 1;  // B?M[j]
                Csel  = 1;
                next  = S3;
            end
            //---------------------------------------------
            S3: begin
                // compare on registered A,B
                if (AgtB) next = S4;
                else      next = S7;
            end
            //---------------------------------------------
            S4: begin
                // write M[i] = B
                Csel  = 0;
                Bout  = 1;
                WE    = 1;
                next  = S5;
            end
            //---------------------------------------------
            S5: begin
                // write M[j] = A
                Csel  = 1;
                Bout  = 0;
                WE    = 1;
                next  = S6;
            end
            //---------------------------------------------
            S6: begin
                // reload A?M[i]
                EA    = 1;
                Csel  = 0;
                next  = S7;
            end
            //---------------------------------------------
            S7: begin
                // increment j or finish inner
                Ej    = 1;
                if (!zj) next = S2;
                else     next = S8;
            end
            //---------------------------------------------
            S8: begin
                // increment i or finish
                Ei    = 1;
                if (!zi) next = S1;
                else     next = S0;  // done; back to wait
            end
            //---------------------------------------------
            default: next = S0;
        endcase
        // done flag when returning to S0 from S8 with s still high
        if ((state == S8) && zi)
            done = 1;
    end
endmodule
