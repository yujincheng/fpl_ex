import numpy as np
from scipy.signal import convolve2d
from pdb import set_trace
from inst import Scheduler
from basic import *
import config


class ParamBuf:
	def __init__(self):
		self.length = length
		self.data = np.zeros(length)

class KernelSim:
	def __init__(self, io_bram, weight_buf, bias_buf):
		self.io_bram_ = io_bram # Input BRAM list: 16*4 BRAM
		self.w_buf_ = weight_buf # Weight_Buffer : 16*2 BRAM
		self.b_buf_ = bias_buf # Bias Buffer: 2 BRAM
		self.fifo_ = None
		self.inst_out = None
	
	def pooling(self, mat, p_type):
		row, col = mat.shape

		assert(row % 2 == 0)
		result = np.zeros(row / 2, (col+1)/2) # for odd column 

		for i in range(row / 2):
			for j in range((col + 1) / 2):
				if p_type == 1: # max pooling
					result[i,j] = np.max(mat[i*2:i*2+2,j*2:j*2+2])
				else:
					result[i,j] = mat[i*2,j*2]
		return result


	def run_inst(self, inst):
		input_data = np.zeros((INPUT_PARALL, 4, inst.p('ilc_linelen'))).astype('int')
		bsr_buffermux = inst.p('bsr_buffermux')
		ilc_st_addr = inst.p('ilc_st_addr')

		buffermux = [0] * 4
		addr = [0] * 4
		
		for i in range(4):
			buffermux[i] = (bsr_buffermux >> (i*2)) & 3
			addr[i] = (ilc_st_addr >> (i * ADDR_LENGTH)) & ((1 << ADDR_LENGTH) - 1)

		# load input data
		for i in range(4):
			if inst.p('bsr_iszero') & (1<<i) != 0:
				input_data[i,:] = 0 
			elif inst.p('ilc_ispad'):
				for j in range(INPUT_PARALL):
					input_data[j,i,1:-1] = self.io_bram_[j][buffermux[i]].read_data(addr[buffermux[i]], inst.p('ilc_linelen') - 2)
			else:
				for j in range(INPUT_PARALL):
					input_data[j,i,:] = self.io_bram_[j][buffermux[i]].read_data(addr[buffermux[i]], inst.p('ilc_linelen'))
		#input_data[input_data>127] -= 256

		# load weights
		weight = np.zeros((INPUT_PARALL, OUTPUT_PARALL, 3, 3)).astype('int')
		weight_addr = inst.p('wb_st_rd_addr')
		for i in range(INPUT_PARALL):
			for j in range(OUTPUT_PARALL):
				weight[i,j,:,:] = self.w_buf_[j][i / WEIGHT_BRAM_WIDTH].data[weight_addr + WEIGHT_BRAM_WIDTH - 1 - i % WEIGHT_BRAM_WIDTH:weight_addr + 9 * WEIGHT_BRAM_WIDTH : WEIGHT_BRAM_WIDTH].reshape((3,3))
		#weight[weight>127] -= 256

		# convolution
		output_data = np.zeros((OUTPUT_PARALL, 2, inst.p('ilc_linelen') - 2)).astype('int')
		for i in range(OUTPUT_PARALL):
			for j in range(INPUT_PARALL):
				output_data[i,:,:] += convolve2d(input_data[j], np.rot90(weight[j,i],2), 'valid')

		self.inst_out = output_data.copy() # the result of the inst

		# fifo
		if inst.p('PEC_fromfifo'):
			assert(self.fifo_ != None) # no input in fifo
			output_data += self.fifo_
			self.fifo_ = None
		if inst.p('PEC_tofifo'):
			self.fifo_ = output_data

		# bias
		if inst.p('is_bb_'):
			bias = np.zeros(OUTPUT_PARALL).astype('int')
			for i in range(OUTPUT_PARALL / BIAS_BRAM_WIDTH):
				bias[i * BIAS_BRAM_WIDTH:(i + 1) * BIAS_BRAM_WIDTH] = self.b_buf_[i].data[inst.p('bias_addr'):inst.p('bias_addr') + BIAS_BRAM_WIDTH]
			#bias[bias>127] -= 256
			bias = bias << inst.p('bias_shift')
			for i in range(OUTPUT_PARALL):
				output_data[i] += bias[i]

		# write back
		if inst.p('is_w2c_back'):
			write_data = np.zeros((OUTPUT_PARALL, 2 - inst.p('w2c_pooled'), inst.p('w2c_linelen'))).astype('int')
			for i in range(OUTPUT_PARALL):
				if inst.p('w2c_pooled'):
					write_data[i] = self.pooling(output_data[i], inst.p('pooled_type'))
				else:
					write_data[i] = output_data[i]
			write_data = write_data >> inst.p('w2c_shift_len')
			#write_data &= 0b11111111
			
			w2c_st_addr = inst.p('w2c_st_addr')
			write_addr = [0] * 4
			for i in range(4):
				write_addr[3-i] = (w2c_st_addr >> (i * ADDR_LENGTH)) & ((1 << ADDR_LENGTH) - 1)
			
			for i in range(OUTPUT_PARALL):
				for j in range(write_data.shape[1]):
					self.io_bram_[i][(inst.p('w2c_valid_mac') + j) % 4].write_data(write_addr[(inst.p('w2c_valid_mac') + j) % 4], write_data[i][j])
			set_trace()
		return self.inst_out
		

