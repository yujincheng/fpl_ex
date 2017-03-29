import numpy as np
from bitstring import BitArray
from collections import OrderedDict
from pdb import set_trace

# Hardware configuration
INST_LEN = 220
ADDR_LENGTH = 16
BIAS_ADDR_LENGTH = 16
WEIGHT_ADDR_LENGTH = 16
DATA_BRAM_WIDTH = 4
BIAS_BRAM_WIDTH = 8
WEIGHT_BRAM_WIDTH = 8
INTER_WIDTH = 3 # 24bit representing a single number

# for bias
SINGLE_LEN = 24

INPUT_PARALL = 16
OUTPUT_PARALL = 16

KERNEL_SIZE = 3


ceil_div = lambda x, y:-(-x//y)
ceil_to = lambda x, y: ceil_div(x,y) * y


class Layerparam(object):
    def __init__(self):
        self.input_channel = 16
        self.shape = (64,64)
        self.pooling = 0
        self.maxpooling = 0
        self.padding = 0
        self.output_channel = 16
        self.split = 1

    def set_param(self, ic, shape, pool, maxpooling, padding, oc, sp):
        self.input_channel = ic
        self.shape = shape
        self.pooling = pool
        self.maxpooling = maxpooling
        self.padding = padding
        self.output_channel = oc
        self.split = sp

    def ops(self):
        return self.shape[0] * self.shape[1] * KERNEL_SIZE * KERNEL_SIZE * \
            self.output_channel * self.input_channel
    	

    def outshape(self):
        size_change =  - KERNEL_SIZE + 1 + 2 * self.padding
        o_shape = (self.shape[0] + size_change, self.shape[1] + size_change)
        if self.pooling:
            return (ceil_div(o_shape[0], 2), ceil_div(o_shape[1], 2))
        else:
            return o_shape
    
    def padshape(self):
        return (self.shape[0] + 2 * self.padding, self.shape[1] + 2 * self.padding)

    def datasize(self):
        return self.shape[0] * self.shape[1] * self.input_channel

    def bram_datasize(self):
        return ceil_to(self.shape[0], 4) * ceil_to(self.shape[1], DATA_BRAM_WIDTH) * \
            ceil_to(self.input_channel, INPUT_PARALL)

    def outsize(self):
        return self.outshape()[0] * self.outshape()[1] * self.output_channel
    
    def bram_outsize(self):
        return ceil_to(self.outshape()[0], 4) * ceil_to(self.outshape()[1], DATA_BRAM_WIDTH) * \
            ceil_to(self.output_channel, OUTPUT_PARALL)

    def wsize(self):
        return self.input_channel * self.output_channel * KERNEL_SIZE * KERNEL_SIZE

    def bram_wsize(self):
        return ceil_to(self.input_channel, INPUT_PARALL) * \
            ceil_to(self.output_channel, OUTPUT_PARALL) * \
            KERNEL_SIZE * KERNEL_SIZE
    def bram_bsize(self):
        return ceil_to(self.output_channel, OUTPUT_PARALL)

class Bram(object):
    def __init__(self, length, width):
        self.length = length
        self.data = np.zeros(length * width).astype('int')
        self.i_head_ = 0
        self.i_tail_ = 0
        self.o_head_ = 0
        self.o_tail_ = 0
        self.width = width

    def get_write_addr(self):
        return self.o_tail_

    def malloc_inter(self, length):
        self.o_head_ = (self.o_head_ + length) % self.length
        self.o_tail_ = (self.o_tail_ + length) % self.length

    def write_addr(self, length):
        self.o_tail_ = (self.o_tail_ + length) % self.length

    def read_addr(self, length):
        self.i_head_ = (self.i_head_ + length) % self.length

    def get_read_addr(self):
        return self.i_head_


    def addr(self, addr, offset = 0):
        return (addr + offset) % self.length

    def next_layer(self):
        self.i_head_ = self.o_head_
        self.i_tail_ = self.o_tail_
        self.o_head_ = self.i_tail_
        self.o_tail_ = self.i_tail_


    ######################### 

    def read_data(self, addr, data_length):
        #assert(data_length % self.width == 0)
        if addr + ceil_div(data_length, self.width)  < self.length:
            return self.data[addr * self.width:addr * self.width + data_length]
        else:
            return np.concatenate((self.data[addr * self.width:],
                self.data[0:(addr * self.width + data_length) % (self.length * self.width)]))
    def from_file(self, filename):
        #TODO: reverse the 4 number of every 32bit
        pass

    def write_data(self, addr, data):
        #assert(addr == self.o_tail_)
        assert(len(data))
        #self.data[addr * self.width:addr * self.width + len(data)] = data
        
        if addr + ceil_div(len(data), self.width)  <= self.length:
            self.data[addr * self.width:addr * self.width + len(data)] = data
        else:
            self.data[addr * self.width:] = data[:self.length - addr * self.width]
            self.data[:(addr * self.width + len(data)) % (self.length * self.width)] = data[self.length - addr * self.width:]
    
        self.o_tail_ = (self.o_tail_ + len(data) / self.width + (len(data) % self.width != 0)) % self.length
    
    def init_data(self, data):
        self.data[0:len(data)] = data
        self.i_head_ = 0
        self.i_tail_ = len(data) / self.width
        self.o_head_ = len(data) / self.width
        self.o_tail_ = len(data) / self.width


class Inst(object):
    params_list = [
    	OrderedDict([ # compute
	        ('inst_type',4),
	        #('inst_depend',1), # whether need to wait the last inst
	        ('ilc_st_addr', ADDR_LENGTH * 4),
	        ('ilc_ispad',1),
	        ('ilc_linelen',9), # include padding
	        ('bsr_iszero',4),
	        ('bsr_buffermux',8), # the bram index of the i-th row of kernel(reversed)
	        ('PEC_fromfifo',1),
	        ('PEC_tofifo',1),
	        ('is_w2c_back',1),
	        ('w2c_st_addr', ADDR_LENGTH * 4), # address of writing back
	        ('w2c_linelen',9),
	        ('w2c_pooled',1),
	        ('pooled_type',1),
	        ('wb_st_rd_addr', WEIGHT_ADDR_LENGTH), 
	        ('w2c_shift_len',5),  # shift right & lower 8bit
	        ('w2c_valid_mac',2),
	        ('is_bb_',1),
	        ('bias_addr', BIAS_ADDR_LENGTH),
	        ('bias_shift',5)# shift left
	        ]),
    	OrderedDict([ # load bias
    		('inst_type',4),
            ('bfc_bias_num', SINGLE_LEN)
    		])]

    #def __new__(self, *args, **kwargs):
    #    BitArray.__new__(self, length = INST_LEN)

    def __init__(self, inst_type):
        for params in Inst.params_list:
            assert(sum(params.values()) <= INST_LEN)
        self.inst = BitArray(length = INST_LEN)
        self.params = Inst.params_list[inst_type]
        
    def set_inst(self, *args, **kwargs):
        if len(args) == len(self.params):
            p = INST_LEN
            v = self.params.values()
            for i in range(len(args)):
                try:
                    self.inst[p - v[i] : p] = args[i]
                    p = p - v[i]
                except:
                    print 'in the '+str(i) + 'th argument'
        else:
            print 'wrong number of args'
            set_trace()
            raise Exception()
            for param in kwargs:
                self.set_param(param, kwargs[param])

    def set_param(self, param, val):
        if self.params.has_key(param):
            p = self.param_tailpos(param)
            self.inst[p - self.params[param]:p] = val

    def param_tailpos(self, param):
        if self.params.has_key(param):
            i = self.params.keys().index(param)
            return INST_LEN - sum(self.params.values()[0:i])
        else:
            return None
    def p(self, param):
        if self.params.has_key(param):
            p = self.param_tailpos(param)
            return self.inst[p - self.params[param]:p].uint
        else:
            raise AttributeError('No parameters named ' + param)
            return None
    def print_params(self, param = None):
        if param == None:
            for i in self.params.keys():
                print i + ' : ' + str(self.p(i))
        else:
            print param + ' : ' + str(self.p(param))

    def write_file(self, fout):
        fout.write(self.inst.hex + '\n')
    def hex(self):
        return self.inst.hex
    
