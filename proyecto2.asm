		PROCESSOR 16F877
		INCLUDE <P16F877.INC>
		
valor	equ h'20'			;Registros auxiliares para rutina de retardo
valor1	equ h'21'
valor2	equ h'22'
contadorCentesima equ h'23'	;Registros auxiliares para conversi�n Hexa - Decimal
contadorDecima equ h'24'
contadorUnidad equ h'25'
aux equ h'28'
regaux equ h'26'			;Registros auxiliares para visualizar en Hexadecimal
regaux2 equ h'27'

			ORG 0 ;Vector de reset
			GOTO INICIO
			ORG 5

INICIO:		CLRF PORTA ; Limpia PORTA
			CLRF PORTB ; Limpia PORTB
			CLRF PORTC 	; Limpia PORTC
			CLRF PORTD 	; Limpia PORTD
			CLRF PORTE	; Limpia PORTE
			BSF STATUS,5 ; Cambia a banco 1
			BCF STATUS,6
			MOVLW 0x00
			MOVWF TRISB	;TRISB<- 0x00 configuramos puerto B como salida
			MOVLW H'0'		; CONFIGURA PUERTO C COMO SALIDA
			MOVWF TRISC		; (TRISC) <-- 0h
			MOVLW 0xFF		; CONFIGURA PUERTO D COMO ENTRADA
			MOVWF TRISD		; (TRISD) <-- FFh
			MOVLW 0xFF		; CONFIGURA PUERTO E COMO ENTRADA
			MOVWF TRISE		; (TRISE) <-- FFh
			MOVLW 0x07
			MOVWF ADCON1 ;ADCON1 <- 0x07, configura puerto A y E como entradas digitales
			MOVLW 0x00	
			MOVWF TRISA	 ;TRISA <- 0x00, configura puerto A como salida 
			BCF STATUS,5 ;Regresamos al banco 0
			CALL INICIA_LCD
			MOVLW 0x80
			CALL COMANDO
			
LOOP_P:		MOVF PORTE,W	;W<-- (PORTE)
			ANDLW 7			;W <-- W&00000111
			ADDWF PCL,F		;(PCL)<-- (PCL)+W
			GOTO NOMBRES	;PC+0	-> Switches: 000
			GOTO DECIMAL	;PC+1	-> Switches: 001	Conversi�n entrada dipswitch de 8 bits a decimal
			GOTO HEXADECIMAL;PC+2	-> Switches: 010	Conversi�n entrada dipswitch de 8 bits a hexadecimal
			GOTO BINARIO	;PC+3	-> Switches: 011	Conversi�n entrada dipswitch de 8 bits a binario
			GOTO CARACTER	;PC+4	-> Switches: 100	
			GOTO DEFAULT	;PC+5	-> Switches: 101
			GOTO DEFAULT	;PC+6 -> Switches: 110
			GOTO DEFAULT	;PC+7 -> -> Switches: 111
			
