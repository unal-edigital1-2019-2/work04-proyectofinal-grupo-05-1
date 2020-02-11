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
module cam_read #(
		parameter AW = 17 // Cantidad de bits  de la direccin 
		)(
		input rst,					// Reset
		input pclk,					// Sennal PCLK de la camara
		input vsync,				// Sennal VSYNC
		input href,					// Sennal HREF
		input [7:0] px_data,		// Sennal D - datos
		input [2:0] option,		// Controla el valor de leds (switches)
		input boton_CAM,			// Boton para tomar foto
		input boton_video,		// Boton para volver a video

		output reg [AW-1:0] mem_px_addr = 0,		// Direccion de entrada (escritura)
		output reg [7:0] mem_px_data = 0,			// Dato de entrada
		output reg px_wr = 0,							// Control de escritura
		output reg [15:0] leds							// Guarda el valor del contador
   );
	
	reg [2:0] fsm_state=1;								// Controla la maquina de estados finitos
	reg pas_vsync = 0;									// Valor anterior de VSYNC
	reg cont = 1'b0;										// Controla la captura de datos
	reg [15:0] cont_href=16'b0000000000000000;	// Contador de HREF
	reg [15:0] pas_href=16'b0000000000000000;		// Valor anterior de HREF
	reg [15:0] cont_pixel=16'b0000000000000000;	// Contador de pixeles por linea
	reg [15:0] cont_pclk=16'b0000000000000000;	// Contador PCLKs totales
	
	always@(posedge pclk) begin						// Flancos de subida PCLK
		
		if (rst)
		begin
			mem_px_addr=0;									// Reinicia el valor de la direccion
			leds[15:0]=16'b0000000000000000;			// Reinicia leds
			cont_href[15:0]=16'b0000000000000000;	// Reinicia contador HREF
			fsm_state=1;									// Pasa al primer estado
			pas_vsync=0;									// Asigna cero al valor anterior de VSYNC
			
		end else 
		
		// Maquina de estados finitos		
		case(fsm_state) 					
			
		1:		// Valores iniciales
			begin
				cont_href[15:0]=16'h0000;				// Reinicia contador HREF
				mem_px_addr=0;								
				if(pas_vsync && !vsync) fsm_state=2;// Pasa al segundo estado
			end
			
		2:		// Contador HREF
			begin
				if(!pas_href && href) begin
						cont_href = cont_href +1;		// Contador de HREF
						cont_pixel = 0;					//	Reinicia contador pixel
						fsm_state = 3;						// Pasa al tercer estado
						mem_px_data[7:2] = {px_data[7:5],px_data[2:0]};		// Captura rojo y verde
						px_wr = 0;							// No escribir en la RAM
						cont = ~cont;						// Variable que oscila entre 0 y 1
						cont_pclk = cont_pclk + 1;		// Contador de PCLK
					
				end 
				else if(vsync) 
						fsm_state=1;						// Pasa al primer estado
				else if(boton_CAM)
						fsm_state = 4;						// Pasa al cuarto estado
			end
			
		3:		// Captura de datos
		begin
			if(href) begin  
				// Contador de pixeles
				if (cont==0)
				begin
					mem_px_data[7:2] = {px_data[7:5],px_data[2:0]};// Captura del rojo y verde
					px_wr = 0;												  // No escribir en la RAM
					cont_pclk = cont_pclk + 1;							  // Contador de PCLK
				end
				else 
				begin
					mem_px_data[1:0] = {px_data[4:3]};				  // Captura del color azul
					px_wr = 1;											     // Escribir en la RAM
					if(mem_px_addr < 76800)								  // Si es menor a 320x240
						mem_px_addr = mem_px_addr + 1;				  // Aumenta en uno la direccion
					cont_pixel = cont_pixel +1;						  // Contador de pixeles
					
				end
				cont = ~cont;	// Controla si se guarda rojo y verde o sólo azul
				
			end else
				fsm_state=2;	// Pasa al segundo estado
		end
		
		4:		// Mostrar imagen		
		begin
			px_wr = 0;
			
			// Multiplexor - se controla con 3 switches
			case(option)
			1:
			leds[15:0]=cont_href;	// Muestra el numero de HREF
			
			3:
			leds[15:0]=cont_pixel;	// Muestra el numero de PCLK por línea
			
			7:
			leds[15:0]=cont_pclk;	// Muestra el numero de PCLK
			endcase
			
			if(boton_video)
				fsm_state = 1;			// Pasa al primer estado
		end
		endcase
		
		pas_vsync = vsync;			// Se asigna a pas_vsync el valor actual
	end

endmodule
