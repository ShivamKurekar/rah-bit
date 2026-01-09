module subtractor (
    input                               clk,
    input signed [RAH_PACKET_WIDTH-1:0] a,
    input                               empty,

    output reg signed [RAH_PACKET_WIDTH-1:0] c = 0,
    output reg                          rden = 0,
    output reg                          wren = 0
);

parameter RAH_PACKET_WIDTH = 48;

localparam IDLE = 2'd0;
localparam NEXT = 2'd1;
localparam LB = 2'd2;
localparam SUBB = 2'd3;

reg signed [RAH_PACKET_WIDTH-1:0] da = 0;
reg signed [RAH_PACKET_WIDTH-1:0] db = 0;
reg r_wait = 0;
reg [1:0] state = IDLE;

always @(posedge clk) begin
    case(state)
        IDLE:begin
            wren <= 0;

            if (~empty) begin
               rden <= 1;
               state <= NEXT;
            end else begin
               rden <= 0;
            end
        end

        NEXT: begin
            if (r_wait) begin
                da <= a;
                state <= LB;
                r_wait <= 0;
            end else begin
                r_wait <= ~r_wait;
            end
        end

        LB: begin
            db <= a;
            rden <= 0;
            state <= SUBB;
        end

        SUBB: begin
            c <= da - db;
            wren <= 1;
            state <= IDLE;
        end
    endcase
end

endmodule