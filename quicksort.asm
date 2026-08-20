# Algoritmo Quicksort en MIPS32

.data
    array:  .word 35, 10, 28, 5, 42, 15, 18
    longitud:   .word 7

.text
.globl main

main:
    la   $a0, array      # direccion base del arreglo
    li   $a1, 0          # low = 0
    lw   $a2, longitud
    addi $a2, $a2, -1    # high = longitud - 1
    
    jal  quicksort

#-------- IMPRIMIR EL ARREGLO ORDENADO EN CONSOLA --------
    la   $s0, array      # direccion base
    lw   $s1, longitud       # cantidad de elementos
    li   $t0, 0          # i = 0

recorrido_print:
    beq  $t0, $s1, exit_program

    sll  $t1, $t0, 2
    add  $t1, $s0, $t1
    lw   $a0, 0($t1)     # cargar elemento
    li   $v0, 1          # syscall 1: imprimir entero
    syscall

    li   $a0, 32         # caracter espacio (' ')
    li   $v0, 11         # syscall 11: imprimir caracter
    syscall

    addi $t0, $t0, 1     # i++
    j    recorrido_print

exit_program:
    li   $v0, 10         # syscall 10: salir del programa
    syscall

quicksort:
    #reservar 12 bytes en la pila
    subu $sp, $sp, 12
    sw   $ra, 8($sp)
    sw   $a1, 4($sp)     # guardar low
    sw   $a2, 0($sp)     # guardar high

    slt  $t0, $a1, $a2   # low < high ?
    beq  $t0, $zero, qs_end

    # particionar el arreglo
    jal  particion
    # $v0 contiene el índice del pivote (pi)

    # ordenar la mitad izquierda: quicksort(arr, low, pi - 1)
    lw   $a1, 4($sp)     # recuperar low original
    addi $a2, $v0, -1    # high = pi - 1
    jal  quicksort

    # ordenar la mitad derecha: quicksort(arr, pi + 1, high)
    addi $a1, $v0, 1     # low = pi + 1
    lw   $a2, 0($sp)     # recuperar high original
    jal  quicksort

qs_end:
    #restaurar registros y liberar pila
    lw   $ra, 8($sp)
    lw   $a1, 4($sp)
    lw   $a2, 0($sp)
    addu $sp, $sp, 12
    jr   $ra

particion:
    #preservar $s0 en la pila (convencion de registros guardados)
    subu $sp, $sp, 4
    sw   $s0, 0($sp)

    #tomar el elemento final como pivote
    sll  $t0, $a2, 2     # Offset del pivote (high * 4)
    add  $t0, $a0, $t0
    lw   $s0, 0($t0)     # $s0 = pivot = arr[high]

    addi $t1, $a1, -1    # i = low - 1
    move $t2, $a1        # j = low

particion_recorrido:
    slt  $t3, $t2, $a2   # j < high ?
    beq  $t3, $zero, particion_end

    sll  $t4, $t2, 2     # Offset de j
    add  $t4, $a0, $t4
    lw   $t5, 0($t4)     # $t5 = arr[j]

    slt  $t6, $t5, $s0   # arr[j] < pivot 
    beq  $t6, $zero, particion_continue

    addi $t1, $t1, 1     # i++
    sll  $t7, $t1, 2     # Offset de i
    add  $t7, $a0, $t7
    lw   $t8, 0($t7)     # intercambiar arr[i] y arr[j] mediante $t8 y $t9
    lw   $t9, 0($t4)
    sw   $t9, 0($t7)
    sw   $t8, 0($t4)

particion_continue:
    addi $t2, $t2, 1     # j++
    j    particion_recorrido

particion_end:
    addi $t1, $t1, 1     # posicion final del pivote
    sll  $t7, $t1, 2
    add  $t7, $a0, $t7
    lw   $t8, 0($t7)     # colocar el pivote en su posicion correcta
    sll  $t4, $a2, 2
    add  $t4, $a0, $t4
    lw   $t9, 0($t4)
    sw   $t9, 0($t7)
    sw   $t8, 0($t4)

    move $v0, $t1        # retornar el indice del pivote ($v0 = pi)

    #restaurar $s0 desde la pila
    lw   $s0, 0($sp)
    addu $sp, $sp, 4
    jr   $ra
