# Algoritmo Mergesort en MIPS32

.data
    array:  .word 50, 20, 10, 40, 30, 5
    longitud:   .word 6
    aux:    .space 24  # espacio auxiliar para la fase de mezcla (merge)

.text
.globl main

main:
    la   $a0, array      # direccion base del arreglo
    li   $a1, 0          # left = 0
    lw   $a2, longitud
    addi $a2, $a2, -1    # right = longitud - 1
    
    jal  mergesort

    # --- IMPRIMIR EL ARREGLO ORDENADO ---
    la   $s0, array      # direccion base
    lw   $s1, longitud       # cantidad de elementos
    li   $t0, 0          # indice i = 0

recorrido_print:
    beq  $t0, $s1, exit_program

    sll  $t1, $t0, 2
    add  $t1, $s0, $t1
    lw   $a0, 0($t1)     # cargar elemento
    li   $v0, 1          # syscall 1: imprimir entero
    syscall

    li   $a0, 32         # imprimir espacio entre numeros
    li   $v0, 11         # syscall 11: imprimir caracter
    syscall

    addi $t0, $t0, 1     # i++
    j    recorrido_print

exit_program:
    li   $v0, 10         # syscall 10: salir del programa
    syscall
    
mergesort:
    subu $sp, $sp, 16
    sw   $ra, 12($sp)
    sw   $a1, 8($sp)     # left
    sw   $a2, 4($sp)     # right

    slt  $t0, $a1, $a2   # left < right ?
    beq  $t0, $zero, ms_end

    # encontrar el punto medio: mid = (left + right) / 2
    add  $t1, $a1, $a2
    sra  $t2, $t1, 1     # $t2 = mid

    # mergesort (arr, left, mid)
    sw   $t2, 0($sp)     # guardar mid temporalmente
    # $a1 se mantiene en left
    move $a2, $t2        # right = mid
    jal  mergesort

    # mergesort (arr, mid + 1, right)
    lw   $a1, 0($sp)     # recuperar mid
    addi $a1, $a1, 1     # left = mid + 1
    lw   $a2, 4($sp)     # recuperar right original
    jal  mergesort

    # mezclar ambas mitades: merge(arr, left, mid, right)
    lw   $a1, 8($sp)     # left original
    lw   $t2, 0($sp)     # mid
    lw   $a2, 4($sp)     # right original
    move $a3, $t2        # pasar mid en $a3
    jal  merge

ms_end:
    lw   $ra, 12($sp)
    addu $sp, $sp, 16
    jr   $ra

merge:
    # mezcla de subarreglos ordenados
    # $a0 = arr, $a1 = left, $a2 = right, $a3 = mid
    la   $t8, aux        # cargar direccion base del arreglo auxiliar

    # inicializar indices
    move $t0, $a1        # i = left
    addi $t1, $a3, 1     # j = mid + 1
    move $t2, $a1        # k = left

merge_recorrido:
    # Si i > mid o j > right, salir del bucle
    bgt  $t0, $a3, copy_j  
    bgt  $t1, $a2, copy_i  

    # cargar arr[i]
    sll  $t3, $t0, 2
    add  $t3, $a0, $t3
    lw   $t4, 0($t3)     # $t4 = arr[i]

    # cargar arr[j]
    sll  $t5, $t1, 2
    add  $t5, $a0, $t5
    lw   $t6, 0($t5)     # $t6 = arr[j]

    # comparar: arr[i] > arr[j]
    bgt  $t4, $t6, derecha_j 

izquierda_i:
    sll  $t7, $t2, 2
    add  $t7, $t8, $t7
    sw   $t4, 0($t7)     # aux[k] = arr[i]
    addi $t0, $t0, 1     # i++
    j    merge_siguiente

derecha_j:
    sll  $t7, $t2, 2
    add  $t7, $t8, $t7
    sw   $t6, 0($t7)     # aux[k] = arr[j]
    addi $t1, $t1, 1     # j++

merge_siguiente:
    addi $t2, $t2, 1     # k++
    j    merge_recorrido

copy_i:
    bgt  $t0, $a3, preparacion
    sll  $t3, $t0, 2
    add  $t3, $a0, $t3
    lw   $t4, 0($t3)
    sll  $t7, $t2, 2
    add  $t7, $t8, $t7
    sw   $t4, 0($t7)
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j    copy_i

copy_j:
    bgt  $t1, $a2, preparacion
    sll  $t5, $t1, 2
    add  $t5, $a0, $t5
    lw   $t6, 0($t5)
    sll  $t7, $t2, 2
    add  $t7, $t8, $t7
    sw   $t6, 0($t7)
    addi $t1, $t1, 1
    addi $t2, $t2, 1
    j    copy_j

preparacion:
    move $t2, $a1        # k = left

copy_end:
    # volcar datos ordenados de aux a array
    bgt  $t2, $a2, merge_end  
    
    sll  $t7, $t2, 2
    add  $t7, $t8, $t7
    lw   $t4, 0($t7)     # $t4 = aux[k]

    sll  $t3, $t2, 2
    add  $t3, $a0, $t3
    sw   $t4, 0($t3)     # arr[k] = aux[k]

    addi $t2, $t2, 1     # k++
    j    copy_end

merge_end:
    jr   $ra
