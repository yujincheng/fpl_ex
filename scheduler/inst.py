from bitstring import BitArray
from collections import OrderedDict
from pdb import set_trace
import config
from copy import deepcopy
from basic import *
import split
from models import *

# considering outputchannels are always multiplies of 16



class Scheduler():
    def __init__(self, net, config):
        self.net = net
        self.config = config

        #initializing BRAMs ?
        self.bram = Bram(config.bram_length, DATA_BRAM_WIDTH)
        self.last_inst = [None] * len(net) # The last executed inst of each layer
        self.blob_addr = [None] * (len(net) + 1) # The start addr of each layer's data
        self.blob_addr[0] = 0
        self.bias_addr = [None] * len(net)
        self.bias_addr[0] = 0

        self.data_source = None
        
        self._ddr_bias_offset = self.config.ddr_offset
        self._ddr_weight_offset = None
        self._ddr_out_offset = None

        for i in range(len(self.net) - 1):
            if net[i].split == 0:
                self.bias_addr[i + 1] = self.bias_addr[i] + ceil_div(self.net[i].output_channel, OUTPUT_PARALL)
            else:
                self.bias_addr[i + 1] = 0
        self.weight_addr = [None] * len(net)
        self.weight_addr[0] = 0
        for i in range(len(self.net) - 1):
            self.weight_addr[i + 1] = self.weight_addr[i] + 3 * 3 * \
                ceil_div(self.net[i].output_channel, OUTPUT_PARALL) * \
                ceil_div(self.net[i].input_channel, INPUT_PARALL)

        self.next_row = [0] * (len(net) + 1)

    @property
    def ddr_bias_offset(self):
        return self._ddr_bias_offset

    @ddr_bias_offset.setter
    def ddr_bias_offset(self, val):
        self._ddr_bias_offset = val + self.config.ddr_offset
        return
    
    @property
    def ddr_weight_offset(self):
        if self._ddr_weight_offset == None:
            ret = self.ddr_bias_offset
            for i in range(len(self.net)):
                ret += ceil_to(self.net[i].output_channel, OUTPUT_PARALL) * DDR_BIAS_WIDTH / OUTPUT_PARALL
            return ret
        else:
            return self._ddr_weight_offset

    @ddr_weight_offset.setter
    def ddr_weight_offset(self, val):
        self._ddr_weight_offset = val + self.config.ddr_offset
        return
    
    @property
    def ddr_data_offset(self):
        if self.data_source != None:
            return self.data_source
        else:
            ret = self.ddr_weight_offset
            for i in range(len(self.net)):
                ret += ceil_to(self.net[i].output_channel, OUTPUT_PARALL) * ceil_to(self.net[i].input_channel, INPUT_PARALL) * \
                    KERNEL_SIZE * KERNEL_SIZE 
            return ret
    
    @property
    def ddr_out_offset(self):
        if self._ddr_out_offset == None:
            ret = self.ddr_data_offset
            ret += ceil_to(self.net[0].shape[0], 2) * ceil_to(self.net[0].shape[1], DATA_BRAM_WIDTH) * ceil_to(self.net[0].input_channel, INPUT_PARALL)
            return ret
        else:
            return self._ddr_out_offset

    @ddr_out_offset.setter
    def ddr_out_offset(self, val):
        self._ddr_out_offset = val + self.config.ddr_offset
        return

    def ddr_out_tail(self):
        ret = self.ddr_out_offset
        ret += ceil_to(self.net[-1].outshape[0], 2) * ceil_to(self.net[-1].outshape[1], DATA_BRAM_WIDTH) * ceil_to(self.net[-1].output_channel, OUTPUT_PARALL)
        return ret

    def addr4in1(self, addrs):
        result = BitArray()
        for addr in addrs:
            addr = self.bram.addr(addr)
            result.append(BitArray(length = ADDR_LENGTH, uint = addr))
        return result.int

    def get_data_addr(self, blob_index, row_index, channel_index):
        if (blob_index < len(self.net)) and (row_index < 0 or row_index >= self.net[blob_index].shape[0]):
            return 0
        else:
            addr = self.blob_addr[blob_index]

            if blob_index == 0 or self.net[blob_index - 1].split == True: # whole blob
                if blob_index == len(self.net):
                    addr += row_index // 4 * ceil_div(self.net[blob_index - 1].output_channel , OUTPUT_PARALL) * \
                        ceil_div(self.net[blob_index - 1].outshape[1], DATA_BRAM_WIDTH)
                    # addr += row_index // 4 * ceil_div(self.net[blob_index - 1].outshape[1], DATA_BRAM_WIDTH)
                else:
                    addr += row_index // 4 * ceil_div(self.net[blob_index].input_channel , INPUT_PARALL) * \
                        ceil_div(self.net[blob_index].shape[1], DATA_BRAM_WIDTH)
                    # addr += row_index // 4 * ceil_div(self.net[blob_index].shape[1], DATA_BRAM_WIDTH)

                # offset of channel
                if blob_index == len(self.net):
                    addr += channel_index // INPUT_PARALL * ceil_div(self.net[blob_index - 1].outshape[1], DATA_BRAM_WIDTH)
                    # addr += channel_index // INPUT_PARALL * ceil_div(self.net[blob_index - 1].outshape[1], DATA_BRAM_WIDTH) * \
                    #    ceil_div(self.net[blob_index - 1].outshape[0], 4)
                else:
                    addr += channel_index // INPUT_PARALL * ceil_div(self.net[blob_index].shape[1], DATA_BRAM_WIDTH)
                    # addr += channel_index // INPUT_PARALL * ceil_div(self.net[blob_index].shape[1], DATA_BRAM_WIDTH) * \
                    #    ceil_div(self.net[blob_index].shape[0], 4)
            else: #interlayer blob
                
                if blob_index == len(self.net):
                    # channel offset
                    # addr += channel_index // INPUT_PARALL * ceil_div(self.net[blob_index - 1].outshape[1], DATA_BRAM_WIDTH) * 2
                    addr += channel_index // INPUT_PARALL * ceil_div(self.net[blob_index - 1].outshape[1], DATA_BRAM_WIDTH)
                    
                    # row offset
                    #addr += (row_index % 8) // 4 * ceil_div(self.net[blob_index - 1].outshape[1], DATA_BRAM_WIDTH)
                    addr += (row_index % 8) // 4 * ceil_div(self.net[blob_index - 1].output_channel , OUTPUT_PARALL) * \
                        ceil_div(self.net[blob_index - 1].outshape[1], DATA_BRAM_WIDTH)
                else:
                    # channel offset
                    # addr += channel_index // INPUT_PARALL * ceil_div(self.net[blob_index].shape[1], DATA_BRAM_WIDTH) * 2
                    addr += channel_index // INPUT_PARALL * ceil_div(self.net[blob_index].shape[1], DATA_BRAM_WIDTH)
                    
                    # row offset
                    # addr += (row_index % 8) // 4 * ceil_div(self.net[blob_index].shape[1], DATA_BRAM_WIDTH)
                    addr += (row_index % 8) // 4 * ceil_div(self.net[blob_index].input_channel , INPUT_PARALL) * \
                        ceil_div(self.net[blob_index].shape[1], DATA_BRAM_WIDTH)
                    
            # assert(addr <= self.config.bram_length)
            addr = self.bram.addr(addr)
            return addr #

    def get_bias_addr(self, layer_index, channel_index):
        addr = self.bias_addr[layer_index]
        addr += channel_index // OUTPUT_PARALL
        return addr

    def get_w_addr(self, layer_index, input_channel_index, output_channel_index):
        #TODO consider load weights
        addr = self.weight_addr[layer_index]
        addr += output_channel_index // OUTPUT_PARALL * KERNEL_SIZE * KERNEL_SIZE * \
            ceil_div(self.net[layer_index].input_channel, INPUT_PARALL) #* DDR_WEIGHT_DIV
        addr += input_channel_index // INPUT_PARALL * KERNEL_SIZE * KERNEL_SIZE # * DDR_WEIGHT_DIV
        #addr += output_channel_index // (OUTPUT_PARALL / DDR_WEIGHT_DIV) * KERNEL_SIZE * KERNEL_SIZE
        
        assert(addr <= self.config.bram_length)
        return addr

    def inst_load_init_data(self):
        # load data
        insts = []
        dfc_ddr_st_addr = self.ddr_data_offset
        #dfc_data_st_addr = 0
        inst_dep = 0b1111
        for channel_head in range(0, self.net[0].input_channel, INPUT_PARALL):
            for row_head in range(0, self.net[0].shape[0], 2):
                    inst = Inst(INST_TYPE_LOAD_DATA)
                    dfc_data_width = ceil_div(self.net[0].shape[1], DATA_BRAM_WIDTH)
                    dfc_data_ddr_byte = dfc_data_width * DATA_BRAM_WIDTH * INPUT_PARALL * 2
                    dfc_st_mac = row_head % 4 
                    dfc_data_st_addr = self.get_data_addr(0,row_head,channel_head)
                    
                    inst.set_inst(INST_TYPE_LOAD_DATA, dfc_data_width, dfc_data_ddr_byte, dfc_ddr_st_addr,
                        dfc_data_st_addr, dfc_st_mac, inst_dep)
                    insts.append(inst)

                    #dfc_ddr_st_addr += dfc_data_ddr_byte
                    #if dfc_st_mac % 4 == 2:
                    #    dfc_data_st_addr += dfc_data_width
        
        return insts
    

    def inst_write_final_data(self, layer_index, inst_type = INST_TYPE_WRITE_DATA):
        # write data
        insts = []
        dwc_ddr_st_addr = self.ddr_out_offset
        #dwc_data_st_addr = self.blob_addr[layer_index + 1]
        dwc_data_width = ceil_div(self.net[layer_index].outshape[1], DATA_BRAM_WIDTH)
        dwc_st_mac = 2

        inst_dep = 0b1111
        for channel_head in range(0, self.net[layer_index].output_channel, OUTPUT_PARALL):
            #if channel_head != 0 and dwc_st_mac == 0:
            #    dwc_data_st_addr += dwc_data_width

            for row_head in range(0, self.net[layer_index].outshape[0], 2):
                
                inst = Inst(inst_type)
                dwc_data_ddr_byte = dwc_data_width * DATA_BRAM_WIDTH * OUTPUT_PARALL * 2
                dwc_st_mac = row_head % 4 
                dwc_data_st_addr = self.get_data_addr(layer_index+1, row_head, channel_head)
                inst.set_inst(inst_type, dwc_data_width, dwc_data_ddr_byte, dwc_ddr_st_addr,
                    dwc_data_st_addr, dwc_st_mac, inst_dep)
                insts.append(inst)
                
                
                
                dwc_ddr_st_addr += dwc_data_ddr_byte
                #if dwc_st_mac % 4 == 2:
                #    dwc_data_st_addr += dwc_data_width
        
        return insts

    def calc_net(self):
        insts = []

        # initialize bram data
        ceil_div = lambda x, y:x/y + (x%y != 0)
        data_length = ceil_div(self.net[0].shape[1], DATA_BRAM_WIDTH) * ceil_div(self.net[0].shape[0],4) * \
            ceil_div(self.net[0].input_channel, INPUT_PARALL)
        self.bram.init_data([0] * data_length * DATA_BRAM_WIDTH)

        blob_nodes = [0]
        for i in range(len(self.net)):
            if self.net[i].split:
                blob_nodes.append(i+1)

        insts = insts + self.inst_load_init_data()
        for i in range(len(blob_nodes) - 1):
            if blob_nodes[i + 1] - blob_nodes[i] > 1:
                insts = insts + self.calc_interlayer(blob_nodes[i], blob_nodes[i + 1])
            else:
                insts = insts + self.calc_singlelayer(blob_nodes[i])
            #TEST
            if i==1:
                break

        #TEST
        insts = insts + self.inst_write_final_data(5)
        #insts = insts + self.inst_write_final_data(len(self.net) - 1)
        return insts #

    def interlayer_finished(self, start_index, end_index):
        for i in range(start_index, end_index):
            if self.next_row[i] + 2 < self.net[i].padshape()[0]:
                return False
        return True

        
    def get_ddr_layer_w_block_n(self, i, single = False):
        if single == False:
            return ceil_div(self.net[i].input_channel, INPUT_PARALL) * \
                ceil_div(self.net[i].output_channel, OUTPUT_PARALL)
        else:
            return ceil_div(self.net[i].input_channel, INPUT_PARALL) 

    def get_ddr_w_block_n(self, start_index, end_index, single = False):
        result = 0
        for i in range(start_index, end_index):
            result += self.get_ddr_layer_w_block_n(i, single)
        return result 

    def get_ddr_w_addr(self, start_index):
        return self.ddr_weight_offset + self.get_ddr_w_block_n(0, start_index) * INPUT_PARALL * \
            OUTPUT_PARALL * KERNEL_SIZE * KERNEL_SIZE * DDR_ADDR_BYTE
 
    def get_ddr_layer_b_block_n(self, i):
        return ceil_div(self.net[i].output_channel, OUTPUT_PARALL)

    def get_ddr_b_block_n(self, start_index, end_index):
        result = 0
        for i in range(start_index, end_index):
            result += self.get_ddr_layer_b_block_n(i)
        return result 

    def get_ddr_b_addr(self, start_index):
        return self.ddr_bias_offset + self.get_ddr_b_block_n(0, start_index) * DDR_BIAS_WIDTH

    def inst_load_interlayer_weights(self, start_index, end_index):
        insts = []

        self.weight_addr[start_index] = 0
        wfc_wb_st_addr = self.weight_addr[start_index] 

        for i in range(start_index, end_index):
            inst = Inst(INST_TYPE_LOAD_WEIGHT)

            inst_dep = 0b1111
            
            #wfc_wb_st_addr = self.weight_addr[start_index]
            wfc_ddr_st_addr = self.get_ddr_w_addr(i)
            wfc_weight_num = self.get_ddr_w_block_n(i, i+1)
            wfc_weight_ddr_byte = wfc_weight_num * KERNEL_SIZE * KERNEL_SIZE * INPUT_PARALL * OUTPUT_PARALL 
            inst.set_inst(INST_TYPE_LOAD_WEIGHT, wfc_weight_num, wfc_weight_ddr_byte, \
                wfc_ddr_st_addr, wfc_wb_st_addr, inst_dep)
            insts.append(inst)

            if i + 1 < len(self.weight_addr):
                self.weight_addr[i + 1] = self.weight_addr[i] + 3 * 3 * \
                    ceil_div(self.net[i].output_channel, OUTPUT_PARALL) * \
                    ceil_div(self.net[i].input_channel, INPUT_PARALL)
                wfc_wb_st_addr = self.weight_addr[i+1] 
        
        #self.weight_addr[start_index] = wfc_wb_st_addr # 0 
        #for i in range(start_index, end_index - 1):
        #   self.weight_addr[i + 1] = self.weight_addr[i] + 3 * 3 * \
        #        ceil_div(self.net[i].output_channel, OUTPUT_PARALL) * \
        #        ceil_div(self.net[i].input_channel, INPUT_PARALL)
        return insts

    def inst_load_singlelayer_weights(self, layer_index, partial_channel):
        insts = []
        inst = Inst(INST_TYPE_LOAD_WEIGHT)

        inst_dep = 0b0101
        
        
        wfc_wb_st_addr = (partial_channel / OUTPUT_PARALL) % 2 * KERNEL_SIZE * KERNEL_SIZE * \
            ceil_div(self.net[layer_index].input_channel, INPUT_PARALL)
        wfc_ddr_st_addr = self.get_ddr_w_addr(layer_index)
        
        wfc_weight_num = self.get_ddr_w_block_n(layer_index, layer_index + 1, True)
        wfc_weight_ddr_byte = wfc_weight_num * KERNEL_SIZE * KERNEL_SIZE * INPUT_PARALL * OUTPUT_PARALL 

        wfc_ddr_st_addr += wfc_weight_ddr_byte * (partial_channel / OUTPUT_PARALL)

        inst.set_inst(INST_TYPE_LOAD_WEIGHT, wfc_weight_num, wfc_weight_ddr_byte, \
            wfc_ddr_st_addr, wfc_wb_st_addr, inst_dep)
        insts.append(inst)

        self.weight_addr[layer_index] = 0 # wfc_wb_st_addr 
        
        return insts

    def inst_load_interlayer_bias(self, start_index, end_index):
        insts = []
        inst = Inst(INST_TYPE_LOAD_BIAS)
        bfc_bias_num = self.get_ddr_b_block_n(start_index, end_index)
        bfc_bias_ddr_byte = bfc_bias_num * DDR_BIAS_WIDTH
        bfc_ddr_st_addr = self.get_ddr_b_addr(start_index)
        bfc_bb_st_addr = 0
        inst_dep = 0b0110
        inst.set_inst(INST_TYPE_LOAD_BIAS, bfc_bias_num, bfc_bias_ddr_byte,
            bfc_ddr_st_addr, bfc_bb_st_addr, inst_dep)
        insts.append(inst)
        return insts
    
    def calc_singlelayer(self, layer_index):

        layer = self.net[layer_index]
        print str(layer_index) + ' to ' +  str(layer_index + 1) + ' single'

        self.blob_addr[layer_index + 1] = self.bram.get_write_addr() #start address for inter blob data
        
        insts = []
        
        # load bias
        insts = insts + self.inst_load_interlayer_bias(layer_index, layer_index + 1)

        for output_channel_head in range(0, layer.output_channel, OUTPUT_PARALL):

            cur_loadw = self.inst_load_singlelayer_weights(layer_index, output_channel_head)

            if output_channel_head == 0:
                insts = insts + cur_loadw
            else:
                last_comp[1:1] = cur_loadw
                insts = insts + last_comp

            self.next_row[layer_index] = 0
            self.last_inst[layer_index] = None

            row_index = 0
            last_comp = []
            while not self.interlayer_finished(layer_index, layer_index + 1):
                last_comp = last_comp + self.interlayer_next2row(layer_index, layer_index + 1, row_index, output_channel_head)
                row_index += 2
            last_comp[0].set_param('inst_dep', 0b0111)
        
        insts = insts + last_comp

        # make sure the io pointers are set correctly before returning
        self.bram.next_layer()
        return insts #

        

    def calc_interlayer(self, start_index, end_index):
        # assuming that the io pointers are correctly set
        # set write addrs

        print str(start_index) + ' to ' +  str(end_index)

        self.blob_addr[start_index + 1] = self.bram.get_write_addr() #start address for inter blob data
        inter_length =  0 # length of inter blob data in each BRAM in unit of BRAD_WIDTH
        for i in range(start_index + 1, end_index):
            inter_length += ceil_div(self.net[i].input_channel, INPUT_PARALL) * \
                ceil_div(self.net[i].shape[1], DATA_BRAM_WIDTH) * 2
            self.blob_addr[i + 1] = self.bram.get_write_addr() + inter_length

        self.bram.malloc_inter(self.blob_addr[end_index] - self.blob_addr[start_index + 1])
        
        insts = []
        # load weights
        insts = insts + self.inst_load_interlayer_weights(start_index, end_index)
        # load bias
        insts = insts + self.inst_load_interlayer_bias(start_index, end_index)

        # start compute
        row_index = 0
        comp_inst = []

        #TEST
        ii = 0
        while not self.interlayer_finished(start_index, end_index):
            comp_inst = comp_inst + self.interlayer_next2row(start_index, end_index, row_index)
            row_index += 2

            #TEST
            ii += 1
            if ii >= 6:
                #break
                pass

        comp_inst[0].set_param('inst_dep',0b0111)
        insts = insts + comp_inst
        # make sure the io pointers are set correctly before returning
        self.bram.next_layer()
        return insts #

    def interlayer_next2row(self, start_index, end_index, row_index, partial_channel = None):
        insts = []
        # consider pooling layer
        row_tail = row_index + 4 - self.net[start_index].padding # not include padding
        for i in range(start_index, end_index):
            if partial_channel == None:
                o_channel = self.net[i].output_channel
            else:
                o_channel = OUTPUT_PARALL
                
            if self.next_row[i] + 4 >  min(row_tail + self.net[start_index].padding, self.net[i].shape[0] + self.net[i].padding * 2 + 1):
                if self.net[i].pooling:
                    row_tail -= 2 - self.net[i].padding
                    row_tail /= 2
                else:
                    row_tail -= 2
                continue
                #old version:
                #row_tail -= 2
                #if self.net[i].pooling:
                #    row_tail /= 2
                #continue
            elif self.last_inst[i] == None:
                layer_insts = self.layer_first4row(i, self.next_row[i] - self.net[i].padding, partial_channel) # addr_offset ?= input data addr
                self.last_inst[i] = deepcopy(layer_insts[0])
                insts = insts + layer_insts

                # deal with bram addr
                if i == end_index - 1:
                    # but it is the first 4 rows , so just do it
                    #self.bram.write_addr(ceil_div(self.net[i].output_channel , OUTPUT_PARALL) * \
                    #    ceil_div(self.net[i].outshape[1], DATA_BRAM_WIDTH))
                    self.bram.write_addr(ceil_div(o_channel , OUTPUT_PARALL) * \
                        ceil_div(self.net[i].outshape[1], DATA_BRAM_WIDTH))

                self.next_row[i] += 2
                break

            else:
                layer_insts = self.layer_next2row(i, self.next_row[i] - self.net[i].padding, partial_channel)
                self.last_inst[i] = deepcopy(layer_insts[0])
                insts = insts + layer_insts

                if self.net[i].pooling:
                    row_tail -= 2 - self.net[i].padding
                    row_tail /= 2
                else:
                    row_tail -= 2

                # deal with bram addr
                if i == end_index - 1:
                    # the 4 brams may not be aligned
                    if (self.net[i].pooling ==0 and (row_tail % 4 <= 1)) or \
                        ((self.net[i].pooling) and (row_tail % 4 == 0)):
                        self.bram.write_addr(ceil_div(o_channel , OUTPUT_PARALL) * \
                            ceil_div(self.net[i].outshape[1], DATA_BRAM_WIDTH))                        
                if i == start_index and partial_channel == None:
                    if (row_index - self.net[i].padding + 2) % 4 <= 1:
                        self.bram.read_addr(ceil_div(self.net[i].input_channel , INPUT_PARALL) * \
                            ceil_div(self.net[i].shape[1], DATA_BRAM_WIDTH))

                self.next_row[i] += 2
        return insts #


    def layer_next2row(self, layer_index, row_index, partial_channel = None):
        layer = self.net[layer_index]
        insts = []
        last = self.last_inst[layer_index]

        inst_type = INST_TYPE_COMPUTE # compute
        row, col = layer.shape
        padrow, padcol = layer.padshape() # include padding zeros
        
        ilc_ispad = last.p('ilc_ispad')
        ilc_linelen = last.p('ilc_linelen')
        w2c_linelen = last.p('w2c_linelen')
        w2c_pooled = last.p('w2c_pooled')
        pooled_type = last.p('pooled_type')
        w2c_shift_len = last.p('w2c_shift_len')
        bias_shift = last.p('bias_shift')
        with_relu = last.p('with_relu')

        bsr_zerolist = [int(x >= self.net[layer_index].shape[0]) for x in range(row_index, row_index + 4)]
        bsr_zerolist.reverse()
        bsr_iszero = int(''.join(map(str, bsr_zerolist)), 2)

        inst_dep = 0b0100

        # switch the front 4 bit and the last 4 bit 
        last_bsr_buffermux = last.p('bsr_buffermux')
        bsr_buffermux = ((last_bsr_buffermux & 0b1111) << 4) + (last_bsr_buffermux >> 4)

        if partial_channel == None:
            output_channel_head_list = range(0, layer.output_channel, OUTPUT_PARALL)
        else:
            output_channel_head_list = [partial_channel]

        for output_channel_head in output_channel_head_list:
            assert((row_index + ilc_ispad) % 2 == 0)
            if w2c_pooled:
                outrow = (row_index + ilc_ispad) / 2
            else:
                outrow = (row_index + ilc_ispad)
            w2c_st_addr = [self.get_data_addr(layer_index + 1, outrow, output_channel_head)] * 4
            w2c_st_addr = self.addr4in1(w2c_st_addr)

            last_w2c_valid_mac = last.p('w2c_valid_mac')
            if w2c_pooled:
                w2c_valid_mac = last_w2c_valid_mac + 1
            else:
                w2c_valid_mac = last_w2c_valid_mac + 2
            w2c_valid_mac %= 4

            bias_addr = self.get_bias_addr(layer_index, output_channel_head)

            for input_channel_head in range(0, layer.input_channel, INPUT_PARALL):
                PEC_tofifo = 1
                PEC_fromfifo = 1
                if input_channel_head == 0:
                    PEC_fromfifo = 0
                if layer.input_channel - input_channel_head <= INPUT_PARALL:
                    PEC_tofifo = 0
                
                is_w2c_back = 1 - PEC_tofifo
                is_bb_ = is_w2c_back

                # ilc_st_addr = [self.get_data_addr(layer_index, row_i, input_channel_head) for row_i in range(row_index, row_index + 4)]
                ilc_st_addr = [self.get_data_addr(layer_index, row_i, input_channel_head) for row_i in self.cycle4(range(row_index, row_index + 4))]
                ilc_st_addr.reverse()
                ilc_st_addr = self.addr4in1(ilc_st_addr)

                if partial_channel == None:
                    wb_st_rd_addr = self.get_w_addr(layer_index, input_channel_head, output_channel_head)
                else:
                    wb_st_rd_addr = self.get_w_addr(layer_index, input_channel_head, output_channel_head % (OUTPUT_PARALL * 2)) # ping pong

                inst = Inst(inst_type)
                inst.set_inst(inst_type, ilc_st_addr, ilc_ispad, ilc_linelen, bsr_iszero, \
                    bsr_buffermux, PEC_fromfifo, PEC_tofifo, is_w2c_back, w2c_st_addr, \
                    w2c_linelen, w2c_pooled, pooled_type, wb_st_rd_addr, w2c_shift_len, \
                    w2c_valid_mac, is_bb_, bias_addr, bias_shift, inst_dep, with_relu)

                insts.append(inst)


        return insts
    
    def cycle4(self, rg):
        ret = [0] * 4
        for i in rg:
            ret[i % 4] = i
        return ret

    def layer_first4row(self, layer_index, row_index, partial_channel = None):
        layer = self.net[layer_index]
        insts = []

        inst_type = INST_TYPE_COMPUTE # compute
        row, col = layer.shape
        padrow, padcol = layer.padshape() # include padding zeros

        inst_dep = 0b0100
        if layer.padding:
            bsr_iszero = 1 # 0001
            bsr_buffermux = 0b10010011
        else:
            bsr_iszero = 0 # 0000
            bsr_buffermux = 0b11100100
        ilc_ispad = layer.padding

        ilc_linelen = padcol
        w2c_linelen = padcol - 2

        with_relu = layer.with_relu

        if layer.pooling:
            w2c_linelen = ceil_div(w2c_linelen, 2)

        w2c_pooled = layer.pooling
        pooled_type = layer.maxpooling

        w2c_shift_len = layer.shift_weight + layer.shift_in - layer.shift_out
        bias_shift = layer.shift_weight + layer.shift_in - layer.shift_bias
        assert(w2c_shift_len >= 0)
        assert(bias_shift >= 0)
        
        if partial_channel == None:
            output_channel_head_list = range(0, layer.output_channel, OUTPUT_PARALL)
        else:
            output_channel_head_list = [partial_channel]

        for output_channel_head in output_channel_head_list:
            # TODO considering o_c not multiple of 16

            assert((row_index + ilc_ispad) % 2 == 0)
            if w2c_pooled:
                outrow = (row_index + ilc_ispad) / 2
            else:
                outrow = (row_index + ilc_ispad)
            w2c_st_addr = [self.get_data_addr(layer_index + 1, outrow, output_channel_head)] * 4
            w2c_st_addr = self.addr4in1(w2c_st_addr)
            w2c_valid_mac = 0
            bias_addr = self.get_bias_addr(layer_index, output_channel_head)

            for input_channel_head in range(0, layer.input_channel, INPUT_PARALL):

                #FIFO params
                PEC_tofifo = 1
                PEC_fromfifo = 1
                if input_channel_head == 0:
                    PEC_fromfifo = 0
                if layer.input_channel - input_channel_head <= INPUT_PARALL:
                    PEC_tofifo = 0
            
                is_w2c_back = 1 - PEC_tofifo
                is_bb_ = is_w2c_back

                ilc_st_addr = [self.get_data_addr(layer_index, 0, input_channel_head)] * 4
                ilc_st_addr = self.addr4in1(ilc_st_addr)

                if partial_channel == None:
                    wb_st_rd_addr = self.get_w_addr(layer_index, input_channel_head, output_channel_head)
                else:
                    wb_st_rd_addr = self.get_w_addr(layer_index, input_channel_head, output_channel_head % (OUTPUT_PARALL * 2))

                inst = Inst(inst_type)
                inst.set_inst(inst_type, ilc_st_addr, ilc_ispad, ilc_linelen, bsr_iszero, \
                    bsr_buffermux, PEC_fromfifo, PEC_tofifo, is_w2c_back, w2c_st_addr, \
                    w2c_linelen, w2c_pooled, pooled_type, wb_st_rd_addr, w2c_shift_len, \
                    w2c_valid_mac, is_bb_, bias_addr, bias_shift, inst_dep, with_relu)
                insts.append(inst)
        return insts 
        

