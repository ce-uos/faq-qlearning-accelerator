set base_dir [file dirname [info script]]
set configdir "${base_dir}/../src/hdl/src/config_constants.vhd"
puts $configdir

proc writeconfig {path sw aw p r s} {
    set baseconfig "library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package config_constants is
    constant config_policy_random : integer := %d;
    constant config_action_rams : integer := %d;
    constant config_sarsa : integer := %d;
    constant config_state_width : integer := %d;
    constant config_action_width : integer := %d;
    constant config_reward_width : integer := 16;
end config_constants;"

    set fp [open $path "w"]
    puts $fp [format $baseconfig $p $r $s $sw $aw]
    close $fp
}

proc runeval {evaldir base_dir} {
    open_project ${base_dir}/../project/qlearn_architecture/qlearn_architecture.xpr
    update_compile_order -fileset sources_1
    reset_run synth_1
    reset_run impl_1
    launch_runs impl_1 -jobs 6
    wait_on_run impl_1
    open_run impl_1

    report_power -hierarchical_depth 3 -file ${evaldir}/power_report.xml -format xml
    report_power -hierarchical_depth 3 -file ${evaldir}/power_report.txt -format text
    report_utilization -hierarchical -hierarchical_depth 3 -file ${evaldir}/utilization.xml -format xml
    report_utilization -hierarchical -hierarchical_depth 3 -file ${evaldir}/utilization.txt 
    report_timing -file ${evaldir}/timing.txt
    close_project
}

set sws [list 16]
set aws [list 2 3]

for {set p 0} {$p < 2} {incr p} {
    for {set r 0} {$r < 2} {incr r} {
        for {set s 0} {$s < 2} {incr s} {
            for {set i 0} {$i < 2} {incr i} {
                set aw [lindex $aws $i]
                for {set j 0} {$j < 1} {incr j} {
                    set sw [lindex $sws $j]
                    if {$s == 1} {
                        set qors "sarsa"
                    } else {
                        set qors "ql"
                    }
                    if {$r == 1} {
                        set arams "actionrams"
                    } else {
                        set arams "singleram"
                    }
                    if {$p == 1} {
                        set policy "random"
                    } else {
                        set policy "egreedy"
                    }
                    set evaldir "reports_${qors}_${arams}_${policy}_aw${aw}_sw${sw}"
                    file mkdir $evaldir
                    writeconfig $configdir $sw $aw $p $r $s
                    runeval $evaldir $base_dir
                }
            }
        }
    }
}

exit
