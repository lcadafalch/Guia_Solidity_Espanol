// DENIAL OF SERVICE O DENEGACIÓN DE SERVICIO.
pragma solidity ^0.8.17;

Hay muchas formas de atacar un contrato inteligente para dejarlo inutilizable.
Una vulnerabilidad que presentamos aquí es la denegación de servicio al hacer que la función para enviar Ether falle.

/*
El objetivo de KingOfEther es convertirse en rey enviando más Ether que
el rey anterior. El rey anterior será reembolsado con la cantidad de Ether
el usuario envió.

¿Qué pasó?
El ataque se convirtió en el rey. Todo nuevo desafío para reclamar el trono será rechazado.
ya que el contrato de ataque no tiene una función de respaldo, negándose a aceptar el
Ether enviado desde KingOfEther antes de que se establezca el nuevo rey.
*/
