/* 
 * Alfio Di Mauro <adimauro@iis.ee.ethz.ch>
 *
 * Copyright (C) 2018-2020 ETH Zurich, University of Bologna
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 *
 *                http://solderpad.org/licenses/SHL-0.51. 
 *
 * Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

module udma_cpi_wrap
    import udma_pkg::udma_evt_t;
    import cpi_pkg::pad_to_cpi_t;
(
    input logic         sys_clk_i,
    input logic         periph_clk_i,
	  input logic         rstn_i,
    input logic         dft_test_mode_i,
    input logic         dft_cg_enable_i,


	  input logic [31:0]  cfg_data_i,
	  input logic [4:0]   cfg_addr_i,
	  input logic         cfg_valid_i,
	  input logic         cfg_rwn_i,
	  output logic        cfg_ready_o,
    output logic [31:0] cfg_data_o,

    output udma_evt_t   events_o,
    input  udma_evt_t   events_i,

    // UDMA CHANNEL CONNECTION
    UDMA_LIN_CH.rx_out  rx_ch[0:0],

    // PAD SIGNALS CONNECTION
    input pad_to_cpi_t  pad_to_cpi

);

import udma_pkg::TRANS_SIZE;  
import udma_pkg::L2_AWIDTH_NOAL; 

logic [9:0] data_s;
logic frame_evt_s;

camera_if #(.L2_AWIDTH_NOAL(L2_AWIDTH_NOAL), .TRANS_SIZE(TRANS_SIZE), .DATA_WIDTH(10), .BUFFER_WIDTH(8)) i_camera_if (
    .clk_i              ( sys_clk_i           ),
    .rstn_i             ( rstn_i              ),

    .dft_test_mode_i    ( dft_test_mode_i     ),
    .dft_cg_enable_i    ( dft_cg_enable_i     ),

    .frame_evt_o        ( frame_evt_s         ),

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
    .cfg_rx_dest_o      ( rx_ch[0].destination),

    .data_rx_datasize_o ( rx_ch[0].datasize   ),
    .data_rx_data_o     ( rx_ch[0].data       ),
    .data_rx_valid_o    ( rx_ch[0].valid      ),
    .data_rx_ready_i    ( rx_ch[0].ready      ),

    .cam_clk_i          ( pad_to_cpi.pclk_i   ),
    .cam_data_i         ( data_s              ),
    .cam_hsync_i        ( pad_to_cpi.hsync_i  ),
    .cam_vsync_i        ( pad_to_cpi.vsync_i  )
);

assign data_s[0] = pad_to_cpi.data0_i;
assign data_s[1] = pad_to_cpi.data1_i;
assign data_s[2] = pad_to_cpi.data2_i;
assign data_s[3] = pad_to_cpi.data3_i;
assign data_s[4] = pad_to_cpi.data4_i;
assign data_s[5] = pad_to_cpi.data5_i;
assign data_s[6] = pad_to_cpi.data6_i;
assign data_s[7] = pad_to_cpi.data7_i;
assign data_s[8] = pad_to_cpi.data8_i;
assign data_s[9] = pad_to_cpi.data9_i;

assign events_o[0]   = rx_ch[0].events;
assign events_o[1]   = frame_evt_s;
assign events_o[2]   = 1'b0;
assign events_o[3]   = 1'b0;

// assigning unused signals
assign rx_ch[0].stream      = '0;
assign rx_ch[0].stream_id   = '0;

endmodule : udma_cpi_wrap








