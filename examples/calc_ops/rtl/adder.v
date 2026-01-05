module adder (
    input                               clk,
    input [RAH_PACKET_WIDTH-1:0]        a,
    input                               empty,

    output reg [RAH_PACKET_WIDTH-1:0]   c = 0,
    output reg                          rden = 0,
    output reg                          wren = 0
);

parameter RAH_PACKET_WIDTH = 48;

localparam IDLE = 2'd0;
localparam LOAD_a = 2'd1;
localparam LOAD_b = 2'd2;
localparam ADD = 2'd3;

reg [RAH_PACKET_WIDTH-1:0] da = 0;
reg [RAH_PACKET_WIDTH-1:0] db = 0;
reg r_wait = 0;
reg [1:0] state = IDLE;

always @(posedge clk) begin
    case(state)
        IDLE:begin
            wren <= 0;

            if (!empty) begin
               rden <= 1;
               state <= LOAD_a;
            end else begin
               rden <= 0;
            end
        end

        LOAD_a: begin
            if (r_wait) begin
                if (!empty) begin
                    da <= a;
                    state <= LOAD_b;
                    r_wait <= 0;
                end
                else begin
                end
            end else begin
                r_wait <= ~r_wait;
            end
        end

        LOAD_b: begin
            if(!empty) begin
            db <= a;
            rden <= 0;
            state <= ADD;
            end
            else
            state <= LOAD_b;
        end

        ADD: begin
            c <= da + db;
            wren <= 1;
            state <= IDLE;
        end
    endcase
end

endmodule
