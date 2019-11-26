# create project
create_project rocket_board_design rocket_board_design -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.4 [current_project]
set_property  ip_repo_paths  {rocket_ip_core /home/inf3/ar42enus/Documents/axi_full_address_converter} [current_project]
update_ip_catalog

# create block design
create_bd_design "main_design"

# Rocket CPU
create_bd_cell -type ip -vlnv user.org:user:ExampleRocketSystem:1.0 ExampleRocketSystem_0

# GPIO port
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property -dict [list CONFIG.C_GPIO_WIDTH {8} CONFIG.C_GPIO2_WIDTH {8} CONFIG.C_IS_DUAL {1} CONFIG.C_ALL_INPUTS_2 {1} CONFIG.C_ALL_OUTPUTS {1}] [get_bd_cells axi_gpio_0]

# UARTlite ports 0, 1
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
set_property -dict [list CONFIG.C_BAUDRATE {115200}] [get_bd_cells axi_uartlite_0]
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_1
set_property -dict [list CONFIG.C_BAUDRATE {115200}] [get_bd_cells axi_uartlite_1]

# UART 16500 port
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_1

# ZYNQ 7
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
set_property -dict [list CONFIG.preset {ZedBoard}] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {0} CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {0} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {0} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} CONFIG.PCW_USE_M_AXI_GP0 {0}] [get_bd_cells processing_system7_0]

# Philipp's Address Converter
create_bd_cell -type ip -vlnv user.org:user:axi_full_address_converter:1.0 axi_full_address_con_0
set_property -dict [list CONFIG.OFFSET_VALUE {0x000000007FF00000} CONFIG.SUBTRACT {true} CONFIG.C_S_AXI_ID_WIDTH {6} CONFIG.C_S_AXI_ADDR_WIDTH {32} CONFIG.C_S_AXI_DATA_WIDTH {64} CONFIG.C_M_AXI_ID_WIDTH {6} CONFIG.C_M_AXI_ADDR_WIDTH {32} CONFIG.C_M_AXI_DATA_WIDTH {64}] [get_bd_cells axi_full_address_con_0]

# connect ZYNQ DDR and fixed IO
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# make UART0 external
create_bd_port -dir O uart_rtl_0_txd
connect_bd_net [get_bd_ports uart_rtl_0_txd] [get_bd_pins axi_uartlite_0/tx]
create_bd_port -dir I uart_rtl_0_rxd
connect_bd_net [get_bd_ports uart_rtl_0_rxd] [get_bd_pins axi_uartlite_0/rx]

# make UART1 external
create_bd_port -dir O uart_rtl_1_txd
connect_bd_net [get_bd_ports uart_rtl_1_txd] [get_bd_pins axi_uartlite_1/tx]
create_bd_port -dir I uart_rtl_1_rxd
connect_bd_net [get_bd_ports uart_rtl_1_rxd] [get_bd_pins axi_uartlite_1/rx]

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

# make GPIO external with ZedBoard presets (LEDs on GPIO1, SWs und GPIO2)
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {sws_8bits ( DIP switches ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_gpio_0/GPIO2]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {leds_8bits ( LED ) } Manual_Source {Auto}}  [get_bd_intf_pins axi_gpio_0/GPIO]

# connect Rocket Core to GPIO
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0} Clk_slave {/processing_system7_0/FCLK_CLK0} Clk_xbar {/processing_system7_0/FCLK_CLK0} Master {/ExampleRocketSystem_0/mmio_if} Slave {/axi_gpio_0/S_AXI} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_gpio_0/S_AXI]
set_property offset 0x60100000 [get_bd_addr_segs {ExampleRocketSystem_0/mmio_if/SEG_axi_gpio_0_Reg}]

