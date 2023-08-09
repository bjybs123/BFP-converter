`timescale 1ns / 1ps


module bfp_converter #( 
    parameter GRPSIZE = 16,
    parameter FPEXPSIZE = 8,
    parameter FPMANSIZE = 23,
    parameter BFPEXPSIZE = 8,
    parameter BFPMANSIZE = 3
) (
    input  [FPEXPSIZE-1:0]        i_exps      [0:GRPSIZE-1],
    input  [(FPMANSIZE+1)-1:0]    i_mans      [0:GRPSIZE-1],
    output [BFPEXPSIZE-1:0]       o_bfp_exp,
    output [(BFPMANSIZE+1)-1:0]   o_bfps      [0:GRPSIZE-1]
);

    parameter levels = $clog2(GRPSIZE);


    logic signs [0:GRPSIZE-1];
    logic [FPMANSIZE-1:0] mans [0:GRPSIZE-1];
    logic [FPMANSIZE-1:0] mans_align [0:GRPSIZE-1];

    logic [BFPEXPSIZE-1:0] exps [0:GRPSIZE-1];
    logic [BFPEXPSIZE-1:0] tmp_result [1:GRPSIZE-1];
    logic [BFPEXPSIZE-1:0] max_exp;
    logic [BFPEXPSIZE-1:0] sft_amt [0:GRPSIZE-1];

    logic [BFPMANSIZE-1:0] bfp_mans [0:GRPSIZE-1];

    genvar idx;
    generate
        for(idx=0; idx<GRPSIZE; idx=idx+1) begin : man_slice
            assign exps[idx] = i_exps[idx] == 0 ? i_exps[idx] : i_exps[idx] + 1;
            assign {signs[idx], mans[idx]} = i_mans[idx];
        end
    endgenerate


    genvar lv, cmp;
    generate
        for(lv=levels-1; lv>=0; lv=lv-1) begin : level
            for(cmp=0; cmp<2**lv; cmp=cmp+1) begin :compare
                always @ (*) begin
                    if(lv == levels-1) begin
                        tmp_result[2**lv+cmp] = (exps[cmp*2] > exps[cmp*2+1]) ? exps[cmp*2] : exps[cmp*2+1];
                    end
                    else begin
                        tmp_result[2**lv+cmp] =     tmp_result[2**(lv+1)+cmp*2] > tmp_result[2**(lv+1)+cmp*2+1] ? 
                                                    tmp_result[2**(lv+1)+cmp*2] : tmp_result[2**(lv+1)+cmp*2+1];
                    end
                end
            end
        end
    endgenerate

    assign max_exp = tmp_result[1];

    genvar sub;
    generate
        for(sub=0; sub<GRPSIZE; sub=sub+1) begin : exp_sub
            assign sft_amt[sub] = max_exp - exps[sub];
        end
    endgenerate


    genvar sft;
    generate
        for(sft=0; sft<GRPSIZE; sft=sft+1) begin : sft_exp
            always_comb begin
                // Denormalized
                if(exps[sft] == 0) begin
                    mans_align[sft] = mans[sft] >> sft_amt[sft];
                end
                // Not Denormalized number, 
                // eliminate leading 1 by shifting right for simplicity, {1'b1, mans[sft][22:1]} 
                else begin
                    mans_align[sft] = {1'b1, mans[sft][FPMANSIZE-1:1]} >> sft_amt[sft];
                end
            end
        end
    endgenerate


    // Nearest rounding
    genvar round;
    generate
        for(round=0; round<GRPSIZE; round=round+1) begin
            always @ (*) begin
                if(mans_align[round][(FPMANSIZE-1)-3] == 1'b1) begin
                    // if the mantissa is the highest value
                    if(mans_align[round][FPMANSIZE-1:(FPMANSIZE-1)-2] == 3'b111) begin
                        bfp_mans[round] = mans_align[round][FPMANSIZE-1:(FPMANSIZE-1)-2];
                    end
                    else begin
                        bfp_mans[round] = mans_align[round][FPMANSIZE-1:(FPMANSIZE-1)-2] + 1;
                    end
                end
                else begin
                    bfp_mans[round] = mans_align[round][FPMANSIZE-1:(FPMANSIZE-1)-2];
                end
            end
        end
    endgenerate
    
    assign o_bfp_exp = max_exp;

    genvar concat;
    generate
        for(concat=0; concat<GRPSIZE; concat=concat+1) begin : bfp_concat
            assign o_bfps[concat] = {signs[concat], bfp_mans[concat]};
        end
    endgenerate

`ifdef DEBUG
    logic [BFPMANSIZE:0] o_bfps_0;
    logic [BFPMANSIZE:0] o_bfps_1;
    logic [BFPMANSIZE:0] o_bfps_2;
    logic [BFPMANSIZE:0] o_bfps_3;
    logic [BFPMANSIZE:0] o_bfps_4;
    logic [BFPMANSIZE:0] o_bfps_5;
    logic [BFPMANSIZE:0] o_bfps_6;
    logic [BFPMANSIZE:0] o_bfps_7;
    logic [BFPMANSIZE:0] o_bfps_8;
    logic [BFPMANSIZE:0] o_bfps_9;
    logic [BFPMANSIZE:0] o_bfps_10;
    logic [BFPMANSIZE:0] o_bfps_11;
    logic [BFPMANSIZE:0] o_bfps_12;
    logic [BFPMANSIZE:0] o_bfps_13;
    logic [BFPMANSIZE:0] o_bfps_14;
    logic [BFPMANSIZE:0] o_bfps_15;
    always_comb begin        
        o_bfps_0 =  o_bfps[0];
        o_bfps_1 =  o_bfps[1];
        o_bfps_2 =  o_bfps[2];
        o_bfps_3 =  o_bfps[3];
        o_bfps_4 =  o_bfps[4];
        o_bfps_5 =  o_bfps[5];
        o_bfps_6 =  o_bfps[6];
        o_bfps_7 =  o_bfps[7 ];
        o_bfps_8 =  o_bfps[8 ];
        o_bfps_9 =  o_bfps[9 ];
        o_bfps_10 = o_bfps[10];
        o_bfps_11 = o_bfps[11];
        o_bfps_12 = o_bfps[12];
        o_bfps_13 = o_bfps[13];
        o_bfps_14 = o_bfps[14];
        o_bfps_15 = o_bfps[15];
    end
`endif


endmodule