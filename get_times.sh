#!/bin/bash


mkdir regs 2>/dev/null

# Iterar sobre cada línea del archivo
grep -H "EST_ANALYTICS_TIME" $(find ./ -name *"eisa.log" 2>/dev/null) | awk {'print $1";"$2 ";"'} > regs/analytics.reg
grep -H "SIM_WTHOUT_PDI" $(find ./ -name *"eisa.log" 2>/dev/null) | awk {'print $2 ";" $4 ";"'} > regs/sim.reg
grep -H "PDI_DELAY" $(find ./ -name *"eisa.log" 2>/dev/null) | awk {'print $2 ";" $4'} > regs/pdi.reg

paste regs/analytics.reg regs/sim.reg regs/pdi.reg  > regs/final.reg

