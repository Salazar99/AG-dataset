class transaction;
  //declaring the transaction items
  //rand logic start,dec;
  //rand logic [3:0] in;
  @RAND_SIGNAL_DECLARATION@
  
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
    @TRANSACTION_SIGNALS_ASS@
    return trans;
  endfunction
endclass
