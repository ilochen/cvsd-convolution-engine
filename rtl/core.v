
module core (                       //Don't modify interface
	input      		i_clk,
	input      		i_rst_n,
	input    	  	i_in_valid,
	input 	[31: 0] i_in_data,

	output			o_in_ready,

	output	[ 7: 0]	o_out_data1,
	output	[ 7: 0]	o_out_data2,
	output	[ 7: 0]	o_out_data3,
	output	[ 7: 0]	o_out_data4,

	output	[11: 0] o_out_addr1,
	output	[11: 0] o_out_addr2,
	output	[11: 0] o_out_addr3,
	output	[11: 0] o_out_addr4,

	output 			o_out_valid1,
	output 			o_out_valid2,
	output 			o_out_valid3,
	output 			o_out_valid4,

	output 			o_exe_finish
);

wire [7:0] in_data4 = i_in_data[7:0];
wire [7:0] in_data3 = i_in_data[15:8];
wire [7:0] in_data2 = i_in_data[23:16];
wire [7:0] in_data1 = i_in_data[31:24];

wire lsb4 = i_in_data[0];
wire lsb3 = i_in_data[8];
wire lsb2 = i_in_data[16];
wire lsb1 = i_in_data[24];

reg [(11+11+11+11+13-1)+3:0] barcode_w, barcode_r; //3 extra bits so shifted data isn't lost
wire [53:0] match1 = {barcode_r[56:28], barcode_r[26], barcode_r[24:17], barcode_r[15] , barcode_r[13:0]};
wire [53:0] match2 = {barcode_r[56+1:28+1], barcode_r[26+1], barcode_r[24+1:17+1], barcode_r[15+1] , barcode_r[13+1:0+1]};
wire [53:0] match3 = {barcode_r[56+2:28+2], barcode_r[26+2], barcode_r[24+2:17+2], barcode_r[15+2] , barcode_r[13+2:0+2]};
wire [53:0] match4 = {barcode_r[56+3:28+3], barcode_r[26+3], barcode_r[24+3:17+3], barcode_r[15+3] , barcode_r[13+3:0+3]};
localparam Code1 = 11'b11001101100; //11 bits
localparam Code2 = 11'b11001100110; //11 bits
localparam Code3 = 11'b10010011000; //11 bits
localparam Start_Code_C = 11'b11010011100; //11 bits
localparam Stop_Symbol = 13'b1100011101011; //13 bits

localparam mask = 53'b11010011100_10010011000_110011010_110011010_1100011101011;



reg [1:0] state_w, state_r;
localparam LOAD_IMAGE = 2'd0;
localparam LOAD_WEIGHT = 2'd1;
localparam CONV = 2'd2;
localparam DONE = 2'd3;

reg out_in_ready_w, out_in_ready_r;
assign o_in_ready = out_in_ready_r;

reg [7:0] out_data1_w, out_data1_r;
reg [7:0] out_data2_w, out_data2_r;
reg [7:0] out_data3_w, out_data3_r;
reg [7:0] out_data4_w, out_data4_r;

assign o_out_data1 = out_data1_r;
assign o_out_data2 = out_data2_r;
assign o_out_data3 = out_data3_r;
assign o_out_data4 = out_data4_r;

reg out_valid1_w, out_valid1_r;
reg out_valid2_w, out_valid2_r;
reg out_valid3_w, out_valid3_r;
reg out_valid4_w, out_valid4_r;
reg out_valid_pipelined1_w, out_valid_pipelined1_r;
reg out_valid_pipelined2_w, out_valid_pipelined2_r;
reg out_valid_pipelined3_w, out_valid_pipelined3_r;
reg out_valid_pipelined4_w, out_valid_pipelined4_r;

reg out_valid_pipelined2_1_w, out_valid_pipelined2_1_r;
reg out_valid_pipelined2_2_w, out_valid_pipelined2_2_r;
reg out_valid_pipelined2_3_w, out_valid_pipelined2_3_r;
reg out_valid_pipelined2_4_w, out_valid_pipelined2_4_r;

reg out_valid_pipelined3_1_w, out_valid_pipelined3_1_r;
reg out_valid_pipelined3_2_w, out_valid_pipelined3_2_r;
reg out_valid_pipelined3_3_w, out_valid_pipelined3_3_r;
reg out_valid_pipelined3_4_w, out_valid_pipelined3_4_r;

reg out_valid_pipelined4_1_w, out_valid_pipelined4_1_r;
reg out_valid_pipelined4_2_w, out_valid_pipelined4_2_r;
reg out_valid_pipelined4_3_w, out_valid_pipelined4_3_r;
reg out_valid_pipelined4_4_w, out_valid_pipelined4_4_r;

assign o_out_valid1 = out_valid_pipelined4_1_r;
assign o_out_valid2 = out_valid_pipelined4_2_r;
assign o_out_valid3 = out_valid_pipelined4_3_r;
assign o_out_valid4 = out_valid_pipelined4_4_r;

reg [11:0] out_addr1_w, out_addr1_r;
reg [11:0] out_addr2_w, out_addr2_r;
reg [11:0] out_addr3_w, out_addr3_r;
reg [11:0] out_addr4_w, out_addr4_r;
reg [12:0] o_addr;

reg [11:0] out_addr_pipelined1_w, out_addr_pipelined1_r;
reg [11:0] out_addr_pipelined2_w, out_addr_pipelined2_r;
reg [11:0] out_addr_pipelined3_w, out_addr_pipelined3_r;
reg [11:0] out_addr_pipelined4_w, out_addr_pipelined4_r;

