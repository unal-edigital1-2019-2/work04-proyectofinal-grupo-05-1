`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:14:22 12/02/2019 
// Design Name: 
// Module Name:    cam_read 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cam_read_lecture #(
		parameter AW = 16 // Cantidad de bits  de la direccin 
		)(
		input clk,	input pclk,
		input rst,
		input vsync,
		input href,
		input [7:0] px_data,

		output reg [AW-1:0] mem_px_addr = 0,
		output reg [7:0] mem_px_data = 0,
		output reg px_wr = 0
   );
	

	reg cont = 1'b0;

reg [2:0] fsm_state=0;
always@(posedge pclk) begin
	if (rst)
	begin
		mem_px_addr=0;
		fsm_state=0;
	end
	case(fsm_state) 
	2'b00:
		if (vsync==0 && mem_px_addr==0) fsm_state=1;
	1:
		if (vsync==1) fsm_state=2;
		
	2:
		if (vsync==0) fsm_state=3;
	3: begin
		if (href) begin
			mem_px_addr=mem_px_addr+1;
	//		fsm_state=4;
		end
		if (vsync==1) fsm_state=0;
		end
	4: begin
		if (href==0) begin
			fsm_state=3;
		end	
		if (vsync==1) fsm_state=0;
		end
		/*4: begin			
		if (href)			
			fsm_state=3;
		if (href==0)
			fsm_state=0;
		end*/
		
	endcase 


end

endmodule