def fusenet(net):
    for layer in net:
        layer.split = 0
    net[-1].split = 1
    return net

def vgg19_net_fused():
    return fusenet(vgg19_net())


def vgg19_first5layer():
    net = vgg19_net()
    return net[:5]

def vgg19_first5layer_fused():
    return fusenet(vgg19_first5layer())

def print_net(net, flayer = []):
    #full data io
    data = 0
    for i in range(1,len(net)):
        data += 2 * net[i].bram_datasize()
    data += net[0].datasize() + net[-1].bram_outsize()
    print 'Full data: ', str(data)

    #new full data io
    data = 0
    data += net[0].datasize() + net[-1].bram_outsize()
    print 'New Fused data: ', str(data)
    data += net[1].bram_datasize()
    print 'New Full data: ', str(data)


    weight = 0
    for i in range(len(net)):
        weight += net[i].wsize()
    print 'Weights: ', str(weight)

    #all fused data
    data = [layer.bram_datasize() for layer in net]
    data.append(net[-1].bram_outsize())
    data[0] = net[0].datasize()
    fused_data = 0
    for i in range(len(flayer)):
        if i == 0 or i == len(flayer)-1:
            fused_data += data[flayer[i]]
        else:
            fused_data += data[flayer[i]] * 2
    print 'Fused Data: ', str(fused_data)

    # ops
    ops = 0
    for layer in net:
        ops += layer.ops()
    print 'ops: ', str(ops)

