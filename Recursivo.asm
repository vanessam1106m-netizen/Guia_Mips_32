.data
    num:     .asciiz "Ingrese un numero entero positivo: "
    resultado:  .asciiz "El resultado de la paridad recursiva es: "
    
.text
.globl main

# =============================================================
# PROGRAMA PRINCIPAL (Para probar la función)
# =============================================================
main:
    li $v0, 4
    la $a0, num
    syscall

    li $v0, 5
    syscall
    move $s0, $v0       

    move $a0, $s0      
    jal paridad_recursiva
    move $s1, $v0      
    
    li $v0, 4
    la $a0, resultado
    syscall

    li $v0, 1
    move $a0, $s1
    syscall

    li $v0, 10
    syscall


# =============================================================
# FUNCIÓN RECURSIVA: paridad(n)
# =============================================================

paridad_recursiva:
    # ---------------------------------------------------------
    # CASO BASE: Si n == 0, la paridad es 0.
    # ---------------------------------------------------------
    bne $a0, $zero, paso_recursivo 
    li $v0, 0                      
    jr $ra                         

    # ---------------------------------------------------------
    # PASO RECURSIVO: Si n > 0, calculamos: 1 - paridad(n - 1)
    # ---------------------------------------------------------
paso_recursivo:
   
    addi $sp, $sp, -8      
    sw $ra, 4($sp)          
    sw $a0, 0($sp)         

    # PREPARAR LA LLAMADA RECURSIVA: paridad(n - 1)
    addi $a0, $a0, -1      
    jal paridad_recursiva   
    
    # RETORNO DE LA RECURSIÓN (Restaurar el estado anterior)
    lw $a0, 0($sp)          
    lw $ra, 4($sp)          
    addi $sp, $sp, 8        

    # APLICAR LA FÓRMULA: 1 - paridad(n - 1)
 
    li $t0, 1
    sub $v0, $t0, $v0       

    jr $ra                  # Volvemos al nivel anterior (o al main si terminamos)
