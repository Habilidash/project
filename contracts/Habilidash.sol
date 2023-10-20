// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        if (_status == _ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Habilidash is Ownable, ReentrancyGuard {
    uint256 public JobCount = 0;
    uint256 public offerCount = 0;
    IERC20 public stableToken;
    
    enum ProgressStatus {
        PENDING,
        IN_PROGRESS,
        APPROVAL_PENDING,
        COMPLETED,
        REJECTED,
        DISPUTED,
        CANCELLED
    }

    enum FreelancerStatus{
        REGISTERED,
        VERIFIED,
        SUPREME,
        TOP_SELLER
    }

    enum StakeStatus{
        NOTSTAKING,
        ONE_STAKING,
        THREE_STAKING,
        SIX_STAKING,
        STAKER
    }

    enum JobStatus{
        ACTIVE,
        PAUSED,
        DELETED
    }

    struct HabilidashData {
        ClientProfile[] clients;
        FreelancerProfile[] freelancers;
        Job[] jobs;
    }

    struct FreelancerProfile {
        string name;
        string specialty;
        string[] skills;
        string[] experience;
        string[] portfolio;
        uint256 balance;
        uint32 jobs;
        bool blocked;
        uint256 timesRated;
        uint256 rating;
        uint256 totalEarnings;
        FreelancerStatus status;
        StakeStatus stakeStatus;
    }

    struct ClientProfile{
        string name;
        string description;
        uint32 jobs;
         bool blocked;
        uint256 timesRated;
        uint256 rating;
    }

    struct Job {
        uint256 jobId;
        string jobDescription;
        uint256 initialPrice;
        address serviceOwner;
        uint256 estimatedDeliveryTime;
        JobStatus jobStatus;
    }

    struct Offer {
        uint256 jobId;
        ProgressStatus progressStatus;
        address client;
        uint256 price;
        uint256 deliveryTime;
    }

    struct Dispute {
        uint256 jobId;
        string reason;
        bool resolved;
        address judge;
    }

    mapping(uint256 => Job) public jobList;
    mapping(address => FreelancerProfile) freelancer;
    mapping(address => ClientProfile) client;
    mapping(uint256 => Dispute) public disputes;
    mapping(address => bool) public isClient;
    mapping(address => bool) public isFreelancer;
    //      _jobId     offers
    mapping(uint256 => Offer[]) public jobOffers;
    //     freelancer   jobId
    mapping(address => uint256[]) public freelancerJobs;
    //       _jobId   array of _offerIDs
    mapping(uint256 => uint256[]) public jobToOfferIds; 
    //     _offerID    Offer    
    mapping(uint256 => Offer) public offerById;

    event JobCreated(uint256 indexed _jobID, address indexed _freelancer);
    event JobEdited(uint256 indexed _jobID, address indexed _freelancer, uint256 _price);
    event JobDeleted(uint256 indexed _jobID, address indexed _freelancer);
    event OfferSubmitted(uint256 indexed _jobID, address indexed _client, uint256 _price, uint256 _deliveryTime);
    event OfferAccepted(uint256 indexed _jobID, address indexed _freelancer, address indexed _client);
    event OfferRejected(uint256 indexed _jobID, address indexed _freelancer, address indexed _client);
    event OfferCancelled(uint256 indexed _jobID, address indexed _client);
    event JobDelivered(uint256 indexed _jobID, address indexed _freelancer, address indexed _client);
    event JobCompleted(uint256 indexed _jobID, address indexed _freelancer, address indexed _client);
    event JobDisputed(uint256 indexed _jobID, address indexed _client, string reason);
    event FreelancerCreated(string indexed _name, address indexed _freelancer, string indexed _specialty);
    event ClientCreated(string indexed _name, address indexed _client, string indexed _description);
    event FreelancerBlocked(address indexed _freelancer);
    event ClientBlocked(address indexed _client);
    event FreelancerRated(address indexed _freelancer, uint256 _rating);
    event ClientRated(address indexed _client, uint256 _rating);
    event DisputeResolved(uint256 indexed _jobID, bool inFavorOfClient);
    event StakeStatusChanged(address indexed freelancer, StakeStatus newStatus);

    receive() external payable {}

    constructor(address _tokenAddress) {
        stableToken = IERC20(_tokenAddress);
    }

    modifier idExist(uint256 _jobID) {
        require(_jobID > 0 && _jobID <= JobCount);
        _;
    }

    modifier jobOwner(uint256 _jobID) {
        Job memory job = jobList[_jobID];
        require(msg.sender == job.serviceOwner);
        _;
    }

    modifier OnlyClient() {
        require(isClient[msg.sender] == true, "You do not have access, Only a Client account can access this");
        _;
    }

    modifier OnlyFreelancer() {
        require(isFreelancer[msg.sender] == true, "You do not have access, Only a Freelancer account can access this");
        _;
    }

    function createJob(string memory _jobDescription, uint256 _initialPrice, uint256 _estimatedDeliveryTime) external OnlyFreelancer returns (uint256){
        // Create struct with job details
        Job memory job = Job(
            JobCount,
            _jobDescription,
            _initialPrice,
            msg.sender,
            _estimatedDeliveryTime,
            JobStatus.ACTIVE
        );

        // Increment Job Number
        JobCount = JobCount + 1;

        // Add the current job to jobList
        jobList[JobCount] = job;

        // Update the freelancer's job list
        freelancerJobs[msg.sender].push(JobCount);

        // Update the freelancer's job count in their profile
        freelancer[msg.sender].jobs += 1;

        // Emmit event
        emit JobCreated(JobCount, msg.sender);

        // Return ID
        return JobCount;
    }

    function deleteJob(uint256 _jobID) external jobOwner(_jobID) OnlyFreelancer {
        Job storage job = jobList[_jobID];
        job.jobStatus = JobStatus.DELETED;

        // Emmit event
        emit JobDeleted(_jobID, msg.sender);
    }

    function editJob(uint256 _jobID, string memory _newJobDescription, uint256 _newPrice, uint256 _newEstimatedDeliveryTime) external jobOwner(_jobID) OnlyFreelancer {
        Job storage job = jobList[_jobID];

        job.jobDescription = _newJobDescription;
        job.initialPrice = _newPrice;
        job.estimatedDeliveryTime = _newEstimatedDeliveryTime;

        // Emmit event
        emit JobEdited(_jobID, msg.sender, _newPrice);
    }

    function submitOffer(uint256 _jobID, uint256 _price, uint256 _deliveryTime) external nonReentrant OnlyClient returns (uint256) {
        // Checking if the job exists
        require(jobList[_jobID].jobId == _jobID, "Job does not exist");

        // Transfer client's funds to the contract as escrow
        require(stableToken.transferFrom(msg.sender, address(this), _price), "Transfer failed");

        offerCount += 1;
        Offer memory newOffer = Offer(
            _jobID,
            ProgressStatus.PENDING,
            msg.sender,
            _price,
            _deliveryTime
        );

        offerById[offerCount] = newOffer;
        jobToOfferIds[_jobID].push(offerCount);

        emit OfferSubmitted(_jobID, msg.sender, _price, _deliveryTime);

        // Return the index of the offer in the array for future references
        return offerCount;
    }

    function viewOffers(uint256 _jobID) external OnlyFreelancer view returns (Offer[] memory) {
        // Ensure the freelancer is the job owner
        require(jobList[_jobID].serviceOwner == msg.sender, "Not the owner of the job");

        uint256[] memory offerIds = jobToOfferIds[_jobID];
        Offer[] memory offers = new Offer[](offerIds.length);

        for (uint256 i = 0; i < offerIds.length; i++) {
            offers[i] = offerById[offerIds[i]];
        }

        return offers;
    }

    function acceptOffer(uint256 _offerID) external OnlyFreelancer nonReentrant{
        Offer storage selectedOffer = offerById[_offerID];
        require(jobList[selectedOffer.jobId].serviceOwner == msg.sender, "Not the owner of the job");
        require(selectedOffer.progressStatus == ProgressStatus.PENDING, "Offer not in pending state");

        // Changing the status of the offer to IN_PROGRESS
        selectedOffer.progressStatus = ProgressStatus.IN_PROGRESS;

        // Transfer the offer amount to the freelancer
        require(stableToken.transfer(msg.sender, selectedOffer.price), "Transfer failed");

        emit OfferAccepted(selectedOffer.jobId, msg.sender, selectedOffer.client);
    }

    function rejectOffer(uint256 _offerID) external OnlyFreelancer nonReentrant{
        Offer storage selectedOffer = offerById[_offerID];
        require(jobList[selectedOffer.jobId].serviceOwner == msg.sender, "Not the owner of the job");
        require(selectedOffer.progressStatus == ProgressStatus.PENDING, "Offer not in pending state");

        // Changing the status of the offer to REJECTED
        selectedOffer.progressStatus = ProgressStatus.REJECTED;

        // Refund the offer amount to the client since it was rejected
        require(stableToken.transfer(selectedOffer.client, selectedOffer.price), "Transfer failed");

        emit OfferRejected(selectedOffer.jobId, msg.sender, selectedOffer.client);
    }

    function cancelOffer(uint256 _offerID) external OnlyClient nonReentrant{
        Offer storage selectedOffer = offerById[_offerID];
        require(selectedOffer.client == msg.sender, "Not the owner of the offer");
        require(selectedOffer.progressStatus == ProgressStatus.PENDING, "Can only cancel a pending offer");

        // Refund the offer amount back to the client
        require(stableToken.transfer(msg.sender, selectedOffer.price), "Transfer failed");

        // Changing the status of the offer to CANCELLED
        selectedOffer.progressStatus = ProgressStatus.CANCELLED;

        emit OfferCancelled(selectedOffer.jobId, msg.sender);
    }

    function deliverJob(uint256 _jobID, uint256 _offerID) external OnlyFreelancer {
        Offer storage selectedOffer = offerById[_offerID];
        require(jobList[_jobID].serviceOwner == msg.sender, "Not the owner of the job");
        require(selectedOffer.progressStatus == ProgressStatus.IN_PROGRESS, "Job is not in progress");

        // Updating the job's progress status to APPROVAL_PENDING
        selectedOffer.progressStatus = ProgressStatus.APPROVAL_PENDING;
        emit JobDelivered(_jobID, msg.sender, selectedOffer.client);
    }

    
    function completeJob(uint256 _offerID) external OnlyClient {
        Offer storage selectedOffer = offerById[_offerID];
        require(selectedOffer.client == msg.sender, "Not the owner of the offer");
        require(selectedOffer.progressStatus == ProgressStatus.APPROVAL_PENDING, "Job is not pending approval");

        selectedOffer.progressStatus = ProgressStatus.COMPLETED;
        emit JobCompleted(selectedOffer.jobId, jobList[selectedOffer.jobId].serviceOwner, msg.sender);
    }

    function disputeJob(uint256 _offerID, string memory _reason) external OnlyClient {
        Offer storage selectedOffer = offerById[_offerID];
        require(selectedOffer.client == msg.sender, "Not the owner of the offer");
        require(selectedOffer.progressStatus == ProgressStatus.IN_PROGRESS, "Job is not in progress");

        selectedOffer.progressStatus = ProgressStatus.DISPUTED;
        emit JobDisputed(selectedOffer.jobId, msg.sender, _reason);
    }

    function createFreelancer(string memory _name,string memory _specialty,string[] memory _skills) external {
        require(!isFreelancer[msg.sender], "Freelancer already registered");
        FreelancerProfile memory profile = FreelancerProfile({
            name: _name,
            specialty: _specialty,
            skills: _skills,
            experience: new string[](0),
            portfolio: new string[](0),
            balance: 0,
            jobs: 0,
            blocked: false,
            timesRated: 0,
            rating: 0,
            totalEarnings: 0,
            status: FreelancerStatus.REGISTERED,
            stakeStatus: StakeStatus.NOTSTAKING
        });
        freelancer[msg.sender] = profile;
        isFreelancer[msg.sender] = true;

        emit FreelancerCreated(_name, msg.sender, _specialty);
    }

    function createClient(string memory _name, string memory _description) external {
        require(!isClient[msg.sender], "Client already registered");
        ClientProfile memory profile = ClientProfile({
            name: _name,
            description: _description,
            jobs: 0,
            blocked: false,
            timesRated: 0,
            rating: 0
        });
        client[msg.sender] = profile;
        isClient[msg.sender] = true;

        emit ClientCreated(_name, msg.sender, _description);
    }

    function rateFreelancer(address _freelancerAddress, uint256 _rating) external OnlyClient {
        require(_rating >= 1 && _rating <= 5, "Rating should be between 1 and 5");
        FreelancerProfile storage freelancerProfile = freelancer[_freelancerAddress];
        require(!freelancerProfile.blocked, "Freelancer is blocked");

        freelancerProfile.rating = ((freelancerProfile.rating * freelancerProfile.timesRated) + _rating) / (freelancerProfile.timesRated + 1);
        freelancerProfile.timesRated++;

        emit FreelancerRated(_freelancerAddress, _rating);
    }

    function rateClient(address _clientAddress, uint256 _rating) external OnlyFreelancer {
        require(_rating >= 1 && _rating <= 5, "Rating should be between 1 and 5");
        ClientProfile storage clientProfile = client[_clientAddress];
        require(!clientProfile.blocked, "Client is blocked");

        clientProfile.rating = ((clientProfile.rating * clientProfile.timesRated) + _rating) / (clientProfile.timesRated + 1);
        clientProfile.timesRated++;

        emit ClientRated(_clientAddress, _rating);
    }

    function blockFreelancer(address _freelancerAddress, bool _blocked) external onlyOwner{
        freelancer[_freelancerAddress].blocked = _blocked;
        emit FreelancerBlocked(_freelancerAddress);
    }

    function blockClient(address _clientAddress, bool _blocked) external onlyOwner{
        client[_clientAddress].blocked = _blocked;
        emit ClientBlocked(_clientAddress);
    }

    function changeStakeStatus(address _freelancerAddress, StakeStatus _newStatus) external onlyOwner {
        require(isFreelancer[_freelancerAddress], "Address is not a registered freelancer");
        FreelancerProfile storage profile = freelancer[_freelancerAddress];
        profile.stakeStatus = _newStatus;
        emit StakeStatusChanged(_freelancerAddress, _newStatus);
    }
}