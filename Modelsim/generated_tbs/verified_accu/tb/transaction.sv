class transaction;
  //declaring the transaction items
  //rand logic start,dec;
  //rand logic [3:0] in;
    rand logic [7:0] data_in;
  rand logic  valid_in;

  
  //post-randomize function, displaying randomized values of items 
  function void post_randomize();
    $display("--------- [Trans] post_randomize ------");
    //$display("\t start = %0h",start);
    //$display("\t in = %0h",in);
    //$display("\t dec = %0h",dec);
    $display("-----------------------------------------");
  endfunction
  
  //deep copy method
  function transaction do_copy();
    transaction trans;
    trans = new();
    //trans.start  = this.start;
    //trans.in  = this.in;
    //trans.dec  = this.dec;
      trans.data_in = this.data_in;
  trans.valid_in = this.valid_in;

    return trans;
  endfunction
endclass
