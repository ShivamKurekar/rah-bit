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
localparam WRITE = 3'd4;

reg [RAH_PACKET_WIDTH-1:0] numb = 0;
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
            if( numb % 2 == 0) begin
                numb <= numb >> 1;
                ptr <= ptr + 1;
                prime_stack[ptr] <= 2;
                state <= DIV_2;
            end
            else
                state <= DIV_I;
        end

        DIV_I: begin
            if (i * i <= numb) begin
                if (numb % i == 0) begin
                    numb <= numb / i;
                    ptr <= ptr + 1;
                    prime_stack[ptr] <= i;
                end
                else begin
                    i <= i + 2;
                end
                state <= DIV_I;
            end
            else begin
                ptr <= ptr + 1;
                prime_stack[ptr] <= numb;
                state <= WRITE;
            end
        end

        WRITE: begin
            c <= prime_stack[ptr];

            if(ptr > 0) begin
                ptr <= ptr - 1;
                wren <= 1;
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