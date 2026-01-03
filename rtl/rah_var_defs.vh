`define TOTAL_APPS 4

`define ADD 1
`define SHIFT 2
`define MUL 3
`define SUBB 4

`define VERSION "1.3.0"

`define GET_DATA_RAH(a) rd_data[a * RAH_PACKET_WIDTH +: RAH_PACKET_WIDTH]
`define SET_DATA_RAH(a) wr_data[a * RAH_PACKET_WIDTH +: RAH_PACKET_WIDTH]
