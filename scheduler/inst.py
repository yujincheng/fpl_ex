from bitstring import BitArray
from collections import OrderedDict
from pdb import set_trace
import config
from copy import deepcopy
from basic import *
import split

# considering outputchannels are always multiplies of 16




class Scheduler():
    def __init__(self, net, config):
        self.net = net
        self.config = config

        #initializing BRAMs ?
        self.brams = [Bram(config.bram_length, DATA_BRAM_WIDTH) for i in range(4)]
        self.bram = Bram(config.bram_length, DATA_BRAM_WIDTH)
        self.last_inst = [None] * len(net) # The last executed inst of each layer
        self.blob_addr = [None] * (len(net) + 1) # The start addr of each layer's data
        self.blob_addr[0] = 0
        self.bias_addr = [None] * len(net)
        self.bias_addr[0] = 0
        for i in range(len(self.net) - 1):
            self.bias_addr[i + 1] = self.bias_addr[i] + ceil_div(self.net[i].output_channel, OUTPUT_PARALL)
        self.weight_addr = [None] * len(net)
        self.weight_addr[0] = 0
        for i in range(len(self.net) - 1):
            self.weight_addr[i + 1] = self.weight_addr[i] + 3 * 3 * \
                ceil_div(self.net[i].output_channel, OUTPUT_PARALL) * \
                ceil_div(self.net[i].input_channel, INPUT_PARALL)

        self.next_row = [0] * (len(net) + 1)
        self.test_counter1 = 0
        self.test_counter2 = 0


    def addr4in1(self, addrs):
        result = BitArray()
        for addr in addrs:
            addr = self.bram.addr(addr)
            result.append(BitArray(length = ADDR_LENGTH, uint = addr))
        return result.int

    def get_data_addr(self, blob_index, row_index, channel_index):
        if (blob_index < len(self.net)) and (row_index < 0 or row_index >= self.net[blob_index].shape[0]):
            #set_trace()
            return 0
        else:
            addr = self.blob_addr[blob_index]
            # offset of channel
            if blob_index == len(self.net):
                addr += channel_index // INPUT_PARALL * ceil_div(self.net[blob_index - 1].outshape()[1], DATA_BRAM_WIDTH)
            else:
                addr += channel_index // INPUT_PARALL * ceil_div(self.net[blob_index].shape[1], DATA_BRAM_WIDTH)
            if blob_index == 0 or self.net[blob_index - 1].split == True: # whole blob
                if blob_index == len(self.net):
                    addr += row_index // 4 * ceil_div(self.net[blob_index - 1].output_channel , OUTPUT_PARALL) * \
                        ceil_div(self.net[blob_index - 1].outshape()[1], DATA_BRAM_WIDTH)
                else:
                    addr += row_index // 4 * ceil_div(self.net[blob_index].input_channel , INPUT_PARALL) * \
                        ceil_div(self.net[blob_index].shape[1], DATA_BRAM_WIDTH)
            return addr #

    def get_bias_addr(self, layer_index, channel_index):
        addr = self.bias_addr[layer_index]
        addr += channel_index // OUTPUT_PARALL
        return addr

    def get_w_addr(self, layer_index, input_channel_index, output_channel_index):
        #TODO consider load weights
        addr = self.weight_addr[layer_index]
        addr += output_channel_index // OUTPUT_PARALL * KERNEL_SIZE * KERNEL_SIZE * \
            ceil_div(self.net[layer_index].input_channel, INPUT_PARALL)
        addr += input_channel_index // INPUT_PARALL * KERNEL_SIZE * KERNEL_SIZE
        
        # for test
        addr %= self.config.bram_length

        return addr

    def calc_net(self):
        #TODO load weights
        
        # initialize bram data
        ceil_div = lambda x, y:x/y + (x%y != 0)
        data_length = ceil_div(self.net[0].shape[1], DATA_BRAM_WIDTH) * ceil_div(self.net[0].shape[0],4)
        for bram in self.brams:
            bram.init_data([0] * data_length) 
        self.bram.init_data([0] * data_length)

        blob_nodes = [0]
        insts = []
        for i in range(len(self.net)):
            if self.net[i].split:
                blob_nodes.append(i+1)
        print blob_nodes
        for i in range(len(blob_nodes) - 1):
            insts = insts + self.calc_interlayer(blob_nodes[i], blob_nodes[i + 1])

        return insts #

    def interlayer_finished(self, start_index, end_index):
        for i in range(start_index, end_index):
            if self.next_row[i] + 2 < self.net[i].padshape()[0]:
                return False
        return True

    def calc_interlayer(self, start_index, end_index):
        # assuming that the io pointers are correctly set
        # set write addrs

        print str(start_index) + ' to ' +  str(end_index)


        self.blob_addr[start_index + 1] = self.bram.get_write_addr() #start address for inter blob data
        inter_length =  0 # length of inter blob data in each BRAM in unit of BRAD_WIDTH
        for i in range(start_index + 1, end_index):
            inter_length += ceil_div(self.net[i].input_channel, INPUT_PARALL) * \
                ceil_div(self.net[i].outshape()[1], DATA_BRAM_WIDTH)
            self.blob_addr[i + 1] = self.bram.get_write_addr() + inter_length

        self.bram.malloc_inter(self.blob_addr[end_index] - self.blob_addr[start_index + 1])

        # start compute
        insts = []
        row_index = 0
        while not self.interlayer_finished(start_index, end_index):
            insts = insts + self.interlayer_next2row(start_index, end_index, row_index)
            row_index += 2

        # make sure the io pointers are set correctly before returning
        self.bram.next_layer()

        return insts #

    def interlayer_next2row(self, start_index, end_index, row_index):
        insts = []
        # consider pooling layer
        row_tail = row_index + 4 - self.net[start_index].padding # not include padding
        for i in range(start_index, end_index):
            if self.next_row[i] + 4 >  min(row_tail + self.net[start_index].padding, self.net[i].shape[0] + self.net[i].padding * 2 + 1):
                row_tail -= 2
                if self.net[i].pooling:
                    row_tail /= 2
                continue
            elif self.last_inst[i] == None:
                layer_insts = self.layer_first4row(i, self.next_row[i] - self.net[i].padding) # addr_offset ?= input data addr
                self.last_inst[i] = deepcopy(layer_insts[0])
                insts = insts + layer_insts

                # deal with bram addr
                if i == end_index - 1:
                    # but it is the first 4 rows , so just do it
                    self.bram.write_addr(ceil_div(self.net[i].output_channel , OUTPUT_PARALL) * \
                        ceil_div(self.net[i].outshape()[1], DATA_BRAM_WIDTH))

                self.next_row[i] += 2
                break

            else:
                layer_insts = self.layer_next2row(i, self.next_row[i] - self.net[i].padding)
                self.last_inst[i] = deepcopy(layer_insts[0])
                insts = insts + layer_insts
                

                row_tail -= 2
                if self.net[i].pooling:
                    row_tail /= 2

                # deal with bram addr
                if i == end_index - 1:
                    # the 4 brams may not be aligned
                    if (self.net[i].pooling and (row_tail % 4 <= 1)) or \
                        ((self.net[i].pooling == 0) and (row_tail % 4 == 0)):
                        self.bram.write_addr(ceil_div(self.net[i].output_channel , OUTPUT_PARALL) * \
                            ceil_div(self.net[i].outshape()[1], DATA_BRAM_WIDTH))                        
                if i == start_index:
                    if (row_index - self.net[i].padding + 2) % 4 <= 1:
                        self.bram.read_addr(ceil_div(self.net[i].input_channel , INPUT_PARALL) * \
                            ceil_div(self.net[i].shape[1], DATA_BRAM_WIDTH))

                self.next_row[i] += 2
        return insts #


    def layer_next2row(self, layer_index, row_index):
        
        layer = self.net[layer_index]
        insts = []
        last = self.last_inst[layer_index]

        inst_type = 0 # compute
        row, col = layer.shape
        padrow, padcol = layer.padshape() # include padding zeros
        
        ilc_ispad = last.p('ilc_ispad')
        ilc_linelen = last.p('ilc_linelen')
        w2c_linelen = last.p('w2c_linelen')
        w2c_pooled = last.p('w2c_pooled')
        pooled_type = last.p('pooled_type')
        w2c_shift_len = last.p('w2c_shift_len')
        bias_shift = last.p('bias_shift')

        bsr_zerolist = [int(x >= self.net[layer_index].shape[0]) for x in range(row_index, row_index + 4)]
        bsr_zerolist.reverse()
        bsr_iszero = int(''.join(map(str, bsr_zerolist)), 2)

        # switch the front 4 bit and the last 4 bit 
        last_bsr_buffermux = last.p('bsr_buffermux')
        bsr_buffermux = ((last_bsr_buffermux & 0b1111) << 4) + (last_bsr_buffermux >> 4)

        for output_channel_head in range(0, layer.output_channel, OUTPUT_PARALL):
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

                #TODO need reverse??
                ilc_st_addr = [self.get_data_addr(layer_index, row_i, input_channel_head) for row_i in range(row_index, row_index + 4)]
                ilc_st_addr = self.addr4in1(ilc_st_addr)

                wb_st_rd_addr = self.get_w_addr(layer_index, input_channel_head, output_channel_head)

                inst = Inst(inst_type)
                inst.set_inst(inst_type, ilc_st_addr, ilc_ispad, ilc_linelen, bsr_iszero, \
                    bsr_buffermux, PEC_fromfifo, PEC_tofifo, is_w2c_back, w2c_st_addr, \
                    w2c_linelen, w2c_pooled, pooled_type, wb_st_rd_addr, w2c_shift_len, \
                    w2c_valid_mac, is_bb_, bias_addr, bias_shift)

                insts.append(inst)


        return insts


    def layer_first4row(self, layer_index, row_index):
        layer = self.net[layer_index]
        insts = []

        inst_type = 0 # compute
        row, col = layer.shape
        padrow, padcol = layer.padshape() # include padding zeros

        if layer.padding:
            bsr_iszero = 1 # 0001
            bsr_buffermux = 0b10010011
        else:
            bsr_iszero = 0 # 0000
            bsr_buffermux = 0b11100100
        ilc_ispad = layer.padding

        ilc_linelen = padcol
        w2c_linelen = padcol - 2

        if layer.pooling:
            w2c_linelen = ceil_div(w2c_linelen, 2)

        w2c_pooled = layer.pooling
        pooled_type = layer.maxpooling

        w2c_shift_len = 0 #TODO

        bias_shift = 0 #TODO
        
        for output_channel_head in range(0, layer.output_channel, OUTPUT_PARALL):
            # TODO considering o_c not multiple of 16

            w2c_st_addr = [self.get_data_addr(layer_index + 1, row_index, output_channel_head)] * 4
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
                wb_st_rd_addr = self.get_w_addr(layer_index, input_channel_head, output_channel_head)

                inst = Inst(inst_type)
                inst.set_inst(inst_type, ilc_st_addr, ilc_ispad, ilc_linelen, bsr_iszero, \
                    bsr_buffermux, PEC_fromfifo, PEC_tofifo, is_w2c_back, w2c_st_addr, \
                    w2c_linelen, w2c_pooled, pooled_type, wb_st_rd_addr, w2c_shift_len, \
                    w2c_valid_mac, is_bb_, bias_addr, bias_shift)
                insts.append(inst)

        return insts 
        


    '''
    def calc_layer(layer, addr_offset = [0] * 4):
        #TODO
        #OUTPUT channel
        # addr_offset
        write_addr = [256] * 4

        row, col = layer.shape # row includes zero lines if padding
        
        if layer.padding:
            row += 2
            col += 2

        inst_type = 0

        # calc zero rows
        zero_rows = set()
        if layer.padding:
            zero_rows.add(0)
            zero_rows.add(row - 1)
        if row % 2:
            zero_rows.add(row)

        ilc_ispad = layer.padding

        ilc_linelen = col
        w2c_linelen = col - 2

        if layer.pooling:
            w2c_linelen = (w2c_linelen + 1) / 2

        w2c_pooled = layer.pooling
        pooled_type = layer.maxpooling

        w2c_shift_len = 0 #TODO

        insts = []

        for channel_head in range(0, layer.input_channel, INPUT_PARALL):

            #FIFO params
            PEC_tofifo = 1
            PEC_fromfifo = 1

            if channel_head == 0:
                PEC_fromfifo = 0
            
            if layer.input_channel - channel_head <= INPUT_PARALL:
                PEC_tofifo = 0
            
        
            is_w2c_back = 1 - PEC_tofifo
            kernel_mux = [0] * 4

            # for test (bias)
            is_bb_ = is_w2c_back
            bias_addr = 0
            bias_shift = 0

            # Row Iteration
            for row_head in range(0, row - 2, 2):
                kernel_shift = row_head % 4

                for i in range(4):
                    kernel_mux[i] = (row_head + i - layer.padding) % 4
                kernel_mux.reverse()

                bsr_buffermux = int(''.join([bin(x).replace('0b','').zfill(2) for x in kernel_mux]), 2)

                if kernel_shift != 0:
                    kernel_shift = 4 - kernel_shift

                row_iszero = map(lambda x:str(int(x in zero_rows)), range(row_head, row_head+4))
                kernel_iszero = [row_iszero[(x + kernel_shift) % 4] for x in range(4)]
                kernel_iszero.reverse() #Q
                bsr_iszero = int(''.join(kernel_iszero), 2)

                addrs = [0] * 4
                for i in range(4):
                    data_line = row_head + i - layer.padding
                    bram_offset = data_line / 4 * ((col -  2 * layer.padding) / DATA_BRAM_WIDTH)
                    addrs[data_line%4] = bram_offset
                addrs.reverse()
                ilc_st_addr = addr4in1(addrs)

                w2c_valid_mac = row_head % 4
                #print write_addr
                w2c_st_addr = addr4in1(write_addr)
                write_addr[row_head % 4] = write_addr[row_head%4] + (w2c_linelen / 4) + ((w2c_linelen % 4) != 0)
                write_addr[(row_head + 1) % 4] = write_addr[(row_head+1)%4] + (w2c_linelen / 4) + ((w2c_linelen % 4) != 0)

                wb_st_rd_addr = 0 #Q

                inst = Inst(inst_type)
                inst.set_inst(inst_type, ilc_st_addr, ilc_ispad, ilc_linelen, bsr_iszero, \
                    bsr_buffermux, PEC_fromfifo, PEC_tofifo, is_w2c_back, w2c_st_addr, \
                    w2c_linelen, w2c_pooled, pooled_type,wb_st_rd_addr, w2c_shift_len, \
                    w2c_valid_mac, is_bb_, bias_addr, bias_shift)

                insts.append(inst)
                #insts.append(inst.hex())
        #with open('inst.txt','w') as fout:
        #    fout.writelines([x + '\n' for x in insts])
        return insts
    '''

