X_MAC = 4;
X_MESH = 16;


print "task init_braminst();"
print "begin"
for i in xrange(0,X_MESH):
	for j in xrange(0,X_MAC):
		prefix = '_' + i.__str__() + '_' + j.__str__();
		print "    $readmemh ( \"..//sim_data//BP_data//bram%s.txt\", bp.BUF_UNIT_1[%d].BUF_UNIT_2[%d].bram_inst.ram_name);"%(prefix,i,j)
print "end"
print "endtask"


