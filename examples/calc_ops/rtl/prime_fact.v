module prime_factor (
    input                               clk,
    input [RAH_PACKET_WIDTH-1:0]        a,
    input                               empty,

    output reg [RAH_PACKET_WIDTH-1:0]   c = 0,
    output reg                          rden = 0,
    output reg                          wren = 0
);

parameter RAH_PACKET_WIDTH = 48;

localparam IDLE = 3'd0;
localparam LOAD = 3'd1;
localparam DIV_2 = 3'd2;
localparam DIV_I = 3'd3;
localparam DATA_LENGTH = 3'd4;
localparam WRITE = 3'd5;

reg [RAH_PACKET_WIDTH-1:0] numb = 0;
reg [RAH_PACKET_WIDTH-1:0] rem = 0;
reg [RAH_PACKET_WIDTH-1:0] qcnt = 0;
reg r_wait = 0;
reg [RAH_PACKET_WIDTH-1:0] i = 3;
reg [2:0] state = IDLE;

reg [RAH_PACKET_WIDTH-1: 0] prime_stack [0:23];
reg [4:0] ptr = 0;

always @(posedge clk) begin
    case(state)
        IDLE: begin
            wren <= 0;
            rden <= 0;
            i <= 3;
            qcnt <= 0;
            rem <= 0;
            numb <= 0;
            if (~empty) begin
               rden <= 1;
               state <= LOAD;
            end
        end

        LOAD: begin
            if (r_wait) begin
                numb <= a;
                r_wait <= 0;
                state <= DIV_2;
                rden <= 0;
            end else begin
                r_wait <= ~r_wait;
            end
        end

        DIV_2: begin
            if(!numb[0]) begin
                numb <= numb >> 1;
                ptr <= ptr + 1;
                prime_stack[ptr] <= 2;
                state <= DIV_2;
            end
            else begin
                if (numb == 1) begin
                    state <= DATA_LENGTH;
                end
                else begin
                    rem <= numb;
                    state <= DIV_I;
                end
            end
        end

        DIV_I: begin

            if (rem < i) begin
                qcnt <= 0;
                if(rem == 0) begin
                    numb <= qcnt;
                    rem <= qcnt;
                    ptr <= ptr + 1;
                    prime_stack[ptr] <= i;
                    if(qcnt == 1)
                        state <= DATA_LENGTH;
                    else
                        state <= DIV_I;
                    // state <= DIV_2;
                end
                else begin
                    rem <= numb;
                    i <= i + 2;
                end
            end
            else begin
                rem <= rem - i;
                qcnt <= qcnt + 1;
            end

        end

        DATA_LENGTH: begin
            wren <= 1;
            c <= ptr; // This sends the length/ total number of factors to be sent
            state <= WRITE;
        end

        WRITE: begin
            if(ptr > 0) begin
                c <= prime_stack[ptr - 1];
                ptr <= ptr - 1;
                // wren <= 1;
                state <= WRITE;
            end
            else begin
                ptr <= 0;
                wren <= 0;
                state <= IDLE;
            end
        end
    endcase
end

endmodule