def test_net():
    net = [Layerparam() for i in range(5)] # comments below are the number of insts needed 
    net[0].set_param(3, (64,64), 0, 0, 0, 16, 1) # 1 * 1 * 31
    net[1].set_param(16, (62, 62), 0,0, 1, 32, 1) # 1 * 2 * 31
    net[2].set_param(32, (62, 62), 0, 0, 0, 64, 0) # 2 * 4 * 30
    net[3].set_param(64, (60, 60), 0, 0, 1, 128, 0) # 4 * 8 * 30
    net[4].set_param(128, (60, 60), 1, 0, 0, 16, 1) # 8 * 1 * 29
    return net


def vgg19_net():
    net = [Layerparam() for i in range(16)]
    # i_channe, shape, pooling, is_maxpool, padding, o_channel, split
    net[0].set_param(3, (224, 224), 0, 0, 1, 64, 1)
    net[1].set_param(64, (224, 224), 1, 1, 1, 64, 1)
    net[2].set_param(64, (112, 112), 0, 0, 1, 128, 1)
    net[3].set_param(128, (112, 112), 1, 1, 1, 128, 1)
    net[4].set_param(128, (56, 56), 0, 0, 1, 256, 1)
    net[5].set_param(256, (56, 56), 0, 0, 1, 256, 1)
    net[6].set_param(256, (56, 56), 0, 0, 1, 256, 1)
    net[7].set_param(256, (56, 56), 1, 1, 1, 256, 1)
    net[8].set_param(256, (28, 28), 0, 0, 1, 512, 1)
    net[9].set_param(512, (28, 28), 0, 0, 1, 512, 1)
    net[10].set_param(512, (28, 28), 0, 0, 1, 512, 1)
    net[11].set_param(512, (28, 28), 1, 1, 1, 512, 1)
    net[12].set_param(512, (14, 14), 0, 0, 1, 512, 1)
    net[13].set_param(512, (14, 14), 0, 0, 1, 512, 1)
    net[14].set_param(512, (14, 14), 0, 0, 1, 512, 1)
    net[15].set_param(512, (14, 14), 1, 1, 1, 512, 1)
    return net

