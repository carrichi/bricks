title "Proyecto: Bricks" ;codigo opcional. Descripcion breve del programa, el texto entrecomillado se imprime como cabecera en cada página de código
	.model small	;directiva de modelo de memoria, small => 64KB para memoria de programa y 64KB para memoria de datos
	.386			;directiva para indicar version del procesador
	.stack 64 		;Define el tamano del segmento de stack, se mide en bytes
	.data			;Definicion del segmento de datos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Definición de constantes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Valor ASCII de caracteres para el marco del programa
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqInfDer 		equ 	188d	;'╝'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqSupIzq 		equ 	201d 	;'╔'
marcoCruceVerSup	equ		203d	;'╦'
marcoCruceHorDer	equ 	185d 	;'╣'
marcoCruceVerInf	equ		202d	;'╩'
marcoCruceHorIzq	equ 	204d 	;'╠'
marcoCruce 			equ		206d	;'╬'
marcoHor 			equ 	205d 	;'═'
marcoVer 			equ 	186d 	;'║'
;Atributos de color de BIOS
;Valores de color para carácter
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ		0A0h
bgCyanClaro		equ		0B0h
bgRojoClaro		equ		0C0h
bgMagentaClaro	equ		0D0h
bgAmarillo 		equ		0E0h
bgBlanco 		equ		0F0h
;Valores para delimitar el área de juego
lim_superior 	equ		1
lim_inferior 	equ		23
lim_izquierdo 	equ		1
lim_derecho 	equ		30
;Valores de referencia para la posición inicial del jugador y la bola
ini_columna 	equ 	lim_derecho/2
ini_renglon 	equ 	22

;Valores para la posición de los controles e indicadores dentro del juego
;Lives
lives_col 		equ  	lim_derecho+7
lives_ren 		equ  	4

;Scores
hiscore_ren	 	equ 	11
hiscore_col 	equ 	lim_derecho+7
score_ren	 	equ 	13
score_col 		equ 	lim_derecho+7

;Botón STOP
stop_col 		equ 	lim_derecho+15
stop_ren 		equ 	18
stop_izq 		equ 	stop_col
stop_der 		equ 	stop_col+2
stop_sup 		equ 	stop_ren
stop_inf 		equ 	stop_ren+2
stopKeyStr_col	equ		22
stopKeyStr_ren	equ		44

;Botón PAUSE
pause_col 		equ 	lim_derecho+25
pause_ren 		equ 	18
pause_izq 		equ 	pause_col
pause_der 		equ 	pause_col+2
pause_sup 		equ 	pause_ren
pause_inf 		equ 	pause_ren+2
pauseKeyStr_col	equ		22
pauseKeyStr_ren	equ		53

;Botón PLAY
play_col 		equ 	lim_derecho+35
play_ren 		equ 	18
play_izq 		equ 	play_col
play_der 		equ 	play_col+2
play_sup 		equ 	play_ren
play_inf 		equ 	play_col+2
playKeyStr_col	equ		22
playKeyStr_ren	equ		63

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;////////////////////////////////////////////////////
;Definición de variables
;////////////////////////////////////////////////////
titulo 			db 		"BRICKS"
scoreStr 		db 		"SCORE"
hiscoreStr		db 		"HI-SCORE"
livesStr		db 		"LIVES"
blank			db 		"     "
playKeyStr		db		"[ENTER]"
pauseKeyStr		db		"[SPACE]"
stopKeyStr		db		"[ESC]"
player_lives 	db 		3
player_score 	dw 		0
player_hiscore 	dw 		0
player_col		db 		ini_columna
player_ren		db 		ini_renglon

col_aux 		db 		0
ren_aux 		db 		0

conta 			db 		0
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;1000 auxiliar para operación DIV entre 1000
diez 			dw 		10 		;10 auxiliar para operaciones
sesenta			db 		60 		;60 auxiliar para operaciones
status 			db 		0 		;0 stop, 1 play, 2 pause
ticks 			dw		0 		;Variable para almacenar el número de ticks del sistema y usarlo como referencia

