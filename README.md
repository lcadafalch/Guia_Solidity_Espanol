 # solidity_attacks // Ataques en solidity
 
Analisys of multiples sources of attacking in Solidity ,( Smart contracts) and how can stop it,
Useful reccomendation is to use always **OPENZEPPELIN**  and **AUDIT** always before deploying anything :)


Análisis de múltiples fuentes de ataque en Solidity (contratos inteligentes) y cómo detenerlo.
Una recomendación útil es usar siempre **OPENZEPPELIN** y **AUDIT** siempre antes de implementar cualquier cosa :)
https://www.openzeppelin.com/


Review Certik / Slowmist , etc..

## Reentrancy attack o ataque de reentrada.
Partimos de la base de que hay dos contratos, un contrato A, y otro contrato B
Y en este funcionamiento A llama al contrato B para ejecutar una función, entonces en reentrancy Attack consiste en volver a ejecutar el contrato antes de que acabe el contrato completo.

En pocas palabras, consiste en crear un bucle entre las funciones de withdraw del contrato de Etherstore y atacante , y la función fallback, de manera que  se vaya ejecutando en forma de bucle, para sacar todos los Ethers del contrato, sin dejar acabar de ejecutar la función principal, con lo cuál tienes una función que no termina de ejecutarse withdraw() que va enviando ethers al contrato elegido , en forma de bucle.

El problema es en el momento que se hace el update del Balance.
 
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

```
En este caso usaríamos el modifier cada vez que se ejecuta una función crítica.
Pero para mí seguiría el consejo de usar Openzeppelin que tiene una función específica para este tipo de contratos.
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

## Aritmetic Overflow y Underflow

Esta forma de hackear contratos consiste en aprovecharse del máximo y el mínimo que cabe en un UINT.
un UINT es una palabra reservada donde se guardan enteros de 32 bits, que tiene un mínimo y un máximo ,una vez el número sobrepase este varemo, vuelve al valor de 0.
Ejemplo: Ponemos que el máximo de un uint de ejemplo es 7, si en algun momento esta variable tubiera el valor de 8, pasaría automáticamente a 1.
De esta manera podemos ejecutar código malicioso y modificar un smart contract, ( Hay que decir que a partir de la versión de solidity 0.8 , se ha modificado para que no suceda

## Selfdestruct

La función selfdestruct se ejecuta cuando se quiere acabar con el contrato y que no de más uso.
En cuanto a vulnerabilidad podemos forzar la ejecución de el selfdestruct() y con la activación de este, se envían los Ethers restantes a la cuenta que se elija.
En el código donde hay el posible hackeo nos encontramos con que forzándolo se puede ejecutar antes la función selfdestruct() antes que la winner()

con lo cuál la selfdestruct envia Ethers a la cuenta seleccionada, con lo que nunca se debe poner que el self destruct envíe en msg.sender, sinó que envíe a cuenta que esté gestionada por el propietario del smart contract.
```solidity
    function attack() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // cast address to payable
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
```
## Accessing Private Data
En este caso estamos delante de que la información de la blockchain es totalmente pública aunque tenga variables privadas ( solo sirven para que no se accedan desde contratos externos)

Se puede ver fácilmente con librerias de javascript cómo web3js o etherjs, ya que la info es totalmente pública
En este código se puede ver la forma de sacar la información mediante funciones
```solidity
   function getArrayLocation(
        uint slot,
        uint index,
        uint elementSize
    ) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(slot))) + (index * elementSize);
    }

    function getMapLocation(uint slot, uint key) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(key, slot)));
    }
}