def vggc_net():
    net = [Layerparam() for i in range(16)]
    # i_channe, shape, pooling, is_maxpool, padding, o_channel, split
    net[0].set_param(3, (224, 224), 0, 0, 1, 64, 1)
    net[1].set_param(64, (224, 224), 1, 1, 1, 64, 1)
    net[2].set_param(64, (112, 112), 0, 0, 1, 128, 1)
    net[3].set_param(128, (112, 112), 1, 1, 1, 128, 1)
    net[4].set_param(128, (56, 56), 0, 0, 1, 256, 1)
    net[5].set_param(256, (56, 56), 0, 0, 1, 256, 1)
    net[7].set_param(256, (56, 56), 1, 1, 1, 256, 1)
    net[8].set_param(256, (28, 28), 0, 0, 1, 512, 1)
    net[9].set_param(512, (28, 28), 0, 0, 1, 512, 1)
    net[11].set_param(512, (28, 28), 1, 1, 1, 512, 1)
    net[12].set_param(512, (14, 14), 0, 0, 1, 512, 1)
    net[13].set_param(512, (14, 14), 0, 0, 1, 512, 1)
    net[15].set_param(512, (14, 14), 1, 1, 1, 512, 1)
    return net

def vggd_net(): # not supported 
    net = [Layerparam() for i in range(13)]
    # i_channe, shape, pooling, is_maxpool, padding, o_channel, split
    net[0].set_param(3, (224, 224), 0, 0, 1, 64, 1)
    net[1].set_param(64, (224, 224), 1, 1, 1, 64, 1)
    net[2].set_param(64, (112, 112), 0, 0, 1, 128, 1)
    net[3].set_param(128, (112, 112), 1, 1, 1, 128, 1)
    net[4].set_param(128, (56, 56), 0, 0, 1, 256, 1)
    net[5].set_param(256, (56, 56), 0, 0, 1, 256, 1)
    net[6].set_param(256, (56, 56), 1, 1, 1, 256, 1)
    net[7].set_param(256, (28, 28), 0, 0, 1, 512, 1)
    net[8].set_param(512, (28, 28), 0, 0, 1, 512, 1)
    net[9].set_param(512, (28, 28), 1, 1, 1, 512, 1)
    net[10].set_param(512, (14, 14), 0, 0, 1, 512, 1)
    net[11].set_param(512, (14, 14), 0, 0, 1, 512, 1)
    net[12].set_param(512, (14, 14), 1, 1, 1, 512, 1)
    return net


