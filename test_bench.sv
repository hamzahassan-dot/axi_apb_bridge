`timescale 1ns / 1ps

import axi_lite_pkg::*;

module test_bench;

	localparam STEP = 10;
	
	logic aclk, areset_n;
	axi_lite_if axi_lite_if();
	logic start_read;
	logic start_write;

	axi_lite_master master(
		.aclk(aclk), .areset_n(areset_n),
		.m_axi_lite(axi_lite_if),
		.start_read(start_read), .start_write(start_write)
	);

	axi_lite_slave  slave (
		.aclk(aclk), .areset_n(areset_n),
		.s_axi_lite(axi_lite_if)
	);

	always begin
		aclk = 1; #(STEP / 2);
		aclk = 0; #(STEP / 2);
	end

	initial begin
		start_read = 0; start_write = 0;
		areset_n = 1;
		#(STEP * 10) areset_n = 0;
		#(STEP * 10) areset_n = 1;
		start_write = 1; #(STEP) start_write = 0;
		#(STEP * 10)
		start_read = 1; #(STEP) start_read = 0;

		#(STEP * 10);

		test_write();
		test_read();

		$finish;
	end

	addr_t addr = 32'h4;
	data_t data = 32'hdeadbeef;
	int flag_w = 1, flag_r = 1;
	
	task test_write;
		if (slave.buffer[addr] != data) flag_w = 0;
		$display("actual:%h expected:%h\n", slave.buffer[addr], data);

		if (flag_w) $display("Pass");
		else $display("Fail");
	endtask : test_write

	task test_read;
		if (axi_lite_if.wvalid && axi_lite_if.wready) begin
			if (master.rdata != data) flag_r = 0;
		end
		$display("actual:%h expected:%h\n", master.rdata, data);

		if (flag_r) $display("Pass");
		else $display("Fail");
	endtask : test_read

endmodule
