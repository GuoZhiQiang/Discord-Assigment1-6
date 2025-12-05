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

    //反转
    function reverseString(string memory name) pure external returns (string memory) {
        bytes memory b = bytes(name);
        uint len = b.length;
        for (uint i = 0; i < len / 2; i++) {
            bytes1 temp = b[i];
            b[i] = b[len - 1 - i];
            b[len - 1 - i] = temp;
        }
        return string(b);
    }
    //整数转罗马数字
    function romanToInt(string calldata romon) pure external returns (uint256) {
        bytes calldata b = bytes(romon);
        uint256 total = 0;
        uint256 prev = 0;

        for (uint256 i = b.length; i > 0; i--) {
            uint256 value = _romanValue(b[i - 1]);

            // 如果当前值 < 上一个（右边字符），说明需要做减法（如 IV = 5 - 1）
            if (value < prev) {
                total -= value;
            } else {
                total += value;
            }

            prev = value;
        }

        return total;
    }
    function _romanValue(bytes1 r) pure internal returns (uint256) {
        if (r == "I") return 1;
        if (r == "V") return 5;
        if (r == "X") return 10;
        if (r == "L") return 50;
        if (r == "C") return 100;
        if (r == "D") return 500;
        if (r == "M") return 1000;
        revert("Invalid Roman numeral");
    }

    // int 转罗马字符
    function intToRoman(uint256 value) pure external returns (string memory) {
        require(value > 0 && value <= 3999, "Value out of range");
        // 所有 Roman 组合（含特殊组合）
        string[13] memory romans = [
            "M",  "CM", "D",  "CD", "C",
            "XC", "L",  "XL", "X",  "IX",
            "V",  "IV", "I"
        ];

        // 对应数值
        uint256[13] memory vals = [
            uint256(1000), 900, 500, 400, 100,
            90,   50,  40,  10,  9,
            5,    4,   1
        ];

        string memory result = "";
        for (uint256 i = 0; i < romans.length; i++) 
        {
            while (value >= vals[i]) {
                value = value - vals[i];
                result = string.concat(result, romans[i]);
            }   
        }
        return result;
    }

    //合并两个有序数组 (Merge Sorted Array)
    function mergeSortedArray(uint256[] calldata arrayA, uint256[] calldata arrayB) external pure returns (uint256[] memory) {
        uint256 lengthA = arrayA.length;
        uint256 lengthB = arrayB.length;
        uint256 i = 0;
        uint256 j = 0;
        uint256 k = 0;
        uint256[] memory result = new uint256[](lengthA+lengthB);
        while (i < lengthA && j < lengthB) {
            if (arrayA[i] < arrayB[j]) {
                result[k] = arrayA[i];
                i++;
            } else {
                result[k] = arrayB[j];
                j++;
            }
            k++;
        }
        while(i < lengthA) {
            result[k] = arrayA[i];
            k++;
            i++;
        }
        while (j < lengthB) {
            result[k] = arrayB[j];
            k++;
            j++;
        }
        return result;
    }

    // 二分查找 (Binary Search)
    function binarySearch(uint256[] calldata array, uint256 target) external pure returns (int256) {

        if (array.length == 0) {
            return -1;
        }
        uint256 left = 0;
        uint256 right = array.length-1;


        while (left <= right) {
            uint256 mid = left + (right-left)/2;
            if (array[mid] == target) {
                return int256(mid);
            } else if (array[mid] > target) {
                right = mid-1;
            } else {
                left = mid + 1;
            }
        }
        return -1;
    }

}