def vggb_net():
    net = [Layerparam() for i in range(10)]
    # i_channe, shape, pooling, is_maxpool, padding, o_channel, split
    net[0].set_param(3, (224, 224), 0, 0, 1, 64, 1)
    net[1].set_param(64, (224, 224), 1, 1, 1, 64, 1)
    net[2].set_param(64, (112, 112), 0, 0, 1, 128, 1)
    net[3].set_param(128, (112, 112), 1, 1, 1, 128, 1)
    net[4].set_param(128, (56, 56), 0, 0, 1, 256, 1)
    net[5].set_param(256, (56, 56), 1, 1, 1, 256, 1)
    net[6].set_param(256, (28, 28), 0, 0, 1, 512, 1)
    net[7].set_param(512, (28, 28), 1, 1, 1, 512, 1)
    net[8].set_param(512, (14, 14), 0, 0, 1, 512, 1)
    net[9].set_param(512, (14, 14), 1, 1, 1, 512, 1)
    return net

def vgga_net():
    net = [Layerparam() for i in range(8)]
    # i_channe, shape, pooling, is_maxpool, padding, o_channel, split
    net[0].set_param(3, (224, 224), 1, 1, 1, 64, 1)
    net[1].set_param(128, (112, 112), 1, 1, 1, 128, 1)
    net[2].set_param(128, (56, 56), 0, 0, 1, 256, 1)
    net[3].set_param(256, (56, 56), 1, 1, 1, 256, 1)
    net[4].set_param(256, (28, 28), 0, 0, 1, 512, 1)
    net[5].set_param(512, (28, 28), 1, 1, 1, 512, 1)
    net[6].set_param(512, (14, 14), 0, 0, 1, 512, 1)
    net[7].set_param(512, (14, 14), 1, 1, 1, 512, 1)
    return net

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