brick_color 	db 		0
mapa_bricks 	db 		3,2,1,3,2,1,'#',2,1,3,2,1,3,'#',1,3,2,1,3,2,'#',3,2,1,3,2,1,'#',2,1,3,2,1,3,'%' 
;el número indica el "nivel" del brick, el carácter '#' indica el fin del renglón
;el carácter '%' indica el fin del mapa
;Bola
bola_col		db 		ini_columna 	 	;columna de la bola
bola_ren		db 		ini_renglon-1 		;renglón de la bola
bola_pend 		db 		1 		;pendiente de desplazamiento de la bola
bola_rap 		dw 		2 		;rapidez de la bola
bola_dir		db 		1 		;dirección de la bola. 0 izquierda-abajo, 1 derecha-abajo, 2 izquierda-arriba, 3 derecha-arriba
bola_status		db		0	; 0 N0 puede moverse, 1 SI puede moverse.

;Variables que sirven de parámetros de entrada para el procedimiento IMPRIME_BOTON
boton_caracter 	db 		0
boton_renglon 	db 		0
boton_columna 	db 		0
boton_color		db 		0
boton_bg_color	db 		0


;Auxiliar para calculo de coordenadas del mouse
ocho			db 		8
;Cuando el driver del mouse no está disponible
no_mouse		db 	'No se encuentra driver de mouse. Presione [enter] para salir$'

;////////////////////////////////////////////////////

;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;Macros;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h		;llama interrupcion 10h con opcion 00h. 
				;Establece modo de video limpiando pantalla
endm

;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 

;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas utilizando interrupción 10h
endm

;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;posiciona_cursor_mouse - Establece la posición inicial del cursor del mouse
posiciona_cursor_mouse	macro columna,renglon
	mov dx,renglon
	mov cx,columna
	mov ax,4		;opcion 0004h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;apaga_cursor_parpadeo - Deshabilita el parpadeo del cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
;Los colores disponibles están en la lista a continuacion;
; Colores:
; 0h: Negro
; 1h: Azul
; 2h: Verde
; 3h: Cyan
; 4h: Rojo
; 5h: Magenta
; 6h: Cafe
; 7h: Gris Claro
; 8h: Gris Oscuro
; 9h: Azul Claro
; Ah: Verde Claro
; Bh: Cyan Claro
; Ch: Rojo Claro
; Dh: Magenta Claro
; Eh: Amarillo
; Fh: Blanco
; utiliza int 10h opcion 09h
; 'caracter' - caracter que se va a imprimir
; 'color' - color que tomará el caracter
; 'bg_color' - color de fondo para el carácter en la celda
; Cuando se define el color del carácter, éste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter
imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;AL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'caracter', 'color' y 'bg_color'. 
; utiliza int 10h opcion 09h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm
 

;lee_teclado - Lee el buffer.
;AH = 10h
;Devuelve:
;AH = BIOS scan code
;AL = ASCII character

lee_teclado	macro	;para entradas del teclado 
	mov ah,10h 	
	int 16h		;interrupcion 16h (maneja la entrada del teclado)
endm

;clear_buffer - Limpia el buffer a través de la opción 0C de AH.
clear_buffer macro
	mov ah, 0Ch
	int 21h
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm

;get_player_position - Obtiene la posicion central del jugador
get_player_position		macro
	mov al,[player_col]
	mov ah,[player_ren]
	mov [col_aux],al
	mov [ren_aux],ah
endm

;get_ball_position - Obtiene la posicion de la bola
get_ball_position	macro
	mov ah, [bola_col]
	mov al, [bola_ren]
	mov [col_aux], ah
	mov [ren_aux], al
endm

