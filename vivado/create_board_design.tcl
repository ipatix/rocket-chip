set sys_clock 150.000

# create project
create_project rocket_board_design rocket_board_design -part xcvu37p-fsvh2892-2-e-es1
set_property  ip_repo_paths  {rocket_ip_core /home/inf3/ar42enus/Documents/axi_full_address_converter} [current_project]
update_ip_catalog

# create block design
create_bd_design "main_design"

# create some basic constants
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_vec_1_0
set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_vec_1_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_vec_1_1
set_property -dict [list CONFIG.CONST_VAL {1}] [get_bd_cells xlconstant_vec_1_1]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_vec_4_0
set_property -dict [list CONFIG.CONST_WIDTH {4} CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_vec_4_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_vec_22_0
set_property -dict [list CONFIG.CONST_WIDTH {22} CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_vec_22_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_vec_32_0
set_property -dict [list CONFIG.CONST_WIDTH {32} CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_vec_32_0]

# Rocket CPU
create_bd_cell -type ip -vlnv user.org:user:ExampleRocketSystem:1.0 ExampleRocketSystem_0

# GPIO port
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property -dict [list CONFIG.C_GPIO_WIDTH {8} CONFIG.C_GPIO2_WIDTH {8} CONFIG.C_IS_DUAL {1} CONFIG.C_ALL_INPUTS_2 {1} CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_DOUT_DEFAULT {0x000000AA} ] [get_bd_cells axi_gpio_0]

# UARTlite ports 0, 1
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
set_property -dict [list CONFIG.C_BAUDRATE {115200}] [get_bd_cells axi_uartlite_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_1
set_property -dict [list CONFIG.C_BAUDRATE {115200}] [get_bd_cells axi_uartlite_1]

# UART 16500 port
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_1

# AXI HBM
create_bd_cell -type ip -vlnv xilinx.com:ip:hbm:1.0 hbm_0
set_property -dict [list CONFIG.USER_HBM_DENSITY {8GB} CONFIG.USER_HBM_STACK {2} CONFIG.USER_MEMORY_DISPLAY {8192} CONFIG.USER_SWITCH_ENABLE_01 {TRUE} CONFIG.USER_CLK_SEL_LIST0 {AXI_15_ACLK} CONFIG.USER_CLK_SEL_LIST1 {AXI_16_ACLK} CONFIG.USER_MC_ENABLE_08 {TRUE} CONFIG.USER_MC_ENABLE_09 {TRUE} CONFIG.USER_MC_ENABLE_10 {TRUE} CONFIG.USER_MC_ENABLE_11 {TRUE} CONFIG.USER_MC_ENABLE_12 {TRUE} CONFIG.USER_MC_ENABLE_13 {TRUE} CONFIG.USER_MC_ENABLE_14 {TRUE} CONFIG.USER_MC_ENABLE_15 {TRUE} CONFIG.USER_MC0_ECC_BYPASS {true} CONFIG.USER_MC1_ECC_BYPASS {true} CONFIG.USER_MC2_ECC_BYPASS {true} CONFIG.USER_MC3_ECC_BYPASS {true} CONFIG.USER_MC4_ECC_BYPASS {true} CONFIG.USER_MC5_ECC_BYPASS {true} CONFIG.USER_MC6_ECC_BYPASS {true} CONFIG.USER_MC7_ECC_BYPASS {true} CONFIG.USER_MC8_ECC_BYPASS {true} CONFIG.USER_MC9_ECC_BYPASS {true} CONFIG.USER_MC10_ECC_BYPASS {true} CONFIG.USER_MC11_ECC_BYPASS {true} CONFIG.USER_MC12_ECC_BYPASS {true} CONFIG.USER_MC13_ECC_BYPASS {true} CONFIG.USER_MC14_ECC_BYPASS {true} CONFIG.USER_MC15_ECC_BYPASS {true} CONFIG.USER_SAXI_00 {false} CONFIG.USER_SAXI_01 {false} CONFIG.USER_SAXI_02 {false} CONFIG.USER_SAXI_03 {false} CONFIG.USER_SAXI_04 {false} CONFIG.USER_SAXI_05 {false} CONFIG.USER_SAXI_06 {false} CONFIG.USER_SAXI_07 {false} CONFIG.USER_SAXI_08 {false} CONFIG.USER_SAXI_09 {false} CONFIG.USER_SAXI_10 {false} CONFIG.USER_SAXI_11 {false} CONFIG.USER_SAXI_12 {false} CONFIG.USER_SAXI_13 {false} CONFIG.USER_SAXI_14 {false} CONFIG.USER_SAXI_15 {true} CONFIG.USER_SAXI_16 {false} CONFIG.USER_SAXI_17 {false} CONFIG.USER_SAXI_18 {false} CONFIG.USER_SAXI_19 {false} CONFIG.USER_SAXI_20 {false} CONFIG.USER_SAXI_21 {false} CONFIG.USER_SAXI_22 {false} CONFIG.USER_SAXI_23 {false} CONFIG.USER_SAXI_24 {false} CONFIG.USER_SAXI_25 {false} CONFIG.USER_SAXI_26 {false} CONFIG.USER_SAXI_27 {false} CONFIG.USER_SAXI_28 {false} CONFIG.USER_SAXI_29 {false} CONFIG.USER_SAXI_30 {false} CONFIG.USER_SAXI_31 {false} CONFIG.USER_PHY_ENABLE_08 {TRUE} CONFIG.USER_PHY_ENABLE_09 {TRUE} CONFIG.USER_PHY_ENABLE_10 {TRUE} CONFIG.USER_PHY_ENABLE_11 {TRUE} CONFIG.USER_PHY_ENABLE_12 {TRUE} CONFIG.USER_PHY_ENABLE_13 {TRUE} CONFIG.USER_PHY_ENABLE_14 {TRUE} CONFIG.USER_PHY_ENABLE_15 {TRUE}] [get_bd_cells hbm_0]
set_property -dict [list CONFIG.USER_APB_PCLK_0 {75} CONFIG.USER_TEMP_POLL_CNT_0 {75000} CONFIG.USER_APB_PCLK_1 {75} CONFIG.USER_TEMP_POLL_CNT_1 {75000}] [get_bd_cells hbm_0]

# clock generator
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0
set_property -dict [list CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} CONFIG.PRIM_IN_FREQ {300.000} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ ${sys_clock} CONFIG.CLK_OUT1_PORT {clk_sys} CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100.000} CONFIG.CLK_OUT2_PORT {clk_hbm} CONFIG.CLKOUT3_USED {true} CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {75.000} CONFIG.CLK_OUT3_PORT {clk_apb}] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.USE_SAFE_CLOCK_STARTUP {true} CONFIG.CLKOUT1_DRIVES {BUFGCE} CONFIG.CLKOUT2_DRIVES {BUFGCE} CONFIG.CLKOUT3_DRIVES {BUFGCE} CONFIG.CLKOUT4_DRIVES {BUFGCE} CONFIG.CLKOUT5_DRIVES {BUFGCE} CONFIG.CLKOUT6_DRIVES {BUFGCE} CONFIG.CLKOUT7_DRIVES {BUFGCE} CONFIG.FEEDBACK_SOURCE {FDBK_AUTO}] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.USE_RESET {false}] [get_bd_cells clk_wiz_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_sys
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {Auto}}  [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]
connect_bd_net [get_bd_pins clk_wiz_0/clk_sys] [get_bd_pins proc_sys_reset_sys/slowest_sync_clk]
connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_sys/dcm_locked]
connect_bd_net [get_bd_pins proc_sys_reset_sys/mb_reset] [get_bd_pins ExampleRocketSystem_0/reset]

