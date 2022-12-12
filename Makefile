SHELL=bash
BENDER_SIM_BUILD_DIR = sim

TB = udma_camera_tb

VOPT           ?= vopt
VSIM           ?= vsim
VLIB           ?= vlib
VMAP           ?= vmap
VSIM_FLAGS      = ""
VLOG_ARGS      ?= -suppress vlog-2583 -svinputport=net +define+NGGROUPS=$(NGGROUPS) +define+SLICES=$(SLICES) +define+NEURONS=$(NEURONS) +define+LAYER=$(LAYER) 

checkout: bender
	@./bender update

bender:
ifeq (,$(wildcard ./bender))
	curl --proto '=https' --tlsv1.2 -sSf https://pulp-platform.github.io/bender/init | bash -s -- 0.22.0
	touch bender
endif

.PHONY: bender-rm sim opt build
bender-rm:
	rm -f bender

scripts: scripts-vsim

scripts-vsim: | Bender.lock $(BENDER_SIM_BUILD_DIR)
	echo 'set ROOT [file normalize [file dirname [info script]]/..]' > $(BENDER_SIM_BUILD_DIR)/compile.tcl
	./bender script vsim \
		--vlog-arg="$(VLOG_ARGS)" --vcom-arg="" \
		-t rtl -t test -t uvm\
		| grep -v "set ROOT" >> $(BENDER_SIM_BUILD_DIR)/compile.tcl

$(BENDER_SIM_BUILD_DIR)/compile.tcl: Bender.lock
	echo 'set ROOT [file normalize [file dirname [info script]]/..]' > $(BENDER_SIM_BUILD_DIR)/compile.tcl
	./bender script vsim \
		--vlog-arg="$(VLOG_ARGS)" --vcom-arg="" \
		-t rtl -t test \
		| grep -v "set ROOT" >> $(BENDER_SIM_BUILD_DIR)/compile.tcl

#build the RTL platform
build: $(BENDER_SIM_BUILD_DIR)/compile.tcl
	@test -f Bender.lock || { echo "ERROR: Bender.lock file does not exist. Did you run make checkout in bender mode?"; exit 1; }
	@test -f $(BENDER_SIM_BUILD_DIR)/compile.tcl || { echo "ERROR: sim/compile.tcl file does not exist. Did you run make scripts in bender mode?"; exit 1; }
	cd sim && $(VSIM) -c -do 'source compile.tcl; quit'

opt:
	cd sim && $(VOPT) +acc=npr -o vopt_tb $(TB) -work work

sim:
	cd sim && $(VSIM) -64 vopt_tb \
	-suppress vsim-3009 -suppress vsim-8683 -suppress vsim-13288\
	+UVM_NO_RELNOTES -stats -t ps \
	$(VSIM_FLAGS) -do "do wave.do; run -a"


## Remove the RTL model files
clean:
	cd sim && mkdir -p work
	cd sim && rm -r work 
	cd sim && touch modelsim.ini
	cd sim && rm modelsim.ini