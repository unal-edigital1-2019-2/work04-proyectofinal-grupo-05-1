//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:    13:34:31 10/22/2019 
// Design Name: 	 Ferney alberto Beltran Molina
// Module Name:    VGA_Driver 
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
module VGA_Driver640x480 (
	input rst,
	input clk, 					// 25MHz  para 60 hz de 640x480
	input  [7:0] pixelIn, 	// Entrada del valor de color  pixel 
	
	output  [7:0] pixelOut, // Salida del valor pixel a la VGA 
	output  Hsync_n,			// Sennal de sincronizacion en horizontal negada
	output  Vsync_n,			// Sennal de sincronizacion en vertical negada 
	output  [9:0] posX, 		// Posicion en horizontal del pixel siguiente
	output  [8:0] posY 		// Posicion en vertical  del pixel siguiente
);

localparam SCREEN_X = 640; 	// Tamanno de la pantalla visible en horizontal 
localparam FRONT_PORCH_X =16;  
localparam SYNC_PULSE_X = 96;
localparam BACK_PORCH_X = 28;
localparam TOTAL_SCREEN_X = SCREEN_X+FRONT_PORCH_X+SYNC_PULSE_X+BACK_PORCH_X; 	// total pixel pantalla en horizontal 


localparam SCREEN_Y = 480; 	// Tamanno de la pantalla visible en vertical 
localparam FRONT_PORCH_Y =10;  
localparam SYNC_PULSE_Y = 2;
localparam BACK_PORCH_Y = 33;
localparam TOTAL_SCREEN_Y = SCREEN_Y+FRONT_PORCH_Y+SYNC_PULSE_Y+BACK_PORCH_Y; 	// total pixel pantalla en Vertical 


reg  [9:0] countX=SCREEN_X; // No se deja en cero para hacer mas rapida la simulacion
reg  [8:0] countY=SCREEN_Y; // No se deja en cero para hacer mas rapida la simulacion

assign posX    = countX;
assign posY    = countY;

// Si countX<SCREEN_X, pixelOut = pixelIn, sino pixelOut = 0.
assign pixelOut = (countX<SCREEN_X) ? (pixelIn ) : (8'b00000000) ;

// Sennales horizontal y vertical para la pantalla
assign Hsync_n = ~((countX>=SCREEN_X+FRONT_PORCH_X) && (countX<SCREEN_X+SYNC_PULSE_X+FRONT_PORCH_X)); 
assign Vsync_n = ~((countY>=SCREEN_Y+FRONT_PORCH_Y) && (countY<SCREEN_Y+FRONT_PORCH_Y+SYNC_PULSE_Y));


always @(posedge clk) begin
	if (rst) begin
		countX <= SCREEN_X; // No se deja en cero para hacer mas rapida la simulacion
		countY <= SCREEN_Y; // No se deja en cero para hacer mas rapida la simulacion
	end
	else begin 
		if (countX >= (TOTAL_SCREEN_X-1)) begin 
			// Si es mayor o igual al tamanno de la pantalla en X menos 1, countX = 0
			countX <= 0;
			if (countY >= (TOTAL_SCREEN_Y-1)) begin
				// Si es mayor o igual al tamanno de la pantalla en Y menos 1, countY = 0
				countY <= 0;
			end 
			else begin
				// Si no, aumente countY en 1
				countY <= countY + 1;
			end
		end 
		else begin
			// Si no, aumente countX en 1 y countY permanece igual
			countX <= countX + 1;
			countY <= countY;
		end
	end
end

endmodule
