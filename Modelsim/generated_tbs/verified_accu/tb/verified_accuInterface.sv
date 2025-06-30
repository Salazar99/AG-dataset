interface verified_accu_intf(input clk,rst);
  
  //declaring the signals
  //logic start;
  //logic [3:0] in;
  //logic dec;
  //logic stop;
    logic [7:0] data_in;
  logic  valid_in;
  logic  valid_out;
  logic [9:0] data_out;

  

  //modport dut (input clk, rst, start, in, dec, output stop);
  modport dut (input data_in,valid_in,clk, rst, output valid_out,data_out);

endinterface
