task init_weightsbuffer();
begin
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_0_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[0].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_0_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[0].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_1_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[1].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_1_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[1].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_2_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[2].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_2_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[2].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_3_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[3].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_3_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[3].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_4_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[4].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_4_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[4].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_5_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[5].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_5_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[5].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_6_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[6].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_6_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[6].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_7_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[7].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_7_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[7].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_8_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[8].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_8_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[8].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_9_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[9].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_9_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[9].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_10_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[10].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_10_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[10].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_11_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[11].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_11_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[11].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_12_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[12].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_12_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[12].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_13_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[13].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_13_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[13].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_14_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[14].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_14_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[14].BUF_UNIT_2[1].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_15_bram_0.txt", hwtop.WB.wbp.BUF_UNIT_1[15].BUF_UNIT_2[0].bram_inst.ram_name);
    $readmemh ( "..//sim_data//weightbuffer_data//layer_0_out_15_bram_1.txt", hwtop.WB.wbp.BUF_UNIT_1[15].BUF_UNIT_2[1].bram_inst.ram_name);
end
endtask
