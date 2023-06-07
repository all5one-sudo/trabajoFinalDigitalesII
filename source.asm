list p=16f887
#include <P16F887.INC>

__CONFIG _CONFIG1, _FOSC_INTRC_CLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

W_TEMP        EQU    0X70
STATUS_TEMP   EQU    0X71
Variables     UDATA
ADC_VALUE     RES    1

ORG 0x00
GOTO MAIN
ORG 0x04
GOTO ISR
ORG 0x05

MAIN:
    BANKSEL ANSEL
    MOVLW   0x01
    MOVWF   ANSEL ; Configura el pin del potenciómetro como entrada analógica
    BANKSEL OSCCON
    MOVLW   0x71
    MOVWF   OSCCON ; Configura la frecuencia del oscilador
    BANKSEL TRISD
    MOVLW   0x00
    MOVWF   TRISD ; Configura los pines del puerto D como salidas digitales
    BANKSEL PORTD
    CLRF    PORTD ; Limpia el puerto D
    BANKSEL INTCON
    BSF     INTCON, GIE ; Habilita las interrupciones globales
    BCF     INTCON, T0IE ; Deshabilita la interrupción del temporizador 0
    BCF     INTCON, T0IF ; Limpia la bandera de interrupción del temporizador 0
    BSF     INTCON, INTE ; Habilita la interrupción externa
    BCF     INTCON, INTF ; Limpia la bandera de interrupción externa
    BANKSEL OPTION_REG
    MOVLW   b'11000100'
    MOVWF   OPTION_REG ; Configura las opciones del registro OPTION
    BANKSEL WPUB
    BSF     WPUB, WPUB0 ; Habilita la resistencia pull-up en RB0
    BANKSEL IOCB
    BSF     IOCB, IOCB0 ; Habilita la detección de cambios en RB0
    BANKSEL TRISB
    BSF     TRISB, TRISB0 ; Configura RB0 como entrada
    BANKSEL PORTB
    BSF     PORTB, RB0 ; Activa la resistencia pull-up en RB0
    BANKSEL ANSELH
    MOVLW   0x00
    MOVWF   ANSELH ; Configura los pines RA0 y RA1 como entradas digitales
    BANKSEL TRISC
    BCF     TRISC, 2 ; Configura RC2 como salida
    BANKSEL CCP1CON
    MOVLW   0x0C
    MOVWF   CCP1CON ; Configura el CCP1 para el modo PWM
    BANKSEL T2CON
    MOVLW   0x04
    MOVWF   T2CON ; Configura el TMR2 para el modo PWM
    BANKSEL TRISE
    BCF     TRISE, 0 ; Configura RE0 como salida
    BCF     TRISE, 1 ; Configura RE1 como salida
    BANKSEL PORTE
    BSF     PORTE, 0 ; Activa el motor de CC en un sentido
    BCF     PORTE, 1 ; Desactiva el motor de CC en el otro sentido
    BANKSEL ADCON1
    MOVLW   0x0E
    MOVWF   ADCON1 ; Configura los pines RA0 y RA1 como entradas analógicas
    BANKSEL TRISA
    MOVLW   0x01
    MOVWF   TRISA ; Configura RA0 como entrada
    BANKSEL PORTA
    CLRF    PORTA ; Limpia el puerto A
    BANKSEL ADCON0
    MOVLW   0xC1
    MOVWF   ADCON0 ; Configura el ADC para la lectura de RA0
    CLRF    ADC_VALUE ; Limpia el valor del ADC
    BANKSEL RCSTA
    MOVLW   b'10010000'
    MOVWF   RCSTA ; Configura la recepción serial
    BANKSEL TXSTA
    MOVLW   b'00100100'
    MOVWF   TXSTA ; Configura la transmisión serial
    BANKSEL SPBRG
    MOVLW   b'00011001'
    MOVWF   SPBRG ; Configura el baud rate para la comunicación serial
    BANKSEL PIR1
    BCF     PIR1, RCIF ; Limpia la bandera de interrupción de recepción serial

ADC_READ:
    BSF     ADCON0, GO_DONE ; Inicia la conversión ADC
    CALL    DELAY_1MS
    BTFSC   ADCON0, GO_DONE ; Espera a que la conversión ADC se complete
    GOTO    $-1
    MOVF    ADRESH, W ; Lee el valor del ADC
    MOVWF   ADC_VALUE ; Guarda el valor del ADC
    MOVWF   PORTD ; Muestra el valor del ADC en el puerto D
    BANKSEL CCPR1L
    MOVWF   CCPR1L ; Establece el valor del ciclo de trabajo del PWM
    BANKSEL TXSTA
    BTFSS   TXSTA, TRMT ; Espera hasta que el registro de transmisión esté vacío
    GOTO    $-1
    BANKSEL TXREG
    MOVWF   TXREG ; Transmite el valor del ADC por Bluetooth
    CALL    DELAY_1MS
    GOTO    ADC_READ ; Realiza una nueva lectura del ADC

DELAY_1MS:
    BANKSEL INTCON
    BCF     INTCON, T0IF ; Limpia la bandera de interrupción del temporizador 0
    MOVLW   .256
    MOVWF   TMR0 ; Carga el temporizador 0 para generar una espera de 1 ms
    BTFSS   INTCON, T0IF ; Espera hasta que se cumpla el tiempo de espera
    GOTO    $-1
    BCF     INTCON, T0IF ; Limpia la bandera de interrupción del temporizador 0
    RETURN

ISR:
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP ; Guarda los valores de los registros W y STATUS, se salva el contexto
    CALL    DELAY_1MS ; Realiza un retardo para evitar rebotes en la interrupción
    MOVLW   0xFF
    XORWF   PORTE, F ; Cambia el sentido de giro del motor de CC
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS ; Restaura el valor del registro STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W ; Se restaura el contexto
    BANKSEL INTCON
    BCF     INTCON, INTF ; Limpia la bandera de interrupción externa
    RETFIE ; Retorna de la rutina de interrupción

END