if __name__ == '__main__':
    '''
    inst = Inst()
    t = BitArray('uint:9=511,uint:9=511,uint:9=511,uint:9=511')
    inst.set_inst(0, 0, 64, 0, 0b11100100, 0, 1, 1, t.uint, 62, 0, 0, 0, 8, 0)
    '''

    # i_channe, shape, pooling, is_maxpool, padding, o_channel, split
    #layer1 = Layerparam()
    #layer1.set_param(16, (7,7), 0, 0, 1, 16, 1)
    #net = [layer1]

    net = {}
    net['E'] = vgg19_net()
    net['D'] = vggd_net()
    net['B'] = vggb_net()
    net['A'] = vgga_net()

    fblob = {}
    fblob['E'] = [0,4] + range(8,17)
    fblob['D'] = [0] + range(7,14)
    fblob['B'] = [0] + range(6,11)
    fblob['A'] = [0] + range(4,9)


    for i in net:
        print 'Net VGG_' + i + ' : '
        print_net(net[i],fblob[i])
        print ''

    set_trace()
    hardware_config = split.HardwareConfig(config.hardware_config)
    #split.split_net(net, hardware_config)
    #scheduler = Scheduler(net, hardware_config)
    #set_trace()
    #insts = scheduler.calc_net()
    
    for i in net:
        scheduler = Scheduler(net[i], hardware_config)
        insts = scheduler.calc_net()
        with open('insts/VGG-' + i + '.txt','w') as fout:
            for inst in insts:
                inst.write_file(fout)
        print 'VGG-' + i + ' successfully written'

    '''
    with open('insts/vgg_19_net_fused.txt','w') as fout:
        for inst in insts:
            inst.write_file(fout)
    '''
    print 'insts successfully written'

