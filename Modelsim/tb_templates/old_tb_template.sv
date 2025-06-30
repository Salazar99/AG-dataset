// templates/tb_template.sv
`timescale 1ns / 1ps

module tb_@MODULE_NAME@;

  // Clock and Reset - essential for most RTL
  logic clk;
  logic rst_n;

  // Input Signals as SystemVerilog 'rand' variables
  // These will be randomized by calling .randomize()
@INPUT_SIGNAL_DECLARATIONS@

  // Output Signals - 'logic' as they are driven by the DUT
@OUTPUT_SIGNAL_DECLARATIONS@

  // Constraints (can be dynamically added by script or manually for specific designs)
@GENERIC_CONSTRAINTS@

  // DUT Instance
  @MODULE_NAME@ u_dut (
    .clk(clk),
    .rst_n(rst_n),
@DUT_PORT_MAPPINGS@
  );

  // Clock Generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end

  // Reset Generation
  initial begin
    rst_n = 0;
    #100ns; // Hold reset for 100ns
    rst_n = 1; // De-assert reset
  end

  // Stimulus Generation (Constrained Random)
  initial begin
    // Wait for reset to de-assert
    @(negedge rst_n);

    $display("INFO: Starting constrained random transactions for @MODULE_NAME@.");

    repeat (100) begin // Generate 100 random transactions
      @(posedge clk); // Drive inputs on positive clock edge

      // Randomize all input variables declared as 'rand'
      if (!this.randomize()) begin
        $fatal(1, "ERROR: Randomization failed for @MODULE_NAME@!");
      end

      // Optional: Add a small delay for combinational paths to settle before outputs are stable
      #1ns;

      // Basic monitoring for manual inspection
      $display("Time: %0t, Inputs:", $time);
@INPUT_DISPLAY_STATEMENTS@
      $display("Outputs:");
@OUTPUT_DISPLAY_STATEMENTS@
      $display("---");
    end

    $display("INFO: Simulation finished for @MODULE_NAME@. Generated 100 transactions.");
    $finish;
  end


endmodule