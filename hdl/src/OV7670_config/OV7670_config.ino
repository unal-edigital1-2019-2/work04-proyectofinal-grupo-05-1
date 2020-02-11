#include <Wire.h>

#define OV7670_I2C_ADDRESS 0x21 /*Dirección del bus i2c para ña camara*/


void setup() {
  Wire.begin();
  Serial.begin(9600);  
  Serial.println("prueba estado actual");
  get_cam_register();
  
  
  set_cam_RGB565_QCIF();
  set_color_matrix();
  delay(100);
  Serial.println("Despues de config");
  get_cam_register();
  
}


void set_cam_RGB565_QCIF(){
   
  OV7670_write(0x12, 0x80);

  delay(100);
 
 OV7670_write(0x12, 0x24);  //COM7: Set QCIF and RGB
 OV7670_write(0x11, 0xC0);       //CLKR: Set internal clock to use external clock
 OV7670_write(0x0C, 0x08);       //COM3: Enable Scaler
 OV7670_write(0x3E, 0x00);
 OV7670_write(0x40,0xD0);      //COM15: Set RGB 565

 //Color Bar
 //OV7670_write(0x42, 0x08); 
 //OV7670_write(0x12, 0x0E);


 //Registros Mágicos 
 OV7670_write(0x3A,0x04);

 OV7670_write(0x14,0x18); // control de ganancia 

 OV7670_write(0x4F,0xB3);  //abajo
 OV7670_write(0x50,0xB3);  //abaajo
 OV7670_write(0x51,0x00);  //abajo
 OV7670_write(0x52,0x3D);  //abajo
 OV7670_write(0x53,0xA7);  // abajo
 OV7670_write(0x54,0xE4);  //abajo
 OV7670_write(0x58,0x9E);   //abajo
 OV7670_write(0x3D,0xC0);   
 

 OV7670_write(0x17,0x14);  //cambia hstart
 OV7670_write(0x18,0x02);  // cambia hstop
 OV7670_write(0x32,0x80);  // href deja el valor qye  viene por default
 OV7670_write(0x19,0x03);  // vref start
 OV7670_write(0x1A,0x7B);  // vref stop
 OV7670_write(0x03,0x0A);  // cambia vref

 
 OV7670_write(0x0F,0x41);   // no hace nada 
 OV7670_write(0x32,0x80);   // ya lo habias configurado
 OV7670_write(0x1E,0x00);   // no hace nada 
 OV7670_write(0x33,0x0B);  //
 OV7670_write(0x3C,0x78);  // no hace nada y es para  usar vsync
 OV7670_write(0x69,0x00);   // abajo
 OV7670_write(0x74,0x00);   /// esta por defecto el valor 
 OV7670_write(0xB0,0x84);   // configura  abajo
 OV7670_write(0xB1,0x0C);  
 OV7670_write(0xB2, 0x0E);
 OV7670_write(0xB3,0x80);    
 


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


int OV7670_write(int reg_address, byte data){
  return I2C_write(reg_address, &data, 1);
 }

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


void set_color_matrix(){
    OV7670_write(0x4f, 0x80);
    OV7670_write(0x50, 0x80);
    OV7670_write(0x51, 0x00);
    OV7670_write(0x52, 0x22);
    OV7670_write(0x53, 0x5e);
    OV7670_write(0x54, 0x80);
    OV7670_write(0x55, 0x0A);
    OV7670_write(0x56, 0x40);
    OV7670_write(0x58, 0x9e);
    OV7670_write(0x59, 0x88);
    OV7670_write(0x5a, 0x88);
    OV7670_write(0x5b, 0x44);
    OV7670_write(0x5c, 0x67);
    OV7670_write(0x5d, 0x49);
    OV7670_write(0x5e, 0x0e);
    OV7670_write(0x69, 0x00);
    OV7670_write(0x6a, 0x40);
    OV7670_write(0x6b, 0x0a);
    OV7670_write(0x6c, 0x0a);
    OV7670_write(0x6d, 0x55);
    OV7670_write(0x6e, 0x11);
    OV7670_write(0x6f, 0x9f);
    OV7670_write(0xb0, 0x84);
}


void loop(){
  
 }
