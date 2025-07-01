interface verified_adder_8bit_intf(input clk,rst);
  
  //declaring the signals
  //logic start;
  //logic [3:0] in;
  //logic dec;
  //logic stop;
    logic [7:0] a;
  logic [7:0] b;
  logic  cin;
  logic [7:0] sum;
  logic  cout;

  

  //modport dut (input clk, rst, start, in, dec, output stop);
  modport dut (input a,b,cin,clk, rst, output sum,cout);

endinterface
