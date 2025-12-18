// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title TrustGig - Simple Freelance Escrow with Dispute Resolution
/// @notice Minimal prototype for decentralized labor market (client, freelancer, arbitrator)
contract TrustGigEscrow {
    enum JobState {
        Created,
        Funded,
        WorkSubmitted,
        Completed,
        Disputed,
        Resolved
    }

    struct Job {
        address client;
        address freelancer;
        address arbitrator;
        uint256 amount;
        JobState state;
        string workSubmission; // e.g., GitHub link, IPFS hash, etc.
    }

    uint256 public nextJobId;
    mapping(uint256 => Job) public jobs;

    event JobCreated(
        uint256 indexed jobId,
        address indexed client,
        address indexed freelancer,
        address arbitrator,
        uint256 amount
    );

    event JobFunded(uint256 indexed jobId, uint256 amount);
    event WorkSubmitted(uint256 indexed jobId, string workSubmission);
    event JobApproved(uint256 indexed jobId);
    event DisputeRaised(uint256 indexed jobId);
    event DisputeResolved(uint256 indexed jobId, address winner);

    modifier onlyClient(uint256 _jobId) {
        require(msg.sender == jobs[_jobId].client, "Not job client");
        _;
    }

    modifier onlyFreelancer(uint256 _jobId) {
        require(msg.sender == jobs[_jobId].freelancer, "Not job freelancer");
        _;
    }

    modifier onlyArbitrator(uint256 _jobId) {
        require(msg.sender == jobs[_jobId].arbitrator, "Not job arbitrator");
        _;
    }

    modifier inState(uint256 _jobId, JobState _state) {
        require(jobs[_jobId].state == _state, "Invalid job state");
        _;
    }

    function createJob(
        address _freelancer,
        address _arbitrator,
        uint256 _amount
    ) external returns (uint256 jobId) {
        require(_freelancer != address(0), "Freelancer required");
        require(_arbitrator != address(0), "Arbitrator required");
        require(_amount > 0, "Amount must be > 0");

        jobId = nextJobId;
        nextJobId++;

        jobs[jobId] = Job({
            client: msg.sender,
            freelancer: _freelancer,
            arbitrator: _arbitrator,
            amount: _amount,
            state: JobState.Created,
            workSubmission: ""
        });

        emit JobCreated(jobId, msg.sender, _freelancer, _arbitrator, _amount);
    }

    function fundJob(uint256 _jobId)
        external
        payable
        onlyClient(_jobId)
        inState(_jobId, JobState.Created)
    {
        Job storage job = jobs[_jobId];
        require(msg.value == job.amount, "Incorrect funding amount");

        job.state = JobState.Funded;

        emit JobFunded(_jobId, msg.value);
    }

    function submitWork(uint256 _jobId, string calldata _workSubmission)
        external
        onlyFreelancer(_jobId)
        inState(_jobId, JobState.Funded)
    {
        Job storage job = jobs[_jobId];
        job.workSubmission = _workSubmission;
        job.state = JobState.WorkSubmitted;

        emit WorkSubmitted(_jobId, _workSubmission);
    }

    function approveWork(uint256 _jobId)
        external
        onlyClient(_jobId)
        inState(_jobId, JobState.WorkSubmitted)
    {
        Job storage job = jobs[_jobId];
        job.state = JobState.Completed;

        (bool sent, ) = job.freelancer.call{value: job.amount}("");
        require(sent, "Payment failed");

        emit JobApproved(_jobId);
    }

    function raiseDispute(uint256 _jobId)
        external
        inState(_jobId, JobState.WorkSubmitted)
    {
        Job storage job = jobs[_jobId];
        require(
            msg.sender == job.client || msg.sender == job.freelancer,
            "Only client or freelancer"
        );

        job.state = JobState.Disputed;

        emit DisputeRaised(_jobId);
    }

    function resolveDispute(uint256 _jobId, address _winner)
        external
        onlyArbitrator(_jobId)
        inState(_jobId, JobState.Disputed)
    {
        Job storage job = jobs[_jobId];
        require(
            _winner == job.client || _winner == job.freelancer,
            "Winner must be client or freelancer"
        );

        job.state = JobState.Resolved;

        (bool sent, ) = _winner.call{value: job.amount}("");
        require(sent, "Payment failed");

        emit DisputeResolved(_jobId, _winner);
    }

    function getJob(uint256 _jobId)
        external
        view
        returns (
            address client,
            address freelancer,
            address arbitrator,
            uint256 amount,
            JobState state,
            string memory workSubmission
        )
    {
        Job storage job = jobs[_jobId];
        return (
            job.client,
            job.freelancer,
            job.arbitrator,
            job.amount,
            job.state,
            job.workSubmission
        );
    }
}