NOMBRES:	MOVLW a'P'
			CALL DATOS
			MOVLW a'A'
			CALL DATOS
			MOVLW a'M'
			CALL DATOS
			MOVLW a'E'
			CALL DATOS
			MOVLW a'L'
			CALL DATOS
			MOVLW a'A'
			CALL DATOS
			MOVLW 0x20	;Espacio en blanco
			CALL DATOS
			MOVLW a'C'
			CALL DATOS
			MOVLW a'A'
			CALL DATOS
			MOVLW a'S'
			CALL DATOS
			MOVLW a'T'
			CALL DATOS
			MOVLW a'I'
			CALL DATOS
			MOVLW a'L'
			CALL DATOS
			MOVLW a'L'
			CALL DATOS
			MOVLW a'O'
			CALL DATOS
			;SEGUNDO INTEGRANTE
			MOVLW 0xC0		;Valor para hacer salto de linea, inicio linea 2
			CALL COMANDO
			MOVLW a'C'
			CALL DATOS
			MOVLW a'A'
			CALL DATOS
			MOVLW a'R'
			CALL DATOS
			MOVLW a'L'
			CALL DATOS
			MOVLW a'O'
			CALL DATOS
			MOVLW a'S'
			CALL DATOS
			MOVLW 0x20	;Espacio en blanco
			CALL DATOS
			MOVLW a'C'
			CALL DATOS		
			MOVLW a'A'
			CALL DATOS
			MOVLW a'S'
			CALL DATOS
			MOVLW a'T'
			CALL DATOS
			MOVLW a'E'
			CALL DATOS
			MOVLW a'L'
			CALL DATOS
			MOVLW a'A'
			CALL DATOS
			MOVLW a'N'
			CALL DATOS
			MOVLW 0x01		;Limpia Display
			CALL COMANDO
			;TERCER INTEGRANTE
			MOVLW 0x80		;regresa a inicio linea 1
			CALL COMANDO
			MOVLW a'R'
			CALL DATOS
			MOVLW a'O'
			CALL DATOS
			MOVLW a'G'
			CALL DATOS
			MOVLW a'E'
			CALL DATOS
			MOVLW a'L'
			CALL DATOS
			MOVLW a'I'
			CALL DATOS
			MOVLW a'O'
			CALL DATOS
			;MOVLW 0x20	;Espacio en blanco
			;MOVWF PORTB
			;CALL DATOS
			MOVLW a'H'
			CALL DATOS
			MOVLW a'E'
			CALL DATOS
			MOVLW a'R'
			CALL DATOS
			MOVLW a'N'
			CALL DATOS
			MOVLW a'A'
			CALL DATOS
			MOVLW a'N'
			CALL DATOS
			MOVLW a'D'
			CALL DATOS
			MOVLW a'E'
			CALL DATOS
			MOVLW a'Z'
			CALL DATOS
			MOVLW 0x01		;Limpia Display
			CALL COMANDO
			MOVLW 0x80		;regresa a inicio linea 1
			CALL COMANDO
			GOTO LOOP_P

DECIMAL:	CLRF contadorCentesima		;Inicializa en 0
			CLRF contadorDecima			;Inicializa en 0
			CLRF contadorUnidad			;Inicializa en 0
			MOVLW a'D'
			CALL DATOS
			MOVLW 0x3A		;Dos puntos
			CALL DATOS
			MOVF PORTD,W	;Leer el valor de los switches y lo almacena en aux
			MOVWF aux	
	
LOOP_Centesimas:MOVLW 0x64				;Restar 100
				SUBWF aux
				BTFSC STATUS,C			;Verifica el estado de carry
				GOTO CentesimaEncontrada	;SI hay carry, el resultado es un n�mero positivo				
				MOVLW 0x64
				ADDWF aux 					;NO hay carry, entonces recuperar residuo
LOOP_Decimas:	MOVLW 0x0A
				SUBWF aux				;Restar 10
				BTFSC STATUS,C			;Verifica el estado de carry
				GOTO DecimaEncontrada		;SI hay carry, el resultado es un n�mero positivo
				MOVLW 0x0A
				ADDWF aux 					;NO hay carry, entonces recuperar residuo = Unidades
				MOVF aux,w
				MOVWF contadorUnidad	;Guardar en contador

MostrarDigitos:	MOVF contadorCentesima,W	
				ADDLW 0x30					;Obtener valor ASCII
				CALL DATOS					;Display Centesimas
				MOVF contadorDecima,W		
				ADDLW 0x30					;Obtener valor ASCII
				CALL DATOS					;Display Decimas
				MOVF contadorUnidad,W		
				ADDLW 0x30					;Obtener valor ASCII
				CALL DATOS					;Display Unidades

HOLD_DECIMAL:	MOVF PORTE,W
				SUBLW 0x01 		;W<--W-0x10
				BTFSC STATUS,Z  	;�(CONTA)=0X10?
				GOTO HOLD_DECIMAL 		;SI			
				MOVLW 0x01				;NO, Limpia Display
				CALL COMANDO
				MOVLW 0x80			;regresa a inicio linea 1
				CALL COMANDO
				CLRF W
				GOTO LOOP_P	

CentesimaEncontrada:INCF contadorCentesima
					GOTO LOOP_Centesimas

DecimaEncontrada:	INCF contadorDecima	
					GOTO LOOP_Decimas

HEXADECIMAL:MOVLW a'H'
			CALL DATOS
			MOVLW 0x3A		;Dos puntos
			CALL DATOS
			CLRF W
			MOVF PORTD,W
			MOVWF regaux2
			MOVF regaux2,W	;restauramos el valor guardado por si acaso sufriese algun cambio
			ANDLW 0xF0		;extraemos la parte alta
			MOVWF regaux	;regaux <- W
			RRF regaux,f
			RRF regaux,f
			RRF regaux,f
			RRF regaux,f	;convertida en parte baja
			CALL CONVERHEXA
			MOVF regaux2,W	;restauramos el valor guardado por si acaso sufriese algun cambio
			ANDLW 0x0F		;extraemos la parte BAJA
			MOVWF regaux	;regaux <- W
			CALL CONVERHEXA
