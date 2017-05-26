import bitstring as bs
import sys

def lineh2b(line):
    l = bs.BitArray(hex=line)
    l.byteswap()
    return l.bytes

def file2bit(finname, foutname):
    with open(finname,'r') as f:
        lines = f.readlines()
        lines = map(lambda x:x.rstrip(), lines)
        lines = map(lineh2b, lines)
    with open(foutname, 'w') as fout:
        fout.writelines(lines)


if __name__=='__main__':
    dir_name = 'insts/compute/'
    if len(sys.argv) < 2:
        exit(1)
    elif len(sys.argv) == 2:
        finname = dir_name + sys.argv[1]
        foutname = finname + '.bin'
    else:
        finname = dir_name + sys.argv[1]
        foutname = dir_name + sys.argv[2]

    
    file2bit(finname, foutname)