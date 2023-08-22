// INVERSIÓN VENTAJISTA O FRONTRUNNING

// VULNERABILIDAD

/* Las transacciones tardan algún tiempo en extraerse. 
Un atacante puede observar el grupo de transacciones y enviar una transacción, 
incluirla en un bloque antes de la transacción original. Se puede abusar de este mecanismo para reordenar las transacciones en beneficio del atacante.
*/

// SPDX-License-Identifier: MIT
/* EJEMPLO PRÁCTICO :
Alice crea un juego de adivinar
Ganas 10 ether si puedes encontrar la string correcta que hasheada concida con el hash.
Veamos cómo este contrato es vulnerable al FRONRUNNING.

EJECUCIÓN POR PARTES:
1. Alice implementa FindThisHash con 10 Ether.
2. Bob encuentra la cadena correcta que generará el hash objetivo. ("Ethereum").
3. Bob llama a la función solve("Ethereum") con el precio del gas fijado en 15 gwei.
4. Eve está observando el grupo de transacciones hasta que se envíe la respuesta.
5. Eve ve la respuesta de Bob y llama a solve("Ethereum") con un precio de gas más alto que Bob (100 gwei).
6. La transacción de Eve se realizó antes que la transacción de Bob.

PORQUE ( GasBOB < GasEVE) con lo cuál en la mempool --->     TRANSACCIÓN --> SOLVE("ETHEREUM") GAS 100 GWEI EVE
                                                                             SOLVE("ETHEREUM") GAS 15 GWEI BOB ( Se ejecutan por cantidad de gas, cómo más gas antes se ejeecuta)
¿Qué ha pasado?












