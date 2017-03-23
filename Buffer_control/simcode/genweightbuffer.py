X_PE = 16;
X_MESH = 16;


print "task init_weightsbuffer();"
print "begin"
for i in xrange(0,X_PE):
	for j in xrange(0,X_MESH/8):
		prefix = '_out_' + i.__str__() + '_bram_' + j.__str__();
		print "    $readmemh ( \"..//sim_data//weightbuffer_data//layer_0%s.txt\", WB.wbp.BUF_UNIT_1[%d].BUF_UNIT_2[%d].bram_inst.ram_name);"%(prefix,i,j)
print "end"
print "endtask"