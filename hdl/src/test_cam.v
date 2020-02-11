`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:46:19 11/04/2019 
// Design Name: 
// Module Name:    test_cam 
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
module test_cam(
    input wire clk,           	// Reloj 100 MHz Nexys4DDR 
    input wire rst,         		// Boton reset
	 input wire boton_CAM,     	// Boton para tomar foto
	 input wire boton_video,   	// Boton para volver a video

	// VGA input/output  
    output wire VGA_Hsync_n,  	// Horizontal sync output
    output wire VGA_Vsync_n,  	// Vertical sync output
    output wire [3:0] VGA_R,		// 4-bit VGA red output
    output wire [3:0] VGA_G, 	 	// 4-bit VGA green output
    output wire [3:0] VGA_B, 	 	// 4-bit VGA blue output
	
	//CAMARA input/output
	
	output wire CAM_xclk,			// System  clock input
	output wire CAM_pwdn,			// Power down mode 
	output wire CAM_reset,			// Clear all registers of cam
	
	// Entradas  y salidas de la camara  que hace falta

	input wire CAM_pclk,				// Sennal PCLK
	input wire CAM_vsync,			// Sennal VSYNC
	input wire CAM_href,				// Sennal HREF
	input wire [7:0] CAM_px_data,	// Sennal D - datos
	
	output wire [15:0] LEDs,		// Guarda el valor del contador	
	input wire [2:0] switch			// Controla el valor de LEDs
 );

// TAMANO DE ADQUISICION DE LA CAMARA 
parameter CAM_SCREEN_X = 320;		// Ancho: 640/2
parameter CAM_SCREEN_Y = 240;		// Alto: 480/2

localparam AW = 17; 					// LOG2(CAM_SCREEN_X*CAM_SCREEN_Y)
localparam DW = 8;					// Bits para cada pixel

// El color es RGB 332
localparam RED_VGA =   8'b11100000;		// 3 bits para rojo
localparam GREEN_VGA = 8'b00011100;		// 3 bits para verde
localparam BLUE_VGA =  8'b00000011;		// 2 bits para azul

// Clk 
wire clk32M;
wire clk25M;					// Reloj para la pantalla
wire clk24M;					// Reloj para la camara

// Conexion dual por RAM

wire  [AW-1: 0] DP_RAM_addr_in;	// Direccion de entrada (escritura)  	
wire  [DW-1: 0] DP_RAM_data_in;	// Dato de entrada
wire DP_RAM_regW;						// Control de escritura

reg  [AW-1: 0] DP_RAM_addr_out;  
	
// Conexin VGA Driver
wire [DW-1:0]data_mem;	   // Salida de dp_ram al driver VGA
wire [DW-1:0]data_RGB332;  // Salida del driver VGA al puerto
wire [9:0]VGA_posX;		   // Determinar la pos de memoria que viene del VGA
wire [8:0]VGA_posY;		   // Determinar la pos de memoria que viene del VGA


/* ****************************************************************************
La pantalla VGA es RGB 444, pero el almacenamiento en memoria se hace 332
por lo tanto, los bits menos significactivos deben ser cero
**************************************************************************** */

assign VGA_R = {data_RGB332[7:5],1'b0};	// Se annade un cero para completar 4 bits
assign VGA_G = {data_RGB332[4:2],1'b0};	// Se annade un cero para completar 4 bits
assign VGA_B = {data_RGB332[1:0],2'b00};	// Se annade dos ceros para completar 4 bits

/* ****************************************************************************
Asignacion de las sennales de control xclk pwdn y reset de la camara 
**************************************************************************** */

assign CAM_xclk = clk24M;	// Asignando reloj de la camara
assign CAM_pwdn = 0;			// Power down mode 
assign CAM_reset = 0;		// Reset de la camara

/* ****************************************************************************
  Este bloque se debe modificar segun sea le caso. El ejemplo esta dado para
  FPGA Spartan6 lx9 a 32MHz.
  Usar "tools -> Core Generator ..."  y general el ip con Clocking Wizard
  el bloque genera un reloj de 25Mhz usado para el VGA  y un relo de 24 MHz
  utilizado para la camara, a partir de una frecuencia de 32 Mhz
  En este caso el reloj de la FPGA es de 100 MHz
**************************************************************************** */

//assign clk32M =clk;
clk24_25_nexys4
  clk25_24(
  .CLK_IN1(clk),			// Reloj 100 MHz
  .CLK_OUT1(clk25M),		// Reloj 25 MHz - Pantalla		
  .CLK_OUT2(clk24M),		// Reloj 24 MHz - Camara
  .RESET(rst)				// Reset
 );

/*****************************************************************************
Instancia del modulo disennado cam_read - Captura de datos y downsampler
**************************************************************************** */
 cam_read #(AW)ov7076_565_to_332(
 
		// Entradas
		.pclk(CAM_pclk),
		.rst(rst),
		.vsync(CAM_vsync),
		.href(CAM_href),
		.px_data(CAM_px_data),
		.option(switch),
		.boton_CAM(boton_CAM),
		.boton_video(boton_video),
		
		// Salidas
		.mem_px_addr(DP_RAM_addr_in),
		.mem_px_data(DP_RAM_data_in),
		.px_wr(DP_RAM_regW),
		.leds(LEDs)
   );

/* ****************************************************************************
buffer_ram_dp buffer memoria dual port y reloj de lectura y escritura separados
Se debe configurar AW  segn los calculos realizados en el Wp01
se recomiendia dejar DW a 8, con el fin de optimizar recursos  y hacer RGB 332
**************************************************************************** */
buffer_ram_dp #( AW,DW)
	DP_RAM(
	
	// Entradas
	.clk_w(CAM_pclk), 
	.addr_in(DP_RAM_addr_in), 
	.data_in(DP_RAM_data_in),
	.regwrite(DP_RAM_regW), 
	
	// Salidas
	.clk_r(clk25M), 
	.addr_out(DP_RAM_addr_out),
	.data_out(data_mem)
	);
	

/* ****************************************************************************
VGA_Driver640x480
**************************************************************************** */
VGA_Driver640x480 VGA640x480
(
	.rst(rst),
	.clk(clk25M), 				// 25MHz para 60 hz de 640x480
	.pixelIn(data_mem), 		// Entrada del valor de color  pixel RGB 332 
	.pixelOut(data_RGB332), // Salida del valor pixel a la VGA 
	.Hsync_n(VGA_Hsync_n),	// Sennal de sincronizacion en horizontal negada
	.Vsync_n(VGA_Vsync_n),	// Sennal de sincronizacion en vertical negada 
	.posX(VGA_posX), 			// Posicion en horizontal del pixel siguiente
	.posY(VGA_posY) 			// Posicion en vertical  del pixel siguiente
);
 
/* ****************************************************************************
Logica para actualizar el pixel acorde con la buffer de memoria y el pixel de 
VGA si la imagen de la camara es menor que el display VGA, los pixeles 
adicionales seran iguales al color del ultimo pixel de memoria 
**************************************************************************** */
always @ (VGA_posX, VGA_posY) begin
		if ((VGA_posX>CAM_SCREEN_X-1) || (VGA_posY>CAM_SCREEN_Y-1))
			DP_RAM_addr_out=17'b11111111111111111;				// Ultima posicion
		else
			DP_RAM_addr_out=VGA_posX+VGA_posY*CAM_SCREEN_X;	// Calcula la posicion
																			// de la direccion de salida
end

endmodule