# Philipp's Address Converter
create_bd_cell -type ip -vlnv user.org:user:axi_full_address_converter:1.0 axi_full_address_con_0
set_property -dict [list CONFIG.OFFSET_VALUE {0x80000000} CONFIG.SUBTRACT {true} CONFIG.C_S_AXI_ID_WIDTH {6} CONFIG.C_S_AXI_ADDR_WIDTH {34} CONFIG.C_S_AXI_DATA_WIDTH {256} CONFIG.C_M_AXI_ID_WIDTH {6} CONFIG.C_M_AXI_ADDR_WIDTH {34} CONFIG.C_M_AXI_DATA_WIDTH {256}] [get_bd_cells axi_full_address_con_0]
set_property -dict [list CONFIG.C_S_AXI_AWUSER_WIDTH {1} CONFIG.C_S_AXI_ARUSER_WIDTH {1} CONFIG.C_S_AXI_WUSER_WIDTH {1} CONFIG.C_S_AXI_RUSER_WIDTH {1} CONFIG.C_S_AXI_BUSER_WIDTH {1} CONFIG.C_M_AXI_AWUSER_WIDTH {1} CONFIG.C_M_AXI_ARUSER_WIDTH {1} CONFIG.C_M_AXI_WUSER_WIDTH {1} CONFIG.C_M_AXI_RUSER_WIDTH {1} CONFIG.C_M_AXI_BUSER_WIDTH {1}] [get_bd_cells axi_full_address_con_0]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins axi_full_address_con_0/s_axi_awuser]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins axi_full_address_con_0/s_axi_wuser]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins axi_full_address_con_0/s_axi_aruser]

