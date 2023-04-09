// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./IERC20.sol";

contract Governance {
    IERC20 public token;
    uint public constant VOTING_DELAY = 10;
    uint public constant VOTING_DURATION = 60;

    struct ProposalVote {
        uint againstVotes;
        uint forVotes;
        uint abstainVotes;
        mapping(address => bool) hasVoted;
    }

    struct Proposal {
        uint votingStarts;
        uint votingEnds;
        bool executed;
    }

    enum ProposalState {
        Pending,
        Active,
        Succeeded,
        Defeated,
        Executed
    }

    mapping(bytes32 => Proposal) public proposals;
    mapping(bytes32 => ProposalVote) public proposalVotes;

    constructor(IERC20 _token) {
        token = _token;
    }

    function execute(
        address _to,
        uint _value,
        string calldata _func,
        string calldata _data,
        bytes32 _descriptionHash
    ) external returns (bytes memory) {
        bytes32 proposalId = generateProposalId(
            _to,
            _value,
            _func,
            _data,
            _descriptionHash
        );
        require(state(proposalId) == ProposalState.Succeeded, "invalid state");

        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;

        bytes memory data;
        if (bytes(_func).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else {
            data = bytes(_data);
        }

        (bool success, bytes memory response) = _to.call{value: _value}(data);

        require(success, "tx failed");
        return response;
    }

    function propose(
        address _to,
        uint _value,
        string calldata _func,
        string calldata _data,
        string calldata _description
    ) external returns (bytes32) {
        require(token.balanceOf(msg.sender) > 1, "not enough tokens");

        bytes32 proposalId = generateProposalId(
            _to,
            _value,
            _func,
            _data,
            keccak256(bytes(_description))
        );

        require(proposals[proposalId].votingStarts == 0, "proposal exists");

        proposals[proposalId] = Proposal({
            votingStarts: block.timestamp + VOTING_DELAY,
            votingEnds: block.timestamp + VOTING_DELAY + VOTING_DURATION,
            executed: false
        });
        return proposalId;
    }

    function vote(bytes32 _proposalId, uint8 _voteType) external {
        require(state(_proposalId) == ProposalState.Active, "invalid state");
        uint votingPower = token.balanceOf(msg.sender);

        require(votingPower > 0, "not enough tokens");

        ProposalVote storage proposalVote = proposalVotes[_proposalId];

        require(!proposalVote.hasVoted[msg.sender], "already voted");

        if (_voteType == 0) {
            proposalVote.againstVotes += votingPower;
        } else if (_voteType == 1) {
            proposalVote.forVotes += votingPower;
        } else {
            proposalVote.abstainVotes += votingPower;
        }
        proposalVote.hasVoted[msg.sender] = true;
    }

    function state(bytes32 _proposalId) public view returns (ProposalState) {
        Proposal storage proposal = proposals[_proposalId];
        ProposalVote storage proposalVote = proposalVotes[_proposalId];

        require(proposal.votingStarts > 0, "proposal doesnt exists");

        if (proposal.executed) {
            return ProposalState.Executed;
        }
        if (block.timestamp < proposal.votingStarts) {
            return ProposalState.Pending;
        }
        if (
            block.timestamp >= proposal.votingStarts &&
            proposal.votingEnds > block.timestamp
        ) {
            return ProposalState.Active;
        }
        if (proposalVote.forVotes > proposalVote.againstVotes) {
            return ProposalState.Succeeded;
        } else {
            return ProposalState.Defeated;
        }
    }

    function generateProposalId(
        address _to,
        uint _value,
        string calldata _func,
        string calldata _data,
        bytes32 _descriptionHash
    ) internal pure returns (bytes32) {
        return
            keccak256(abi.encode(_to, _value, _func, _data, _descriptionHash));
    }
}