reg [11:0] out_addr_pipelined2_1_w, out_addr_pipelined2_1_r;
reg [11:0] out_addr_pipelined2_2_w, out_addr_pipelined2_2_r;
reg [11:0] out_addr_pipelined2_3_w, out_addr_pipelined2_3_r;
reg [11:0] out_addr_pipelined2_4_w, out_addr_pipelined2_4_r;

reg [11:0] out_addr_pipelined3_1_w, out_addr_pipelined3_1_r;
reg [11:0] out_addr_pipelined3_2_w, out_addr_pipelined3_2_r;
reg [11:0] out_addr_pipelined3_3_w, out_addr_pipelined3_3_r;
reg [11:0] out_addr_pipelined3_4_w, out_addr_pipelined3_4_r;

reg [11:0] out_addr_pipelined4_1_w, out_addr_pipelined4_1_r;
reg [11:0] out_addr_pipelined4_2_w, out_addr_pipelined4_2_r;
reg [11:0] out_addr_pipelined4_3_w, out_addr_pipelined4_3_r;
reg [11:0] out_addr_pipelined4_4_w, out_addr_pipelined4_4_r;

assign o_out_addr1 = out_addr_pipelined4_1_r;
assign o_out_addr2 = out_addr_pipelined4_2_r;
assign o_out_addr3 = out_addr_pipelined4_3_r;
assign o_out_addr4 = out_addr_pipelined4_4_r;

reg out_exe_finish_w, out_exe_finish_r;
reg out_exe_finish_pipelined1_w, out_exe_finish_pipelined1_r;
reg out_exe_finish_pipelined2_w, out_exe_finish_pipelined2_r;
reg out_exe_finish_pipelined3_w, out_exe_finish_pipelined3_r;


assign o_exe_finish = out_exe_finish_pipelined3_r;

reg [11:0] counter_w, counter_r;
reg [10:0] counter_pipelined_w, counter_pipelined_r;

wire [7:0] sram_data_out [0:7];

reg we1, we2, we3, we4, we5, we6, we7, we8;

reg [8:0] sram_address, sram_address_01, sram_address_67;
reg [9:0] address;

reg [1:0] //dilation1_w, dilation_r, dilation2_w, dilation2_r,
		  //dilation3_w, dilation3_r, dilation4_w, dilation4_r,
		  dilation_w, dilation_r;
reg [1:0] //stride1_w, stride1_r, stride2_w, stride2_r,
		  //stride3_w, stride3_r, stride4_w, stride4_r,
		  stride_w, stride_r;

reg [3:0] matchcount_w, matchcount_r;

reg [7:0] weight_matrix_w [0:8], weight_matrix_r [0:8];


reg [7:0] data [0:7];
reg [7:0] data_buffer_0_w [0:7], data_buffer_0_r [0:7];
reg [7:0] data_buffer_1_w [0:7], data_buffer_1_r [0:7];
reg [7:0] data_buffer_2_w [0:7], data_buffer_2_r [0:7];
integer i;
reg [3:0] row_number_w, row_number_r;

reg conv_wait_flag_w, conv_wait_flag_r;
reg conv_done;
wire [7:0] PE_data_out [0:3];

