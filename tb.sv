module testbench;

logic clk, reset;

logic [8-1:0] exp [0:15];
logic [24-1:0] man [0:15];

logic [12-1:0] bfp_expected [0:15];

logic [32-1:0] bfp;

logic [8-1:0] bfp_exp;
wire [4-1:0] bfps [0:15];


logic [32-1:0] vectornum, errors;
logic [(32*16)-1:0] testvectors_fps [0:10000];
logic [(12*16)-1:0] testvectors_bfps [0:10000];


bfp_converter /* #( ) */ dut(
  .i_exps(exp),
  .i_mans(man),
  .o_bfp_exp(bfp_exp),
  .o_bfps(bfps)
);

always #5 clk = ~clk;

initial begin
  $readmemb("./fps.tv", testvectors_fps);
  $readmemb("./bfps.tv", testvectors_bfps);
  vectornum = 0; errors = 0;

  $dumpfile("testbench.vcd");
	$dumpvars(0, testbench);
  clk = 0;
  reset = 1; #27; reset = 0;
end

genvar i;
generate
  for(i=0; i<16; i=i+1) begin
    always @ (posedge clk) begin
      #1; {man[i][23], exp[i], man[i][22:0]} = testvectors_fps[vectornum][(i*32)+:32];
          bfp_expected[i] = testvectors_bfps[vectornum][(i*12)+:12];
    end
  end
endgenerate

genvar idx;
generate
  for(idx=0; idx<16; idx=idx+1) begin
    always @ (negedge clk) begin
      if(~reset) begin
        if({bfps[idx][3], bfp_exp, bfps[idx][2:0]} !== bfp_expected[idx]) begin
          $display("Error: inputs = %b", {man[idx][23], exp[idx], man[idx][22:0]});
          $display(" outputs = %b (%b expected)", {bfps[idx][3], bfp_exp, bfps[idx][2:0]}, bfp_expected[idx]);
          errors = errors + 1;
        end
      end
    end
  end
endgenerate

always @(negedge clk) begin
  if (~reset) begin

    vectornum = vectornum + 1;

    if (testvectors_fps[vectornum] === 512'bx || testvectors_bfps[vectornum] === 192'bx) begin
      $display("%d tests completed with %d errors", vectornum, errors);
      $finish;
    end
  end
end

`ifdef DEBUG
    logic [4-1:0] _bfps_0;
    logic [4-1:0] _bfps_1;
    logic [4-1:0] _bfps_2;
    logic [4-1:0] _bfps_3;
    logic [4-1:0] _bfps_4;
    logic [4-1:0] _bfps_5;
    logic [4-1:0] _bfps_6;
    logic [4-1:0] _bfps_7;
    logic [4-1:0] _bfps_8;
    logic [4-1:0] _bfps_9;
    logic [4-1:0] _bfps_10;
    logic [4-1:0] _bfps_11;
    logic [4-1:0] _bfps_12;
    logic [4-1:0] _bfps_13;
    logic [4-1:0] _bfps_14;
    logic [4-1:0] _bfps_15;
    always_comb begin        
        _bfps_0 =  bfps[0];
        _bfps_1 =  bfps[1];
        _bfps_2 =  bfps[2];
        _bfps_3 =  bfps[3];
        _bfps_4 =  bfps[4];
        _bfps_5 =  bfps[5];
        _bfps_6 =  bfps[6];
        _bfps_7 =  bfps[7 ];
        _bfps_8 =  bfps[8 ];
        _bfps_9 =  bfps[9 ];
        _bfps_10 = bfps[10];
        _bfps_11 = bfps[11];
        _bfps_12 = bfps[12];
        _bfps_13 = bfps[13];
        _bfps_14 = bfps[14];
        _bfps_15 = bfps[15];
    end


`endif


endmodule