# connect rocket's memif over address converter to HBM
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_sys} Clk_slave {/clk_wiz_0/clk_sys} Clk_xbar {/clk_wiz_0/clk_sys} Master {/ExampleRocketSystem_0/mem_if} Slave {/axi_full_address_con_0/s_axi} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_full_address_con_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_sys} Clk_slave {/clk_wiz_0/clk_sys} Clk_xbar {/clk_wiz_0/clk_sys} Master {/axi_full_address_con_0/m_axi} Slave {/hbm_0/SAXI_15} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins hbm_0/SAXI_15]
connect_bd_net [get_bd_pins proc_sys_reset_sys/peripheral_aresetn] [get_bd_pins hbm_0/AXI_15_ARESET_N]
connect_bd_net [get_bd_pins clk_wiz_0/clk_hbm] [get_bd_pins hbm_0/HBM_REF_CLK_0]
connect_bd_net [get_bd_pins clk_wiz_0/clk_hbm] [get_bd_pins hbm_0/HBM_REF_CLK_1]
connect_bd_net [get_bd_pins clk_wiz_0/clk_apb] [get_bd_pins hbm_0/APB_0_PCLK]
connect_bd_net [get_bd_pins clk_wiz_0/clk_apb] [get_bd_pins hbm_0/APB_1_PCLK]
connect_bd_net [get_bd_pins proc_sys_reset_sys/peripheral_aresetn] [get_bd_pins hbm_0/APB_0_PRESET_N]
connect_bd_net [get_bd_pins proc_sys_reset_sys/peripheral_aresetn] [get_bd_pins hbm_0/APB_1_PRESET_N]
connect_bd_net [get_bd_pins xlconstant_vec_22_0/dout] [get_bd_pins hbm_0/APB_0_PADDR]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins hbm_0/APB_0_PENABLE]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins hbm_0/APB_0_PSEL]
connect_bd_net [get_bd_pins xlconstant_vec_32_0/dout] [get_bd_pins hbm_0/APB_0_PWDATA]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins hbm_0/APB_0_PWRITE]
connect_bd_net [get_bd_pins xlconstant_vec_22_0/dout] [get_bd_pins hbm_0/APB_1_PADDR]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins hbm_0/APB_1_PENABLE]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins hbm_0/APB_1_PSEL]
connect_bd_net [get_bd_pins xlconstant_vec_32_0/dout] [get_bd_pins hbm_0/APB_1_PWDATA]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins hbm_0/APB_1_PWRITE]

# make UART0 external
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {Auto}}  [get_bd_intf_pins axi_uartlite_0/UART]

# make UART1 external
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Manual_Source {Auto}}  [get_bd_intf_pins axi_uartlite_1/UART]

# make UART2 (16550) external
create_bd_port -dir O uart_rtl_2_txd
connect_bd_net [get_bd_ports uart_rtl_2_txd] [get_bd_pins axi_uart16550_0/sout]
create_bd_port -dir I uart_rtl_2_rxd
connect_bd_net [get_bd_ports uart_rtl_2_rxd] [get_bd_pins axi_uart16550_0/sin]

# make hidden UART3 (16550) external
create_bd_port -dir O uart_rtl_3_txd
connect_bd_net [get_bd_ports uart_rtl_3_txd] [get_bd_pins axi_uart16550_1/sout]
create_bd_port -dir I uart_rtl_3_rxd
connect_bd_net [get_bd_ports uart_rtl_3_rxd] [get_bd_pins axi_uart16550_1/sin]

# connect GPIOs
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_gpio_in
set_property -dict [list CONFIG.IN0_WIDTH.VALUE_SRC USER CONFIG.IN1_WIDTH.VALUE_SRC USER CONFIG.IN2_WIDTH.VALUE_SRC USER CONFIG.IN3_WIDTH.VALUE_SRC USER CONFIG.IN4_WIDTH.VALUE_SRC USER] [get_bd_cells xlconcat_gpio_in]
set_property -dict [list CONFIG.NUM_PORTS {5} CONFIG.IN2_WIDTH {1} CONFIG.IN3_WIDTH {1} CONFIG.IN4_WIDTH {4}] [get_bd_cells xlconcat_gpio_in]
connect_bd_net [get_bd_pins xlconcat_gpio_in/dout] [get_bd_pins axi_gpio_0/gpio2_io_i]
connect_bd_net [get_bd_pins hbm_0/apb_complete_0] [get_bd_pins xlconcat_gpio_in/In0]
connect_bd_net [get_bd_pins hbm_0/apb_complete_1] [get_bd_pins xlconcat_gpio_in/In1]
create_bd_port -dir I SW1_1
connect_bd_net [get_bd_ports SW1_1] [get_bd_pins xlconcat_gpio_in/In2]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins xlconcat_gpio_in/In3]
connect_bd_net [get_bd_pins xlconstant_vec_4_0/dout] [get_bd_pins xlconcat_gpio_in/In4]
create_bd_port -dir O -from 7 -to 0 USER_LED
connect_bd_net [get_bd_ports USER_LED] [get_bd_pins axi_gpio_0/gpio_io_o]

