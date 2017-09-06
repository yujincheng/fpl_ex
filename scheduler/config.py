bram_length = 16*1024
w_length = 8*1024
hardware_config = {
	'bram_buf' : bram_length * 4 * 8 * 4, # bram_buf = bram_length * DATA_BRAM_WIDTH * INPUT_PARALL * 4
	'w_buf' : w_length * 8 * 8,
	'inter_buf' : 20000,
	'bias_buf' : 10000,
	'bram_length' : bram_length,
	'ddr_offset' : 0x00000000
	}

bram_length = 16*1024
w_length = 4*1024
hardware_config_7045 = {
	'bram_buf' : bram_length * 4 * 8 * 4, # bram_buf = bram_length * DATA_BRAM_WIDTH * INPUT_PARALL * 4
	'w_buf' : w_length * 8 * 8,
	'inter_buf' : 20000,
	'bias_buf' : 10000,
	'bram_length' : bram_length,
	'ddr_offset' : 0x10000000
	}