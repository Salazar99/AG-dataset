//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 

class driver;

    //used to count the number of transactions
    int no_transactions;

    //creating virtual interface handle
    virtual verified_accu_intf verified_accu_vif;

    //creating mailbox handle
    mailbox gen2driv;

    //constructor
    function new(virtual verified_accu_intf verified_accu_vif,mailbox gen2driv);
        //getting the interface
        this.verified_accu_vif = verified_accu_vif;
        //getting the mailbox handles from  environment 
        this.gen2driv = gen2driv;
    endfunction

    //Reset task, Reset the Interface signals to default/initial values
    task reset;
        wait(verified_accu_vif.rst);
        $display("--------- [DRIVER] Reset Started ---------");
        wait(!verified_accu_vif.rst);
        $display("--------- [DRIVER] Reset Ended ---------");
    endtask

    //drives the transaction items to interface signals
    task drive;
        transaction trans;
        //get the transacation
        gen2driv.get(trans);
        //wait for the next negedge to inject the inputs into the DUT
        @(negedge verified_accu_vif.clk);

        //inject the inputs
        verified_accu_vif.data_in=trans.data_in;
verified_accu_vif.valid_in=trans.valid_in;



        no_transactions++;
    endtask


    task main;
        wait(!verified_accu_vif.rst);
        forever
            drive();
   endtask

endclass