wire invalid = (stride_r == 2'd2 && counter_r[1]) ? 1'b1 : 1'b0;

reg kernel_valid_w, kernel_valid_r;

reg [2:0] match_addr_w, match_addr_r;
reg matched_w, matched_r;
reg [1:0] continue_flag_w, continue_flag_r;
// FSM
always @(*) begin
	state_w = state_r;
	counter_w = counter_r;
	case(state_r)
		LOAD_IMAGE: begin
			if(i_in_valid) begin
				counter_w = counter_r + 1;
			end
			if(counter_r == 11'd1024) begin
				state_w = LOAD_WEIGHT;
				counter_w = 11'd0;
			end else begin
				state_w = LOAD_IMAGE;
			end
		end
		LOAD_WEIGHT: begin
			if(i_in_valid) begin
				// Load weights here
				counter_w = counter_r + 1;
				if(counter_r == 10'd2) begin
					state_w = CONV;
					counter_w = 10'd0;
				end
			end
			else if(kernel_valid_r) begin
				if(matchcount_r != 10) begin
					state_w = DONE;
				end
			end else begin
				state_w = LOAD_WEIGHT;
			end
		end
		CONV: begin
			if(conv_wait_flag_r) begin
				counter_w = counter_r;
			end
			else begin
				counter_w = counter_r + 1;
			end
			if(conv_done) begin
				state_w = DONE;
			end
		end
		default: begin
			state_w = state_r;
		end
	endcase
end

always @(*) begin
	match_addr_w = match_addr_r;
	matched_w = matched_r;
	continue_flag_w = continue_flag_r;

	kernel_valid_w = kernel_valid_r;

	out_exe_finish_w = 1'b0;
	out_exe_finish_pipelined1_w = out_exe_finish_r;
	out_exe_finish_pipelined2_w = out_exe_finish_pipelined1_r;
	out_exe_finish_pipelined3_w = out_exe_finish_pipelined2_r;

	out_data1_w = out_data1_r;
	out_data2_w = out_data2_r;
	out_data3_w = out_data3_r;
	out_data4_w = out_data4_r;

	out_in_ready_w = out_in_ready_r;

	out_valid1_w = 1'b0;
	out_valid2_w = 1'b0;
	out_valid3_w = 1'b0;
	out_valid4_w = 1'b0;

	out_addr1_w = out_addr1_r;
	out_addr2_w = out_addr2_r;
	out_addr3_w = out_addr3_r;
	out_addr4_w = out_addr4_r;

	out_valid_pipelined1_w = out_valid1_r;
	out_valid_pipelined2_w = out_valid2_r;
	out_valid_pipelined3_w = out_valid3_r;
	out_valid_pipelined4_w = out_valid4_r;

	out_valid_pipelined2_1_w = out_valid_pipelined1_r;
	out_valid_pipelined2_2_w = out_valid_pipelined2_r;
	out_valid_pipelined2_3_w = out_valid_pipelined3_r;
	out_valid_pipelined2_4_w = out_valid_pipelined4_r;

	out_valid_pipelined3_1_w = out_valid_pipelined2_1_r;
	out_valid_pipelined3_2_w = out_valid_pipelined2_2_r;
	out_valid_pipelined3_3_w = out_valid_pipelined2_3_r;
	out_valid_pipelined3_4_w = out_valid_pipelined2_4_r;

	out_valid_pipelined4_1_w = out_valid_pipelined3_1_r;
	out_valid_pipelined4_2_w = out_valid_pipelined3_2_r;
	out_valid_pipelined4_3_w = out_valid_pipelined3_3_r;
	out_valid_pipelined4_4_w = out_valid_pipelined3_4_r;

	out_addr_pipelined1_w = out_addr1_r;
	out_addr_pipelined2_w = out_addr2_r;
	out_addr_pipelined3_w = out_addr3_r;
	out_addr_pipelined4_w = out_addr4_r;

	out_addr_pipelined2_1_w = out_addr_pipelined1_r;
	out_addr_pipelined2_2_w = out_addr_pipelined2_r;
	out_addr_pipelined2_3_w = out_addr_pipelined3_r;
	out_addr_pipelined2_4_w = out_addr_pipelined4_r;

	out_addr_pipelined3_1_w = out_addr_pipelined2_1_r;
	out_addr_pipelined3_2_w = out_addr_pipelined2_2_r;
	out_addr_pipelined3_3_w = out_addr_pipelined2_3_r;
	out_addr_pipelined3_4_w = out_addr_pipelined2_4_r;

	out_addr_pipelined4_1_w = out_addr_pipelined3_1_r;
	out_addr_pipelined4_2_w = out_addr_pipelined3_2_r;
	out_addr_pipelined4_3_w = out_addr_pipelined3_3_r;
	out_addr_pipelined4_4_w = out_addr_pipelined3_4_r;

	// dilation1_w = 1'd1;
	// stride1_w = 1'd1;
	// dilation2_w = 1'd1;
	// stride2_w = 1'd1;
	// dilation3_w = 1'd1;
	// stride3_w = 1'd1;
	// dilation4_w = 1'd1;
	// stride4_w = 1'd1;
	stride_w = stride_r;
	dilation_w = dilation_r;

	matchcount_w = matchcount_r;
	barcode_w = barcode_r;

	for( i = 0; i < 9; i = i + 1) begin
		weight_matrix_w[i] = weight_matrix_r[i];
	end

	for( i = 0; i < 8; i = i + 1) begin
		data[i] = 8'd0;
		data_buffer_0_w[i] = data_buffer_0_r[i];
		data_buffer_1_w[i] = data_buffer_0_r[i];
		data_buffer_2_w[i] = data_buffer_1_r[i]; // on purpose to simplify shifting logic
	end

	row_number_w = row_number_r;
	conv_wait_flag_w = conv_wait_flag_r;


	we1 = 1'b1;
	we2 = 1'b1;
	we3 = 1'b1;
	we4 = 1'b1;
	we5 = 1'b1;
	we6 = 1'b1;
	we7 = 1'b1;
	we8 = 1'b1;
	sram_address = 9'd0;
	sram_address_01 = sram_address;
	sram_address_67 = sram_address;

	conv_done = 1'b0;

	case(state_r)
		LOAD_IMAGE: begin
			if(i_in_valid) begin
				sram_address = counter_r[9:1]; // divide by 2
				sram_address_01 = sram_address;
				sram_address_67 = sram_address;
				barcode_w = {barcode_r[((11+11+11+11+13-1)+3)-4:0], lsb1, lsb2, lsb3, lsb4};
				// if lsb of counter is 0, write to sram1~4
				if(counter_r[0] == 1'b0) begin
					we1 = 1'b0;
					we2 = 1'b0;
					we3 = 1'b0;
					we4 = 1'b0;
				end
				else begin
					we5 = 1'b0;
					we6 = 1'b0;
					we7 = 1'b0;
					we8 = 1'b0;
				end
			end
			if((counter_r[3:0]== 0 || counter_r[3:0] == 15) && matchcount_r < 10) begin
				if(mask == match1) begin
					if(barcode_r[14]) begin
						dilation_w = 2'd2;
					end
					if(barcode_r[25])  begin
						stride_w = 2'd2;
					end 
					if(counter_r[3:0] == 0) begin
						match_addr_w = 3'd0;
					end else begin
						match_addr_w = 3'd1;
					end
				end

				if(mask == match2) begin
					if(barcode_r[14+1]) begin
						dilation_w = 2'd2;
					end
					if(barcode_r[25+1])  begin
						stride_w = 2'd2;
					end 
					if(counter_r[3:0] == 0) begin
						match_addr_w = 3'd2;
					end else begin
						match_addr_w = 3'd3;
					end
				end

				if(mask == match3) begin
					if(barcode_r[14+2]) begin
						dilation_w = 2'd2;
					end
					if(barcode_r[25+2])  begin
						stride_w = 2'd2;
					end 
					if(counter_r[3:0] == 0) begin
						match_addr_w = 3'd4;
					end else begin
						match_addr_w = 3'd5;
					end
				end

				if(mask == match4) begin
					if(barcode_r[14+3]) begin
						dilation_w = 2'd2;
					end
					if(barcode_r[25+3])  begin
						stride_w = 2'd2;
					end 
					if(counter_r[3:0] == 0) begin
						match_addr_w = 3'd6;
					end else begin
						match_addr_w = 3'd7;
					end
				end


				if( mask == match1 || mask == match2 || mask == match3 || mask == match4 ) begin
					matchcount_w = matchcount_r + 1;
					matched_w = 1'b1;
					continue_flag_w = 1;
					if(matched_r) begin
						if(match_addr_w != match_addr_r) begin
							matchcount_w = 1;
						end
					end
				end else if (continue_flag_r) begin
					continue_flag_w = 0;
				end else begin
					matchcount_w = 0;
					matched_w = 1'b0;
				end
			end

			// if(counter_r == 11'd1024) begin
			// 	out_valid1_w = 1'b1;
			// 	out_valid2_w = 1'b1;
			// 	out_valid3_w = 1'b1;
			// 	if(matchcount_r == 10) begin
			// 		out_data1_w = 3;
			// 		out_data2_w = stride_r;
			// 		out_data3_w = dilation_r;
			// 	end else begin
			// 		out_data1_w = 0;
			// 		out_data2_w = 0;
			// 		out_data3_w = 0;
			// 		out_data4_w = 0;
			// 	end
			// end

		end
		LOAD_WEIGHT: begin
			if(i_in_valid) begin
				case(counter_r[1:0])
					2'b00:begin
						weight_matrix_w[0] = in_data1;
						weight_matrix_w[1] = in_data2;
						weight_matrix_w[2] = in_data3;
						weight_matrix_w[3] = in_data4;
					end
					2'b01:begin
						weight_matrix_w[4] = in_data1;
						weight_matrix_w[5] = in_data2;
						weight_matrix_w[6] = in_data3;
						weight_matrix_w[7] = in_data4;
					end
					default:begin
						weight_matrix_w[8] = in_data1;
					end
				endcase
			end else begin
				if(!kernel_valid_r) begin
					// do nothing
					out_valid1_w = 1'b1;
					out_valid2_w = 1'b1;
					out_valid3_w = 1'b1;
					kernel_valid_w = 1'b1;
					if(matchcount_r == 10) begin
						out_data1_w = 3;
						out_data2_w = stride_r;
						out_data3_w = dilation_r;
					end else begin
						out_data1_w = 0;
						out_data2_w = 0;
						out_data3_w = 0;
						out_data4_w = 0;
					end
				end
			end
		end
		CONV: begin
			out_data1_w = PE_data_out[0];
			out_data2_w = PE_data_out[1];
			out_data3_w = PE_data_out[2];
			out_data4_w = PE_data_out[3];
			address = ((counter_r[5:0]+1) << (3+dilation_r[1])) + row_number_r[3:1];
			sram_address = address[8:0] + (address[9] <<< 3);
			sram_address_01 = sram_address;
			sram_address_67 = sram_address;
			o_addr = (((counter_r[5:0]-1) << 6) << dilation_r[1]) + (row_number_r << 2);
			out_addr1_w = o_addr[11:0] + (o_addr[12] <<< 6);
			if(dilation_r[0]) begin
				out_addr2_w = out_addr1_w + 1;
				out_addr3_w = out_addr1_w + 2;
				out_addr4_w = out_addr1_w + 3;
			end else begin
				out_addr2_w = out_addr1_w + 2;
				out_addr3_w = out_addr1_w + 1;
				out_addr4_w = out_addr1_w + 3;
			end
			if(!conv_wait_flag_r) begin
				if(!counter_r[6]) begin 
					sram_address_67 = sram_address - 1;
					if(dilation_r[0]) begin
						data[0] = (row_number_r == 4'd0) ? 0 : sram_data_out[7];
						data[1] = sram_data_out[0];
						data[2] = sram_data_out[1];
						data[3] = sram_data_out[2];
						data[4] = sram_data_out[1];
						data[5] = sram_data_out[2];
						data[6] = sram_data_out[3];
						data[7] = sram_data_out[4];
					end else begin
						data[0] = (row_number_r == 4'd0) ? 0 : sram_data_out[6];
						data[1] = sram_data_out[0];
						data[2] = sram_data_out[2];
						data[3] = sram_data_out[4];
						data[4] = (row_number_r == 4'd0) ? 0 : sram_data_out[7];
						data[5] = sram_data_out[1];
						data[6] = sram_data_out[3];
						data[7] = sram_data_out[5];
					end
				end else begin
					sram_address_01 = sram_address + 1;
					if(dilation_r[0]) begin
						data[0] = sram_data_out[3];
						data[1] = sram_data_out[4];
						data[2] = sram_data_out[5];
						data[3] = sram_data_out[6];
						data[4] = sram_data_out[5];
						data[5] = sram_data_out[6];
						data[6] = sram_data_out[7];
						data[7] = (row_number_r == 4'd15) ? 0 :sram_data_out[0];
					end else begin
						data[0] = sram_data_out[2];
						data[1] = sram_data_out[4];
						data[2] = sram_data_out[6];
						data[3] = (row_number_r == 4'd15) ? 0 : sram_data_out[0];
						data[4] = sram_data_out[3];
						data[5] = sram_data_out[5];
						data[6] = sram_data_out[7];
						data[7] = (row_number_r == 4'd15) ? 0 : sram_data_out[1];
					end
				end
			end else begin
				if(counter_r[5:0] == 32)begin
					sram_address = address[8:0] + (address[9] <<< 3) - 16; 
				end else begin
					sram_address = row_number_r[3:1];
				end

				if(!counter_r[6]) begin 
						sram_address_67 = sram_address - 1;
						sram_address_01 = sram_address;
				end else begin
						sram_address_67 = sram_address;
						sram_address_01 = sram_address + 1;
				end
				if(counter_r[5:0] == 0) begin
					o_addr = (((counter_r[5:0]-1) << 6) << dilation_r[1]) + ((row_number_r-1) << 2);
				end else begin
					o_addr = (((counter_r[5:0]-1) << 6) << dilation_r[1]) + (row_number_r << 2);
				end
				if(dilation_r[1]) begin
					out_addr1_w = o_addr[11:0] + (o_addr[12] <<< 6);
				end else begin
					out_addr1_w = o_addr[11:0];
				end
				if(dilation_r[0]) begin
					out_addr2_w = out_addr1_w + 1;
					out_addr3_w = out_addr1_w + 2;
					out_addr4_w = out_addr1_w + 3;
				end else begin
					out_addr2_w = out_addr1_w + 2;
					out_addr3_w = out_addr1_w + 1;
					out_addr4_w = out_addr1_w + 3;
				end
			end

			for( i = 0; i < 8; i = i + 1) begin
				data_buffer_0_w[i] = data[i];
			end

			if(counter_r[5:0] || conv_wait_flag_r) begin
				out_valid1_w = 1'b1;
				out_valid2_w = 1'b1;
				out_valid3_w = 1'b1;
				out_valid4_w = 1'b1;
			end

			if(dilation_r[1] && counter_r[5:0] == 32 && !conv_wait_flag_r) begin
				out_valid1_w = 1'b0;
				out_valid2_w = 1'b0;
				out_valid3_w = 1'b0;
				out_valid4_w = 1'b0;
			end

			if(counter_r[5:0] == 63 && !conv_wait_flag_r) begin
				conv_wait_flag_w = 1'b1;
				row_number_w = row_number_r + 1;
			end else if(dilation_r[1] && counter_r[5:0] == 31 && !conv_wait_flag_r) begin
				conv_wait_flag_w = 1'b1;
			end else begin
				conv_wait_flag_w = 1'b0;
			end

			if(counter_r[10]) begin
				conv_done = 1'b1;
				out_addr1_w = 4092;
				if(dilation_r[1]) begin
					out_addr2_w = 4094;
					out_addr3_w = 4093;
				end else begin
					out_addr2_w = 4093;
					out_addr3_w = 4094;
				end
				out_addr4_w = 4095;
			end

			if(stride_r == 2'd2 && counter_r > 0) begin
				if(dilation_r[0]) begin 
					if(!counter_r[0]) begin
						out_valid1_w = 1'b0;
						out_valid2_w = 1'b0;
						out_valid3_w = 1'b0;
						out_valid4_w = 1'b0;
					end else begin
						out_valid1_w = 1'b1;
						out_valid2_w = 1'b0;
						out_valid3_w = 1'b1;
						out_valid4_w = 1'b0;
						out_addr1_w = ((counter_r[5:0]-1) << 4) + (row_number_r<<1);
						out_addr3_w = ((counter_r[5:0]-1) << 4) + (row_number_r<<1) + 1;
					end
				end else begin
					if(counter_r[5] && !conv_wait_flag_r) begin
						out_valid1_w = 1'b0;
						out_valid2_w = 1'b0;
						out_valid3_w = 1'b0;
						out_valid4_w = 1'b0;
					end else begin
						out_valid1_w = 1'b1;
						out_valid2_w = 1'b1;
						out_valid3_w = 1'b0;
						out_valid4_w = 1'b0;
						out_addr1_w = ((counter_r[5:0]-1) << 5) + (row_number_r<<1);
						out_addr2_w = ((counter_r[5:0]-1) << 5) + (row_number_r<<1) + 1;
					end
				end

			end

		end
		DONE: begin
			out_exe_finish_w = 1'b1;
			out_data1_w = PE_data_out[0];
			out_data2_w = PE_data_out[1];
			out_data3_w = PE_data_out[2];
			out_data4_w = PE_data_out[3];
		end
	endcase

end

PE u1_PE (
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.data_in_1(data_buffer_0_r[0]),
	.data_in_2(data_buffer_0_r[1]),
	.data_in_3(data_buffer_0_r[2]),
	.data_in_4(data_buffer_1_r[0]),
	.data_in_5(data_buffer_1_r[1]),
	.data_in_6(data_buffer_1_r[2]),
	.data_in_7(data_buffer_2_r[0]),
	.data_in_8(data_buffer_2_r[1]),
	.data_in_9(data_buffer_2_r[2]),
	.weight1(weight_matrix_r[6]),
	.weight2(weight_matrix_r[7]),
	.weight3(weight_matrix_r[8]),
	.weight4(weight_matrix_r[3]),
	.weight5(weight_matrix_r[4]),
	.weight6(weight_matrix_r[5]),
	.weight7(weight_matrix_r[0]),
	.weight8(weight_matrix_r[1]),
	.weight9(weight_matrix_r[2]),
	.data_out(PE_data_out[0]) // Not connected in this design
);

PE u2_PE (
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.data_in_1(data_buffer_0_r[1]),
	.data_in_2(data_buffer_0_r[2]),
	.data_in_3(data_buffer_0_r[3]),
	.data_in_4(data_buffer_1_r[1]),
	.data_in_5(data_buffer_1_r[2]),
	.data_in_6(data_buffer_1_r[3]),
	.data_in_7(data_buffer_2_r[1]),
	.data_in_8(data_buffer_2_r[2]),
	.data_in_9(data_buffer_2_r[3]),
	.weight1(weight_matrix_r[6]),
	.weight2(weight_matrix_r[7]),
	.weight3(weight_matrix_r[8]),
	.weight4(weight_matrix_r[3]),
	.weight5(weight_matrix_r[4]),
	.weight6(weight_matrix_r[5]),
	.weight7(weight_matrix_r[0]),
	.weight8(weight_matrix_r[1]),
	.weight9(weight_matrix_r[2]),
	.data_out(PE_data_out[1]) // Not connected in this design
);

PE u3_PE (
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.data_in_1(data_buffer_0_r[4]),
	.data_in_2(data_buffer_0_r[5]),
	.data_in_3(data_buffer_0_r[6]),
	.data_in_4(data_buffer_1_r[4]),
	.data_in_5(data_buffer_1_r[5]),
	.data_in_6(data_buffer_1_r[6]),
	.data_in_7(data_buffer_2_r[4]),
	.data_in_8(data_buffer_2_r[5]),
	.data_in_9(data_buffer_2_r[6]),
	.weight1(weight_matrix_r[6]),
	.weight2(weight_matrix_r[7]),
	.weight3(weight_matrix_r[8]),
	.weight4(weight_matrix_r[3]),
	.weight5(weight_matrix_r[4]),
	.weight6(weight_matrix_r[5]),
	.weight7(weight_matrix_r[0]),
	.weight8(weight_matrix_r[1]),
	.weight9(weight_matrix_r[2]),
	.data_out(PE_data_out[2]) // Not connected in this design
);

PE u4_PE (
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.data_in_1(data_buffer_0_r[5]),
	.data_in_2(data_buffer_0_r[6]),
	.data_in_3(data_buffer_0_r[7]),
	.data_in_4(data_buffer_1_r[5]),
	.data_in_5(data_buffer_1_r[6]),
	.data_in_6(data_buffer_1_r[7]),
	.data_in_7(data_buffer_2_r[5]),
	.data_in_8(data_buffer_2_r[6]),
	.data_in_9(data_buffer_2_r[7]),
	.weight1(weight_matrix_r[6]),
	.weight2(weight_matrix_r[7]),
	.weight3(weight_matrix_r[8]),
	.weight4(weight_matrix_r[3]),
	.weight5(weight_matrix_r[4]),
	.weight6(weight_matrix_r[5]),
	.weight7(weight_matrix_r[0]),
	.weight8(weight_matrix_r[1]),
	.weight9(weight_matrix_r[2]),
	.data_out(PE_data_out[3]) // Not connected in this design
);

sram_512x8 u0_sram_512x8 (
	.Q(sram_data_out[0]),
	.CLK(i_clk),
	.CEN(1'b0),
	.WEN(we1),
	.A(sram_address_01),
	.D(in_data1)
);

sram_512x8 u1_sram_512x8 (
	.Q(sram_data_out[1]),
	.CLK(i_clk),
	.CEN(1'b0),
	.WEN(we2),
	.A(sram_address_01),
	.D(in_data2)
);

sram_512x8 u2_sram_512x8 (
	.Q(sram_data_out[2]),
	.CLK(i_clk),
	.CEN(1'b0),
	.WEN(we3),
	.A(sram_address),
	.D(in_data3)
);

sram_512x8 u3_sram_512x8 (
	.Q(sram_data_out[3]),
	.CLK(i_clk),
	.CEN(1'b0),
	.WEN(we4),
	.A(sram_address),
	.D(in_data4)
);

sram_512x8 u4_sram_512x8 (
	.Q(sram_data_out[4]),
	.CLK(i_clk),
	.CEN(1'b0),
	.WEN(we5),
	.A(sram_address),
	.D(in_data1)
);

sram_512x8 u5_sram_512x8 (
	.Q(sram_data_out[5]),
	.CLK(i_clk),
	.CEN(1'b0),
	.WEN(we6),
	.A(sram_address),
	.D(in_data2)
);

sram_512x8 u6_sram_512x8 (
	.Q(sram_data_out[6]),
	.CLK(i_clk),
	.CEN(1'b0),
	.WEN(we7),
	.A(sram_address_67),
	.D(in_data3)
);


sram_512x8 u7_sram_512x8 (
	.Q(sram_data_out[7]),
	.CLK(i_clk),
	.CEN(1'b0),
	.WEN(we8),
	.A(sram_address_67),
	.D(in_data4)
);

// reg i_rst_n2, i_rst_n1;
// always @(posedge i_clk or negedge i_rst_n ) begin
// 	if(!i_rst_n) begin
// 		// i_rst_n2 <= 1'b0;
// 		i_rst_n1 <= 1'b0;
// 	end
// 	else begin
// 		i_rst_n1 <= 1'b1;
// 		// i_rst_n2 <= i_rst_n1;
// 	end
// end

always @(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n)begin
		out_data1_r <= 8'd0;
		out_data2_r <= 8'd0;
		out_data3_r <= 8'd0;
		out_data4_r <= 8'd0;
		out_in_ready_r <= 1'b1;
		state_r <= LOAD_IMAGE;
		out_valid1_r <= 1'b0;
		out_valid2_r <= 1'b0;
		out_valid3_r <= 1'b0;
		out_valid4_r <= 1'b0;
		out_addr1_r <= 12'd0;
		out_addr2_r <= 12'd0;
		out_addr3_r <= 12'd0;
		out_addr4_r <= 12'd0;
		out_exe_finish_r <= 1'b0;
		out_exe_finish_pipelined1_r <= 1'b0;
		out_exe_finish_pipelined2_r <= 1'b0;
		out_exe_finish_pipelined3_r <= 1'b0;

		out_valid_pipelined1_r <= 1'b0;
		out_valid_pipelined2_r <= 1'b0;
		out_valid_pipelined3_r <= 1'b0;
		out_valid_pipelined4_r <= 1'b0;
		out_addr_pipelined1_r <= 12'd0;
		out_addr_pipelined2_r <= 12'd0;
		out_addr_pipelined3_r <= 12'd0;
		out_addr_pipelined4_r <= 12'd0;

		out_valid_pipelined2_1_r <= 1'b0;
		out_valid_pipelined2_2_r <= 1'b0;
		out_valid_pipelined2_3_r <= 1'b0;
		out_valid_pipelined2_4_r <= 1'b0;

		out_addr_pipelined2_1_r <= 12'd0;
		out_addr_pipelined2_2_r <= 12'd0;
		out_addr_pipelined2_3_r <= 12'd0;
		out_addr_pipelined2_4_r <= 12'd0;

		out_valid_pipelined3_1_r <= 1'b0;
		out_valid_pipelined3_2_r <= 1'b0;
		out_valid_pipelined3_3_r <= 1'b0;
		out_valid_pipelined3_4_r <= 1'b0;

		out_addr_pipelined3_1_r <= 12'd0;
		out_addr_pipelined3_2_r <= 12'd0;
		out_addr_pipelined3_3_r <= 12'd0;
		out_addr_pipelined3_4_r <= 12'd0;

		out_valid_pipelined4_1_r <= 1'b0;
		out_valid_pipelined4_2_r <= 1'b0;
		out_valid_pipelined4_3_r <= 1'b0;
		out_valid_pipelined4_4_r <= 1'b0;

		out_addr_pipelined4_1_r <= 12'd0;
		out_addr_pipelined4_2_r <= 12'd0;
		out_addr_pipelined4_3_r <= 12'd0;
		out_addr_pipelined4_4_r <= 12'd0;

		counter_r <= 10'd0;

		barcode_r <= 0;
		matchcount_r <= 10'd0;

		dilation_r <= 2'd1;
		stride_r <= 2'd1;

		kernel_valid_r <= 1'b0;

		for( i = 0; i < 9; i = i + 1) begin
			weight_matrix_r[i] <= 8'd0;
		end

		for( i = 0; i < 8; i = i + 1) begin
			data_buffer_0_r[i] <= 0;
			data_buffer_1_r[i] <= 0;
			data_buffer_2_r[i] <= 0;
		end

		row_number_r <= 4'd0;
		conv_wait_flag_r <= 1'b0;

		match_addr_r <= 3'd0;
		matched_r <= 1'b0;
		continue_flag_r <= 1'b0;
	end
	else begin
		out_data1_r <= out_data1_w;
		out_data2_r <= out_data2_w;
		out_data3_r <= out_data3_w;
		out_data4_r <= out_data4_w;
		out_in_ready_r <= out_in_ready_w;
		out_valid1_r <= out_valid1_w;
		out_valid2_r <= out_valid2_w;
		out_valid3_r <= out_valid3_w;
		out_valid4_r <= out_valid4_w;
		out_addr1_r <= out_addr1_w;
		out_addr2_r <= out_addr2_w;
		out_addr3_r <= out_addr3_w;
		out_addr4_r <= out_addr4_w;
		out_exe_finish_r <= out_exe_finish_w;
		out_exe_finish_pipelined1_r <= out_exe_finish_pipelined1_w;
		out_exe_finish_pipelined2_r <= out_exe_finish_pipelined2_w;
		out_exe_finish_pipelined3_r <= out_exe_finish_pipelined3_w;

		out_valid_pipelined1_r <= out_valid_pipelined1_w;
		out_valid_pipelined2_r <= out_valid_pipelined2_w;
		out_valid_pipelined3_r <= out_valid_pipelined3_w;
		out_valid_pipelined4_r <= out_valid_pipelined4_w;

		out_valid_pipelined2_1_r <= out_valid_pipelined2_1_w;
		out_valid_pipelined2_2_r <= out_valid_pipelined2_2_w;
		out_valid_pipelined2_3_r <= out_valid_pipelined2_3_w;
		out_valid_pipelined2_4_r <= out_valid_pipelined2_4_w;

		out_valid_pipelined3_1_r <= out_valid_pipelined3_1_w;
		out_valid_pipelined3_2_r <= out_valid_pipelined3_2_w;
		out_valid_pipelined3_3_r <= out_valid_pipelined3_3_w;
		out_valid_pipelined3_4_r <= out_valid_pipelined3_4_w;

		out_valid_pipelined4_1_r <= out_valid_pipelined4_1_w;
		out_valid_pipelined4_2_r <= out_valid_pipelined4_2_w;
		out_valid_pipelined4_3_r <= out_valid_pipelined4_3_w;
		out_valid_pipelined4_4_r <= out_valid_pipelined4_4_w;

		out_addr_pipelined1_r <= out_addr_pipelined1_w;
		out_addr_pipelined2_r <= out_addr_pipelined2_w;
		out_addr_pipelined3_r <= out_addr_pipelined3_w;
		out_addr_pipelined4_r <= out_addr_pipelined4_w;

		out_addr_pipelined2_1_r <= out_addr_pipelined2_1_w;
		out_addr_pipelined2_2_r <= out_addr_pipelined2_2_w;
		out_addr_pipelined2_3_r <= out_addr_pipelined2_3_w;
		out_addr_pipelined2_4_r <= out_addr_pipelined2_4_w;

		out_addr_pipelined3_1_r <= out_addr_pipelined3_1_w;
		out_addr_pipelined3_2_r <= out_addr_pipelined3_2_w;	
		out_addr_pipelined3_3_r <= out_addr_pipelined3_3_w;
		out_addr_pipelined3_4_r <= out_addr_pipelined3_4_w;

		out_addr_pipelined4_1_r <= out_addr_pipelined4_1_w;
		out_addr_pipelined4_2_r <= out_addr_pipelined4_2_w;
		out_addr_pipelined4_3_r <= out_addr_pipelined4_3_w;
		out_addr_pipelined4_4_r <= out_addr_pipelined4_4_w;

		state_r <= state_w;

		counter_r <= counter_w;

		barcode_r <= barcode_w;
		matchcount_r <= matchcount_w;

		dilation_r <= dilation_w;
		stride_r <= stride_w;

		kernel_valid_r <= kernel_valid_w;

		for( i = 0; i < 9; i = i + 1) begin
			weight_matrix_r[i] <= weight_matrix_w[i];
		end

		for( i = 0; i < 8; i = i + 1) begin
			data_buffer_0_r[i] <= data_buffer_0_w[i];
			data_buffer_1_r[i] <= data_buffer_1_w[i];
			data_buffer_2_r[i] <= data_buffer_2_w[i];
		end

		row_number_r <= row_number_w;
		conv_wait_flag_r <= conv_wait_flag_w;

		match_addr_r <= match_addr_w;
		matched_r <= matched_w;
		continue_flag_r <= continue_flag_w;
	end
end

endmodule

module PE (
	input i_clk,
	input i_rst_n,
	input  [7:0] data_in_1,
	input  [7:0] data_in_2,
	input  [7:0] data_in_3,
	input  [7:0] data_in_4,
	input  [7:0] data_in_5,
	input  [7:0] data_in_6,
	input  [7:0] data_in_7,
	input  [7:0] data_in_8,
	input  [7:0] data_in_9,
	input  [7:0] weight1,
	input  [7:0] weight2,
	input  [7:0] weight3,
	input  [7:0] weight4,
	input  [7:0] weight5,
	input  [7:0] weight6,
	input  [7:0] weight7,
	input  [7:0] weight8,
	input  [7:0] weight9,
	output [7:0] data_out
);

	wire signed [(8+9)-1:0] product1;
	wire signed [(8+9)-1:0] product2;
	wire signed [(8+9)-1:0] product3;
	wire signed [(8+9)-1:0] product4;
	wire signed [(8+9)-1:0] product5;
	wire signed [(8+9)-1:0] product6;
	wire signed [(8+9)-1:0] product7;
	wire signed [(8+9)-1:0] product8;
	wire signed [(8+9)-1:0] product9;

	DW02_mult_3_stage #(
        .A_width(9),
        .B_width(8)
    ) 
    U0 (
        .A($signed({1'b0, data_in_1})),
        .B($signed(weight1)),
        .TC(1'b1),
        .CLK(i_clk),
        .PRODUCT(product1)
    );

    DW02_mult_3_stage #(
        .A_width(9),
        .B_width(8)
    ) 
    U1 (
        .A($signed({1'b0, data_in_2})),
        .B($signed(weight2)),
        .TC(1'b1),
        .CLK(i_clk),
        .PRODUCT(product2)
    );

    DW02_mult_3_stage #(
        .A_width(9),
        .B_width(8)
    ) 
    U2 (
        .A($signed({1'b0, data_in_3})),
        .B($signed(weight3)),
        .TC(1'b1),
        .CLK(i_clk),
        .PRODUCT(product3)
    );

    DW02_mult_3_stage #(
        .A_width(9),
        .B_width(8)
    ) 
    U3 (
        .A($signed({1'b0, data_in_4})),
        .B($signed(weight4)),
        .TC(1'b1),
        .CLK(i_clk),
        .PRODUCT(product4)
    );

    DW02_mult_3_stage #(
        .A_width(9),
        .B_width(8)
    ) 
    U4 (
        .A($signed({1'b0, data_in_5})),
        .B($signed(weight5)),
        .TC(1'b1),
        .CLK(i_clk),
        .PRODUCT(product5)
    );

    DW02_mult_3_stage #(
        .A_width(9),
        .B_width(8)
    ) 
    U5 (
        .A($signed({1'b0, data_in_6})),
        .B($signed(weight6)),
        .TC(1'b1),
        .CLK(i_clk),
        .PRODUCT(product6)
    );

    DW02_mult_3_stage #(
        .A_width(9),
        .B_width(8)
    ) 
    U6 (
        .A($signed({1'b0, data_in_7})),
        .B($signed(weight7)),
        .TC(1'b1),
        .CLK(i_clk),
        .PRODUCT(product7)
    );

    DW02_mult_3_stage #(
        .A_width(9),
        .B_width(8)
    ) 
    U7 (
        .A($signed({1'b0, data_in_8})),
        .B($signed(weight8)),
        .TC(1'b1),
        .CLK(i_clk),
        .PRODUCT(product8)
    );

    DW02_mult_3_stage #(
        .A_width(9),
        .B_width(8)
    ) 
    U8 (
        .A($signed({1'b0, data_in_9})),
        .B($signed(weight9)),
        .TC(1'b1),
        .CLK(i_clk),
        .PRODUCT(product9)
    );

	reg signed [((8+9)-1)+2:0] sum1_3_w, sum1_3_r;
	reg signed [((8+9)-1)+2:0] sum4_6_w, sum4_6_r;
	reg signed [((8+9)-1)+2:0] sum7_9_w, sum7_9_r;
	always @(*) begin
		sum1_3_w = product1 + product2 + product3;
		sum4_6_w = product4 + product5 + product6;
		sum7_9_w = product7 + product8 + product9;
	end

	always @(posedge i_clk or negedge i_rst_n) begin
		if(!i_rst_n) begin
			sum1_3_r <= 0;
			sum4_6_r <= 0;
			sum7_9_r <= 0;
		end
		else begin
			sum1_3_r <= sum1_3_w ;
			sum4_6_r <= sum4_6_w ;
			sum7_9_r <= sum7_9_w ;
		end
	end

	wire signed [((8+9)-1)+4:0] sum_raw = sum1_3_r + sum4_6_r + sum7_9_r;

	wire [((8+9)-1)+4-7:0] sum_rounded = sum_raw[((8+9)-1)+4:7] + sum_raw[6];

	assign data_out = (sum_rounded[((8+9)-1)+4-7]) ? 8'd0 :
					  (sum_rounded > 255) ? 8'd255 :
					  sum_rounded[7:0];
endmodule