# connect Rocket Core to GPIO
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_sys } Clk_slave {/clk_wiz_0/clk_sys } Clk_xbar {/clk_wiz_0/clk_sys } Master {/ExampleRocketSystem_0/mmio_if} Slave {/axi_gpio_0/S_AXI} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_gpio_0/S_AXI]
set_property offset 0x60100000 [get_bd_addr_segs {ExampleRocketSystem_0/mmio_if/SEG_axi_gpio_0_Reg}]

# connect Rocket Core to UARTs
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_sys } Clk_slave {/clk_wiz_0/clk_sys } Clk_xbar {/clk_wiz_0/clk_sys } Master {/ExampleRocketSystem_0/mmio_if} Slave {/axi_uartlite_0/S_AXI} intc_ip {/ExampleRocketSystem_0_axi_periph_1} master_apm {0}}  [get_bd_intf_pins axi_uartlite_0/S_AXI]
set_property offset 0x60000000 [get_bd_addr_segs {ExampleRocketSystem_0/mmio_if/SEG_axi_uartlite_0_Reg}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_sys } Clk_slave {/clk_wiz_0/clk_sys } Clk_xbar {/clk_wiz_0/clk_sys } Master {/ExampleRocketSystem_0/mmio_if} Slave {/axi_uartlite_1/S_AXI} intc_ip {/ExampleRocketSystem_0_axi_periph_1} master_apm {0}}  [get_bd_intf_pins axi_uartlite_1/S_AXI]
set_property offset 0x60010000 [get_bd_addr_segs {ExampleRocketSystem_0/mmio_if/SEG_axi_uartlite_1_Reg}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_sys } Clk_slave {/clk_wiz_0/clk_sys } Clk_xbar {/clk_wiz_0/clk_sys } Master {/ExampleRocketSystem_0/mmio_if} Slave {/axi_uart16550_0/S_AXI} intc_ip {/ExampleRocketSystem_0_axi_periph_1} master_apm {0}}  [get_bd_intf_pins axi_uart16550_0/S_AXI]
set_property offset 0x60020000 [get_bd_addr_segs {ExampleRocketSystem_0/mmio_if/SEG_axi_uart16550_0_Reg}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/clk_wiz_0/clk_sys } Clk_slave {/clk_wiz_0/clk_sys } Clk_xbar {/clk_wiz_0/clk_sys } Master {/ExampleRocketSystem_0/mmio_if} Slave {/axi_uart16550_1/S_AXI} intc_ip {/ExampleRocketSystem_0_axi_periph_1} master_apm {0}}  [get_bd_intf_pins axi_uart16550_1/S_AXI]
set_property offset 0x60030000 [get_bd_addr_segs {ExampleRocketSystem_0/mmio_if/SEG_axi_uart16550_1_Reg}]

# improve timing on mmio path
set_property -dict [list CONFIG.S00_HAS_REGSLICE {4}] [get_bd_cells ExampleRocketSystem_0_axi_periph_1]

## connect UART interrupts
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_irq
set_property -dict [list CONFIG.NUM_PORTS {3}] [get_bd_cells xlconcat_irq]
connect_bd_net [get_bd_pins axi_uartlite_0/interrupt] [get_bd_pins xlconcat_irq/In0]
connect_bd_net [get_bd_pins axi_uartlite_1/interrupt] [get_bd_pins xlconcat_irq/In1]
connect_bd_net [get_bd_pins axi_uart16550_0/ip2intc_irpt] [get_bd_pins xlconcat_irq/In2]
connect_bd_net [get_bd_pins ExampleRocketSystem_0/interrupts] [get_bd_pins xlconcat_irq/dout]

# connect additional reset pin to the outer port
create_bd_port -dir I -type rst greset
set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports greset]
set_property -dict [list CONFIG.C_AUX_RESET_HIGH.VALUE_SRC USER] [get_bd_cells proc_sys_reset_sys]
connect_bd_net [get_bd_ports greset] [get_bd_pins proc_sys_reset_sys/ext_reset_in]
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_pins proc_sys_reset_sys/aux_reset_in]

