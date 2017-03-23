task init_biasbuffer();
begin
    $readmemh ( "..//sim_data//biasbuffer_data//layer_0_bias_bram_0.txt", hwtop.BB.bbp.BUF_UNIT[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//biasbuffer_data//layer_0_bias_bram_1.txt", hwtop.BB.bbp.BUF_UNIT[1].bram_inst.ram_name);
end
endtask