cambiar_color_boton macro char, fondo, renglon, columna
	mov [boton_caracter], char
	mov [boton_color], fondo
	mov [boton_renglon], renglon
	mov [boton_columna], columna
	call IMPRIME_BOTON
endm
;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;Fin Macros;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

	.code
inicio:					;etiqueta inicio
	inicializa_ds_es
	comprueba_mouse		;macro para revisar driver de mouse
	xor ax,0FFFFh		;compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz imprime_ui		;Si existe el driver del mouse, entonces salta a 'imprime_ui'
	;Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]
	mov ax,0900h	;opcion 9 para interrupcion 21h
	int 21h			;interrupcion 21h. Imprime cadena.
	jmp salir_teclado		;Solicitara [enter] para terminar la ejecucion.
imprime_ui:
	clear 					;limpia pantalla
	oculta_cursor_teclado	;oculta cursor del mouse
	apaga_cursor_parpadeo 	;Deshabilita parpadeo del cursor
	call DIBUJA_UI 			;procedimiento que dibuja marco de la interfaz
	muestra_cursor_mouse 	;hace visible el cursor del mouse

;En "mouse_no_clic" se revisa que el boton izquierdo del mouse no esté presionado
;Si el botón está suelto, continúa a la sección "mouse"
;si no, se mantiene indefinidamente en "mouse_no_clic" hasta que se suelte
mouse_no_clic:
	lee_mouse
	test bx,0001h
	jnz mouse_no_clic
;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
conversion_mouse:

	;IMPLEMENTACION PARA LIMITAR EL TECLADO AL CAMPO DE JUEGO
	cmp cx,248
	jg continuacion
	posiciona_cursor_mouse 249,dx

continuacion:
	;Leer la posicion del mouse y hacer la conversion a resolucion
	;80x25 (columnas x renglones) en modo texto
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)

	;Aquí se revisa si se hizo clic en el botón izquierdo
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Si el mouse fue presionado en el renglon 0
	;se va a revisar si fue dentro del boton [X]
	cmp dx,0
	je boton_x ;Da el salto si el click fue en el renglon 0.

	;Se revisa si el click fue en el renglon 19 (reglon de los botones STOP, PAUSE y START)
	cmp dx, 18
	jge mas_botones ;Da el salto si el click fue en un reglon mayor o igual a 18.

	;Si no se dieron saltos, significa que no ocurrio ningun click.
	
	jmp mouse_no_clic ;Si no se dieron saltos, se determinara que no se dio ningun click.

;;;;;;;;;;;
; BOTON X ;
;;;;;;;;;;;
; SE DIO CLICK EN EL RENGLON 0
boton_x:
	jmp boton_x1
;Lógica para revisar si el mouse fue presionado en [X]
;[X] se encuentra en renglon 0 y entre columnas 76 y 78
boton_x1:
	cmp cx,76
	jge boton_x2
	jmp mouse_no_clic
boton_x2:
	cmp cx,78
	jbe boton_x3
	jmp mouse_no_clic
boton_x3:
	;Se cumplieron todas las condiciones
	jmp salir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Lógica para el resto de botones;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mas_botones:
	; Si llego aqui es porque se presiono en el renglon 19 o mayor.
	; Ahora se verifica si el cursor estaba en el 21 o menor.
	cmp dx, 21
	jbe mas_botones1 ;Da el salto si el click fue en un reglon menor o igual a 21.
	jmp mouse_no_clic

mas_botones1:
	; Si llego aqui es porque esta ente el renglon 19 y 21.
	; Se verifica si el cursor estaba dentro de algun boton,
	; se comienza por el boton PLAY.
	jmp boton_play

;;;;;;;;;;;;;
; BOTON PLAY
;;;;;;;;;;;;;
boton_play:
	; Si la posicion del cursor es mayor o igual a play_izq salta a la siguiente condicion.
	cmp cx, play_izq
	jge boton_play1
	; Si no se dio el salto, se verifica si esta en el el boton PAUSE.
	jmp boton_pause
