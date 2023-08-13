 // Escondiendo código malicioso en un contrato externo // Hiding Malicious Code with External Contract

// VULNERABILIDAD
/*
En Solidity, cualquier dirección se puede convertir en un contrato específico, incluso si el contrato en la dirección no es el que se está emitiendo.
Esto puede explotarse para ocultar código malicioso. Veamos cómo
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
Digamos que Alice puede ver el código de Foo y Bar pero no Mal.
Es obvio para Alice que Foo.callBar() ejecuta el código dentro de Bar.log().
Sin embargo, Eve implementa a Foo con la dirección de Mal, por lo que llamar a Foo.callBar()
en realidad ejecutará el código en Mal.
*/

/*
1. Eve despliega Mal
2. Eve despliega Foo con la dirección de Mal
3. Alice llama a Foo.callBar() después de leer el código y puens que es seguro para llamar.
4. Aunque Alice esperaba que se ejecutara Bar.log(), se ejecutará Mal.log().
*/

contract Foo {
    Bar bar;

    constructor(address _bar) {
        bar = Bar(_bar);
    }

    function callBar() public {
        bar.log();
    }
}

contract Bar {
    event Log(string message);

    function log() public {
        emit Log("Bar was called");
    }
}
// Este código está oculto en un archivo separado
contract Mal {
    event Log(string message);

// function () external {
//     emit Log("Mal was called");
// }
// En realidad, podemos ejecutar el mismo exploit incluso si esta función lo hace
// no existe usando la funcion 
    function log() public {
        emit Log("Mal was called");
    }
}

// TÉCNICAS PREVENTIVAS
// Inicializar un nuevo contrato dentro del constructor.
// Hacer pública la dirección del contrato externo para que se pueda revisar el código del contrato externo

Bar public bar;

constructor() public {
    bar = new Bar();
}
