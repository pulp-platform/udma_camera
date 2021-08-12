import uvm_pkg::*;
`include "uvm_macros.svh"

`define PERIOD 500

`define DATA_WIDTH 10
`define LINE_PIXELS 166
`define FRAME_LINES 128

`define CFG_REGS 4

`define TRANSACTIONS 4

//`define VERBOSE

class camera_item extends uvm_sequence_item;

	rand logic [`FRAME_LINES-1:0][`LINE_PIXELS-1:0][9:0] pdata;
	// cfg registers values
	camera_verisuite_pkg::cfg_reg_t [`CFG_REGS-1:0] cfg_regs;

	logic [`FRAME_LINES-1:0][`LINE_PIXELS-1:0][15:0] vmemspace;
	
	`uvm_object_utils_begin(camera_item)
		`uvm_field_int(pdata,UVM_DEFAULT)
		`uvm_field_int(cfg_regs,UVM_DEFAULT)
		`uvm_field_int(vmemspace,UVM_DEFAULT)
	`uvm_object_utils_end

	virtual function string convert2str();
		`ifdef VERBOSE
			return $sformatf("vmemspace=%0h",vmemspace);
		`else 
			return $sformatf("Omitting data packed print, use VERBOSE deifne to print it");
		`endif
	endfunction

	function new (string name = "camera_item");
		super.new(name);
	endfunction
endclass

class driver extends uvm_driver #(camera_item);
	`uvm_component_utils(driver)
	function new (string name = "driver", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	virtual reg_if vif;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("DRV","Driver build",UVM_LOW)
		if (!uvm_config_db#(virtual reg_if)::get(this, "", "reg_vif",vif)) begin
			`uvm_fatal("DRV","Could not get vif")
		end
	endfunction

	virtual task pre_reset_phase (uvm_phase phase);
		phase.raise_objection(this);
		vif.rstn_i = 1'b1;
		vif.cfg_data_i = '0;
		vif.cfg_addr_i = '0;
		vif.cfg_valid_i = '0;
		vif.cfg_rwn_i = '0;
		vif.ready_o = 1'b0;
		vif.pad2cpi.pclk_i  = '0;
		vif.pad2cpi.data0_i = '0;
		vif.pad2cpi.data1_i = '0;
		vif.pad2cpi.data2_i = '0;
		vif.pad2cpi.data3_i = '0;
		vif.pad2cpi.data4_i = '0;
		vif.pad2cpi.data5_i = '0;
		vif.pad2cpi.data6_i = '0;
		vif.pad2cpi.data7_i = '0;
		vif.pad2cpi.data8_i = '0;
		vif.pad2cpi.data9_i = '0;
		vif.pad2cpi.vsync_i = '0;
		vif.pad2cpi.hsync_i = '0;
		#1;
		phase.drop_objection(this);
	endtask: pre_reset_phase

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		//`uvm_info("DRV","Driver run...",UVM_LOW)
		forever begin
			camera_item m_item;
			//`uvm_info("DRV", $sformatf("Wait for item from sequencer"),UVM_LOW)
			seq_item_port.get_next_item(m_item);
			drive_item(m_item);
			seq_item_port.item_done();
		end
	endtask

	virtual task write_cfg_reg(camera_verisuite_pkg::cfg_reg_t regval);
		vif.cfg_valid_i <= 1;
		vif.cfg_data_i <= regval.value;
		vif.cfg_rwn_i <= 0;
		vif.cfg_addr_i <= regval.addr;
		@( posedge vif.clk_i);
		while (!vif.cfg_ready_o) begin
			`uvm_info("DRV", $sformatf("Wait until cfg_ready_o is high"), UVM_LOW)
			@( posedge vif.clk_i);
		end
		vif.cfg_valid_i <= 0;
		// verify that the register has been written and in case issue an error
	endtask

	task clock_cycles(input int cycles);
		for (int i = 0; i < cycles; i++) begin
			vif.pad2cpi.pclk_i = 0;
			#(`PERIOD/2);
			vif.pad2cpi.pclk_i = 1;
			#(`PERIOD/2); 
		end
	endtask

	task send_pixel (logic [`DATA_WIDTH-1:0] pixel);
		vif.pad2cpi.pclk_i <= 0;
		vif.pad2cpi.data0_i <= pixel[0];
		vif.pad2cpi.data1_i <= pixel[1];
		vif.pad2cpi.data2_i <= pixel[2];
		vif.pad2cpi.data3_i <= pixel[3];
		vif.pad2cpi.data4_i <= pixel[4];
		vif.pad2cpi.data5_i <= pixel[5];
		vif.pad2cpi.data6_i <= pixel[6];
		vif.pad2cpi.data7_i <= pixel[7];
		vif.pad2cpi.data8_i <= pixel[8];
		vif.pad2cpi.data9_i <= pixel[9];
		#(`PERIOD/2);
		vif.pad2cpi.pclk_i <= 1;
		#(`PERIOD/2); 
	endtask

	task drive_item(camera_item m_item);

		m_item.cfg_regs[0].addr = 32'h00000001;
		m_item.cfg_regs[1].addr = 32'h00000002;
		m_item.cfg_regs[2].addr = 32'h00000008;
		m_item.cfg_regs[3].addr = 32'h0000000b;

		m_item.cfg_regs[0].value = 32'h00000000 + `FRAME_LINES*`LINE_PIXELS*(`TRANSACTIONS)*2;
		m_item.cfg_regs[1].value = 32'h00000000 + 1 + (1'b1 << 3);
		m_item.cfg_regs[2].value = 32'h00000000 + (1'b1 << 31) + (3'b110 << 8);
		m_item.cfg_regs[3].value = 32'h00000000 + `FRAME_LINES;

		// first configure the peripheral
		for (int i = 0; i < `CFG_REGS; i++) begin
			write_cfg_reg(m_item.cfg_regs[i]);
		end
		#1us;
		// drive the pixel
		clock_cycles(2);
		vif.pad2cpi.vsync_i <= 1;
		clock_cycles(1);
		vif.pad2cpi.vsync_i <= 0;
		clock_cycles(1);
		for (int y = 0; y < `FRAME_LINES; y++) begin
			clock_cycles(4);
			vif.pad2cpi.hsync_i <= 1;
			for (int x = 0; x < `LINE_PIXELS; x++) begin
				send_pixel(m_item.pdata[y][x]);
			end
			//#(`PERIOD/2);
			vif.pad2cpi.hsync_i <= 0;
		end
		vif.pad2cpi.vsync_i <= 0;
		clock_cycles(10);
	endtask
endclass

class monitor extends uvm_monitor;
	`uvm_component_utils(monitor)
	function new(string name="monitor",uvm_component parent=null);
		super.new(name, parent);
	endfunction

	uvm_analysis_port #(camera_item) mon_analysis_port;
	virtual reg_if vif;
	semaphore sema4;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//`uvm_info("MON","Monitor build",UVM_LOW)
		if (!uvm_config_db#(virtual reg_if)::get(this, "", "reg_vif",vif)) begin
			`uvm_fatal("MON","Could not get vif")
		end
		sema4 = new(1);
		mon_analysis_port = new("mon_analysis_port",this);
	endfunction

	task sniff_camera_item_input(ref camera_item item);
		int line_pixels = 0;
		int frame_lines = 0;
		// `uvm_info("SNF","Sniff camera input",UVM_LOW)
		@(posedge vif.pad2cpi.vsync_i);
		while (frame_lines < `FRAME_LINES) begin

			@(posedge vif.pad2cpi.pclk_i);
			// if (vif.pad2cpi.vsync_i) begin
				line_pixels = 0;
				while (line_pixels < `LINE_PIXELS) begin
					@(posedge vif.pad2cpi.pclk_i);
					if (vif.pad2cpi.hsync_i) begin
						item.pdata[frame_lines][line_pixels][0] = vif.pad2cpi.data0_i;
						item.pdata[frame_lines][line_pixels][1] = vif.pad2cpi.data1_i;
						item.pdata[frame_lines][line_pixels][2] = vif.pad2cpi.data2_i;
						item.pdata[frame_lines][line_pixels][3] = vif.pad2cpi.data3_i;
						item.pdata[frame_lines][line_pixels][4] = vif.pad2cpi.data4_i;
						item.pdata[frame_lines][line_pixels][5] = vif.pad2cpi.data5_i;
						item.pdata[frame_lines][line_pixels][6] = vif.pad2cpi.data6_i;
						item.pdata[frame_lines][line_pixels][7] = vif.pad2cpi.data7_i;
						item.pdata[frame_lines][line_pixels][8] = vif.pad2cpi.data8_i;
						item.pdata[frame_lines][line_pixels][9] = vif.pad2cpi.data9_i;
						line_pixels = line_pixels + 1;
					end
				end
				frame_lines = frame_lines + 1;
			// end
		end
	endtask

	task collect_camera_item_output(ref camera_item item);
		int pixel_p = 0;
		int line_p = 0;
		// `uvm_info("CLL","Collect peripheral output",UVM_LOW)
		vif.ready_o <= 1'b1;
		while(line_p < `FRAME_LINES) begin
			pixel_p = 0;
			while(pixel_p < `LINE_PIXELS) begin
				if (vif.valid_i && vif.ready_o) begin
					item.vmemspace[line_p][pixel_p+1] = vif.data_i[15:0];
					item.vmemspace[line_p][pixel_p] = vif.data_i[31:16];
					pixel_p = pixel_p + 2;
				end
				@(posedge vif.clk_i);
			end
			line_p++;
		end
	endtask

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		// `uvm_info("MON","Monitor run...",UVM_LOW)
		forever begin
			camera_item item_res = new;
			fork
				sniff_camera_item_input(item_res);
				collect_camera_item_output(item_res);
			join
			`uvm_info(get_type_name(),$sformatf("Monitor found packet %s",item_res.convert2str()),UVM_LOW)
			mon_analysis_port.write(item_res);
		end
	endtask
endclass

class agent extends uvm_agent;
	`uvm_component_utils(agent)
	function new(string name="agent",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	driver d0; // Driver handle
	monitor m0; // Monitor handle
	uvm_sequencer #(camera_item) s0; //Sequencer handle

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		s0 = uvm_sequencer#(camera_item)::type_id::create("s0",this);
		d0 = driver::type_id::create("d0",this);
		m0 = monitor::type_id::create("m0",this);
	endfunction 

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		d0.seq_item_port.connect(s0.seq_item_export);
	endfunction

endclass

// here the scoreboard
class scoreboard extends uvm_scoreboard;
	`uvm_component_utils(scoreboard)
	function new(string name="scoreboard",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	camera_item refq[`TRANSACTIONS];
	uvm_analysis_imp #(camera_item,scoreboard) m_analysis_imp;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_analysis_imp = new("m_analysis_imp",this);
		`uvm_info("SCBD","Scoreboard build",UVM_LOW)
	endfunction

	virtual function write(camera_item item);
		int errors = 0;
		//`uvm_info("SCBD","Scoreboard write",UVM_LOW)
		for (int i = 0; i < `FRAME_LINES; i++) begin
			for (int j = 0; j < `LINE_PIXELS; j++) begin
				if (item.pdata[i][j] != item.vmemspace[i][j]) begin
					`uvm_error(get_type_name(),$sformatf("Error @ pixel (%0d,%0d): p = %0x, m = %0x",i,j,item.pdata[i][j],item.vmemspace[i][j]));
					errors++;
				end 
			end
		end

		if (errors != 0) begin
			`uvm_fatal(get_type_name(),"Transaction failed");
		end else begin
			`uvm_info(get_type_name(),"Transaction passed",UVM_LOW);
		end

	endfunction
endclass 


class env extends uvm_env;
	`uvm_component_utils(env)
	function new(string name="env",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	agent a0;
	scoreboard sb0;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		a0 = agent::type_id::create("a0", this);
		sb0 = scoreboard::type_id::create("sb0",this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		a0.m0.mon_analysis_port.connect(sb0.m_analysis_imp);
	endfunction
endclass

class gen_item_seq extends uvm_sequence;
	`uvm_object_utils(gen_item_seq)
	function new(string name="gen_item_seq");
		super.new(name);
	endfunction

	virtual task body();
		for (int i = 0; i < `TRANSACTIONS; i++) begin
			camera_item m_item = camera_item::type_id::create("m_item");
			start_item(m_item);
			m_item.randomize();
			//`uvm_info("SEQ",$sformatf("Generate new item: "),UVM_LOW);
			finish_item(m_item);
		end
	endtask : body
endclass

class test extends uvm_test;
	`uvm_component_utils(test)
	function new(string name="test",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	env e0;
	virtual reg_if vif;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		e0 = env::type_id::create("e0",this);
		if (!uvm_config_db#(virtual reg_if)::get(this, "", "reg_vif",vif)) begin
			`uvm_fatal("TEST","Could not get vif")
		end

		uvm_config_db#(virtual reg_if)::set(this, "e0.a0.*", "reg_vif", vif);
	endfunction

	virtual task run_phase(uvm_phase phase);
		gen_item_seq seq = gen_item_seq::type_id::create("seq");
		phase.raise_objection(this);
		apply_reset();
		seq.randomize();
		seq.start(e0.a0.s0);
		#20us;
		phase.drop_objection(this);
	endtask

	virtual task apply_reset();
		vif.rstn_i <= 0;
		#1us;
		vif.rstn_i <= 1;
	endtask : apply_reset
endclass