boton_play1:
	cmp cx, play_der
	jbe boton_play2
	; Si no se dio el salto, el cursor NO esta dentro de PLAY.
	jmp mouse_no_clic
boton_play2:
	;Ya se encuentra dentro de cualquier parte del boton PLAY.
	mov [status], 1
	;Se implementa el procedimiento de inicio del juego.
	clear_buffer
	; Se indica que el boton fue presionado
	cambiar_color_boton 16d, bgCyanClaro, play_ren, play_col
	; Se 'desactivan' los otros dos botones
	cambiar_color_boton 19d, bgAmarillo, pause_ren, pause_col
	cambiar_color_boton 254d, bgAmarillo, stop_ren, stop_col

	; COMIENZA A MOVERSE LA BOLITA
	mov [bola_status], 0
	mov [bola_dir], 3 ;La primer direccion que tomara sera 3 derecha-arriba
	jmp can_play

teclado_no_click:
	jmp listen_teclado ; Al comienzo del juego, se pone a la espera de instrucciones.

can_play:
	cmp [status], 1
	je play
	jmp mouse_no_clic

play:
	jmp listen_teclado
continue:
	call BALL_CAN_MOVE
	cmp [bola_status], 1
	je move_ball_accepted
	jmp boton_stop2
move_ball_accepted:
	call MOVE_BALL

listen_teclado:
	lee_teclado
	cmp al, 6Ah		;compara la entrada de teclado si fue [j]
	je mover_izquierda
	cmp al, 6Bh		;compara la entrada de teclado si fue [k]
	je mover_derecha
	cmp al, 20h		;compara la entrada de teclado si fue [space]
	je boton_pause2
	cmp al, 1Bh		;compara la entrada de teclado si fue [esc]
	je boton_stop2
	cmp al, 0Dh		;compara la entrada de teclado si fue [enter]
	je boton_play2
	jmp listen_teclado

; En el caso que se presione la flecha izquierda, el jugador se mueve a la izquierda.
mover_derecha:
	; Si no dio el salto, llego al limite de la zona de juego
	get_player_position
	cmp [col_aux],27
	jbe mover_derecha_aceptado
	jmp continue

mover_derecha_aceptado:
	; Se verifica si se encuentra en los limites de la zona de juego.
	call BORRA_JUGADOR
	inc [player_col]	
	call IMPRIME_JUGADOR
	jmp continue

; En el caso que se presione la flecha izquierda, el jugador se mueve a la izquierda.
mover_izquierda:
	; Se realizará el movimiento si esta dentro del rango de juego.
	get_player_position
	cmp [col_aux], 4
	jge mover_izquierda_aceptado
	jmp continue

mover_izquierda_aceptado:
	call BORRA_JUGADOR
	dec [player_col]
	call IMPRIME_JUGADOR
	jmp continue

;;;;;;;;;;;;;;;
; BOTON PAUSE
;;;;;;;;;;;;;;;
boton_pause:
	cmp cx, pause_izq
	jge boton_pause1
	; Si no se dio el salto, se vefitica si esta en el boton STOP.
	jmp boton_stop
boton_pause1:
	cmp cx, pause_der
	jbe boton_pause2
	; Si no se dio el salto, el cursor NO esta dentro de PAUSE.
	jmp mouse_no_clic
boton_pause2:
	;Ya se encuentra dentro de cualquier parte del boton.
	mov [status], 2
	clear_buffer
	; Se cambia el color del boton de PLAY para indicar que se desactivo.
	cambiar_color_boton 16d, bgAmarillo, play_ren, play_col
	; Se cambia el color del boton PAUSE para indicar que se desactivo.
	cambiar_color_boton 254d, bgAmarillo, stop_ren, stop_col
	; Se cambia el color del boton PAUSE para indicar que se activo.
	cambiar_color_boton 19d, bgCyanClaro, pause_ren, pause_col
	jmp can_play

