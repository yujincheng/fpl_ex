
#文章结构

Overleaf链接：https://www.overleaf.com/8702087qghmbvdwbzjj

-[ ] 图不全


-[ ] 缺部分参考文献
-[ ] 实验结果

## 1Intro

余

##2 Background
余

##3 System design
余

###3.1 Overview

###3.2 Computation

###3.3 Buffer

###3.4 Control&instructions



## 4 Scheduling
###4.1cross layer introduction
余，胡

### 4.2Network split

- [ ] 给我们的图取一个吊炸天的名字

### 4.3compiler design

- 数据排布方案

  - 把BRAM当作一个整体，暂不考虑其内部
  - 资源分配方案
    数据在BRAM与DDR中如何流动
    layer data flow
    对应code/scheduler/kernelsim.py

- 算法资源消耗分析

  - 在本节中提出BRAM内具体的存储结构，循环队列等

  - 每一层要花多少memory，包括features, weights, bias

    与上一节的Check函数相关

    对应code/scheduler/split.py

- 指令调度（七层循环）

  - 具体如何生成指令，对应code/scheduler/inst.py
  - 伪代码
  - ​

## 5 Experiments

余，胡，。。

##6 Related work
妃

##7 Conclusion
汪

