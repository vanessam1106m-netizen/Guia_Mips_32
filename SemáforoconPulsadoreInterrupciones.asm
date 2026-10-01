# Práctica de Laboratorio 4 - Ejercicio 2: Semáforo con Pulsador e Interrupciones

.eqv KEYBOARD_CONTROL 0xFFFF0000
.eqv KEYBOARD_DATA    0xFFFF0004

.data
str_verde:    .asciiz "\nSemáforo en verde, esperando pulsador ('s')...\n"
str_pulsado:  .asciiz "\nPulsador activado: en 20 segundos, el semáforo cambiará a amarillo"
str_amarillo: .asciiz "\nSemáforo en amarillo, en 10 segundos, semáforo en rojo"
str_rojo:     .asciiz "\nSemáforo en rojo, en 30 segundos, semáforo en verde"

.globl flag_pulsador
flag_pulsador: .word 0        # 1 cuando se presiona la 's'

.text
.globl main

main:
    # 1. Habilitar Interrupciones en el Teclado MMIO (Bit 1 = 1)
    li   $t0, KEYBOARD_CONTROL
    li   $t1, 2
    sw   $t1, 0($t0)

    # 2. Habilitar Interrupciones en el Procesador (CP0 Status Register $12)
    mfc0 $t0, $12
    ori  $t0, $t0, 0x0001      
    ori  $t0, $t0, 0x0800    
    mtc0 $t0, $12

ciclo_semaforo:
    # ESTADO 1: VERDE
    li   $v0, 4
    la   $a0, str_verde
    syscall

    # Resetear bandera del pulsador
    la   $t0, flag_pulsador
    sw   $zero, 0($t0)

esperar_s:
    # Bucle asíncrono esperando a que la ISR cambie flag_pulsador a 1
    la   $t0, flag_pulsador
    lw   $t1, 0($t0)
    beq  $t1, $zero, esperar_s

    # ESTADO 2: PULSADO (Aviso -> Esperar 20s)
    li   $v0, 4
    la   $a0, str_pulsado
    syscall

    li   $a0, 20000            # Retardo de 20 segundos
    jal  temporizar_asincrono

    # ESTADO 3: AMARILLO (Aviso -> Esperar 10s)
    li   $v0, 4
    la   $a0, str_amarillo
    syscall

    li   $a0, 10000            # Retardo de 10 segundos
    jal  temporizar_asincrono

    # ESTADO 4: ROJO (Aviso -> Esperar 30s)
    li   $v0, 4
    la   $a0, str_rojo
    syscall

    li   $a0, 30000            # Retardo de 30 segundos
    jal  temporizar_asincrono

    j    ciclo_semaforo        # Repetir ciclo

# Subrutina de temporización asíncrona
temporizar_asincrono:
    li   $t8, 0
    sll  $t9, $a0, 4           # Ajuste de escala de ciclos
loop_temp:
    addi $t8, $t8, 1
    blt  $t8, $t9, loop_temp
    jr   $ra

# =========================================================================
# RUTINA DE SERVICIO A INTERRUPCIÓN (ISR) - ATENCIÓN AL PULSADOR 's'
# =========================================================================
.ktext 0x80000180
isr_teclado_semaforo:
    .kdata
    k_at: .word 0
    k_v0: .word 0
    k_t0: .word 0
    k_t1: .word 0
    .ktext

    # Guardar contexto en memoria del Kernel
    sw   $at, k_at
    sw   $v0, k_v0
    sw   $t0, k_t0
    sw   $t1, k_t1

    # Leer tecla capturada en el teclado MMIO
    li   $t0, KEYBOARD_DATA
    lw   $t1, 0($t0)           # $t1 = Carácter presionado

    # Verificar si es la tecla 's' (ASCII 115)
    li   $t0, 115
    bne  $t1, $t0, fin_isr_sem

    # Activar la bandera del pulsador
    li   $t0, 1
    la   $t1, flag_pulsador
    sw   $t0, 0($t1)

fin_isr_sem:
    # Restaurar contexto
    lw   $at, k_at
    lw   $v0, k_v0
    lw   $t0, k_t0
    lw   $t1, k_t1

    eret                       # Retorno de la excepción/interrupción
