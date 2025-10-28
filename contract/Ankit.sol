// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TaskBounty
 * @dev A decentralized platform for creating and claiming task bounties
 */
contract TaskBounty {
    
    struct Task {
        uint256 id;
        address creator;
        string description;
        uint256 reward;
        address assignee;
        bool isCompleted;
        bool isClaimed;
        uint256 createdAt;
    }
    
    uint256 private taskCounter;
    mapping(uint256 => Task) public tasks;
    
    event TaskCreated(uint256 indexed taskId, address indexed creator, uint256 reward);
    event TaskAssigned(uint256 indexed taskId, address indexed assignee);
    event TaskCompleted(uint256 indexed taskId, address indexed assignee, uint256 reward);
    
    /**
     * @dev Create a new task bounty
     * @param _description Description of the task
     */
    function createTask(string memory _description) public payable {
        require(msg.value > 0, "Reward must be greater than 0");
        require(bytes(_description).length > 0, "Description cannot be empty");
        
        taskCounter++;
        
        tasks[taskCounter] = Task({
            id: taskCounter,
            creator: msg.sender,
            description: _description,
            reward: msg.value,
            assignee: address(0),
            isCompleted: false,
            isClaimed: false,
            createdAt: block.timestamp
        });
        
        emit TaskCreated(taskCounter, msg.sender, msg.value);
    }
    
    /**
     * @dev Assign yourself to work on a task
     * @param _taskId ID of the task to claim
     */
    function claimTask(uint256 _taskId) public {
        Task storage task = tasks[_taskId];
        
        require(task.id != 0, "Task does not exist");
        require(task.assignee == address(0), "Task already claimed");
        require(!task.isCompleted, "Task already completed");
        require(task.creator != msg.sender, "Creator cannot claim own task");
        
        task.assignee = msg.sender;
        
        emit TaskAssigned(_taskId, msg.sender);
    }
    
    /**
     * @dev Mark task as complete and release payment to assignee
     * @param _taskId ID of the task to complete
     */
    function completeTask(uint256 _taskId) public {
        Task storage task = tasks[_taskId];
        
        require(task.id != 0, "Task does not exist");
        require(msg.sender == task.creator, "Only creator can mark as complete");
        require(task.assignee != address(0), "Task not claimed yet");
        require(!task.isCompleted, "Task already completed");
        
        task.isCompleted = true;
        task.isClaimed = true;
        
        payable(task.assignee).transfer(task.reward);
        
        emit TaskCompleted(_taskId, task.assignee, task.reward);
    }
    
    /**
     * @dev Get task details
     * @param _taskId ID of the task
     */
    function getTask(uint256 _taskId) public view returns (Task memory) {
        require(tasks[_taskId].id != 0, "Task does not exist");
        return tasks[_taskId];
    }
    
    /**
     * @dev Get total number of tasks
     */
    function getTotalTasks() public view returns (uint256) {
        return taskCounter;
    }
}