;;;;;;;;;;;;;;;
; BOTON STOP
;;;;;;;;;;;;;;;
boton_stop:
	cmp cx, stop_izq
	jge boton_stop1
	; Si no se dio el salto, el cursor no esta sobre ningun boton.
	jmp mouse_no_clic
boton_stop1:
	cmp cx, stop_der
	jbe boton_stop2
	; Si no se dio el salto, el cursor no esta sobre ningun boton.
	jmp mouse_no_clic
boton_stop2:
	;Ya se encuentra dentro de cualquier parte del boton.
	mov [status], 0
	;Limpia el buffer para que el jugador ya no pueda moverse.
	clear_buffer
	; Se cambia el color del boton de PLAY para indicar que se desactivo.
	cambiar_color_boton 16d, bgAmarillo, play_ren, play_col
	; Se cambia el color del boton PAUSE para indicar que se activo.
	cambiar_color_boton 19d, bgAmarillo, pause_ren, pause_col
	; Se cambia el color del boton STOP para indicar que se activo.
	cambiar_color_boton 254d, bgCyanClaro, stop_ren, stop_col
	;Se reacomoda al jugador en su posicion inicial.
	;Se reacomoda al jugador en su posicion inicial.
	call BORRA_JUGADOR
	mov al, ini_columna
	mov ah, ini_renglon
	mov [player_col], al
	mov [player_ren], ah
	call IMPRIME_JUGADOR
	;Se reacomoda la bola a su posicion inicial.
	;      Por implementar....
	call BORRA_BOLA
	mov al, ini_columna
	mov ah, ini_renglon-1
	mov [bola_col], al
	mov [bola_ren], ah
	call IMPRIME_BOLA
	;Coloca los ladrillos en su posicion inicial.
	call IMPRIME_BRICKS
	jmp mouse_no_clic

;;;;;;;;;;;;;;;;;;;;;;;
; Etiquetas de SALIDA ;
;;;;;;;;;;;;;;;;;;;;;;;

