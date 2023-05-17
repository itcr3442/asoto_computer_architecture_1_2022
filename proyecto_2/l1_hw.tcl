# TCL File Generated by Component Editor 20.1
# Tue May 16 07:39:30 GMT 2023
# DO NOT MODIFY


# 
# l1 "L1 cache" v1.0
#  2023.05.16.07:39:30
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module l1
# 
set_module_property DESCRIPTION ""
set_module_property NAME l1
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "L1 cache"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL cache_l1
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file l1.sv SYSTEM_VERILOG PATH rtl/cache/l1.sv TOP_LEVEL_FILE
add_fileset_file 4way.sv SYSTEM_VERILOG PATH rtl/cache/4way.sv
add_fileset_file set.sv SYSTEM_VERILOG PATH rtl/cache/set.sv
add_fileset_file sram.sv SYSTEM_VERILOG PATH rtl/cache/sram.sv


# 
# parameters
# 
add_parameter cache_entry INTEGER 14
set_parameter_property cache_entry DEFAULT_VALUE 14
set_parameter_property cache_entry DISPLAY_NAME cache_entry
set_parameter_property cache_entry TYPE INTEGER
set_parameter_property cache_entry UNITS None
set_parameter_property cache_entry HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink rst_n reset_n Input 1


# 
# connection point master
# 
add_interface master avalon start
set_interface_property master addressUnits SYMBOLS
set_interface_property master associatedClock clock
set_interface_property master associatedReset reset_sink
set_interface_property master bitsPerSymbol 8
set_interface_property master burstOnBurstBoundariesOnly false
set_interface_property master burstcountUnits WORDS
set_interface_property master doStreamReads false
set_interface_property master doStreamWrites false
set_interface_property master holdTime 0
set_interface_property master linewrapBursts false
set_interface_property master maximumPendingReadTransactions 0
set_interface_property master maximumPendingWriteTransactions 0
set_interface_property master readLatency 0
set_interface_property master readWaitTime 1
set_interface_property master setupTime 0
set_interface_property master timingUnits Cycles
set_interface_property master writeWaitTime 0
set_interface_property master ENABLED true
set_interface_property master EXPORT_OF ""
set_interface_property master PORT_NAME_MAP ""
set_interface_property master CMSIS_SVD_VARIABLES ""
set_interface_property master SVD_ADDRESS_GROUP ""

add_interface_port master m_addr address Output 32
add_interface_port master m_writedata writedata Output 128
add_interface_port master m_read read Output 1
add_interface_port master m_write write Output 1
add_interface_port master m_readdata readdata Input 128
add_interface_port master m_readdata_valid readdatavalid Input 1
add_interface_port master m_waitrequest waitrequest Input 1


# 
# connection point slave
# 
add_interface slave avalon end
set_interface_property slave addressUnits WORDS
set_interface_property slave associatedClock clock
set_interface_property slave associatedReset reset_sink
set_interface_property slave bitsPerSymbol 8
set_interface_property slave burstOnBurstBoundariesOnly false
set_interface_property slave burstcountUnits WORDS
set_interface_property slave explicitAddressSpan 0
set_interface_property slave holdTime 0
set_interface_property slave linewrapBursts false
set_interface_property slave maximumPendingReadTransactions 1
set_interface_property slave maximumPendingWriteTransactions 0
set_interface_property slave readLatency 0
set_interface_property slave readWaitTime 1
set_interface_property slave setupTime 0
set_interface_property slave timingUnits Cycles
set_interface_property slave writeWaitTime 0
set_interface_property slave ENABLED true
set_interface_property slave EXPORT_OF ""
set_interface_property slave PORT_NAME_MAP ""
set_interface_property slave CMSIS_SVD_VARIABLES ""
set_interface_property slave SVD_ADDRESS_GROUP ""

add_interface_port slave p_writedata writedata Input 32
add_interface_port slave p_read read Input 1
add_interface_port slave p_write write Input 1
add_interface_port slave p_readdata readdata Output 32
add_interface_port slave p_readdata_valid readdatavalid Output 1
add_interface_port slave p_waitrequest waitrequest Output 1
add_interface_port slave p_addr address Input 30
set_interface_assignment slave embeddedsw.configuration.isFlash 0
set_interface_assignment slave embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment slave embeddedsw.configuration.isPrintableDevice 0
