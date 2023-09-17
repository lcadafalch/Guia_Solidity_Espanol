// Subir dos contratos diferentes en la misma dirección / Deploy Different Contracts at the Same Address

La dirección del contrato implementada con create se calcula de la siguiente manera.

```solidity 
contract address = last 20 bytes of sha3(rlp_encode(sender, nonce))
```

