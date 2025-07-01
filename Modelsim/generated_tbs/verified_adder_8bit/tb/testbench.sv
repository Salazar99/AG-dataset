
//including interface and testcase files
`include "verified_adder_8bitInterface.sv"
`include "test.sv"

module tbench_top;

  logic clk,rst;
  
  
  //clock generation
  always #5 clk = ~clk;
  
  //reset Generation
  initial begin
    rst = 1;
    clk = 0;
    #5 rst =0;
  end
  
  
  //creating an instance of interface to connect DUT and testcase
  verified_adder_8bit_intf intf(clk,rst);
  
  //testcase instance, interface handle is passed to test as an argument
  test t1(intf);
  
  //DUT instance, interface signals are connected to the DUT ports
  verified_adder_8bit DUT (intf.dut);
  
  //enabling the wave dump
  initial begin 
    $dumpfile("verified_adder_8bit.vcd");
    $dumpvars(0, tbench_top, intf);
  end
endmodule
