# solidity_attacks
Analisys of multiples sources of attacking in Solidity ,( Smart contracts) and how can stop it,
Useful reccomendation is to use always OPENZEPPELIN  and AUDIT always before deploying anything :)

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
Con lo cuál de deposita el ethereum y seguidamente se envia al contrato de EtherStore, se deposita , se ejecuta la función withdraw, y seguidamente la función fallback de 