# PL debug signals to LEDs
create_bd_port -dir O -type rst DBG_0
connect_bd_net [get_bd_ports greset] [get_bd_ports DBG_0]

create_bd_port -dir O -type rst DBG_1
connect_bd_net [get_bd_pins proc_sys_reset_sys/peripheral_reset] [get_bd_ports DBG_1]

create_bd_port -dir O DBG_2
create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 c_counter_binary_apb
set_property -dict [list CONFIG.Output_Width {25}] [get_bd_cells c_counter_binary_apb]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_cnt_apb
set_property -dict [list CONFIG.DIN_TO {24} CONFIG.DIN_FROM {24} CONFIG.DIN_WIDTH {25} CONFIG.DIN_FROM {24} CONFIG.DOUT_WIDTH {1}] [get_bd_cells xlslice_cnt_apb]
connect_bd_net [get_bd_pins clk_wiz_0/clk_apb] [get_bd_pins c_counter_binary_apb/CLK]
connect_bd_net [get_bd_pins c_counter_binary_apb/Q] [get_bd_pins xlslice_cnt_apb/Din]
connect_bd_net [get_bd_pins xlslice_cnt_apb/Dout] [get_bd_ports DBG_2]

create_bd_port -dir O DBG_3
create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 c_counter_binary_hbm
set_property -dict [list CONFIG.Output_Width {25}] [get_bd_cells c_counter_binary_hbm]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_cnt_hbm
set_property -dict [list CONFIG.DIN_TO {24} CONFIG.DIN_FROM {24} CONFIG.DIN_WIDTH {25} CONFIG.DIN_FROM {24} CONFIG.DOUT_WIDTH {1}] [get_bd_cells xlslice_cnt_hbm]
connect_bd_net [get_bd_pins clk_wiz_0/clk_hbm] [get_bd_pins c_counter_binary_hbm/CLK]
connect_bd_net [get_bd_pins c_counter_binary_hbm/Q] [get_bd_pins xlslice_cnt_hbm/Din]
connect_bd_net [get_bd_pins xlslice_cnt_hbm/Dout] [get_bd_ports DBG_3]

create_bd_port -dir O DBG_4
create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 c_counter_binary_sys
set_property -dict [list CONFIG.Output_Width {25}] [get_bd_cells c_counter_binary_sys]
create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_cnt_sys
set_property -dict [list CONFIG.DIN_TO {24} CONFIG.DIN_FROM {24} CONFIG.DIN_WIDTH {25} CONFIG.DIN_FROM {24} CONFIG.DOUT_WIDTH {1}] [get_bd_cells xlslice_cnt_sys]
connect_bd_net [get_bd_pins clk_wiz_0/clk_sys] [get_bd_pins c_counter_binary_sys/CLK]
connect_bd_net [get_bd_pins c_counter_binary_sys/Q] [get_bd_pins xlslice_cnt_sys/Din]
connect_bd_net [get_bd_pins xlslice_cnt_sys/Dout] [get_bd_ports DBG_4]

create_bd_port -dir O DBG_A
connect_bd_net [get_bd_pins proc_sys_reset_sys/mb_reset] [get_bd_ports DBG_A]
create_bd_port -dir O DBG_B
connect_bd_net [get_bd_pins clk_wiz_0/locked] [get_bd_ports DBG_B]
create_bd_port -dir O DBG_C
connect_bd_net [get_bd_pins xlconstant_vec_1_0/dout] [get_bd_ports DBG_C]
create_bd_port -dir O DBG_D
connect_bd_net [get_bd_pins xlconstant_vec_1_1/dout] [get_bd_ports DBG_D]

# finish
validate_bd_design
save_bd_design

# create HDL wrapper for top level module
make_wrapper -files [get_files rocket_board_design/rocket_board_design.srcs/sources_1/bd/main_design/main_design.bd] -top
# add resulting verilog file to design sources
add_files -norecurse rocket_board_design/rocket_board_design.srcs/sources_1/bd/main_design/hdl/main_design_wrapper.v

# Generate Output Products of block design
#generate_target all [get_files  rocket_board_design/rocket_board_design.srcs/sources_1/bd/main_design/main_design.bd]

import_files -fileset constrs_1 constraints.xdc

update_compile_order -fileset sources_1

set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE ExploreWithAggressiveHoldFix [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]

launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1

file mkdir rocket_board_design/rocket_board_design.sdk
file copy -force rocket_board_design/rocket_board_design.runs/impl_1/main_design_wrapper.sysdef rocket_board_design/rocket_board_design.sdk/main_design_wrapper.hdf

close_project
