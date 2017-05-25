# My Title

## 指令
###指令结构
见basic.py，注意的是第一个参数是从指令的低位开始数

## inter layer scheduling

###关于BRAM IO
在inter layer中，除起始layer在开始载入，结束layer需要写回，其他layer最多只需要存4行即可，要在编译时在BRAM中预留出用于中间层的地址空间

对于BRAM0来说，其在进行inter layer调度时，内部地址存储内容为：
B0C0R0, B0C0R4, B0C0R8, ..., B0C0R60, B0C16R0, B0C16R4 ... B0C48R60, 
B1C0R0, B1C16R0, ... B1C48R0, B2C0R0 ...

### BIAS BRAM

### LOAD DATA指令

要进行计算的最小数据单元是 $2\times width \times 8channel$ ,每次Load进来512bit=64Byte的结构为$2\times 4B \times 8channel$ ,随后读同一行中的后4B,读满一行后读第2行。

- DDR中数据:
- C0R0col0~3, C1R0col0~3 ... C15R0col0~3, C0R0col4~7 ...  C15R0col-end, 
- C0R1col0~3, C1R1col0~3 ... C15R1col0~3, C0R1col4~7 ...  C15R1col-end,
- ……
- C0Rendcol0~3, C1Rendcol0~3 ... C15Rendcol0~3, C0Rendcol4~7 ...  C15Rendcol-end,  
- C16R0col0~3, C17R0col0~3 ... C31R0col0~3, C16R0col4~7 ...  C31R0col-end, 
- ……

## 实验

- vgg-e 前五层fused
- vgg-e 前五层不fused
- vgg-e 全19层fused
- face alignent 全
- YOLO 全
