X_PE = 16;
X_MESH = 16;


print "task init_biasbuffer();"
print "begin"
for i in xrange(0,X_PE/8):
	prefix = i.__str__();
	print "    $readmemh ( \"..//sim_data//biasbuffer_data//layer_0_bias_bram_%s.txt\", BB.bbp.BUF_UNIT[%d].bram_inst.ram_name);"%(prefix,i)
print "end"
print "endtask"
