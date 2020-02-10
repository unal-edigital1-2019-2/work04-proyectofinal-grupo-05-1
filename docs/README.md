## GRUPO DE TRABAJO 05

## INTEGRANTES DEL GRUPO
#### Jhohan David Contreras Aragón		1007687796
#### Andrés Felipe Medina Medina 		1015464557
#### Mitchell Elizabeth Rodríguez Barreto	1032503089

![d_estructural](./figs/Diagrama_estructural_todo.png)
Figura []. Diagrama estructural de toda la descripción del hardware de la cámara

![d_funcional](./figs/Diagrama_funcional.png)
Figura []. Diagrama funcional del módulo diseñado *cam_read.v*

![fsm](./figs/fsm_state.png)
Figura []. Máquina de estado finitos para la captura de datos y contadores

![fsm_sennal](./figs/sennal_estados.png)
Figura []. Estados según las señales enviadas por la cámara


![conexiones](./figs/Diagconexiones.png)
Figura []. Diagrama de las conexiones entre la FPGA, la cámara y el Arduino Mega

#### Máxima memoria RAM

Para determinar el tamaño máximo del buffer de memoria RAM que se puede crear con la FPGA, en este caso la Nexys 4 DDR, primero se revisó el datasheet y se encontró que el valor de bloque de memoria RAM en la FPGA es de 4.860.000 bits.


Para calcular el número de bits que va a ocupar la memoria se debe tener en cuenta el formato del pixel con el que se va a trabajar, ya que este define la cantidad de bits que necesita cada pixel para conformar la imagen final.El formato de imagen escogido es el RGB 332, en donde cada píxel necesita 8 bits, es decir, cada pixel está conformado por 1 byte. Por lo tanto, el tamaño de la RAM está definido de la siguiente manera:


![ancho_registro](./figs/Ancho_registro.PNG)


En donde cada fila es un pixel, por ende la altura está definida por la cantidad de pixeles que hay en la imagen y la cantidad de columnas representa la cantidad de bits por pixel en este caso 8.
* Para una imagen de 640 x 480 píxeles el número de posiciones en una memoria está dado por 2^n, en éste caso, como el número de pixeles a usar es de 640 x 480 = 307.200, se busca un exponente tal que 2 elevado a ese exponente sea mayor o igual a 307.200. Para encontrar el valor de _n_ se halla el logaritmo en base 2 de 307.200 y como el exponente debe ser entero, ya que es la altura de una matriz, se redondea el resultado al entero mayor más cercano.

![eq1](./figs/eq1.png)

El tamaño en bits de la memoria RAM sería el número de posiciones por el ancho del registro:

![eq2](./figs/eq2.png)

Como se puede observar el número de bits es cercano al máximo permitido en la tarjeta más es conveniente alejarse de ese valor ya que la memoria no puede llegar a llenarse y hacer que deje de funcionar correctamente la FPGA así.

* Para una imagen de 160 x 120 píxeles.
Se decide recortar el tamaño de la imagen para que no exceda la capacidad de la FPGA, se escala por un factor de 4, por lo que la nueva imagen es ahora 1/16 del tamaño con respecto al tamaño anterior. Ahora el número de posiciones, o píxeles, totales es de 160 x 120 = 19.200. Se hace el mismo procedimiento y se encuentra que el exponente de 2 más cercano que almacena esta cantidad de pixeles es:

![eq3](./figs/eq3.png)


Como se puede observar el tamaño en bits de la memoria RAM para una imagen de 160 x 120 píxeles ocuparía el 5.40 % de la memoria disponible en la FPGA, por lo tanto, se decide usar este tamaño. El tamaño en bytes sería de 32.768.
