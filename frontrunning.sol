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
                                                                             SOLVE("ETHEREUM") GAS 15 GWEI BOB ( Se ejecutan por cantidad de gas, cómo más gas antes se ejecuta)
¿Qué ha pasado?
Las transacciones tardan algún tiempo en ser minadas.
Las transacciones que aún no se han extraído se colocan en el grupo de transacciones.
Las transacciones con un precio de gas más alto suelen realizarse primero.
Un atacante puede obtener la respuesta del grupo de transacciones y enviar una transacción
con un mayor precio del gas por lo que su transacción se incluirá en un bloque antes del original.
*/

contract FindThisHash {
    bytes32 public constant hash =
        0x564ccaf7594d66b1eaaea24fe01f0585bf52ee70852af4eac0cc4b04711cd0e2;

    constructor() payable {}

    function solve(string memory solution) public {
        require(hash == keccak256(abi.encodePacked(solution)), "Incorrect answer");

        (bool sent, ) = msg.sender.call{value: 10 ether}("");
        require(sent, "Failed to send Ether");
    }
}

// CÓMO EVITARLO?
// USANDO FLASHBOTS 
// Guía para el uso de Flashbots
// https://docs.flashbots.net/flashbots-protect/quick-start









