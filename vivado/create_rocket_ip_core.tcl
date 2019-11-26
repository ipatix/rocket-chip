#create project
create_project rocket_ip_core rocket_ip_core
import_files -flat -norecurse ../vsim/generated-src/freechips.rocketchip.system.ZedboardConfig.v
import_files -flat -norecurse ../vsim/generated-src/freechips.rocketchip.system.ZedboardConfig/plusarg_reader.v
import_files -flat -norecurse ../vsim/generated-src/freechips.rocketchip.system.ZedboardConfig.behav_srams.v
update_compile_order -fileset sources_1
set_property top ExampleRocketSystem [current_fileset]

#package ip
ipx::package_project -root_dir rocket_ip_core/rocket_ip_core.srcs/sources_1/imports -vendor user.org -library user -taxonomy /UserIP
source create_rocket_ip_core_props.tcl
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project