def ddr_arrange(nets):
    ddr_bias = [0]
    for net in nets:
        ddr_bias.append(ddr_bias[-1] + sum([layer.ddr_bsize() for layer in net]))
    ddr_weights = [ddr_bias[-1]]
    ddr_bias = ddr_bias[0:-1]
    for net in nets:
        ddr_weights.append(ddr_weights[-1] + sum([layer.ddr_wsize() for layer in net]))
    ddr_input = ddr_weights[-1]
    ddr_weights = ddr_weights[0:-1]

    ddr_output = [ddr_input + ceil_to(nets[0][0].input_channel, INPUT_PARALL) * ceil_to(nets[0][0].shape[0],2) * \
            ceil_to(nets[0][0].shape[1], DATA_BRAM_WIDTH)]
    cur_output = ddr_output[0]

    for net in nets:
        cur_output += ceil_to(net[-1].output_channel, OUTPUT_PARALL) * ceil_to(net[-1].outshape[0],2) * \
            ceil_to(net[-1].outshape[1], DATA_BRAM_WIDTH)
        ddr_output.append(cur_output)
    ddr_output = ddr_output[0:-1]
    
    return ddr_bias, ddr_weights, ddr_input, ddr_output
    

def test_ssd():
    net, depend = ssd_net()
    hardware_config = split.HardwareConfig(config.hardware_config)
    
    for i in depend:
        assert(depend[i]<=i)
    ddr_bias, ddr_weights, ddr_input, ddr_output = ddr_arrange(net)

    ddr_net_output = [0] * len(net)
    insts = []
    for i in range(len(net)):
        split.split_net(net[i], hardware_config)
        scheduler = Scheduler(net[i], hardware_config)
        
        #TODO custom ddr address here
        scheduler.ddr_bias_offset = ddr_bias[i]
        scheduler.ddr_weight_offset = ddr_weights[i]
        scheduler.ddr_out_offset = ddr_output[i]
        
        if i == 0:
            scheduler.data_source = scheduler.config.ddr_offset + ddr_input
        if depend[i] != i:
            scheduler.data_source = ddr_net_output[depend[i]]
        ddr_net_output[i] = scheduler.ddr_out_offset

        print scheduler.ddr_data_offset
        print scheduler.ddr_out_offset
        insts += scheduler.calc_net()
        #print scheduler.blob_addr
        print 'SSD-' + str(i) + ' succeed'
        break
    set_trace()
    with open('insts/SSD/' + 'SSD_newaddr_n1l6.txt','w') as fout:
        for inst in insts:
            inst.write_file(fout)
            

