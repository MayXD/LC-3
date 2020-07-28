# Xs  appear as RED lines in the ModelSim waveform
#     diagrams. They frequently mean that a signal's
#     value can't be resolved because >= 2 values
#     are being assigned to it simultaneously.
#    
# Us  are also RED, indicating that no values are
#     being assigned to a signal#
# Zs  are BLUE

vlib ./work

vcom -93 -explicit -work work template_register.vhd
vcom -93 -explicit -work work ALU.vhd
vcom -93 -explicit -work work MEMORY.vhd
vcom -93 -explicit -work work ADDR_CTL_LOGIC.vhd
vcom -93 -explicit -work work REG_FILE.vhd
vcom -93 -explicit -work work NZP_LOGIC.vhd
vcom -93 -explicit -work work BussedDriversResolved.vhd
vcom -93 -explicit -work work Microsequencer.vhd
vcom -93 -explicit -work work Control_Store.vhd
vcom -93 -explicit -work work CONTROL_guts_package.vhd
vcom -93 -explicit -work work CONTROL.vhd
vcom -93 -explicit -work work data_path_package.vhd
vcom -93 -explicit -work work LC_3_data_path.vhd

vsim LC_3_data_path

view wave
view structure
view signals

#add wave -divider -height 32 Top_level
add wave Reset
add wave -height 32 Clock

add wave -height 32 -unsigned PC
add wave -height 32 -unsigned MAR

#add wave -height 48 mem
add wave -height 32 MDR
add wave -height 32 IR
#add wave -height 32 MEM_EN
add wave -height 32 R

#add wave -divider TheCONTROL-C_S
#add wave -height 32 Clock
#add wave -height 32 TheCONTROL/C_S/IRD
#add wave -height 32 TheCONTROL/C_S/COND
#add wave -height 32 -unsigned TheCONTROL/C_S/J
#add wave -height 32 -unsigned TheCONTROL/local_next_state
#add wave -height 32 TheCONTROL/local_BEN
#add wave -height 32 LD_BEN

#add wave -divider -height 32 Things_NZP
#add wave N
#add wave Z
#add wave P

#add wave -divider -height 32 TheMEMORY
#add wave TheMEMORY/SRAM(0)
#add wave TheMEMORY/SRAM(1)
#add wave TheMEMORY/SRAM(2)
#add wave TheMEMORY/SRAM(3)
#add wave TheMEMORY/SRAM(4)
#add wave TheMEMORY/SRAM(5)
#add wave TheMEMORY/SRAM(6)
#add wave TheMEMORY/SRAM(7)
#add wave TheMEMORY/SRAM(8)
#add wave TheMEMORY/SRAM(9)

#add wave TheMEMORY/SRAM(10)
#add wave TheMEMORY/SRAM(11)
#add wave TheMEMORY/SRAM(12)
#add wave TheMEMORY/SRAM(13)
#add wave TheMEMORY/SRAM(14)
#add wave TheMEMORY/SRAM(15)
#add wave TheMEMORY/SRAM(16)
#add wave TheMEMORY/SRAM(17)
#add wave TheMEMORY/SRAM(18)
#add wave TheMEMORY/SRAM(19)

#add wave TheMEMORY/SRAM(20)
#add wave TheMEMORY/SRAM(21)
#add wave TheMEMORY/SRAM(22)
#add wave TheMEMORY/SRAM(23)
#add wave TheMEMORY/SRAM(24)
#add wave TheMEMORY/SRAM(25)
#add wave TheMEMORY/SRAM(26)
#add wave TheMEMORY/SRAM(27)
#add wave TheMEMORY/SRAM(28)
#add wave TheMEMORY/SRAM(29)

#add wave TheMEMORY/SRAM(30)
#add wave TheMEMORY/SRAM(31)
#add wave TheMEMORY/SRAM(32)
#add wave TheMEMORY/SRAM(33)
#add wave TheMEMORY/SRAM(34)
#add wave TheMEMORY/SRAM(35)
#add wave TheMEMORY/SRAM(36)
#add wave TheMEMORY/SRAM(37)
#add wave TheMEMORY/SRAM(38)
#add wave TheMEMORY/SRAM(39)

add wave -divider -height 32 TheREG_FILE
add wave Reset
add wave -height 32 Clock
add wave -height 32 -unsigned TheCONTROL/local_next_state 
add wave -height 32 -unsigned PC
add wave -decimal TheREG_FILE/R0
#add wave -decimal TheREG_FILE/R1
#add wave -decimal TheREG_FILE/R2
#add wave -decimal TheREG_FILE/R3
#add wave -decimal TheREG_FILE/R4
#add wave -decimal TheREG_FILE/R5
#add wave -decimal TheREG_FILE/R6
add wave -decimal TheREG_FILE/R7

force -deposit Clock 0 0, 1 10 -r 20
force -deposit Reset 0 0, 1 3, 0 13
force -deposit KBDR_in 0000000000000000 0

run 2000
