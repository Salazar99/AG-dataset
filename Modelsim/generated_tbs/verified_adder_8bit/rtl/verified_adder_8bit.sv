module verified_adder_8bit (verified_adder_8bit_intf intf);
    
    wire [8:0] c;

    full_adder FA0 (.a(intf.a[0]), .b(intf.b[0]), .cin(intf.cin), .sum(intf.sum[0]), .cout(c[0]));
    full_adder FA1 (.a(intf.a[1]), .b(intf.b[1]), .cin(c[0]), .sum(intf.sum[1]), .cout(c[1]));
    full_adder FA2 (.a(intf.a[2]), .b(intf.b[2]), .cin(c[1]), .sum(intf.sum[2]), .cout(c[2]));
    full_adder FA3 (.a(intf.a[3]), .b(intf.b[3]), .cin(c[2]), .sum(intf.sum[3]), .cout(c[3]));
    full_adder FA4 (.a(intf.a[4]), .b(intf.b[4]), .cin(c[3]), .sum(intf.sum[4]), .cout(c[4]));
    full_adder FA5 (.a(intf.a[5]), .b(intf.b[5]), .cin(c[4]), .sum(intf.sum[5]), .cout(c[5]));
    full_adder FA6 (.a(intf.a[6]), .b(intf.b[6]), .cin(c[5]), .sum(intf.sum[6]), .cout(c[6]));
    full_adder FA7 (.a(intf.a[7]), .b(intf.b[7]), .cin(c[6]), .sum(intf.sum[7]), .cout(c[7]));

    assign intf.cout = c[7]; 
endmodule

module full_adder (input a, b, cin, output sum, cout);
    assign {cout, sum} = a + b + cin;
endmodule