# Práctica de Laboratorio 3 - Ejercicio 1: Sensor de Luminosidad

.eqv LUZ_CONTROL 0xFFFF0000   # Registro de control del sensor
.eqv LUZ_ESTADO  0xFFFF0004   # Registro de estado del sensor
.eqv LUZ_DATOS   0xFFFF0008   # Registro de datos de luminosidad

.text
.globl InicializarSensorLuz
.globl LeerLuminosidad

# Procedimiento: InicializarSensorLuz
InicializarSensorLuz:
    li   $t0, LUZ_CONTROL       # Cargar dirección de LuzControl
    li   $t1, 1                 # Comando de inicialización (0x1)
    sw   $t1, 0($t0)            # Escribir 0x1 en LuzControl

    li   $t0, LUZ_ESTADO        # Cargar dirección de LuzEstado

esperar_listo:
    lw   $t2, 0($t0)            # Leer estado actual
    
    beq  $t2, $zero, esperar_listo # Si estado == 0, sigue midiendo/esperando
    
    # Si sale del bucle, el estado cambió a 1 (listo) o -1 (error)
    jr   $ra

# Procedimiento: LeerLuminosidad
# Devuelve en $v0 el valor de luminosidad o el dato leído.
# Devuelve en $v1 el código de estado: 0 = Lectura correcta, -1 = Error.
LeerLuminosidad:
    li   $t0, LUZ_ESTADO
    lw   $t2, 0($t0)            # Leer estado actual
    
    li   $t3, 1
    bne  $t2, $t3, error_lectura # Si estado != 1, ir a error
    
    # Lectura Correcta
    li   $t0, LUZ_DATOS         # Cargar dirección de datos
    lw   $v0, 0($t0)            # $v0 = Valor de luminosidad (0 a 1023)
    move $v1, $zero             # $v1 = 0 (Estado correcto)
    jr   $ra

error_lectura:
    li   $v0, -1                # Valor nulo por error
    li   $v1, -1                # $v1 = -1 (Código de error)
    jr   $ra
