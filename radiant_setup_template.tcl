set current_path "O:/src/Propel/iCE40UP/ice40_nano"

cd $current_path

set radiant_project "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano.rdf"

set DEVICE "iCE40UP5K-SG48I"

set DESIGN "ice40_nano"

array set VFILE_LIST ""
set VFILE_LIST(1) "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano/lib/personal/ip/ahb_spsram/1.1.0/ahb_spsram.ipx"
set VFILE_LIST(2) "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano/ice40_nano_Top.v"
set VFILE_LIST(3) "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano/lib/latticesemi.com/ip/cpu0/1.1.0/cpu0.ipx"
set VFILE_LIST(4) "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano/ice40_nano.v"
set VFILE_LIST(5) "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano/lib/latticesemi.com/module/ahbl0/1.4.0/ahbl0.ipx"
set VFILE_LIST(6) "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano/lib/personal/ip/timer/1.2.1/timer.ipx"
set VFILE_LIST(7) "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano/lib/personal/ip/ice40_ip_interface/1.0.1/ice40_ip_interface.ipx"
set VFILE_LIST(8) "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano/lib/personal/ip/gpio0/1.1.1/gpio0.ipx"
set VFILE_LIST(9) "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano/lib/personal/ip/ahbl_uart/1.1.3/ahbl_uart.ipx"

set index [array names VFILE_LIST]
if { [file exists $radiant_project] == 1} {
    prj_open $radiant_project
    prj_set_device -part $DEVICE -performance High-Performance_1.2V
} else {
    prj_create -name "ice40_nano" -impl "impl_1" -dev $DEVICE -performance High-Performance_1.2V -synthesis "synplify"
    prj_save
}

prj_remove_source "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano/lib/personal/ip/systime/1.2.1/systime.ipx"

foreach i $index {
    if { [catch {prj_add_source $VFILE_LIST($i)} fid] } {
        puts "file already exists in project."
    }
}

prj_add_source "O:/src/Propel/iCE40UP/ice40_nano/ice40_nano.pdc"

prj_save

