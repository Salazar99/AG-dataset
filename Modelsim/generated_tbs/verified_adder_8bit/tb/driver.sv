//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 

class driver;

    //used to count the number of transactions
    int no_transactions;

    //creating virtual interface handle
    virtual verified_adder_8bit_intf verified_adder_8bit_vif;

    //creating mailbox handle
    mailbox gen2driv;

    //constructor
    function new(virtual verified_adder_8bit_intf verified_adder_8bit_vif,mailbox gen2driv);
        //getting the interface
        this.verified_adder_8bit_vif = verified_adder_8bit_vif;
        //getting the mailbox handles from  environment 
        this.gen2driv = gen2driv;
    endfunction

    //Reset task, Reset the Interface signals to default/initial values
    task reset;
        wait(verified_adder_8bit_vif.rst);
        $display("--------- [DRIVER] Reset Started ---------");
        wait(!verified_adder_8bit_vif.rst);
        $display("--------- [DRIVER] Reset Ended ---------");
    endtask

    //drives the transaction items to interface signals
    task drive;
        transaction trans;
        //get the transacation
        gen2driv.get(trans);
        //wait for the next negedge to inject the inputs into the DUT
        @(negedge verified_adder_8bit_vif.clk);

        //inject the inputs
        verified_adder_8bit_vif.a=trans.a;
verified_adder_8bit_vif.b=trans.b;
verified_adder_8bit_vif.cin=trans.cin;



        no_transactions++;
    endtask


    task main;
        wait(!verified_adder_8bit_vif.rst);
        forever
            drive();
   endtask

endclass
