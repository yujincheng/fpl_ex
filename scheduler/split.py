from pdb import set_trace
from basic import *
import config
import inst as instr
'''
data=[224*224*3,
    224*224*64,
    112*112*64,
    112*112*128,
    56*56*128,
    56*56*256,
    56*56*256,
    28*28*256,
    28*28*512,
    28*28*512,
    14*14*512,
    14*14*512,
    14*14*512,
    7*7*512
    ]
inter_data=[3*64*224,
    64*64*224,
    64*128*112,
    128*128*112,
    128*256*56,
    256*256*56,
    256*256*56,
    256*512*28,
    512*512*28,
    512*512*28,
    512*512*14,
    512*512*14,
    512*512*14
    ]
inter_data=[x*4 for x in inter_data]
weights = [64*64*3*3]*10
'''


class HardwareConfig():
    def __init__(self, initial_data):
        for key in initial_data:
            setattr(self, key, initial_data[key])

def check_hardware(net, data, start_index, end_index, hardware_config):
    # check data buffer
    '''
    in_data = net[start_index].datasize()
    if end_index < len(net):
        out_data = net[end_index].datasize()
    else:
        out_data = net[end_index].outsize()
    '''
    # print 'Checking ' + str(start_index) + ' to ' + str(end_index) + ': ',
    interlayer_data = 0
    for i in range(start_index, end_index - 1):
        interlayer_data += ceil_to(net[i].outshape()[1], DATA_BRAM_WIDTH) * 4 * \
            ceil_to(net[i].output_channel, OUTPUT_PARALL)
			
    bram_buf = max(data[start_index], data[end_index]) + interlayer_data
    if bram_buf > hardware_config.bram_buf:
        # print 'data failed'
        return False

    # check inter buffer
    inter_buf = 0
    for i in range(start_index, end_index):
        cur_inter_buf = OUTPUT_PARALL * 2 * net[i].outshape()[1] * INTER_WIDTH 
        if inter_buf < cur_inter_buf:
            inter_buf = cur_inter_buf
    if inter_buf > hardware_config.inter_buf:
        # print 'inter buffer failed'
        return False

    # check weight buffer and bias buffer
    bias_buf = 0
    for i in range(start_index, end_index):
        bias_buf += net[i].bram_bsize()

    w_buf = 0
    if end_index - start_index > 1:
        for i in range(start_index, end_index):
            w_buf += net[i].bram_wsize()
    else:
        w_buf = INPUT_PARALL * KERNEL_SIZE * KERNEL_SIZE * \
            ceil_to(net[start_index].output_channel, OUTPUT_PARALL) 

    if w_buf > hardware_config.w_buf or bias_buf > hardware_config.bias_buf:
        # print 'weight or bias failed'
        return False

    # return True if satified
    return True



def split_net(net, hardware_config):
    blob_num = len(net) + 1

    data = [layer.bram_datasize() for layer in net]
    data.append(net[-1].bram_outsize())
    data[0] = net[0].datasize()
    min_dt = [0] * blob_num
    lastnode = [-1] * blob_num

    min_dt[0] = 0
    lastnode[0] = 0
    for i in range(1, blob_num):
        min_dt[i] = sum(data[:i])
        #min_dt[i] = sum([layer.datasize() for layer in net[:i]])
        for j in range(0,i):
            if not check_hardware(net, data, j, i, hardware_config):
                continue
            if min_dt[j] + data[j] <= min_dt[i]:
                min_dt[i] = min_dt[j] + data[j]
                lastnode[i] = j
    i=len(data)-1
    res = data[i]
    print lastnode

    for layer in net:
        layer.split = 0
    
    for node in lastnode:
        if node != -1 and node != 0:
            net[node-1].split = 1

    #set_trace()



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

if __name__=='__main__':
    # net = vgg19_net()
    net = instr.vggd_net()
    hardware_config = HardwareConfig(config.hardware_config)
    split_net(net, hardware_config)