def test_load_net():
	import fordata.gen_weights as gw
	import fordata.gen_bias as gb
	import fordata.gen_input as gi
	from pickle import load

	finput = open('fordata/data/input_data.pickle','r')
	data_input = load(finput)
	bram_input = gi.input_toBRAM(data_input) # 16 * 4 * length
	finput.close()

	fweight = open('fordata/weights/input_weight.pickle','r')
	data_weight = load(fweight)
	bram_weight = gw.weight_toBRAM(data_weight)
	bram_weight = bram_weight['layer_0']
	fweight.close()

	fbias = open('fordata/bias/bias.pickle','r')
	data_bias = load(fbias)
	bram_bias = gb.bias_toBRAM(data_bias)
	bram_bias = bram_bias['layer_0']
	fbias.close()
	set_trace()
	# init bram
	io_bram = [[Bram(512,4) for i in range(4)] for j in range(16)]
	weight_buf = [[Bram(32,8) for i in range(2)] for j in range(16)]
	bias_buf = [Bram(32,8) for i in range(2)]

	for i in range(16):
		for j in range(4):
			io_bram[i][j].init_data(bram_input[i][j])
		for j in range(2):
			weight_buf[i][j].init_data(bram_weight[i][j])
		bias_buf[i/8].data[0:8] = bram_bias[i/8]
	
	return io_bram, weight_buf, bias_buf

def single_inst():
	io_bram, weight_buf, bias_buf = test_load_net()

	kernel_sim = KernelSim(io_bram, weight_buf, bias_buf)

	test_inst = Inst()
	t = BitArray('uint:13=1024,uint:13=1024,uint:13=1024,uint:13=1024')

	test_inst.set_inst(0, 0, 0, 64, 0, 0b11100100, 0, 1, 1, t.uint, 62, 0, 0, 0, 0, 0, 1, 0, 0)
	result = kernel_sim.run_inst(test_inst)
	#set_trace()

def layer_insts_test():
	io_bram, weight_buf, bias_buf = test_load_net()
	kernel_sim = KernelSim(io_bram, weight_buf, bias_buf)

	layer1 = Layerparam()
	net = [layer1]
	scheduler = Scheduler(net, config.hardware_config)
	insts = scheduler.calc_net()

	for inst in insts:
		result = kernel_sim.run_inst(inst)
	set_trace()

if __name__=='__main__':

	layer_insts_test()
