set base_dir [file dirname [info script]]
set configdir "${base_dir}/../src/hdl/src/config_constants.vhd"
puts $configdir

proc writeconfig {path sw aw p r s s34 m} {
    set baseconfig "
-- This file contains constants to configure the design.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

package config_constants is
    -- Choose between random and e-greedy policy:
    -- 0 = e-greedy
    -- 1 = random
    constant config_policy_random : integer := %d;
    
    -- Choose the Q-Table memory configuration
    -- 0 = single memory
    -- 1 = one memory per possible action
    constant config_action_rams : integer := %d;
    
    -- Choose the algorithm
    -- 0 = Q-Learning
    -- 1 = SARSA
    constant config_sarsa : integer := %d;
    
    -- Configure the state width
    -- this will result in 2^(state_width) possible states (not all of them need to be used)
    constant config_state_width : integer := %d;
    
    -- Configure the action width
    -- this will result in 2^(action_width) possible actions
    constant config_action_width : integer := %d;
    
    -- Configure the reward width
    constant config_reward_width : integer := 16;
    
    -- Configure the number of pipeline stages
    -- 0 = 3 stages
    -- 1 = 4 stages
    constant config_4stage : integer := %d;
    
    
    constant config_mult : integer := %d;
end config_constants;
"

    set fp [open $path "w"]
    puts $fp [format $baseconfig $p $r $s $sw $aw $s34 $m]
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

set aws [list 2 3]
set sws [list 4 6 8 10 12 14 16 18]
#
#for {set p 0} {$p < 2} {incr p} {
#    for {set r 0} {$r < 2} {incr r} {
#        for {set s 0} {$s < 2} {incr s} {
#            for {set i 0} {$i < 2} {incr i} {
#                set aw [lindex $aws $i]
#                for {set j 0} {$j < 8} {incr j} {
#                    set sw [lindex $sws $j]
#                    if {$s == 0 && $r == 1 && $p == 0} {
#                        continue
#                    }
#                    if {$s == 0 && $r == 0 && $p == 0} {
#                        continue
#                    }
#                    if {$s == 1} {
#                        set qors "sarsa"
#                    } else {
#                        set qors "ql"
#                    }
#                    if {$r == 1} {
#                        set arams "actionrams"
#                    } else {
#                        set arams "singleram"
#                    }
#                    if {$p == 1} {
#                        set policy "random"
#                    } else {
#                        set policy "egreedy"
#                    }
#                    set evaldir "reports_${qors}_${arams}_${policy}_aw${aw}_sw${sw}"
#                    puts "$s $qors $r $arams  $p $policy"
#                    puts $evaldir
#                    file mkdir $evaldir
#                    writeconfig $configdir $sw $aw $p $r $s
#                    runeval $evaldir $base_dir
#                }
#            }
#        }
#    }
#}

#set s 0
#set r 0
#set p 1
#for {set i 0} {$i < 2} {incr i} {
#    set aw [lindex $aws $i]
#    for {set j 0} {$j < 8} {incr j} {
#        set sw [lindex $sws $j]
#        if {$s == 1} {
#            set qors "sarsa"
#        } else {
#            set qors "ql"
#        }
#        if {$r == 1} {
#            set arams "actionrams"
#        } else {
#            set arams "singleram"
#        }
#        if {$p == 1} {
#            set policy "random"
#        } else {
#            set policy "egreedy"
#        }
#        set evaldir "reports_${qors}_${arams}_${policy}_aw${aw}_sw${sw}"
#        file mkdir $evaldir
#        writeconfig $configdir $sw $aw $p $r $s
#        runeval $evaldir $base_dir
#    }
#}

#set s 0
#set r 0
#set p 1
#set aw 3
#for {set j 0} {$j < 4} {incr j} {
#    set sw [lindex $sws $j]
#    if {$s == 1} {
#        set qors "sarsa"
#    } else {
#        set qors "ql"
#    }
#    if {$r == 1} {
#        set arams "actionrams"
#    } else {
#        set arams "singleram"
#    }
#    if {$p == 1} {
#        set policy "random"
#    } else {
#        set policy "egreedy"
#    }
#    set evaldir "reports_${qors}_${arams}_${policy}_aw${aw}_sw${sw}"
#    file mkdir $evaldir
#    writeconfig $configdir $sw $aw $p $r $s
#    runeval $evaldir $base_dir
#}

#set s 0
#set r 0
#set p 1
#set aw 3
#set sw 18
#set s34 0
#set m 0
#if {$s == 1} {
#    set qors "sarsa"
#} else {
#    set qors "ql"
#}
#if {$r == 1} {
#    set arams "actionrams"
#} else {
#    set arams "singleram"
#}
#if {$p == 1} {
#    set policy "random"
#} else {
#    set policy "egreedy"
#}
#if {$s34 == 0} {
#    set stages "3stages"
#} else {
#    set stages "4stages"
#}
#if {$m == 0} {
#    set mults "shift"
#} else {
#    set mults "dsps"
#}
#set evaldir "reports_${qors}_${arams}_${policy}_${stages}_${mults}_aw${aw}_sw${sw}"
#file mkdir $evaldir
#writeconfig $configdir $sw $aw $p $r $s
#runeval $evaldir $base_dir

set s 0
set p 1
set m 0
set r 1
for {set s34 0} {$s34 < 2} {incr s34} {
    for {set i 0} {$i < 2} {incr i} {
        set aw [lindex $aws $i]
        for {set j 0} {$j < 8} {incr j} {
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
            if {$s34 == 0} {
                set stages "3stages"
            } else {
                set stages "4stages"
            }
            if {$m == 0} {
                set mults "shift"
            } else {
                set mults "dsps"
            }
            set evaldir "reports_${qors}_${arams}_${policy}_${stages}_${mults}_aw${aw}_sw${sw}"
            file mkdir $evaldir
            writeconfig $configdir $sw $aw $p $r $s $s34 $m
            runeval $evaldir $base_dir
        }
    }
}

exit
