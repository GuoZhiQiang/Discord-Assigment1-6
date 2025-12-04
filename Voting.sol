// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Voting {
    // Owner (admin) 权限，用于 addCandidate / resetVotes 等管理操作
    address public owner;
    // 候选人票数字典
    // 使用 bytes32 (keccak256(name)) 作为 key，节省 gas
    mapping (bytes32 => uint256) private votes;
    mapping (bytes32 => bool) private candidatesExist; //候选人去重用
    mapping (bytes32 => bool) private hasVotes; //是否已经投过票
    // 保存所有候选人名称，方便 reset 时遍历
    bytes32[] private candidates;

    modifier onlyOwner() {
        require(owner == msg.sender, "Only Owner");
        _;
    }
    constructor() {
        owner = msg.sender;
    }

    //string 类型的name 转bytes32
    function _idToBytes32(string memory name) pure internal returns (bytes32) {
        return keccak256(bytes(name));
    }
    //初始化时，添加候选人
    function addCandidate(string calldata name) external onlyOwner {
        bytes32 _id = _idToBytes32(name);
        require(!candidatesExist[_id], "Candidate exist");
        candidatesExist[_id] = true;
        candidates.push(_id);
    } 

    // 给指定候选人投票
    function vote(string calldata name) external {
        bytes32 _id = _idToBytes32(name);
        require(candidatesExist[_id], "Candidate not exist");
        require(!hasVotes[_id], "has voted");
        hasVotes[_id] = true;
        votes[_id] += 1;
    }

    //// 获取某个候选人票数
    function getVotes(string calldata name) view external returns(uint256) {
        bytes32 _id = _idToBytes32(name);
        return votes[_id];
    }
    // 重置所有候选人票数
    function resetVotes() public {
        // 清零每个候选人的票数
        for (uint i = 0; i < candidates.length; i++) 
        {
            votes[candidates[i]] = 0;
        }
        // 选举状态清理
        for (uint i = 0; i < candidates.length; i++) 
        {
            hasVotes[candidates[i]] = false;
        }
    }

}
