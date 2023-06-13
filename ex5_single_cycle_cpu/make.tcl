# --------------------------------------------------------------------------------
#  Company: FAU Erlangen - Nuernberg
#  Engineer: Vittorio Serra and Cedric Donges
# 
#  Description: Universal Project Creation Script for CPU_VHDL Project.
#               Copy this file into the project directory and execute it from vivado.
#               CAUTION: This script will delete an existing vivado project folder.
#               Imports only .xdc, .wcfg .vhd files from local and global src folder.
#               Fileformat: *_tb.vhd is Top of Simulation
#               Fileformat: *_top.vhd is Top of Synthesis
#               Fileformat: *_old.* will not be added to the project
# --------------------------------------------------------------------------------

# Set User Output Strings
set textFileSourceSimTop   "Add source file as sim-top:  "
set textFileSourceSynthTop "Add source file as synth-top:"
set textFileSource         "Add source file:             "
set textFileSourceConstr   "Add constraints file:        "
set textFileSourceWaveform "Add waveform config file:    "

# Get Paths and Names
set scriptPath [file normalize [file dirname [info script]]]
set projectName [file tail $scriptPath]
set projectPath [file normalize [file join $scriptPath ./vivado]]
set globalSrcPath [file normalize [file join $scriptPath ../global_src]]
set localSrcPath [file normalize [file join $scriptPath ./src]]

# Remove existing Vivado Project
file delete -force -- $projectPath

# Create Vivado Project
file mkdir $projectPath
create_project ${projectName} ${projectPath} -part xc7z020clg484-1

# Set project properties
set obj [current_project]
set_property -name "board_part" -value "avnet.com:zedboard:part0:1.4" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$projectPath/${projectName}.cache/ip" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "platform.board_id" -value "zedboard" -objects $obj
set_property -name "revised_directory_structure" -value "1" -objects $obj
set_property -name "sim.central_dir" -value "$projectPath/${projectName}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "VHDL" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj

# Create filesets
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}
set sourcesSet [get_filesets sources_1]

if {[string equal [get_filesets -quiet constrs_1] ""]} {
    create_fileset -constrset constrs_1
}
set constrsSet [get_filesets constrs_1]

if {[string equal [get_filesets -quiet sim_1] ""]} {
    create_fileset -simset sim_1
}
set simSet [get_filesets sim_1]
set_property -name "top_lib" -value "xil_defaultlib" -objects $simSet
set_property -name "top_auto_set" -value "0" -objects $simSet

# Search for Remote Files
set srcFiles [list \
    {*}[glob -nocomplain -- $globalSrcPath/*.*] \
    {*}[glob -nocomplain -- $localSrcPath/*.*]]

# Link Remote Files to filesets
foreach file $srcFiles {
    set fileExt [file extension $file]
    set fileTitle [file rootname [file tail $file]]
    if {[string match "*_old" $fileTitle]} {
        # skip this file
    } elseif {[string equal $fileExt ".vhd"]} {
        if {[string match "*_tb" $fileTitle]} {
            # Top Level Source of Simulation
            puts [concat $textFileSourceSimTop $file]
            add_files -norecurse -fileset $simSet $file
            set_property -name "file_type" -value "VHDL" -objects \
                [get_files -of_objects $simSet [list "*$file"]]
            set_property -name "top" -value $fileTitle -objects $simSet
        } elseif {[string match "*_top" $fileTitle]} {
            # Top Level Source of Synthesis
            puts [concat $textFileSourceSynthTop $file]
            add_files -norecurse -fileset $sourcesSet $file
            set_property -name "file_type" -value "VHDL" -objects \
                [get_files -of_objects $sourcesSet [list "*$file"]]
            set_property -name "top" -value $fileTitle -objects $sourcesSet
        } else {
            # Simple Source
            puts [concat $textFileSource $file]
            add_files -norecurse -fileset $sourcesSet $file
            set_property -name "file_type" -value "VHDL" -objects \
                [get_files -of_objects $sourcesSet [list "*$file"]]
        }
    } elseif {[string equal $fileExt ".xdc"]} {
        # Constraints file
        puts [concat $textFileSourceConstr $file]
        add_files -norecurse -fileset $constrsSet $file
        set_property -name "file_type" -value "XDC" -objects \
            [get_files -of_objects $constrsSet [list "*$file"]]
    } elseif {[string equal $fileExt ".wcfg"]} {
        # Waveform config
        puts [concat $textFileSourceWaveform $file]
        add_files -norecurse -fileset $simSet $file
    }
}

# Set generic for project path (to read files relative to the project)
set_property -name "generic" -value "project_path=$projectPath/" -objects $sourcesSet
set_property -name "vhdl_generic" -value "project_path=$projectPath/" -objects $sourcesSet
