interface @MODULE_NAME@_intf(input clk,rst);
  
  //declaring the signals
  //logic start;
  //logic [3:0] in;
  //logic dec;
  //logic stop;
  @LOGIC_SIGNALS_DECLARATION@
  

  //modport dut (input clk, rst, start, in, dec, output stop);
  modport dut (input @INPUT_SIGNAL_DECLARATIONS@, output @OUTPUT_SIGNAL_DECLARATIONS@);

endinterface
