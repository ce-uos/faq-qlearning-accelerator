set base_dir [file dirname [info script]]
set configdir "${base_dir}/../src/hdl/src/config_constants.vhd"
puts $configdir

proc writeconfig {path sw aw pd} {
    set baseconfig "library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package config_constants is
    constant config_state_width : integer := %d;
    constant config_action_width : integer := %d;
    constant config_pipeline_stages : integer := %d;
    constant config_reward_width : integer := 16;
end config_constants;"

    set fp [open $path "w"]
    puts $fp [format $baseconfig $sw $aw $pd]
    close $fp
}

proc runeval {evaldir base_dir} {
    open_project ${base_dir}/../project/qlearn_architecture/qlearn_architecture.xpr
    update_compile_order -fileset sources_1
    update_module_reference design_1_qlearning_axi_0_1
    update_compile_order -fileset sources_1
    reset_run synth_1
    reset_run impl_1
    launch_runs impl_1 -jobs 6
    wait_on_run impl_1
    open_run impl_1

    report_power -hierarchical_depth 5 -file ${evaldir}/power_report.xml -format xml
    report_power -hierarchical_depth 5 -file ${evaldir}/power_report.txt -format text
    report_utilization -hierarchical -hierarchical_depth 4 -file ${evaldir}/utilization.xml -format xml
    report_utilization -hierarchical -hierarchical_depth 4 -file ${evaldir}/utilization.txt 
    report_timing -file ${evaldir}/timing.txt
    close_project
}

set sws [list 4 6 8 10 14 18]
set aws [list 2 3]

for {set i 0} {$i < 1} {incr i} {
    set aw [lindex $aws $i]
    for {set j 0} {$j < 6} {incr j} {
        set sw [lindex $sws $j]
        set evaldir "reports_aw${aw}_sw${sw}"
        file mkdir $evaldir
        writeconfig $configdir $sw $aw 3
        runeval $evaldir $base_dir
    }
}

exit
