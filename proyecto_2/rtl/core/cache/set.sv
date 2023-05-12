// Cache Memory (4way 4word)               //
// i_  means input port                    //
// o_  means output port                   //
// _p_  means data exchange with processor //
// _m_  means data exchange with memory    //
// Replacement policy is LRU (8bit)        //

module core_cache_set(clk,
                      rst_n,
                      entry,
                      o_tag,
                      writedata,
                      byte_en,
                      write,
                      word_en,

                      readdata,
                      wb_addr,
                      hit,
                      modify,
                      miss,
                      valid,
                      read_miss);

    parameter cache_entry = 14;

    input wire                    clk, rst_n;
    input wire [cache_entry-1:0]  entry;
    input wire [22-cache_entry:0] o_tag;
    input wire [127:0] 		      writedata;
    input wire [3:0] 		      byte_en;
    input wire       	          write;
    input wire [3:0]              word_en;
    input wire 			          read_miss;

    output wire [127:0] 		  readdata;
    output wire [22:0] 		      wb_addr;
    output wire 			      hit, modify, miss, valid;



    wire [22-cache_entry:0] 	 i_tag;
    wire 			             dirty;
    wire [24-cache_entry:0] 	 write_tag_data;

    assign hit = valid && (o_tag == i_tag);
    assign modify = valid && (o_tag != i_tag) && dirty;
    assign miss = !valid || ((o_tag != i_tag) && !dirty);

    assign wb_addr = {i_tag, entry};

    //write -> [3:0] write, writedata/readdata 32bit -> 128bit
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram11_3(clk, entry, write && word_en[3]  && byte_en[3], writedata[127:120], entry, readdata[127:120]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram11_2(clk, entry, write && word_en[3]  && byte_en[2], writedata[119:112], entry, readdata[119:112]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram11_1(clk, entry, write && word_en[3]  && byte_en[1], writedata[111:104], entry, readdata[111:104]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram11_0(clk, entry, write && word_en[3]  && byte_en[0], writedata[103:96], entry, readdata[103:96]);

    core_cache_sram #(.width(8), .widthad(cache_entry)) ram10_3(clk, entry, write && word_en[2]  && byte_en[3], writedata[95:88], entry, readdata[95:88]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram10_2(clk, entry, write && word_en[2]  && byte_en[2], writedata[87:80], entry, readdata[87:80]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram10_1(clk, entry, write && word_en[2]  && byte_en[1], writedata[79:72], entry, readdata[79:72]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram10_0(clk, entry, write && word_en[2]  && byte_en[0], writedata[71:64], entry, readdata[71:64]);

    core_cache_sram #(.width(8), .widthad(cache_entry)) ram01_3(clk, entry, write && word_en[1]  && byte_en[3], writedata[63:56], entry, readdata[63:56]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram01_2(clk, entry, write && word_en[1]  && byte_en[2], writedata[55:48], entry, readdata[55:48]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram01_1(clk, entry, write && word_en[1]  && byte_en[1], writedata[47:40], entry, readdata[47:40]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram01_0(clk, entry, write && word_en[1]  && byte_en[0], writedata[39:32], entry, readdata[39:32]);

    core_cache_sram #(.width(8), .widthad(cache_entry)) ram00_3(clk, entry, write && word_en[0]  && byte_en[3], writedata[31:24], entry, readdata[31:24]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram00_2(clk, entry, write && word_en[0]  && byte_en[2], writedata[23:16], entry, readdata[23:16]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram00_1(clk, entry, write && word_en[0]  && byte_en[1], writedata[15: 8], entry, readdata[15:8]);
    core_cache_sram #(.width(8), .widthad(cache_entry)) ram00_0(clk, entry, write && word_en[0]  && byte_en[0], writedata[ 7: 0], entry, readdata[ 7:0]);


    assign write_tag_data = (read_miss) ? {1'b0, 1'b1, o_tag} : (modify || miss ) ? {1'b1, 1'b1, o_tag} : {1'b1, 1'b1, i_tag};
    core_cache_sram #(.width(25-cache_entry), .widthad(cache_entry)) ram_tag(clk, entry, write, write_tag_data, entry, {dirty, valid, i_tag});

`ifdef SIM
    integer i;

    initial begin
        for(i = 0; i <=(2**cache_entry-1); i=i+1) begin
	        ram_tag.mem[i] = 0;
        end
    end
`endif

endmodule
