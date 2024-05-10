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
 
package cpi_pkg;
	 // cpi structure
	typedef struct packed{
		logic pclk_i;
		logic hsync_i;
		logic vsync_i;
		logic data0_i;
		logic data1_i;
		logic data2_i;
		logic data3_i;
		logic data4_i;
		logic data5_i;
		logic data6_i;
		logic data7_i;
		logic data8_i;
		logic data9_i;
	}pad_to_cpi_t;
endpackage