# Trabajo Práctico Final, Electrónica Digital II

En este repositorio se encuentran los archivos necesarios para la programación y ensamble del trabajo práctico final para Electrónica Digital II.

El proyecto se puede describir en los siguientes pasos:

1. Se realiza la lectura de un potenciómetro u otra señal analógica en el puerto AN0.
2. Esa señal analógica se usa para controlar el ciclo de trabajo del PWM implementado para variar la velocidad de un motor de corriente continua. Esto se hace mediante la escritura en el registro CCPR1L.
3. El dato de lectura del ADC se envía por puerto serie, en este caso haciendo uso de un módulo de Bluetooth HC-05 en modo data.
4. En caso de recibir una interrupción por puerto RB0, que en el caso planteado es un pulsador, se realiza un cambio de sentido de rotación del motor controlado.

Para poder comprobar el funcionamiento de la conexión Bluetooth, se puede instalar desde App Store o Play Store, cualquier aplicación que soporte conexión a Bluetooth Classic con terminal de debug.