/*
slot 0 - count
web3.eth.getStorageAt("0x534E4Ce0ffF779513793cfd70308AF195827BD31", 0, console.log)
slot 1 - u16, isTrue, owner
web3.eth.getStorageAt("0x534E4Ce0ffF779513793cfd70308AF195827BD31", 1, console.log)
slot 2 - password
web3.eth.getStorageAt("0x534E4Ce0ffF779513793cfd70308AF195827BD31", 2, console.log)

slot 6 - array length
getArrayLocation(6, 0, 2)
web3.utils.numberToHex("111414077815863400510004064629973595961579173665589224203503662149373724986687")
Note: We can also use web3 to get data location
web3.utils.soliditySha3({ type: "uint", value: 6 })
1st user
web3.eth.getStorageAt("0x534E4Ce0ffF779513793cfd70308AF195827BD31", "0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d3f", console.log)
web3.eth.getStorageAt("0x534E4Ce0ffF779513793cfd70308AF195827BD31", "0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d40", console.log)
Note: use web3.toAscii to convert bytes32 to alphabet
2nd user
web3.eth.getStorageAt("0x534E4Ce0ffF779513793cfd70308AF195827BD31", "0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d41", console.log)
web3.eth.getStorageAt("0x534E4Ce0ffF779513793cfd70308AF195827BD31", "0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d42", console.log)

slot 7 - empty
getMapLocation(7, 1)
web3.utils.numberToHex("81222191986226809103279119994707868322855741819905904417953092666699096963112")
Note: We can also use web3 to get data location
web3.utils.soliditySha3({ type: "uint", value: 1 }, {type: "uint", value: 7})
user 1
web3.eth.getStorageAt("0x534E4Ce0ffF779513793cfd70308AF195827BD31", "0xb39221ace053465ec3453ce2b36430bd138b997ecea25c1043da0c366812b828", console.log)
web3.eth.getStorageAt("0x534E4Ce0ffF779513793cfd70308AF195827BD31", "0xb39221ace053465ec3453ce2b36430bd138b997ecea25c1043da0c366812b829", console.log)
*/
```
**NUNCA** se debe guardar información sensible dentro de la blockchain


## Source of Randomness Vulnerability / Vulnerabilidad de busqueda de aleatorio.

Este error consiste en aprovechar el fallo que tiene la blockchain con los números aleatorios, el problema viene de que si tu haces un número aleatorio, como por ejemplo un math.random() , esa función se ejecutará en todos los nodos de la red de ethereum, y en cada nodo tendrá un resultado diferente, y quedaría totalmente invalidado ese contrato.

En algunos casos se intenta coger el blockhash o el blockstamp, y estas no son formas fiables de coger un numero aleatorio.

En caso personal recomiendo usar chainLink https://chain.link/vrf para tener un numero aleatorio de forma correcta.
```solidity 
contract GuessTheRandomNumber {
    constructor() payable {}

    function guess(uint _guess) public {
        uint answer = uint(
            keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
        );

        if (_guess == answer) {
            (bool sent, ) = msg.sender.call{value: 1 ether}("");
            require(sent, "Failed to send Ether");
        }
    }
}
```
Código de lo que no hay que hacer :)

## Denial of Service // Denegación de servicio.

Hay muchas formas de atacar un contrato inteligente para dejarlo inutilizable.
Una vulnerabilidad que presentamos aquí es la denegación de servicio al hacer que la función para enviar Ether falle.

Este ataque se basa en usar un contrato de atacante, que no tenga una fallback function, de manera que va a fallar el envío de ether. 
En el ejemplo señalado usa la funcion atacante, para enviar el valor, pero falla en el proceso, con lo cuál se queda cómo el atacante el control del contrato.
```solidity

    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
```
## Phishing with tx.origin // Phishing con el origen de la transacción

Un contrato malintencionado puede engañar al propietario de un contrato para que llame a una función que solo el propietario debería poder llamar.
Usando la función a continuación puedes atacar usando la wallet mediante el tx.origin
```solidity
contract Attack {
    address payable public owner;
    Wallet wallet;

    constructor(Wallet _wallet) {
        wallet = Wallet(_wallet);
        owner = payable(msg.sender);
    }

    function attack() public {
        wallet.transfer(owner, address(wallet).balance);
    }
}
```
## Hiding Malicious Code with External Contract // Código malicioso escondido en un contrato externo
En este caso consiste en ejecutar código de un contrato externo pensando que se ejecuta un contrato correcto, realmente se ejecuta un contrato malicioso.
El error es el siguiente yo tengo mi contrato y sé que tu contrato hay una función que me interesa.
```solidity
contract contrato1 {
    Bar bar;
    constructor(address _bar) {
        bar = Bar(_bar);
    }
    function callBar() public {
        bar.log();
    }
}
```
Ejecuto el contrato externo que considero que es el correcto , pero el atacante hace el deploy de un contrato con el mismo nombre pero diferente código, con lo cuál perpetuará la ejecución de código malicioso.

## Honeypot // Trampa para hackers
Combinando dos exploits, reentrada y ocultación de código malicioso, podemos construir un contrato.
La cuestión de esto es básicamente usar una función hackeable, con sólo un evento de Log dentro para únicamente visualizar quien ha intentado ejecutar esa función

En este ataque la idea principal es usar un contrato que se pueda ejecutar un ataque de reentrada, pero con la idea de que el atacante la ejecute pero con código en otro contrato que controle
Tenemos esta función que es vulnerable a los ataques de reentrada:
``` solidity
    function withdraw(uint _amount) public {
        require(_amount <= balances[msg.sender], "Insufficient funds");

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] -= _amount;

        logger.log(msg.sender, _amount, "Withdraw");
    }
```
En otro contrato que no pueda ver el usuario tenemos esta funcion que analiza si es un retiro o un ingreso de dinero a  la cuenta, y en caso de que sea un retiro se ejecuta la funcion revert
```solidity
contract HoneyPot {
    function log(address _caller, uint _amount, string memory _action) public {
        if (equal(_action, "Withdraw")) {
            revert("It's a trap");
        }
    }
```
## Frontrunning // Inversión ventajista.
En el caso de frontrunning, lo primero de todo es contextualizar que es y luego explicar que juego tiene en los mercados tanto tradicionales cómo en los mercados de criptomonedas.

El Front running, también conocido como inversión ventajista es una forma ilegal de operar en el mercado que se da cuando los operadores saben las órdenes de compra y de venta que se van a producir y que provocarán alteraciones en los precios del mercado y deciden utilizar esa información para obtener beneficios.
Es decir, en los mercados tradicionales, es una práctica ilegal, pero en el mercado crypto, cambia todo... porque?
Es diferente básicamente porqué todas las transacciones son públicas , están puestas en una mempool donde todo el mundo las puede ver, con lo cuál no hay nadie que tenga información priviegiada, sino que la tiene todo el mundo.

Una vez contextualizado el que es el frontrunning toca ver cómo ejecutarlo y generar ventaja.






