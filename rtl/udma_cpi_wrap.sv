 module udma_cpi_wrap
    import udma_pkg::udma_evt_t;
(
    input  logic         sys_clk_i,
    input  logic         periph_clk_i,
	input  logic         rstn_i,

	input  logic  [31:0] cfg_data_i,
	input  logic   [4:0] cfg_addr_i,
	input  logic         cfg_valid_i,
	input  logic         cfg_rwn_i,
	output logic         cfg_ready_o,
    output logic  [31:0] cfg_data_o,

    input  udma_evt_t    ch_events_i,
    output udma_evt_t    events_o,
    input  udma_evt_t    events_i,

    // UDMA CHANNEL CONNECTION
    UDMA_LIN_CH.rx_out   rx_ch[0:0],

    // PAD SIGNALS CONNECTION
	BIPAD_IF.PERIPH_SIDE PAD_PCLK,
    BIPAD_IF.PERIPH_SIDE PAD_VSYNCH,
    BIPAD_IF.PERIPH_SIDE PAD_HSYNCH,
    BIPAD_IF.PERIPH_SIDE PAD_DATA0,
    BIPAD_IF.PERIPH_SIDE PAD_DATA1,
    BIPAD_IF.PERIPH_SIDE PAD_DATA2,
    BIPAD_IF.PERIPH_SIDE PAD_DATA3,
    BIPAD_IF.PERIPH_SIDE PAD_DATA4,
    BIPAD_IF.PERIPH_SIDE PAD_DATA5,
    BIPAD_IF.PERIPH_SIDE PAD_DATA6,
    BIPAD_IF.PERIPH_SIDE PAD_DATA7

);

import udma_pkg::TRANS_SIZE;  
import udma_pkg::L2_AWIDTH_NOAL; 

logic [7:0] data_s;

camera_if #(.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL), .TRANS_SIZE(TRANS_SIZE), .DATA_WIDTH(8), .BUFFER_WIDTH(8)) i_camera_if (
    .clk_i              ( periph_clk_i        ),
    .rstn_i             ( rstn_i              ),

    .dft_test_mode_i    ( dft_test_mode_i     ),
    .dft_cg_enable_i    ( dft_cg_enable_i     ),

    .cfg_data_i         ( cfg_data_i          ),
    .cfg_addr_i         ( cfg_addr_i          ),
    .cfg_valid_i        ( cfg_valid_i         ),
    .cfg_rwn_i          ( cfg_rwn_i           ),
    .cfg_data_o         ( cfg_data_o          ),
    .cfg_ready_o        ( cfg_ready_o         ),

    .cfg_rx_startaddr_o ( rx_ch[0].startaddr  ),
    .cfg_rx_size_o      ( rx_ch[0].size       ),           
    .cfg_rx_continuous_o( rx_ch[0].continuous ),
    .cfg_rx_en_o        ( rx_ch[0].cen        ),
    .cfg_rx_clr_o       ( rx_ch[0].clr        ),
    .cfg_rx_en_i        ( rx_ch[0].en         ),
    .cfg_rx_pending_i   ( rx_ch[0].pending    ),
    .cfg_rx_curr_addr_i ( rx_ch[0].curr_addr  ),
    .cfg_rx_bytes_left_i( rx_ch[0].bytes_left ),

    .data_rx_datasize_o ( rx_ch[0].datasize   ),
    .data_rx_data_o     ( rx_ch[0].data[15:0] ),
    .data_rx_valid_o    ( rx_ch[0].valid      ),
    .data_rx_ready_i    ( rx_ch[0].ready      ),

    .cam_clk_i          ( PAD_PCLK.IN         ),
    .cam_data_i         ( data_s              ),
    .cam_hsync_i        ( PAD_HSYNCH.IN       ),
    .cam_vsync_i        ( PAD_VSYNCH.IN       )
);

assign PAD_DATA0.IN  = data_s[0];
assign PAD_DATA0.OUT = 1'b0;
assign PAD_DATA0.OE  = 1'b0;
assign PAD_DATA1.IN  = data_s[1];
assign PAD_DATA1.OUT = 1'b0;
assign PAD_DATA1.OE  = 1'b0;
assign PAD_DATA2.IN  = data_s[2];
assign PAD_DATA2.OUT = 1'b0;
assign PAD_DATA2.OE  = 1'b0;
assign PAD_DATA3.IN  = data_s[3];
assign PAD_DATA3.OUT = 1'b0;
assign PAD_DATA3.OE  = 1'b0;
assign PAD_DATA4.IN  = data_s[4];
assign PAD_DATA4.OUT = 1'b0;
assign PAD_DATA4.OE  = 1'b0;
assign PAD_DATA5.IN  = data_s[5];
assign PAD_DATA5.OUT = 1'b0;
assign PAD_DATA5.OE  = 1'b0;
assign PAD_DATA6.IN  = data_s[6];
assign PAD_DATA6.OUT = 1'b0;
assign PAD_DATA6.OE  = 1'b0;
assign PAD_DATA7.IN  = data_s[7];
assign PAD_DATA7.OUT = 1'b0;
assign PAD_DATA7.OE  = 1'b0;  

assign PAD_PCLK.OUT  = 1'b0;
assign PAD_PCLK.OE   = 1'b0;

assign PAD_VSYNCH.OUT = 1'b0;
assign PAD_VSYNCH.OE  = 1'b0;

assign PAD_HSYNCH.OUT = 1'b0;  
assign PAD_HSYNCH.OE  = 1'b0;  

assign events_o[0]   = ch_events_i[0];
assign events_o[3:1] = 0;

assign rx_ch[0].data[31:16] = 0;

endmodule : udma_cpi_wrap








