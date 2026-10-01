# Práctica 4 - Ejercicio 1: Buffer Circular con Interrupciones de Teclado y Reloj

.eqv DIRECCION_CONTROL 0xFFFF0000
.eqv DIRECCION_DATA    0xFFFF0004 

.data
buffer:     .space 100         # Buffer circular de 100 bytes
msg_flush:  .asciiz "\n\n--- Vaciando Buffer (20s transcurridos) ---\n"

# Variables globales compartidas con la ISR
.globl head
.globl tail
.globl timer_flag
head:       .word 0
tail:       .word 0
timer_flag: .word 0            # Se pone a 1 cuando pasan los 20 segundos

.text
.globl main

main:
    # 1. Habilitar Interrupción en el Periférico (Teclado)
    li   $t0, DIRECCION_CONTROL
    li   $t1, 2                # Bit 1 = Interrupt Enable (IE)
    sw   $t1, 0($t0)

    # 2. Habilitar Interrupciones en el Procesador (CP0 Status Register)
    mfc0 $t0, $12             
    ori  $t0, $t0, 0x0001      
    ori  $t0, $t0, 0x0800      
    mtc0 $t0, $12           

loop_principal:
    # Bucle principal: Esperar de forma asíncrona a que expiren los 20s
    la   $t0, timer_flag
    lw   $t1, 0($t0)
    beq  $t1, $zero, esperar_tiempo

    # Transcurridos los 20s: Imprimir buffer
    li   $v0, 4
    la   $a0, msg_flush
    syscall

    jal  imprimir_y_vaciar_buffer

    # Reiniciar bandera de tiempo
    la   $t0, timer_flag
    sw   $zero, 0($t0)

esperar_tiempo:
    # Simulación de retardo de reloj para los 20 segundos
    addi $s7, $s7, 1
    li   $t8, 300000           # Ajuste de tiempo equivalente
    blt  $s7, $t8, loop_principal

    # Al expirar tiempo, activar bandera
    li   $t1, 1
    la   $t0, timer_flag
    sw   $t1, 0($t0)
    li   $s7, 0
    j    loop_principal

imprimir_y_vaciar_buffer:
    la   $s0, buffer
    la   $t0, head
    la   $t1, tail
    lw   $s1, 0($t0)           # head
    lw   $s2, 0($t1)           # tail

imprimir_loop:
    beq  $s1, $s2, fin_impresion # Buffer vacío

    add  $t7, $s0, $s2
    lb   $a0, 0($t7)           # Cargar carácter

    li   $v0, 11               # Imprimir char
    syscall

    addi $s2, $s2, 1
    rem  $s2, $s2, 100         # Incrementar tail circular
    j    imprimir_loop

fin_impresion:
    # Resetear índices
    la   $t0, head
    la   $t1, tail
    sw   $zero, 0($t0)
    sw   $zero, 0($t1)
    jr   $ra

# =========================================================================
# RUTINA DE SERVICIO A INTERRUPCIÓN (ISR) - SEGMENTO DEL KERNEL
# =========================================================================
.ktext 0x80000180
isr_teclado:
    # Guardar contexto de registros en el espacio del Kernel
    .kdata
    k_at: .word 0
    k_v0: .word 0
    k_a0: .word 0
    k_t0: .word 0
    k_t1: .word 0
    .ktext
    
    sw   $at, k_at
    sw   $v0, k_v0
    sw   $a0, k_a0
    sw   $t0, k_t0
    sw   $t1, k_t1

    # Leer carácter ingresado en el teclado MMIO
    li   $t0, DIRECCION_DATA
    lw   $t1, 0($t0)           # $t1 = Carácter capturado

    # Filtrar Mayúsculas ('A' = 65 a 'Z' = 90)
    blt  $t1, 65, fin_isr      # Si char < 'A', descartar
    bgt  $t1, 90, fin_isr      # Si char > 'Z', descartar

    # Guardar carácter en el buffer circular
    la   $t0, head
    lw   $v0, 0($t0)           # $v0 = head actual
    la   $a0, buffer
    add  $a0, $a0, $v0        # Dirección = buffer + head
    sb   $t1, 0($a0)           # Guardar char

    # Actualizar head
    addi $v0, $v0, 1
    rem  $v0, $v0, 100         # head = (head + 1) % 100
    sw   $v0, 0($t0)

fin_isr:
    # Restaurar contexto
    lw   $at, k_at
    lw   $v0, k_v0
    lw   $a0, k_a0
    lw   $t0, k_t0
    lw   $t1, k_t1

    eret                       # Retornar de la interrupción
