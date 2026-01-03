module prime_factor (
    input                               clk,
    input  [RAH_PACKET_WIDTH-1:0]        a,
    input                               empty,

    output reg [RAH_PACKET_WIDTH-1:0]    c = 0,
    output reg                          rden = 0,
    output reg                          wren = 0
);

parameter RAH_PACKET_WIDTH = 48;

localparam IDLE   = 3'd0;
localparam READ   = 3'd1;
localparam CHECK  = 3'd2;
localparam DIVIDE = 3'd3;
localparam NEXT   = 3'd4;
localparam FINAL  = 3'd5;

reg [2:0] state = IDLE;

reg [9:0] n;              // working number (10-bit)
reg [5:0] divisor;        // up to 31
reg r_wait;

wire [11:0] div_sq;
assign div_sq = divisor * divisor;

always @(posedge clk) begin
    wren <= 0;

    case (state)

        IDLE: begin
            rden <= 0;
            if (!empty) begin
                rden  <= 1;
                r_wait <= 1'b0;
                state <= READ;
            end
        end

        READ: begin
            if (r_wait) begin
                n       <= a[9:0];   // only lower 10 bits used
                divisor <= 6'd2;
                rden    <= 0;
                state   <= CHECK;
            end else begin
                r_wait <= 1'b1;
            end
        end

        CHECK: begin
            if (div_sq > n) begin
                state <= FINAL;
            end else if ((n % divisor) == 0) begin
                state <= DIVIDE;
            end else begin
                state <= NEXT;
            end
        end

        DIVIDE: begin
            c    <= {{(RAH_PACKET_WIDTH-10){1'b0}}, divisor};
            wren <= 1'b1;
            n    <= n / divisor;
            state <= CHECK;
        end

        NEXT: begin
            divisor <= divisor + 6'd1;
            state   <= CHECK;
        end

        FINAL: begin
            if (n > 10'd1) begin
                c    <= {{(RAH_PACKET_WIDTH-10){1'b0}}, n};
                wren <= 1'b1;
            end
            state <= IDLE;
        end

    endcase
end

endmodule
