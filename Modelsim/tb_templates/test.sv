`include "environment.sv"
program test(@MODULE_NAME@_intf intf);

    class my_trans extends transaction;
        function void pre_randomize();
            //in.rand_mode(1);
            //start.rand_mode(1);
            //dec.rand_mode(1);
            @RANDOMIZE_SIGNALS@

        endfunction
    endclass

    //declaring environment instance
    environment env;
    my_trans my_tr;

    initial begin
        //creating environment
        env = new(intf);
        my_tr = new();

        //setting the repeat count of the generator
        env.gen.repeat_count = 1000;

        env.gen.trans = my_tr;

        //calling run of env, it issues calls to the generator and driver
        env.run();
    end
endprogram
