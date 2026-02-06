//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Fri Feb  6 00:18:10 2026
//Host        : Lappy running 64-bit major release  (build 9200)
//Command     : generate_target early_late_bd.bd
//Design      : early_late_bd
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "early_late_bd,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=early_late_bd,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=4,numReposBlks=4,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "early_late_bd.hwdef" *) 
module early_late_bd
   ();

  wire [0:0]util_vector_logic_0_Res;
  wire [7:0]xlconstant_0_dout;
  wire zynq_ultra_ps_e_0_pl_clk0;
  wire zynq_ultra_ps_e_0_pl_resetn0;

  early_late_bd_early_late_bitsync_0_1 early_late_bitsync_0
       (.clk(zynq_ultra_ps_e_0_pl_clk0),
        .data_in(xlconstant_0_dout),
        .rst(util_vector_logic_0_Res));
  early_late_bd_util_vector_logic_0_0 util_vector_logic_0
       (.Op1(zynq_ultra_ps_e_0_pl_resetn0),
        .Res(util_vector_logic_0_Res));
  early_late_bd_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
  early_late_bd_zynq_ultra_ps_e_0_0 zynq_ultra_ps_e_0
       (.pl_clk0(zynq_ultra_ps_e_0_pl_clk0),
        .pl_resetn0(zynq_ultra_ps_e_0_pl_resetn0));
endmodule