HOLD_HEX:	MOVF PORTE,W		;FUNCION PARA RETENER EL RESULTADO EN LCD
			SUBLW 0x02 ;  W<--W-0x30
			BTFSC STATUS,Z  ;�(CONTA)=0X20?
			GOTO HOLD_HEX	;SI			
			MOVLW 0x01		;NO, Limpia Display
			CALL COMANDO
			MOVLW 0x80		;regresa a inicio linea 1
			CALL COMANDO
			CLRF W
			GOTO LOOP_P	
CONVERHEXA:	MOVF regaux,W	; W<- (regaux)
			;ANDLW 15			;W <-- W&00001111, el cuarto bit siempre est� activo para las letras
			ADDWF PCL,F		;(PCL)<-- (PCL)+W
			GOTO CASO0		;PC+0	Caso 0000: Numero 0
			GOTO CASO1		;PC+1	Caso 0001: Numero 1
			GOTO CASO2		;PC+2	Caso 0010: Numero 2
			GOTO CASO3		;PC+3	Caso 0011: Numero 3
			GOTO CASO4		;PC+4	Caso 0100: Numero 4
			GOTO CASO5		;PC+5	Caso 0101: Numero 5
			GOTO CASO6		;PC+6	Caso 0110: Numero 6
			GOTO CASO7		;PC+7 	Caso 0111: Numero 7
			GOTO CASO8		;PC+8	Caso 1000: Numero 8
			GOTO CASO9		;PC+9	Caso 1001: Numero 9
			GOTO CASOA		;PC+10	Caso 1010: Letra A 
			GOTO CASOB		;PC+11	Caso 1011: Letra B 
			GOTO CASOC		;PC+12	Caso 1100: Letra C 
			GOTO CASOD		;PC+13	Caso 1101: Letra D 
			GOTO CASOE		;PC+14	Caso 1110: Letra E 
			GOTO CASOF		;PC+15	Caso 1111: Letra F 
CASO0:		MOVLW a'0'
			GOTO CONVEND
CASO1:		MOVLW a'1'
			GOTO CONVEND
CASO2:		MOVLW a'2'
			GOTO CONVEND
CASO3:		MOVLW a'3'
			GOTO CONVEND
CASO4:		MOVLW a'4'
			GOTO CONVEND
CASO5:		MOVLW a'5'
			GOTO CONVEND
CASO6:		MOVLW a'6'
			GOTO CONVEND
CASO7:		MOVLW a'7'
			GOTO CONVEND
CASO8:		MOVLW a'8'
			GOTO CONVEND
CASO9:		MOVLW a'9'
			GOTO CONVEND
CASOA:		MOVLW a'A'
			GOTO CONVEND
CASOB:		MOVLW a'B'
			GOTO CONVEND
CASOC:		MOVLW a'C'
			GOTO CONVEND
CASOD:		MOVLW a'D'
			GOTO CONVEND
CASOE:		MOVLW a'E'
			GOTO CONVEND
CASOF:		MOVLW a'F'
			GOTO CONVEND

CONVEND:	CALL DATOS		; Imprimimos el simbolo en el LCD
			CLRF W
			RETURN

BINARIO:	MOVLW a'B'
			CALL DATOS
			MOVLW 0x3A		;Dos puntos
			CALL DATOS
			BTFSC PORTD,7
			CALL ES_UNO
			BTFSS PORTD,7
			CALL ES_CERO
			BTFSC PORTD,6
			CALL ES_UNO
			BTFSS PORTD,6
			CALL ES_CERO
			BTFSC PORTD,5
			CALL ES_UNO
			BTFSS PORTD,5
			CALL ES_CERO
			BTFSC PORTD,4
			CALL ES_UNO
			BTFSS PORTD,4
			CALL ES_CERO
			BTFSC PORTD,3
			CALL ES_UNO
			BTFSS PORTD,3
			CALL ES_CERO
			BTFSC PORTD,2
			CALL ES_UNO
			BTFSS PORTD,2
			CALL ES_CERO
			BTFSC PORTD,1
			CALL ES_UNO
			BTFSS PORTD,1
			CALL ES_CERO
			BTFSC PORTD,0
			CALL ES_UNO
			BTFSS PORTD,0
			CALL ES_CERO
