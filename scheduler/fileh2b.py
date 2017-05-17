import bitstring as bs

def lineh2b(line):
    l = bs.BitArray(hex=line)
    return l.bytes

def file2bit(filename):
    with open(filename,'r') as f:
        lines = f.readlines()
        lines = map(lambda x:x.rstrip(), lines)
        lines = map(lineh2b, lines)
    with open(filename + '.bin', 'w') as fout:
        fout.writelines(lines)

file2bit('1.txt')