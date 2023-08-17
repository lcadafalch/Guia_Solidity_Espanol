Suplantación de identidad con tx.origin // Phishing with tx.origins
PARTIENDO DE LA BASE QUE : Si el contrato A llama a B y B llama a C, en C msg.sender es B y tx.origin es A.

RESUMEN: A --> B 
         B --> C MSG.SENDER = B, TX.ORIGIN = A.

Vulnerabilidad
Un contrato malintencionado puede engañar al propietario de un contrato para que llame a una función que solo el propietario debería poder llamar.

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.17;
/*
Wallet es un contrato simple en el que solo el propietario debe poder transferir
Éter a otra dirección. Wallet.transfer() usa tx.origin para verificar que el
la persona que llama es el propietario. Veamos cómo podemos hackear este contrato.
*/

