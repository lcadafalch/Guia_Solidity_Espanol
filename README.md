# solidity_attacks
Analisys of multiples sources of attacking in Solidity ,( Smart contracts) and how can stop it,
Useful reccomendation is to use always OPENZEPPELIN  and AUDIT always before deploying anything :)

Review Certik / Slowmist , etc..

## Reentrancy attack
Partimos de la base de que hay dos contratos, un contrato A, y otro contrato B
Y en este funcionamiento A llama al contrato B para ejecutar una función, entonces en reentrancy Attack consiste en volver a ejecutar el contrato antes de que acabe el contrato completo




