`include "core/uarch.sv"

module core_mul
#(parameter W=16)
(
    input  logic 		   clk,
    					   rst,
    					   start,
    input  logic [W-1:0]   a,
    					   b,
    output logic [2*W-1:0] q,
    output logic 		   ready
);

	localparam COUNT_WIDTH = $clog2(a + 1);
	localparameter IDLE = 1'b0;
	localparameter START = 1'b1;

	logic [2*W-1:0] q, q_temp, next_q;
	logic [1:0] temp, next_temp
	logic [COUNT_WIDTH-1:0] count, next_count, 
	logic state, next_state, ready, next_ready;

	always_ff @(posedge clk or negedge rst) begin
		if (!rst) begin
			q          <= {2*W{1'b0}};
			ready      <= 1'b0;
			state 	   <= IDLE;
			temp       <= 2'b0;
			count      <= 2'b0;
		end else begin
			q          <= next_q;
			ready      <= next_ready;
			state 	   <= next_state;
			temp       <= next_temp;
			count      <= next_count;
		end
	end

	always_comb begin
		case (state)
			IDLE: begin
				next_count = 2'b0;
				next_ready = 1'b0;
				if (start) begin
					next_state = START;
					next_temp  = {a[0], 1'b0};
					next_q     = {{W{1'b0}}, a};
				end 
				else begin
					next_state = state;
					next_temp  = 2'b0;
					next_q     = {2*W{1'b0}};
				end
			end

			START: begin
				case (temp)
					2'b10:   q_temp = {q[2*W-1:W]-b, q[W-1:0]};
					2'b01:   q_temp = {q[2*W-1:W]+b, q[W-1:0]};
					default: q_temp = {q[2*W-1:W],   q[W-1:0]};
				endcase
				next_temp  = {a[count+1], a[count]};
				next_count = count + 1'b1;
				next_q     = q_temp >>> 1;
				if (count == COUNT_WIDTH-1) begin
					next_ready = 1'b1;
					next_state = IDLE;
				end 
				else begin
					next_ready = 1'b0;
					next_state = state;
				end
			end
		endcase
	end

endmodule
