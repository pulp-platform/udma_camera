interface reg_if ();

	// top clock and reset
	logic clk_i;
	logic rstn_i;

	// top configuration interface
	logic [31:0] cfg_data_i;
	logic [4:0] cfg_addr_i;
	logic cfg_valid_i;
	logic cfg_rwn_i;
	logic cfg_ready_o;
	logic [31:0] cfg_data_o;

	// top pad signals
	cpi_pkg::pad_to_cpi_t pad2cpi;

	// top udma channel signals
	logic [31:0] data_i;
	logic valid_i;
	logic ready_o;
	logic [31:0] curr_addr_i;

	// events
	udma_pkg::udma_evt_t udma_evt_o;


endinterface