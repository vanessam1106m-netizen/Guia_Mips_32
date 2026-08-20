.data
    num:     .asciiz "Ingrese un numero entero positivo: "
    resultado:  .asciiz "El resultado de la paridad iterativa es: "

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
    jal paridad_iterativa
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
# FUNCIÓN ITERATIVA: paridad(n)
# =============================================================

paridad_iterativa:

    li $v0, 0               
    move $t0, $zero 
    #$t0 = i       

bucle_iterativo:
    # CONDICIÓN DE PARADA: Si i == n, salimos del bucle
    beq $t0, $a0, fin_iterativa 
    
    # APLICAR FÓRMULA EN CADA PASO: paridad = 1 - paridad
    # Si paridad ($v0) era 0, pasa a ser 1. Si era 1, pasa a ser 0.
    li $t1, 1
    sub $v0, $t1, $v0       # $v0 = 1 - $v0
    
    # INCREMENTAR EL CONTADOR: i = i + 1
    addi $t0, $t0, 1        
    
    # Repetir el ciclo
    j bucle_iterativo

fin_iterativa:
    jr $ra                  # Retornar al programa principal (main) con el resultado en $v0
