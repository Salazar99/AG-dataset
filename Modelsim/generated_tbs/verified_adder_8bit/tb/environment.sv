`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"

class environment;
  
  //generator and driver instance
  generator gen;
  driver    driv;
  
  //mailbox handle's
  mailbox gen2driv;
  
  //event for synchronization between generator and test
  event gen_ended;
  
  //virtual interface
  virtual verified_adder_8bit_intf verified_adder_8bit_vif;
  
  //constructor
  function new(virtual verified_adder_8bit_intf verified_adder_8bit_vif);
    //get the interface from test
    this.verified_adder_8bit_vif = verified_adder_8bit_vif;
    
    //creating the mailbox (Same handle will be shared across generator and driver)
    gen2driv = new();
    
    //creating generator and driver
    gen  = new(gen2driv,gen_ended);
    driv = new(verified_adder_8bit_vif,gen2driv);
  endfunction
  
  task pre_test();
    driv.reset();
  endtask
  
  task test();
    fork 
        gen.main();
        driv.main();
    join_none
  endtask
  
  task post_test();
    wait(gen_ended.triggered);
    wait(gen.repeat_count == driv.no_transactions);
  endtask  
  
  //run task
  task run;
    pre_test();
    test();
    post_test();
    $finish;
  endtask
  
endclass