HOLD_BIN:	MOVF PORTE,W
			SUBLW 0x03 ;  W<--W-0x30
			BTFSC STATUS,Z  ;�(CONTA)=0X30?
			GOTO HOLD_BIN ;SI			
			MOVLW 0x01		;Limpia Display
			CALL COMANDO
			MOVLW 0x80		;regresa a inicio linea 1
			CALL COMANDO
			CLRF W
			GOTO LOOP_P		
ES_UNO:		MOVLW a'1'
			CALL DATOS
			RETURN
ES_CERO		MOVLW a'0'
			CALL DATOS
			RETURN

CARACTER:	MOVLW 0X40 ;ALMACENAR CARACTERES EN CGRAM
			CALL COMANDO
			CALL RET100MS

			;CUADRO 0 - ALMACENANDO - FANTASMA
			MOVLW b'00100'
			CALL DATOS
			MOVLW b'01110'
			CALL DATOS
			MOVLW b'11111'
			CALL DATOS
			MOVLW b'10101'
			CALL DATOS
			MOVLW b'11111'
			CALL DATOS
			MOVLW b'11111'
			CALL DATOS
			MOVLW b'11111'
			CALL DATOS
			MOVLW b'10101'
			CALL DATOS

			;CUADRO 1 - ALMACENANDO - SONRISA
			MOVLW b'00000'
			CALL DATOS
			MOVLW b'11011'
			CALL DATOS
			MOVLW b'11011'
			CALL DATOS
			MOVLW b'00000'
			CALL DATOS
			MOVLW b'10001'
			CALL DATOS
			MOVLW b'11111'
			CALL DATOS
			MOVLW b'01110'
			CALL DATOS
			MOVLW b'00000'
			CALL DATOS

			
			;COLOCA EN PRIMERA LINEA DEL DISPLAY
			MOVLW 0X80
			CALL COMANDO
			CALL RET100MS

			;IMPRESION DE CARACTER
			MOVLW 0X00 ;CUADRO 0 - FANTASMA
			CALL DATOS 
			MOVLW 0X01
			CALL DATOS ;CUADRO 1 - SONRISA

HOLD_CAR:	MOVF PORTE,W
			SUBLW 0x04 ;  W<--W-0x40
			BTFSC STATUS,Z  ;�(CONTA)=0X40?
			GOTO HOLD_CAR ;SI			
			MOVLW 0x01		;Limpia Display
			CALL COMANDO
			MOVLW 0x80		;regresa a inicio linea 1
			CALL COMANDO
			CLRF W
			GOTO LOOP_P	

DEFAULT: 	GOTO LOOP_P		;Caso por defecto, no hace nada, retorna al loop para evaluar los bits de control

INICIA_LCD:	MOVLW 0x30
			CALL COMANDO
			CALL RET100MS
			MOVLW 0x30
			CALL COMANDO
			CALL RET100MS
			MOVLW 0x38
			CALL COMANDO
			MOVLW 0x0C
			CALL COMANDO
			MOVLW 0x01
			CALL COMANDO
			MOVLW 0x06
			CALL COMANDO
			MOVLW 0x02
			CALL COMANDO
			RETURN
COMANDO:	MOVWF PORTB
			CALL RET200
			BCF PORTA,0
			BSF	PORTA,1
			CALL RET200
			BCF PORTA,1
			RETURN
DATOS:		MOVWF PORTB
			CALL RET200
			BSF PORTA,0
			BSF	PORTA,1
			CALL RET200
			BCF PORTA,1
			CALL RET200
			CALL RET200
			RETURN
RET200:		MOVLW 0xAA
			MOVWF valor1
LOOP:		MOVLW d'164'
			MOVWF valor
LOOP1:		DECFSZ valor,1
			GOTO LOOP1
			DECFSZ valor1,1
			GOTO LOOP
			RETURN
RET100MS:	MOVLW 0x03
			MOVWF valor
TRES:		MOVLW 0xFF
			MOVWF valor1
DOS:		MOVLW 0xFF
			MOVWF valor2
UNO:		DECFSZ valor2
			GOTO UNO
			DECFSZ valor1
			GOTO DOS
			DECFSZ valor
			GOTO TRES
			RETURN
			END			
		
