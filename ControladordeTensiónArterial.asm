# Práctica de Laboratorio 3 - Ejercicio 2: Controlador de Tensión Arterial

.eqv TENSION_CONTROL 0xFFFF0010   # Registro de control
.eqv TENSION_ESTADO  0xFFFF0014   # Registro de estado (0: midiendo, 1: listo)
.eqv TENSION_SISTOL  0xFFFF0018   # Registro de resultado Sistólico
.eqv TENSION_DIASTOL 0xFFFF001C   # Registro de resultado Diastólico

.text
.globl controlador_tension

# Procedimiento: controlador_tension
# Inicia la medición de tensión arterial, espera a que finalice y retorna:
#   $v0 = Tensión Sistólica
#   $v1 = Tensión Diastólica
controlador_tension:
    # 1. Iniciar la medición escribiendo 1 en TensionControl
    li   $t0, TENSION_CONTROL   # Cargar dirección de TensionControl
    li   $t1, 1                 
    sw   $t1, 0($t0)            

    # 2. Esperar de forma activa (polling) a que TensionEstado sea 1
    li   $t0, TENSION_ESTADO    # Cargar dirección de TensionEstado

esperar_medicion:
    lw   $t2, 0($t0)            # Leer TensionEstado
    beq  $t2, $zero, esperar_medicion # Mientras sea 0 (midiendo), seguir esperando

    # 3. Leer los resultados de los registros mapeados en memoria
    li   $t0, TENSION_SISTOL
    lw   $v0, 0($t0)            # $v0 = Tensión Sistólica

    li   $t0, TENSION_DIASTOL
    lw   $v1, 0($t0)            # $v1 = Tensión Diastólica

    jr   $ra                    # Retornar al programa principal
