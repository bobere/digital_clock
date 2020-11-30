module display(clk,rst_n,rst_n1,hex1,hex2,hex3,hex4,hex5,hex6,add_in,sub_in,model_in);

	input clk;
	input rst_n;
	input rst_n1;
	output reg [6:0] hex1,hex2,hex3,hex4,hex5,hex6;
	
	input  add_in,sub_in,model_in;
	
	reg [3:0] out1,out2,out3,out4,out5,out6;
	reg [25:0] cnt;
	reg [3:0]temp1,temp2,temp3,temp4,temp5,temp6;
	reg model=1'b1;
	
	
	//产生1s的信号
	always@(posedge clk or negedge rst_n)
	if(rst_n==1'b0)
		cnt<=26'd0;
	else if(cnt==26'd49_999_999)
		cnt<=26'd0;
	else
		cnt<=cnt+1'b1;
	
	
	//产生20ms信号
	reg[19:0] cnt1;
   always @(posedge clk or negedge rst_n)
   if(!rst_n) 
		cnt1 <= 20'd0;
	else if(cnt1== 20'd999_999)
		cnt1<=20'd0;
   else 
		cnt1 <= cnt1 + 1'b1;
	
	//产生1/100s信号
	reg[18:0] cnt3;
   always @(posedge clk or negedge rst_n)
   if(!rst_n) 
		cnt3 <= 19'd0;
	else if(cnt3== 19'd49_999)
		cnt3<=19'd0;
   else 
		cnt3 <= cnt1 + 1'b1;
			
  
   reg[2:0] pin_status;
   always @(posedge clk or negedge rst_n)
   if(!rst_n) 
		pin_status <= 3'b111;
   else if(cnt1 == 20'd999_999) 
		pin_status <= {add_in,sub_in,model_in};
     
   reg[2:0] pin_status_r;
   always @(posedge clk or negedge rst_n)
   if(!rst_n) 
		pin_status_r <= 3'b111;
   else 
		pin_status_r <= pin_status;
   //前20MS的值与后20MS的值
   wire[2:0]  pin_status_ctrl;
   assign pin_status_ctrl = pin_status_r & (~pin_status);
	
	reg[1:0] Time_model;
	always @(posedge clk or negedge rst_n)
   if(!rst_n) 
		Time_model <= 2'b00;
   else if(pin_status_ctrl[0]) 
   begin
      if(Time_model == 2'b11)
          Time_model <= 2'b00;
      else
			 Time_model <= Time_model + 1'b1;
   end
	
	always @(posedge clk or negedge rst_n)
	if(!rst_n)
	begin
		out1<=4'b0000;
		out2<=4'b0000;
		out3<=4'b0000;
		out4<=4'b0000;
		out5<=4'b0000;
		out6<=4'b0000;
		temp1<=4'b0000;
		temp2<=4'b0000;
		temp3<=4'b0000;
		temp4<=4'b0000;
		temp5<=4'b0000;
		temp6<=4'b0000;
	end
	else
	begin
		
		case(Time_model)
			2'b00:
			begin
				model<=1'b1;
				if(cnt==26'd49_999_999)
				begin
					out1<=out1+1'b1;
					if(out1==4'b1001)
					begin
						out1<=4'b0000;
						out2<=out2+1'b1;
						if(out2==4'b0101)
						begin
							out2<=4'b0000;
							out3<=out3+4'b1;
							if(out3==4'b1001)
							begin
								out3<=4'b0000;
								out4<=out4+1'b1;
								if(out4==4'b0101)
								begin
									out4<=4'b0000;
									if(out6==4'b0010)
									begin
										if(out5==4'b0011)
										begin
											out5<=4'b0000;
											out6<=4'b0000;
										end
										else
										begin
											out5<=out5+1'b1;
										end
									end
									else
									begin
										out5<=out5+1'b1;
										if(out5==4'b1000)
										begin
											out5<=4'b0000;
											out6<=out6+1'b1;
										end
									end
								end
							end
						end
					end
				end
			end
			2'b01:
			begin
				model<=1'b1;
				out3<=out3;
				out4<=out4;
				if(pin_status_ctrl[2])
				begin
					out3<=out3+1'b1;
					if(out3==4'b1001)
					begin
						out4<=out4+1'b1;
						out3<=4'b0000;
						if(out4==4'b0101)
							out4<=4'b0000;
					end	
				end
				else if(pin_status_ctrl[1])
				begin
					out3<=out3-1'b1;
					if(out3==4'b0000)
					begin
						out3<=4'b1001;
						out4<=out4-1'b1;
						if(out4==4'b0000)
							out4<=4'b0101;
					end	
				end
			end
			2'b10:
			begin
			model<=1'b1;
			out5<=out5;
			out6<=out6;
			if(pin_status_ctrl[2])
				begin
					if(out6==4'b0010)
					begin
						if(out5==4'b0011)
						begin
							out6<=4'b0000;
							out5<=4'b0000;
						end
						else
							out5<=out5+1'b1;
					end
					else
					begin
						out5<=out5+1'b1;
						if(out5==4'b1001)
						begin
							out5<=4'b0000;
							out6<=out6+1'b1;
						end						
					end	
				end
				else if(pin_status_ctrl[1])
				begin
					if(out6==4'b0000)
					begin
						out5<=out5-1'b1;
						if(out5==4'b0000)
						begin
							out6<=4'b0010;
							out5<=4'b0011;
						end
					end
					else
					begin
						out5<=out5-1'b1;
						if(out5==4'b0000)
						begin
							out5<=4'b1001;
							out6<=out6-1'b1;
						end
					end
				end
		   end
			2'b11:
			begin
				model<=1'b0;
				if(cnt==26'd49_999_999)
				begin
					out1<=out1+1'b1;
					if(out1==4'b1001)
					begin
						out1<=4'b0000;
						out2<=out2+1'b1;
						if(out2==4'b0101)
						begin
							out2<=4'b0000;
							out3<=out3+4'b1;
							if(out3==4'b1001)
							begin
								out3<=4'b0000;
								out4<=out4+1'b1;
								if(out4==4'b0101)
								begin
									out4<=4'b0000;
									if(out6==4'b0010)
									begin
										if(out5==4'b0011)
										begin
											out5<=4'b0000;
											out6<=4'b0000;
										end
										else
										begin
											out5<=out5+1'b1;
										end
									end
									else
									begin
										out5<=out5+1'b1;
										if(out5==4'b1000)
										begin
											out5<=4'b0000;
											out6<=out6+1'b1;
										end
									end
								end
							end
						end
					end
				end
				if(!rst_n1)
				begin
					temp1<=temp1;
					temp2<=temp2;
				   temp3<=temp3;
					temp4<=temp4;
					temp5<=temp5;
					temp6<=temp6;
					if(pin_status_ctrl[2])
					begin
						temp1<=4'b0000;
					   temp2<=4'b0000;
						temp3<=4'b0000;
						temp4<=4'b0000;
						temp5<=4'b0000;
						temp6<=4'b0000;
					end
				end
				
				else
				begin
				if(cnt3== 19'd49_999)
				begin
					temp1<=temp1+1'b1;
					if(temp1==4'b1001)
					begin
						temp1<=4'b0000;
						temp2<=temp2+1'b1;
						if(temp2==4'b1001)
						begin
							temp2<=4'b0000;
							temp3<=temp3+1'b1;
							if(temp3==4'b1001)
							begin
								temp3<=4'b0000;
								temp4<=temp4+1'b1;
								if(temp4==4'b0101)
								begin
									temp4<=4'b0000;
									temp5<=temp5+1'b1;
									if(temp5==4'b1001)
									begin
										temp5<=4'b0000;
										temp6<=temp5+1'b1;
										if(temp6==4'b0101)
										begin
											out6<=4'b0000;
										end
									end
								end
							end
						end
					end
				end
			end
		end
		endcase
	end
	
   reg[3:0]tmp1,tmp2,tmp3,tmp4,tmp5,tmp6;	
	
	always@*
	begin
		if(model==1'b1)
		begin
			tmp1<=out1;
			tmp2<=out2;
			tmp3<=out3;
			tmp4<=out4;
			tmp5<=out5;
			tmp6<=out6;
		end
		else
		begin
			tmp1<=temp1;
			tmp2<=temp2;
			tmp3<=temp3;
			tmp4<=temp4;
			tmp5<=temp5;
			tmp6<=temp6;
		end
	end
	
	
	always@*
	begin
		case(tmp1)
			4'b0000: hex1[6:0]=7'b0000001;
			4'b0001: hex1[6:0]=7'b1001111;
			4'b0010: hex1[6:0]=7'b0010010;
			4'b0011: hex1[6:0]=7'b0000110;
			4'b0100: hex1[6:0]=7'b1001100;
			4'b0101: hex1[6:0]=7'b0100100;
			4'b0110: hex1[6:0]=7'b0100000;
			4'b0111: hex1[6:0]=7'b0001111;
			4'b1000: hex1[6:0]=7'b0000000;
			4'b1001: hex1[6:0]=7'b0000100;
		endcase
	end
	always@*
	begin
		case(tmp2)
			4'b0000: hex2[6:0]=7'b0000001;
			4'b0001: hex2[6:0]=7'b1001111;
			4'b0010: hex2[6:0]=7'b0010010;
			4'b0011: hex2[6:0]=7'b0000110;
			4'b0100: hex2[6:0]=7'b1001100;
			4'b0101: hex2[6:0]=7'b0100100;
			4'b0110: hex2[6:0]=7'b0100000;
			4'b0111: hex2[6:0]=7'b0001111;
			4'b1000: hex2[6:0]=7'b0000000;
			4'b1001: hex2[6:0]=7'b0000100;
		endcase
	end
	always@*
	begin
		case(tmp3)
			4'b0000: hex3[6:0]=7'b0000001;
			4'b0001: hex3[6:0]=7'b1001111;
			4'b0010: hex3[6:0]=7'b0010010;
			4'b0011: hex3[6:0]=7'b0000110;
			4'b0100: hex3[6:0]=7'b1001100;
			4'b0101: hex3[6:0]=7'b0100100;
			4'b0110: hex3[6:0]=7'b0100000;
			4'b0111: hex3[6:0]=7'b0001111;
			4'b1000: hex3[6:0]=7'b0000000;
			4'b1001: hex3[6:0]=7'b0000100;
		endcase
	end
	always@*
	begin
		case(tmp4)
			4'b0000: hex4[6:0]=7'b0000001;
			4'b0001: hex4[6:0]=7'b1001111;
			4'b0010: hex4[6:0]=7'b0010010;
			4'b0011: hex4[6:0]=7'b0000110;
			4'b0100: hex4[6:0]=7'b1001100;
			4'b0101: hex4[6:0]=7'b0100100;
			4'b0110: hex4[6:0]=7'b0100000;
			4'b0111: hex4[6:0]=7'b0001111;
			4'b1000: hex4[6:0]=7'b0000000;
			4'b1001: hex4[6:0]=7'b0000100;
		endcase
	end
	always@*
	begin
		case(tmp5)
			4'b0000: hex5[6:0]=7'b0000001;
			4'b0001: hex5[6:0]=7'b1001111;
			4'b0010: hex5[6:0]=7'b0010010;
			4'b0011: hex5[6:0]=7'b0000110;
			4'b0100: hex5[6:0]=7'b1001100;
			4'b0101: hex5[6:0]=7'b0100100;
			4'b0110: hex5[6:0]=7'b0100000;
			4'b0111: hex5[6:0]=7'b0001111;
			4'b1000: hex5[6:0]=7'b0000000;
			4'b1001: hex5[6:0]=7'b0000100;
		endcase
	end
	always@*
	begin
		case(tmp6)
			4'b0000: hex6[6:0]=7'b0000001;
			4'b0001: hex6[6:0]=7'b1001111;
			4'b0010: hex6[6:0]=7'b0010010;
			4'b0011: hex6[6:0]=7'b0000110;
			4'b0100: hex6[6:0]=7'b1001100;
			4'b0101: hex6[6:0]=7'b0100100;
			4'b0110: hex6[6:0]=7'b0100000;
			4'b0111: hex6[6:0]=7'b0001111;
			4'b1000: hex6[6:0]=7'b0000000;
			4'b1001: hex6[6:0]=7'b0000100;
		endcase
	end
endmodule 
	
	