`include "camera_verisuite.sv"

module udma_camera_tb;

	reg_if _if();
	logic rstn_i;
	logic clk_i;
	always #10 clk_i = ~clk_i;

	UDMA_LIN_CH rx_ch[0:0]();

	assign _if.clk_i = clk_i;
	assign _if.rstn_i = rstn_i;
	assign _if.valid_i = rx_ch[0].valid;
	assign _if.data_i = rx_ch[0].data;
	assign rx_ch[0].ready = _if.ready_o;
	assign rx_ch[0].curr_addr = _if.curr_addr_i; 
 
	udma_cpi_wrap i_udma_cpi_wrap (
		.sys_clk_i   (_if.clk_i       ),
		.periph_clk_i(_if.clk_i       ),
		.rstn_i      (_if.rstn_i      ),
		.cfg_data_i  (_if.cfg_data_i  ),
		.cfg_addr_i  (_if.cfg_addr_i  ),
		.cfg_valid_i (_if.cfg_valid_i ),
		.cfg_rwn_i   (_if.cfg_rwn_i   ),
		.cfg_ready_o (_if.cfg_ready_o ),
		.cfg_data_o  (_if.cfg_data_o  ),
		.events_o    (_if.udma_evt_o  ),
		.events_i    ('0              ),
		.rx_ch       (rx_ch           ),
		.pad_to_cpi  (_if.pad2cpi     )
	);

initial begin
	clk_i = 0;
	uvm_config_db#(virtual reg_if)::set(null, "uvm_test_top", "reg_vif", _if);
	run_test("test");
end

endmodule