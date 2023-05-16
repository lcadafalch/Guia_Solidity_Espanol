# solidity_attacks
Analisys of multiples sources of attacking in Solidity ,( Smart contracts) and how can stop it,
Useful reccomendation is to use always OPENZEPPELIN  and AUDIT always before deploying anything :)
https://www.openzeppelin.com/


Review Certik / Slowmist , etc..

## Reentrancy attack o ataque de reentrada.
Partimos de la base de que hay dos contratos, un contrato A, y otro contrato B
Y en este funcionamiento A llama al contrato B para ejecutar una función, entonces en reentrancy Attack consiste en volver a ejecutar el contrato antes de que acabe el contrato completo
 
 Pongamnos un ejemplo, tenemos una contrato llamado SacarEthereum.

 1.Depositamos un ethereum en el contrato
 
 ```solidity
 function deposit() public payable {
        balances[msg.sender] += msg.value
 ```
Lo que pasa por detrás es que se ejecuta la función attack antes de que se ejecute la función withdraw
con lo cuál cuando uno deposita, primero de ejecuta
 ```solidity
 function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }
    ```
Con lo cuál de deposita el ethereum y seguidamente se envia al contrato de EtherStore, se deposita , se ejecuta la función withdraw del contrato de Etherstore , y seguidamente la función fallback del contrato del atacante y así seguidamente un bucle que deposita todos los Ethers de dentro del contrato a la cuenta del atacante

 ```solidity
    // Fallback se llama cuando alguien envía Ethereum al contrato
    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }
    ```
Cómo podemos evitarlo?
Evitando copiar código de desconocidos / usar siempre que podamos el código de Openzeppelin
* Usando Modificadores para evitar la reenetrada de contratos. 
* Ver que cambios pasa antes de que se acabe el contrato

Ejemplo de código para evitar los ataques de reentrada:
 ```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}
En este caso usaríamos el modifier cada vez que se ejecuta una función crítica.
Pero para mí seguiría el consejo de usar Openzeppelin que tiene una función específica para este tipo de contratos.
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

    

