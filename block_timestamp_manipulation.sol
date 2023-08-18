// Manipulacion del TIMESTAMP del bloque // Block Timestamp Manipulation
VULNERABILIDAD
/* block.timestamp puede ser manipulado por mineros con las siguientes restricciones:

1- NO se puede estampar con un tiempo anterior a su padre
2- NO puede estar demasiado lejos en el futuro

EJERCICIO DE EJEMPLO: 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
EJEMPLO DE RULETA: Ruleta es un juego que puedes ganar todos los Ether en el contrato, si puedes ejecutar una transacción a un tiempo especifico.
CONDICIÓN : SI el usuario envia 10 Ether, si el block.timestamp % 15 == 0.
*/

/*
1. Deploy Roulette with 10 Ether
2. Eve runs a powerful miner that can manipulate the block timestamp.
3. Eve sets the block.timestamp to a number in the future that is divisible by
   15 and finds the target block hash.
4. Eve's block is successfully included into the chain, Eve wins the
   Roulette game.
*/

contract Roulette {
    uint public pastBlockTime;

    constructor() payable {}

    function spin() external payable {
        require(msg.value == 10 ether); // must send 10 ether to play
        require(block.timestamp != pastBlockTime); // only 1 transaction per block

        pastBlockTime = block.timestamp;

        if (block.timestamp % 15 == 0) {
            (bool sent, ) = msg.sender.call{value: address(this).balance}("");
            require(sent, "Failed to send Ether");
        }
    }
}

// TÉCNICAS PREVENTIVAS
1- NUNCA usar block.timestamp cómo creación de número aleatorio o relacionado.
