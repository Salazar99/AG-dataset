//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 

class driver;

    //used to count the number of transactions
    int no_transactions;

    //creating virtual interface handle
    virtual @MODULE_NAME@_intf @MODULE_NAME@_vif;

    //creating mailbox handle
    mailbox gen2driv;

    //constructor
    function new(virtual @MODULE_NAME@_intf @MODULE_NAME@_vif,mailbox gen2driv);
        //getting the interface
        this.@MODULE_NAME@_vif = @MODULE_NAME@_vif;
        //getting the mailbox handles from  environment 
        this.gen2driv = gen2driv;
    endfunction

    //Reset task, Reset the Interface signals to default/initial values
    task reset;
        wait(@MODULE_NAME@_vif.rst);
        $display("--------- [DRIVER] Reset Started ---------");
        wait(!@MODULE_NAME@_vif.rst);
        $display("--------- [DRIVER] Reset Ended ---------");
    endtask

    //drives the transaction items to interface signals
    task drive;
        transaction trans;
        //get the transacation
        gen2driv.get(trans);
        //wait for the next negedge to inject the inputs into the DUT
        @(negedge @MODULE_NAME@_vif.clk);

        //inject the inputs
        @INTF_TO_TRANS@


        no_transactions++;
    endtask


    task main;
        wait(!@MODULE_NAME@_vif.rst);
        forever
            drive();
   endtask

endclass