# connect Rocket Core to UARTs
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0} Clk_slave {/processing_system7_0/FCLK_CLK0} Clk_xbar {/processing_system7_0/FCLK_CLK0} Master {/ExampleRocketSystem_0/mmio_if} Slave {/axi_uartlite_0/S_AXI} intc_ip {/ExampleRocketSystem_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_uartlite_0/S_AXI]
set_property offset 0x60000000 [get_bd_addr_segs {ExampleRocketSystem_0/mmio_if/SEG_axi_uartlite_0_Reg}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0} Clk_slave {/processing_system7_0/FCLK_CLK0} Clk_xbar {/processing_system7_0/FCLK_CLK0} Master {/ExampleRocketSystem_0/mmio_if} Slave {/axi_uartlite_1/S_AXI} intc_ip {/ExampleRocketSystem_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_uartlite_1/S_AXI]
set_property offset 0x60010000 [get_bd_addr_segs {ExampleRocketSystem_0/mmio_if/SEG_axi_uartlite_1_Reg}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0} Clk_slave {/processing_system7_0/FCLK_CLK0} Clk_xbar {/processing_system7_0/FCLK_CLK0} Master {/ExampleRocketSystem_0/mmio_if} Slave {/axi_uart16550_0/S_AXI} intc_ip {/ExampleRocketSystem_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_uart16550_0/S_AXI]
set_property offset 0x60020000 [get_bd_addr_segs {ExampleRocketSystem_0/mmio_if/SEG_axi_uart16550_0_Reg}]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0} Clk_slave {/processing_system7_0/FCLK_CLK0} Clk_xbar {/processing_system7_0/FCLK_CLK0} Master {/ExampleRocketSystem_0/mmio_if} Slave {/axi_uart16550_1/S_AXI} intc_ip {/ExampleRocketSystem_0_axi_periph} master_apm {0}}  [get_bd_intf_pins axi_uart16550_1/S_AXI]
set_property offset 0x60030000 [get_bd_addr_segs {ExampleRocketSystem_0/mmio_if/SEG_axi_uart16550_1_Reg}]

## connect UART interrupts
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_irq
set_property -dict [list CONFIG.NUM_PORTS {3}] [get_bd_cells xlconcat_irq]
connect_bd_net [get_bd_pins axi_uartlite_0/interrupt] [get_bd_pins xlconcat_irq/In0]
connect_bd_net [get_bd_pins axi_uartlite_1/interrupt] [get_bd_pins xlconcat_irq/In1]
connect_bd_net [get_bd_pins axi_uart16550_0/ip2intc_irpt] [get_bd_pins xlconcat_irq/In2]
connect_bd_net [get_bd_pins ExampleRocketSystem_0/interrupts] [get_bd_pins xlconcat_irq/dout]

# connect Rocket Core over Address Converter to HP0
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0} Clk_slave {/processing_system7_0/FCLK_CLK0} Clk_xbar {/processing_system7_0/FCLK_CLK0} Master {/ExampleRocketSystem_0/mem_if} Slave {/axi_full_address_con_0/s_axi} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_full_address_con_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0} Clk_slave {/processing_system7_0/FCLK_CLK0} Clk_xbar {/processing_system7_0/FCLK_CLK0} Master {/axi_full_address_con_0/m_axi} Slave {/processing_system7_0/S_AXI_HP0} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
set_property range 512M [get_bd_addr_segs {ExampleRocketSystem_0/mem_if/SEG_axi_full_address_con_0_reg0}]
set_property offset 0x80000000 [get_bd_addr_segs {ExampleRocketSystem_0/mem_if/SEG_axi_full_address_con_0_reg0}]

# connect additional reset pin to the outer port
create_bd_port -dir I -type rst greset
set_property CONFIG.POLARITY ACTIVE_HIGH [get_bd_ports greset]
set_property -dict [list CONFIG.C_AUX_RESET_HIGH.VALUE_SRC USER] [get_bd_cells rst_ps7_0_50M]
connect_bd_net [get_bd_ports greset] [get_bd_pins rst_ps7_0_50M/aux_reset_in]

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
