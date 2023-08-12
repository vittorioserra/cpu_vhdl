# --------------------------------------------------------------------------------
#  Company: FAU Erlangen - Nuernberg
#  Engineer: Vittorio Serra and Cedric Donges
# 
#  Description: Specific Post Project Creation Script for CPU_VHDL Project.
#               Configures the Synthesis and Implementation
#               Configures IP and PS
# --------------------------------------------------------------------------------

# disable incremental synthesis and implementation (because this cause problems with the loading of new ram contents)
#set_property -name "AUTO_INCREMENTAL_CHECKPOINT" -value "0" -objects [get_runs synth_1]
#set_property -name "AUTO_INCREMENTAL_CHECKPOINT" -value "0" -objects [get_runs impl_1]

# enable performance optimization
set_property -name "strategy"                                        -value "Vivado Synthesis Defaults"           -objects [get_runs synth_1]
set_property -name "strategy"                                        -value "Performance_ExplorePostRoutePhysOpt" -objects [get_runs impl_1]
set_property -name "STEPS.PLACE_DESIGN.ARGS.DIRECTIVE"               -value "ExtraTimingOpt"                      -objects [get_runs impl_1]
set_property -name "STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE" -value "AddRetime"                           -objects [get_runs impl_1]