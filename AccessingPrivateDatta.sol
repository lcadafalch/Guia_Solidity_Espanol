// VULNERABILIDAD ACCESSING PRIVATE DATA o ACCESO A DATOS PRIVADOS
*/
Hay que tener en cuenta que TODOS  los datos dentro de la blockchain son públicos.
Veamos cómo podemos leer datos privados. En el proceso, aprenderá cómo Solidity almacena variables de estado.

*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
Nota: no se puede usar web3 en JVM, así que use el contrato implementado en Goerli
Nota: el navegador Web3 es antiguo, así que use Web3 desde la consola de truffle

Contrato desplegado en Goerli
0x534E4Ce0ffF779513793cfd70308AF195827BD31
*/

/*
# Almacenamiento
- 2 ** 256 ranuras
- 32 bytes para cada ranura
- los datos se almacenan secuencialmente en el orden de declaración
- El almacenamiento está optimizado para ahorrar espacio. Si las variables vecinas caben en una sola
  32 bytes, luego se empaquetan en la misma ranura, comenzando desde la derecha
*/
contract Vault {
    // slot 0
    uint public count = 123;
    // slot 1
    address public owner = msg.sender;
    bool public isTrue = true;
    uint16 public u16 = 31;
    // slot 2
    bytes32 private password;

    // constants do not use storage
    uint public constant someConst = 123;

    // slot 3, 4, 5 (one for each array element)
    bytes32[3] public data;

    struct User {
        uint id;
        bytes32 password;
    }
// ranura 6 - longitud de la matriz
    // a partir de ranura hash (6) - elementos de matriz
    // ranura donde se almacena el elemento de la matriz = keccak256 (ranura)) + (índice * tamaño del elemento)
    // donde slot = 6 y elementSize = 2 (1 (uint) + 1 (bytes32))
 User[] private users;

    // espacio 7 - vacío
    // las entradas se almacenan en hash (clave, ranura)
    // donde ranura = 7, clave = clave de mapa
 mapping(uint => User) private idToUser;

    constructor(bytes32 _password) {
        password = _password;
    }

    function addUser(bytes32 _password) public {
        User memory user = User({id: users.length, password: _password});

        users.push(user);
        idToUser[user.id] = user;
    }

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
TÉCNICAS PREVENTIVAS:
NUNCA almacenes información SENSIBLE  dentro de la cadena de bloques.
