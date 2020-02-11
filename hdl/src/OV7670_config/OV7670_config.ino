#include <Wire.h>

#define OV7670_I2C_ADDRESS 0x21 /*Dirección del bus i2c para la camara*/


void setup() {
  Wire.begin(); // iniciamos la configuracuión del 
  Serial.begin(9600);  // Asigna puerto serial
  Serial.println("prueba estado actual"); 
  get_cam_register(); // Muestra los registros iniciales
  
  
  set_cam_RGB565_QCIF(); // Configura camara 
  set_color_matrix(); // configura ajustes de color, brillo contreaste, etc
  delay(100);
  Serial.println("Despues de config");
  get_cam_register(); //muestra los registros despues de la configuracion
  
}

//Configura parametros de funcionamiento de la camara
void set_cam_RGB565_QCIF(){
   
  OV7670_write(0x12, 0x80); // reinicia los registros a sus valores por defecto

  delay(100);
 
 OV7670_write(0x12, 0x24);  //COM07: Set CIF and RGB
 OV7670_write(0x11, 0xC0);  //CLKR: Set internal clock to use external clock
 OV7670_write(0x0C, 0x08);  //COM3: Enable Scaler
 OV7670_write(0x3E, 0x00);  // COM14 : PCLK no se divide y 
 OV7670_write(0x40, 0xD0);  //COM15: Set RGB 565

 //Color Bar
 //OV7670_write(0x42, 0x08);  //COM17
 //OV7670_write(0x12, 0x0E);  //COM07


 //Registros Mágicos 
 OV7670_write(0x3A,0x04); //TSLB: habilita una secuencia de salida que se usa en el COM13 

 OV7670_write(0x14,0x18); // COM09: control de ganancia 
 OV7670_write(0x3D,0xC0);  //COM13: activa la correccion gamma y el ajuste automatico del nivel de saturacion UV 
 OV7670_write(0x17,0x14);  // HSTART:cambia hstart
 OV7670_write(0x18,0x02);  // HSTOP:cambia hstop
 OV7670_write(0x32,0x80);  // HREF:href deja el valor qye  viene por default
 OV7670_write(0x19,0x03);  // VSTRT:vref start
 OV7670_write(0x1A,0x7B);  // VSTOP:vref stop
 OV7670_write(0x03,0x0A);  // VREF: cambia el control vertical de referencia(vref)

 
 OV7670_write(0x0F,0x41);  // COM06:no reinicia todos los tiempos cuando el formato cambia  
 OV7670_write(0x1E,0x00);  // MVFP: no hace nada se cambian valores reservados 
 OV7670_write(0x33,0x0B);  // CHLF: no hace nada se cambian valores reservados 
 OV7670_write(0x3C,0x78);  // COM12: siempre se tiene HREF aunque VSYNC este en low
 OV7670_write(0x74,0x00);  // REG74: esta por defecto el valor de ganancia es digital es decir esta inhabilitada
 OV7670_write(0xB1,0x0C);  // ABLC1: Habilita el ABLC, es decir la calibracion automatica del nivel de negro 
 OV7670_write(0xB2,0x0E);  // RSVD:se cambian valores reservados
 OV7670_write(0xB3,0x80);  // THL_ST: Valor por defecto que configura el target del ABLC.
 


/*prubas de ferney*/

/*
   OV7670_write(0x12, 0x00);  //COM7: Set QCIF and RGB Using COM7 and Color Bar    
  OV7670_write(0x40,0xC0);        //COM15: Set RGB 565  
  OV7670_write(0x11, 0x0A);       //CLKR: CSet internal clock to use external clock    
  OV7670_write(0x0C, 0x04);       //COM3: Enable Scaler   
  OV7670_write(0x14,0x6A);       
  
  OV7670_write(0x17, 0x16);      
  OV7670_write(0x18, 0x04);     
  */  
}

//Configura de que registros queremos obtener su valor
void get_cam_register(){
  Serial.print ("0x12 ");   
  Serial.println(get_register_value(0x12), HEX); //COM7
  Serial.print ("0x11 ");   
  Serial.println(get_register_value(0x11), HEX); //
  Serial.print ("0x0C ");   
  Serial.println(get_register_value(0x0C), HEX); //
  Serial.print ("0x3E ");   
  Serial.println(get_register_value(0x3E), HEX); //
  Serial.print ("0x40 ");   
  Serial.println(get_register_value(0x40), HEX); //
  Serial.print ("0x3A ");   
  Serial.println(get_register_value(0x3A), HEX); //
  Serial.print ("0x14 ");   
  Serial.println(get_register_value(0x14), HEX);
 Serial.print ("0x17 ");   
   Serial.println(get_register_value(0x17), HEX);
 Serial.print ("0x18 ");   
   Serial.println(get_register_value(0x18), HEX);
   Serial.print ("0x32 "); 
  Serial.println(get_register_value(0x32), HEX);
  Serial.print ("0x19 "); 
  Serial.println(get_register_value(0x19), HEX);
  Serial.print ("0x1A "); 
  Serial.println(get_register_value(0x1a), HEX);
  Serial.print ("0x03 "); 
  Serial.println(get_register_value(0x03), HEX);
  Serial.print ("0x0F "); 
  Serial.println(get_register_value(0x0f), HEX);
  Serial.print ("0x1E "); 
  Serial.println(get_register_value(0x1e), HEX);
  Serial.print ("0x33 "); 
  Serial.println(get_register_value(0x33), HEX);
  Serial.print ("0x3C "); 
  Serial.println(get_register_value(0x3c), HEX);
  Serial.print ("0x69 "); 
  Serial.println(get_register_value(0x69), HEX);
  Serial.print ("0x78 "); 
  Serial.println(get_register_value(0x78), HEX);

}