if __name__ == '__main__':
    '''
    inst = Inst()
    t = BitArray('uint:9=511,uint:9=511,uint:9=511,uint:9=511')
    inst.set_inst(0, 0, 64, 0, 0b11100100, 0, 1, 1, t.uint, 62, 0, 0, 0, 8, 0)
    '''
    test_ssd()
    exit(0)

    net = {}
    
    #net['E_ddr'] = vgg19_net()
    net['yolov2'] = yolov2_net()
    #net['D_bshift6'] = vggd_net()
    #net['C_ddr'] = vggc_net()
    #net['B_ddr'] = vggb_net()
    #net['A_ddr'] = vgga_net()
    
    #net['test_single'] = [Layerparam()]
    #net['test_single'][0].set_shift(0,0,12,12)
    #net['test_single'][0].padding = 1
    #net['test_single'][0].pooling = 1
    #net['test_single'][0].maxpooling = 1

    hardware_config = split.HardwareConfig(config.hardware_config)

    for i in net:
        split.split_net(net[i], hardware_config)
        scheduler = Scheduler(net[i], hardware_config)
        insts = scheduler.calc_net()
        print scheduler.blob_addr
        with open('insts/FPL/' + i + '.txt','w') as fout:
            for inst in insts:
                inst.write_file(fout)
        print 'VGG-' + i + ' successfully written'

    print 'insts successfully written'