;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
salir_teclado:
	mov ah,08h
	int 21h
	cmp al,0Dh		;compara la entrada de teclado si fue [enter]
	jnz salir_teclado 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:				;inicia etiqueta salir
	clear 			;limpia pantalla
	mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code, código devuelto al finalizar el programa
	int 21h			;señal 21h de interrupción, pasa el control al sistema operativo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;PROCEDIMIENTOS;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	DIBUJA_UI proc
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color marcoEsqSupIzq,cAmarillo,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color marcoEsqSupDer,cAmarillo,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cAmarillo,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cAmarillo,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh 
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro
		
		mov cl,[col_aux]
		loop marcos_horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
	marcos_verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Inferior
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cAmarillo,bgNegro
		;Limite mouse
		posiciona_cursor [ren_aux],lim_derecho+1
		imprime_caracter_color marcoVer,cAmarillo,bgNegro

		mov cl,[ren_aux]
		loop marcos_verticales

		;imprimir marcos horizontales internos
		mov cx,79-lim_derecho-1 		
	marcos_horizontales_internos:
		push cx
		mov [col_aux],cl
		add [col_aux],lim_derecho
		;Interno superior 
		posiciona_cursor 8,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro

		;Interno inferior
		posiciona_cursor 16,[col_aux]
		imprime_caracter_color marcoHor,cAmarillo,bgNegro

		mov cl,[col_aux]
		pop cx
		loop marcos_horizontales_internos

		;imprime intersecciones internas	
		posiciona_cursor 0,lim_derecho+1
		imprime_caracter_color marcoCruceVerSup,cAmarillo,bgNegro
		posiciona_cursor 24,lim_derecho+1
		imprime_caracter_color marcoCruceVerInf,cAmarillo,bgNegro

		posiciona_cursor 8,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
		posiciona_cursor 8,79
		imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

		posiciona_cursor 16,lim_derecho+1
		imprime_caracter_color marcoCruceHorIzq,cAmarillo,bgNegro
		posiciona_cursor 16,79
		imprime_caracter_color marcoCruceHorDer,cAmarillo,bgNegro

		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cAmarillo,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cAmarillo,bgNegro

		;imprimir título
		posiciona_cursor 0,37
		imprime_cadena_color [titulo],6,cAmarillo,bgNegro

		call IMPRIME_TEXTOS

		call IMPRIME_BOTONES

		call IMPRIME_BRICKS

		call IMPRIME_DATOS_INICIALES

		call IMPRIME_SCORES

		call IMPRIME_LIVES

		ret
	endp

	IMPRIME_TEXTOS proc
		;Imprime cadena "LIVES"
		posiciona_cursor lives_ren,lives_col
		imprime_cadena_color livesStr,5,cGrisClaro,bgNegro

		;Imprime cadena "SCORE"
		posiciona_cursor score_ren,score_col
		imprime_cadena_color scoreStr,5,cGrisClaro,bgNegro

		;Imprime cadena "HI-SCORE"
		posiciona_cursor hiscore_ren,hiscore_col
		imprime_cadena_color hiscoreStr,8,cGrisClaro,bgNegro

		;Imprime cadena "[ESC]"
		posiciona_cursor stopKeyStr_col, stopKeyStr_ren 
		imprime_cadena_color stopKeyStr,5,cGrisClaro,bgNegro
		
		;Imprime cadena "[SPACE]"
		posiciona_cursor pauseKeyStr_col, pauseKeyStr_ren
		imprime_cadena_color pauseKeyStr,7,cGrisClaro,bgNegro

		;Imprime cadena "[ENTER]"
		posiciona_cursor playKeyStr_col, playKeyStr_ren
		imprime_cadena_color playKeyStr,7,cGrisClaro,bgNegro

		ret
	endp

	IMPRIME_BOTONES proc
		;Botón STOP
		mov [boton_caracter],254d		;Carácter '■'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],stop_ren 	;Renglón en "stop_ren"
		mov [boton_columna],stop_col 	;Columna en "stop_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		;Botón PAUSE
		mov [boton_caracter],19d 		;Carácter '‼'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],pause_ren 	;Renglón en "pause_ren"
		mov [boton_columna],pause_col 	;Columna en "pause_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		;Botón PLAY
		mov [boton_caracter],16d  		;Carácter '►'
		mov [boton_color],bgAmarillo 	;Background amarillo
		mov [boton_renglon],play_ren 	;Renglón en "play_ren"
		mov [boton_columna],play_col 	;Columna en "play_col"
		call IMPRIME_BOTON 				;Procedimiento para imprimir el botón
		ret
	endp

	IMPRIME_SCORES proc
		;Imprime el valor de la variable player_score en una posición definida
		call IMPRIME_SCORE
		;Imprime el valor de la variable player_hiscore en una posición definida
		call IMPRIME_HISCORE
		ret
	endp

	IMPRIME_SCORE proc
		;Imprime "player_score" en la posición relativa a 'score_ren' y 'score_col'
		mov [ren_aux],score_ren
		mov [col_aux],score_col+20
		mov bx,[player_score]
		call IMPRIME_BX
		ret
	endp

	IMPRIME_HISCORE proc
	;Imprime "player_score" en la posición relativa a 'hiscore_ren' y 'hiscore_col'
		mov [ren_aux],hiscore_ren
		mov [col_aux],hiscore_col+20
		mov bx,[player_hiscore]
		call IMPRIME_BX
		ret
	endp

	;BORRA_SCORES borra los marcadores numéricos de pantalla sustituyendo la cadena de números por espacios
	BORRA_SCORES proc
		call BORRA_SCORE
		call BORRA_HISCORE
		ret
	endp

	BORRA_SCORE proc
		;Implementar
		ret
	endp

	BORRA_HISCORE proc
		;Implementar
		ret
	endp

	;Imprime el valor del registro BX como entero sin signo (positivo)
	;Se imprime con 5 dígitos (incluyendo ceros a la izquierda)
	;Se usan divisiones entre 10 para obtener dígito por dígito en un LOOP 5 veces (una por cada dígito)
	IMPRIME_BX proc
		mov ax,bx
		mov cx,5
	div10:
		xor dx,dx
		div [diez]
		push dx
		loop div10
		mov cx,5
	imprime_digito:
		mov [conta],cl
		posiciona_cursor [ren_aux],[col_aux]
		pop dx
		or dl,30h
		imprime_caracter_color dl,cBlanco,bgNegro
		xor ch,ch
		mov cl,[conta]
		inc [col_aux]
		loop imprime_digito
		ret
	endp

	IMPRIME_DATOS_INICIALES proc
		call DATOS_INICIALES 		;inicializa variables de juego
		;imprime la barra del jugador
		;borra la posición actual, luego se reinicializa la posición y entonces se vuelve a imprimir
		call BORRA_JUGADOR
		mov [player_col], ini_columna
		mov [player_ren], ini_renglon
		call IMPRIME_JUGADOR

		;imprime bola
		;borra la posición actual, luego se reinicializa la posición y entonces se vuelve a imprimir
		call BORRA_BOLA
		mov [bola_col], ini_columna
		mov [bola_ren], ini_renglon-1
		call IMPRIME_BOLA

		ret
	endp

	;Inicializa variables del juego
	DATOS_INICIALES proc
		mov [player_score],0
		mov [player_lives],3
		ret
	endp

	;Imprime los caracteres ☻ que representan vidas. Inicialmente se imprime el número de 'player_lives'
	IMPRIME_LIVES proc
		xor cx,cx
		mov di,lives_col+20
		mov cl,[player_lives]
	imprime_live:
		push cx
		mov ax,di
		posiciona_cursor lives_ren,al
		imprime_caracter_color 2d,cCyanClaro,bgNegro
		add di,2
		pop cx
		loop imprime_live
		ret
	endp

	;Imprime la barra del jugador, que recibe como parámetros las variables ren_aux y col_aux, que indican la posición central de la barra
	;imprime el carácter '' en la posición indicada, 2 renglones hacia arriba y 2 hacia abajo
	PRINT_PLAYER proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cBlanco,bgNegro
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cBlanco,bgNegro
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cBlanco,bgNegro
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cBlanco,bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cBlanco,bgNegro
		ret
	endp

	;Imprime un brick, que recibe como parámetros las variables ren_aux, col_aux y color_brick, que indican la posición superior izquierda del brick y su color
	PRINT_BRICK proc
		mov ah,[col_aux]
		mov al,[ren_aux]
		push ax
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,[brick_color],bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,[brick_color],bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,[brick_color],bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,[brick_color],bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,[brick_color],bgNegro
		pop ax
		mov [ren_aux],al
		mov [col_aux],ah
		ret
	endp

	;Imprime la bola de juego, que recibe como parámetros las variables bola_col y bola_ren, que indican la posición de la bola
	IMPRIME_BOLA proc
		get_ball_position
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 2d,cCyanClaro,bgNegro 
		ret
	endp

	;Borra la bola de juego, que recibe como parámetros las variables bola_col y bola_ren, que indican la posición de la bola
	BORRA_BOLA proc
		get_ball_position
		posiciona_cursor [ren_aux], [col_aux]
		imprime_caracter_color 2d,cNegro,bgNegro 
		ret
	endp

	;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 5 columnas
	;con un caracter centrado dentro del boton
	;en la posición que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;boton_caracter: debe contener el caracter que va a mostrar el boton
	;boton_renglon: contiene la posicion del renglon en donde inicia el boton
	;boton_columna: contiene la posicion de la columna en donde inicia el boton
	;boton_color: contiene el color del boton
	IMPRIME_BOTON proc
	 	;background de botón
		mov ax,0600h 		;AH=06h (scroll up window) AL=00h (borrar)
		mov bh,cRojo	 	;Caracteres en color amarillo
		xor bh,[boton_color]
		mov ch,[boton_renglon]
		mov cl,[boton_columna]
		mov dh,ch
		add dh,2
		mov dl,cl
		add dl,2
		int 10h
		mov [col_aux],dl
		mov [ren_aux],dh
		dec [col_aux]
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [boton_caracter],cRojo,[boton_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador
	
	BORRA_JUGADOR proc
		get_player_position
		
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cNegro,bgNegro
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cNegro,bgNegro
		dec [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cNegro,bgNegro
		add [col_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cNegro,bgNegro
		inc [col_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 223,cNegro,bgNegro
		ret
	endp

	IMPRIME_JUGADOR proc
		mov al,[player_col]
		mov ah,[player_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call PRINT_PLAYER
		ret
	endp

	IMPRIME_BRICKS proc
		mov [col_aux],1
		mov [ren_aux],2
		mov di,0
		mapa_sig_columna:
			mov bl,[mapa_bricks+di]
			cmp bl,3
			je mapa_brick_n3
			cmp bl,2
			je mapa_brick_n2
			cmp bl,1
			je mapa_brick_n1
			cmp bl,'#'
			je mapa_fin_renglon
			cmp bl,'%'
			je mapa_fin
		mapa_brick_n3:
			mov [brick_color],cAzul
			jmp mapa_imprime_brick
		mapa_brick_n2:
			mov [brick_color],cVerde
			jmp mapa_imprime_brick
		mapa_brick_n1:
			mov [brick_color],cRojo
		mapa_imprime_brick:
			call PRINT_BRICK
			add [col_aux],5
			inc di
			jmp mapa_sig_columna		
		mapa_fin_renglon:
			add [ren_aux],2
			mov [col_aux],1
			inc di
			jmp mapa_sig_columna
		mapa_fin:
		ret
	endp

	BALL_CAN_MOVE proc
		get_ball_position
		cmp ah, 1
		jge ball_can_move1 ; Si salta, es que se no sobrepasa el limite izquierdo del juego.
		mov [bola_status], 0
		ret
		ball_can_move1:
			cmp ah, 29
			jbe ball_can_move2 ;Si salta, es que la bola no sobrepasa el limite derecho.
			mov [bola_status], 0
			ret
		ball_can_move2:
			cmp al, 1
			jge ball_can_move3 ;Si salta, es que la bola no sobrepasa el limite superior.
			mov [bola_status], 0
			ret
		ball_can_move3:
			cmp al, 25
			jbe can_move
			mov [bola_status], 0 ;Si salta, es que la bola no sobrepasa el limite inferior.
			ret
		can_move:
			mov [bola_status], 1
		ret
	endp

	MOVE_BALL proc
		call BORRA_BOLA
		mov bl, [bola_dir]
		cmp bl, 0
		je mov_izq_abj
		cmp bl, 1
		je mov_der_abj
		cmp bl, 2
		je mov_izq_arr
		cmp bl, 3
		je mov_der_arr
		mov_izq_arr:
			dec [bola_col]
			dec [bola_ren]
			call IMPRIME_BOLA
			ret
		mov_der_arr:
			inc [bola_col]
			dec [bola_ren]
			call IMPRIME_BOLA
			ret
		mov_izq_abj:
			dec [bola_col]
			inc [bola_ren]
			call IMPRIME_BOLA
			ret
		mov_der_abj:
			inc [bola_col]
			inc [bola_ren]
			call IMPRIME_BOLA
			ret
		error:
	endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;FIN PROCEDIMIENTOS;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end inicio			;fin de etiqueta inicio, fin de programa