//crea la funcion OV7670_write con la cual se van a editar los registros
int OV7670_write(int reg_address, byte data){
  return I2C_write(reg_address, &data, 1);
 }
 
//Funcion con la que se escribe el valor configurado con la funcion OV7670_write por medio del I2C
int I2C_write(int start, const byte *pData, int size){
 //  Serial.println ("I2C init");   
    int n,error;
    Wire.beginTransmission(OV7670_I2C_ADDRESS);
    n = Wire.write(start);
    if(n != 1){
      Serial.println ("I2C ERROR WRITING START ADDRESS");   
      return 1;
    }
    n = Wire.write(pData, size);
    if(n != size){
      Serial.println( "I2C ERROR WRITING DATA");
      return 1;
    }
    error = Wire.endTransmission(true);
    if(error != 0){
      Serial.println( String(error));
      return 1;
    }
    Serial.println ("WRITE OK");
    return 0;
 }

//Funcion con la que se lee el valor del registro solicitado
byte get_register_value(int register_address){
  byte data = 0;
  Wire.beginTransmission(OV7670_I2C_ADDRESS);
  Wire.write(register_address);
  Wire.endTransmission();
  Wire.requestFrom(OV7670_I2C_ADDRESS,1);
  while(Wire.available()<1);
  data = Wire.read();
  return data;
}

//funcion que configura parametros del control de color de la camara
void set_color_matrix(){
    OV7670_write(0x4F, 0x80);  //MTX1:Asigna el coeficiente 1 de la matriz de correccion de color
    OV7670_write(0x50, 0x80);  //MTX2:Asigna el coeficiente 2 de la matriz de correccion de color
    OV7670_write(0x51, 0x00);  //MTX3:Asigna el coeficiente 3 de la matriz de correccion de color
    OV7670_write(0x52, 0x22);  //MTX4:Asigna el coeficiente 4 de la matriz de correccion de color
    OV7670_write(0x53, 0x5E);  //MTX5:Asigna el coeficiente 5 de la matriz de correccion de color
    OV7670_write(0x54, 0x80);  //MTX6:Asigna el coeficiente 6 de la matriz de correccion de color
    OV7670_write(0x55, 0x0A);  //BRIGHT: Controla el brillo
    OV7670_write(0x56, 0x40);  //CONTRAS: Controla el contraste de colores
    OV7670_write(0x58, 0x9E);  //MTXS:Determina el signo de las matrices de coeficientes  
    OV7670_write(0x59, 0x88);  //AWBC7:Cambia la señal de control del balance automatico de blancos
    OV7670_write(0x5A, 0x88);  //AWBC8:Cambia la señal de control del balance automatico de blancos
    OV7670_write(0x5B, 0x44);  //AWBC9:Cambia la señal de control del balance automatico de blancos
    OV7670_write(0x5C, 0x67);  //AWBC10:Cambia la señal de control del balance automatico de blancos
    OV7670_write(0x5D, 0x49);  //AWBC11:Cambia la señal de control del balance automatico de blancos
    OV7670_write(0x5E, 0x0E);  //AWBC12:Cambia la señal de control del balance automatico de blancos
    OV7670_write(0x69, 0x00);  //GFIX:Valor por defecto controla la ganancia de color en este caso es 1
    OV7670_write(0x6A, 0x40);  //GGAIN:Varia la ganancia de AWB dependiendo de los verdes y un parametro asignado
    OV7670_write(0x6B, 0x0A);  //DBLV:Asigna que el control del PLL no dependa del reloj de entrada
    OV7670_write(0x6C, 0x0A);  //AWBCTR3:Cambia la señal de control del balance automatico de blancos
    OV7670_write(0x6D, 0x55);  //AWBCTR2:Cambia la señal de control del balance automatico de blancos
    OV7670_write(0x6E, 0x11);  //AWBCTR1:Cambia la señal de control del balance automatico de blancos
    OV7670_write(0x6F, 0x9F);  //AWBCTR0:Cambia la señal de control del balance automatico de blancos
    OV7670_write(0xB0, 0x84);  //RSVD:se cambian valores reservados
}


void loop(){
  
 }
