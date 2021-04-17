pragma solidity ^0.4.17;

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }


    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }


    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }


    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract ApproverRole {
    using Roles for Roles.Role;

    event ApproverAdded(address indexed account);
    event ApproverRemoved(address indexed account);

    Roles.Role private _approvers;


    address firstSignAddress;
    address secondSignAddress;
    
    mapping(address => bool) signed; // Signed flag

    constructor () internal {
        _addApprover(msg.sender);
        
        firstSignAddress = 0xxxxxxxxxxxxxxxxx;   
        secondSignAddress = 0xyyyyyyyyyyyyyyy;
    }

    modifier onlyApprover() {
        require(isApprover(msg.sender), "ApproverRole: caller does not have the Approver role");
        _;
    }

    /* first sign address and second sign address should call this function for sign */
    function Sign() public {
        require (msg.sender == firstSignAddress || msg.sender == secondSignAddress);
        require (signed[msg.sender] == false);
        signed[msg.sender] = true;
    }

    function isApprover(address account) public view returns (bool) {
        return _approvers.has(account);
    }

    function addApprover(address account) public onlyApprover {
        require (signed[firstSignAddress] == true && signed[secondSignAddress] == true);
        _addApprover(account);
        
        signed[firstSignAddress] = false;
        signed[secondSignAddress] = false;
    }

    function removeApprover(address account) public onlyApprover {
        require (signed[firstSignAddress] == true && signed[secondSignAddress] == true);
        _removeApprover(account);
        
        signed[firstSignAddress] = false;
        signed[secondSignAddress] = false;
    }

    function renounceApprover() public {
        require (signed[firstSignAddress] == true && signed[secondSignAddress] == true);
        _removeApprover(msg.sender);
        
        signed[firstSignAddress] = false;
        signed[secondSignAddress] = false;
    }

    function _addApprover(address account) internal {
        _approvers.add(account);
        emit ApproverAdded(account);
    }

    function _removeApprover(address account) internal {
        _approvers.remove(account);
        emit ApproverRemoved(account);
    }
}

contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }


    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");


        _status = _ENTERED;

        _;


        _status = _NOT_ENTERED;
    }
}

contract SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}


contract IERC20 {
    function totalSupply() public constant returns (uint256);

    function balanceOf(address tokenOwner)
        public
        constant
        returns (uint256 balance);

    function allowance(address tokenOwner, address spender)
        public
        constant
        returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public returns (bool success);

    function approve(address spender, uint256 tokens)
        public
        returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint256 tokens
    );
}


contract ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes data
    ) public;
}


contract CyberToken is IERC20, SafeMath {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;


    constructor() public {
        symbol = "Cyber";
        name = "CyberToken";
        decimals = 8;
        _totalSupply = 80000000;
        balances[0xcbfcc6122f5fb79b7cf8e538ebe09bfc129310c1] = _totalSupply;
        emit Transfer(
            address(0),
            0xcbfcc6122f5fb79b7cf8e538ebe09bfc129310c1,
            _totalSupply
        );
    }


    function balanceOf(address tokenOwner)
        public
        constant
        returns (uint256 balance)
    {
        return balances[tokenOwner];
    }


    function transfer(address to, uint256 tokens)
        public
        returns (bool success)
    {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    function approve(address spender, uint256 tokens)
        public
        returns (bool success)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender)
        public
        constant
        returns (uint256 remaining)
    {
        return allowed[tokenOwner][spender];
    }


    function approveAndCall(
        address spender,
        uint256 tokens,
        bytes data
    ) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(
            msg.sender,
            tokens,
            this,
            data
        );
        return true;
    }


    function() public payable {
        revert();
    }
}

contract MainContract is ApproverRole, ReentrancyGuard {

    struct AccountData {
        uint256 accountType;
        string personNameSurname;
        address personWalletAddress;
        string personEmail;
        string personPhoneNumber;
        string personResume;
        string personGitHub;
        string personPortfoyLink;
        string personWorkSkills;
        string personLinkedin;
        uint256 personWorkCount;
        uint256[] personPuan;
        address[] WorkAddresses;
        string personLocation;
        string personLang;
        address[] personFavWorks;
    }

    mapping(address => AccountData[]) accounts;
    mapping(address => bool) personsAddress;
    address[] public deployedWorks;
    address[] public allPersons;
    uint256 private result;
    address CyberTokenDeployer = 0xcbfcc6122f5fb79b7cf8e538ebe09bfc129310c1;

    uint public approverMinCyberLimit = 80000000;
    
    event ChangeApproverMinCyberLimit(address indexed user, uint _approverMinCyberLimit);
    event SendCyberTokenDeployer(address _address, uint256 amount);

    modifier isInAccounts() {
        require(personsAddress[msg.sender]);
        _;
    }
    
    function changeApproverMinCyberLimit(uint _value) public onlyApprover {
        require(msg.sender == CyberTokenDeployer, "Message sender should be token deployer.");
        approverMinCyberLimit = _value;
        
        emit ChangeApproverMinCyberLimit(msg.sender, approverMinCyberLimit);
    }

    // Sending CyberToken To Deployer Address
    function sendCyberTokenDeployer(address _address, uint256 amount) public onlyApprover {
        require(msg.sender == CyberTokenDeployer, "Message sender should be token deployer.");
        CyberToken.transfer(_address, amount);
        
        emit SendCyberTokenDeployer(_address, amount);
    }


    function getAllPersons() public view returns (address[]) {
        return allPersons;
    }


    function addPerson(
        uint256 _accountType,
        string _personNameSurname,
        string _personEmail,
        string _personPhoneNumber,
        string _personResume,
        string _personGitHub,
        string _personPortfoyLink,
        string _personWorkSkills,
        string _personLinkedin,
        string _personLocation,
        string _personLang
    ) public {
        if(_accountType == 1) {
            require(CyberToken.balanceOf(msg.sender) >= approverMinCyberLimit, "Incorrect Token balance!");
        }
        AccountData memory newAccount =
            AccountData({
                accountType: _accountType,
                personNameSurname: _personNameSurname,
                personWalletAddress: msg.sender,
                personEmail: _personEmail,
                personPhoneNumber: _personPhoneNumber,
                personResume: _personResume,
                personGitHub: _personGitHub,
                personPortfoyLink: _personPortfoyLink,
                personWorkSkills: _personWorkSkills,
                personLinkedin: _personLinkedin,
                personWorkCount: 0,
                personPuan: new uint256[](0),
                WorkAddresses: new address[](0),
                personLocation: _personLocation,
                personLang: _personLang,
                personFavWorks: new address[](0)
            });

        accounts[msg.sender].push(newAccount);
        allPersons.push(msg.sender);
        personsAddress[msg.sender] = true;
    }


    function getPersonInfoData(address _personAddress)
        public
        view
        returns (
            string,
            string,
            string,
            string,
            string,
            string,
            string
        )
    {
        AccountData storage data = accounts[_personAddress][0];

        return (
            data.personNameSurname,
            data.personEmail,
            data.personPhoneNumber,
            data.personResume,
            data.personGitHub,
            data.personPortfoyLink,
            data.personWorkSkills
        );
    }


    function getPersonPuan(address _personAddress)
        public
        view
        returns (uint256)
    {
        AccountData memory data = accounts[_personAddress][0];
        result = 0;
        if (data.personPuan.length != 0) {
            for (uint256 i = 0; i < data.personPuan.length; i++) {
                result += data.personPuan[i];
            }
            result = (result * 100) / (data.personPuan.length); // JS => x/1000
        }
        return result;
    }


    function getPersonOtherData(address _personAddress)
        public
        view
        returns (
            uint256,
            string,
            uint256,
            uint256[],
            address[],
            string,
            string,
            address[]
        )
    {
        AccountData storage data = accounts[_personAddress][0];

        return (
            data.accountType,
            data.personLinkedin,
            data.personWorkCount,
            data.personPuan,
            data.WorkAddresses,
            data.personLocation,
            data.personLang,
            data.personFavWorks
        );
    }


    function getPersonWorks(address _personAddress)
        public
        view
        returns (address[])
    {
        AccountData storage data = accounts[_personAddress][0];

        return (data.WorkAddresses);
    }

    function updatePerson(
        uint256 _accountType,
        string _personNameSurname,
        string _personEmail,
        string _personPhoneNumber,
        string _personResume,
        string _personGitHub,
        string _personPortfoyLink,
        string _personWorkSkills,
        string _personLinkedin,
        string _personLocation,
        string _personLang
    ) public isInAccounts {
        AccountData storage data = accounts[msg.sender][0];
        data.accountType = _accountType;
        data.personNameSurname = _personNameSurname;
        data.personEmail = _personEmail;
        data.personPhoneNumber = _personPhoneNumber;
        data.personResume = _personResume;
        data.personGitHub = _personGitHub;
        data.personPortfoyLink = _personPortfoyLink;
        data.personWorkSkills = _personWorkSkills;
        data.personLinkedin = _personLinkedin;
        data.personLocation = _personLocation;
        data.personLang = _personLang;
    }

    function deleteAccount() public isInAccounts {
        delete accounts[msg.sender];
    }

    function selectFavouriteWork(address _workAddress) public isInAccounts {
        AccountData storage data = accounts[msg.sender][0];
        data.personFavWorks.push(_workAddress);
    }

    function getFavouriteWork(address _personAddress)
        public
        view
        returns (address[])
    {
        AccountData storage data = accounts[_personAddress][0];
        return data.personFavWorks;
    }

    function deleteFavouriteWork(uint256 _index) public isInAccounts {
        AccountData storage data = accounts[msg.sender][0];
        delete data.personFavWorks[_index];
    }


    function createWork(
        string _workTitle,
        string _workCategory,
        string _workDescription,
        string _workAvarageBudget
    ) public {
        address newWork =
            new WorkContract(
                _workTitle,
                _workCategory,
                _workDescription,
                _workAvarageBudget,
                msg.sender,
                this
            );
        AccountData storage data = accounts[msg.sender][0];
        data.WorkAddresses.push(newWork);
        deployedWorks.push(newWork);
    }

    function updateWork(
        string _workTitle,
        string _workCategory,
        string _workDescription,
        string _workAvarageBudget,
        uint256 _index
    ) public {
        AccountData storage data = accounts[msg.sender][0];
        WorkContract deployedWork;
        deployedWork = WorkContract(data.WorkAddresses[_index]);
        deployedWork.updateWork(
            _workTitle,
            _workCategory,
            _workDescription,
            _workAvarageBudget,
            data.WorkAddresses[_index]
        );
    }


    function cancelWork(address _workAddress) public {
        AccountData storage data = accounts[msg.sender][0];
        for (uint256 i = 0; i < data.WorkAddresses.length; i++) {
            if (data.WorkAddresses[i] == _workAddress) {
                delete data.WorkAddresses[i];
            }
        }
        for (uint256 j = 0; j < deployedWorks.length; j++) {
            if (deployedWorks[j] == _workAddress) {
                delete deployedWorks[j];
            }
        }
    }

    function getWorks() public view returns (address[]) {
        return deployedWorks;
    }


    function setPuan(uint256 _puan, address _freelancerAddress) public {
        for (uint256 i = 0; i < deployedWorks.length; i++) {
            if (msg.sender == deployedWorks[i]) {
                AccountData storage data = accounts[_freelancerAddress][0];
                data.personPuan.push(_puan);
            }
        }
    }


    function setApproverWorkAddress(
        address _workAddress,
        address _approveraddress
    ) public {
        for (uint256 i = 0; i < deployedWorks.length; i++) {
            if (msg.sender == deployedWorks[i]) {
                AccountData storage data = accounts[_approveraddress][0];
                data.WorkAddresses.push(_workAddress);
            }
        }
    }

    function deleteApproverWorkAddress(
        address _workAddress,
        address _approveraddress
    ) public {
        for (uint256 y = 0; y < deployedWorks.length; y++) {
            if (msg.sender == deployedWorks[y]) {
                AccountData storage data = accounts[_approveraddress][0];
                for (uint256 i = 0; i < data.WorkAddresses.length; i++) {
                    if (data.WorkAddresses[i] == _workAddress) {
                        delete data.WorkAddresses[i];
                    }
                }
            }
        }
    }

    function checkDeadline(address _workAddress)
        public
        view
        returns (bool, address)
    {
        WorkContract deployedWork;
        deployedWork = WorkContract(_workAddress);
        if (now > deployedWork.deadLine() && deployedWork.deadLine() != 0) {
            return (true, _workAddress);
        } else {
            return (false, _workAddress);
        }
    }

    function sendApproverCyberCoin(address _approveraddress) public onlyApprover nonReentrant returns (uint256){
        for (uint256 i = 0; i < deployedWorks.length; i++) {
            if (msg.sender == deployedWorks[i]) {
                uint256 amount = (RemainingCyberToken * 3) / 1000000;
                CyberToken.transfer(_approveraddress, amount);
                RemainingCyberToken -= amount;
            }
        }
        
        return 2;
    }
}

contract WorkContract is ApproverRole, ReentrancyGuard {
    MainContract deployedFromContract;
    struct Offer {
        uint256 offerPrice;
        address freelancerAddress;
        bool isCyberShield;
        string description;
        string title;
        uint256 deadline;
        address offerTokenContract;
        bool tokenContractIsBNB;
    }

    string public workTitle;
    string public workCategory;
    string public workDescription;
    uint256 public workCreateTime;
    string public workAvarageBudget;
    uint256 public workOfferCount;
    bool public workStatus;
    string public workFilesLink;
    uint256 public deadLine;
    bool public freelancerSendFiles;
    bool public isWorkFreelancer;
    bool public employerReceiveFiles;
    uint256 public freelancerSendFilesDate;
    address public employerAddress;
    address public freelancerAddress;
    string public employerCancelDescription;
    uint256 public workStartDate;
    uint256 public workEndDate;
    mapping(address => Offer[]) offers;
    address[] public allFreelancerAddress;
    address public approverAddress;
    uint256 public approverConfirmStatus;
    string public approverReport;
    bool public approverStatus;
    uint256 public workPrice;
    bool public isBNB;


    constructor(
        string _workTitle,
        string _workCategory,
        string _workDescription,
        string _workAvarageBudget,
        address _employerAddress,
        address _t
    ) public {
        require(_employerAddress != address(0), "employerAddress's address(0)");
        require(_t != address(0), "deployedFromContract  address(0)");

        workTitle = _workTitle;
        workCategory = _workCategory;
        workDescription = _workDescription;
        workCreateTime = now;
        workAvarageBudget = _workAvarageBudget;
        workOfferCount = 0;
        workStatus = false;
        employerAddress = _employerAddress;
        isWorkFreelancer = false;
        approverStatus = false;
        freelancerSendFiles = false;
        employerReceiveFiles = false;
        deployedFromContract = MainContract(_t);
    }

    function getAllFreelancers() public view returns (address[]) {
        return allFreelancerAddress;
    }

    function getWorkData()
        public
        view
        returns (
            string,
            string,
            string,
            uint256,
            string,
            uint256,
            bool,
            address
        )
    {
        return (
            workTitle,
            workCategory,
            workDescription,
            workCreateTime,
            workAvarageBudget,
            workOfferCount,
            workStatus,
            employerAddress
        );
    }

    function updateWork(
        string _workTitle,
        string _workCategory,
        string _workDescription,
        string _workAvarageBudget,
        address _workaddress
    ) public {
        require(this == _workaddress, "Incorrect workaddress!");
        require(msg.sender == employerAddress, "Incorrect employerAddress!");
        workTitle = _workTitle;
        workCategory = _workCategory;
        workDescription = _workDescription;
        workAvarageBudget = _workAvarageBudget;
    }

    function createOffer(
        uint256 _offerPrice,
        bool _isCyberShield,
        string _description,
        uint256 _deadline,
        string _title,
        address _tokenContract,
        bool _isBNB
    ) public nonReentrant returns (uint256) {
        Offer memory newOffer =
            Offer({
                offerPrice: _offerPrice,
                freelancerAddress: msg.sender,
                isCyberShield: _isCyberShield,
                description: _description,
                deadline: _deadline,
                title: _title,
                offerTokenContract: _tokenContract,
                tokenContractIsBNB: _isBNB
            });
        offers[msg.sender].push(newOffer);
        allFreelancerAddress.push(msg.sender);
        workOfferCount++;
        
        return 2;
    }

    function deleteOffer() public nonReentrant returns (uint256) {
        delete offers[msg.sender];
        workOfferCount--;
        
        return 2;
    }

    function updateOffer(
        uint256 _offerPrice,
        bool _isCyberShield,
        string _description,
        string _title,
        uint256 _index
    ) public nonReentrant returns (uint256) {
        Offer storage data = offers[msg.sender][_index];
        data.offerPrice = _offerPrice;
        data.isCyberShield = _isCyberShield;
        data.description = _description;
        data.title = _title;
        
        return 2;
    }

    function getOfferData(address _freelancerAddress, uint256 _index)
        public
        view
        returns (
            uint256,
            address,
            bool,
            string,
            string,
            uint256,
            address,
            bool
        )
    {
        Offer storage data = offers[_freelancerAddress][_index];
        return (
            data.offerPrice,
            data.freelancerAddress,
            data.isCyberShield,
            data.description,
            data.title,
            data.deadline,
            data.offerTokenContract,
            data.tokenContractIsBNB
        );
    }

    function selectOffer(
        address _freelancerAddress,
        uint256 _index,
        address _approveraddress
    ) public payable onlyApprover {
        require(CyberToken.balanceOf(_approveraddress) >= deployedFromContract.approverMinCyberLimit(), "Incorrect Token balance!");
        require(msg.sender == employerAddress, "Incorrect employerAddress!");
        Offer storage data = offers[_freelancerAddress][_index];
        require(msg.value >= data.offerPrice, "Value should be bigger than offer price!");
        freelancerAddress = data.freelancerAddress;
        workStatus = true;
        workStartDate = now;
        deadLine = data.deadline;
        isWorkFreelancer = true;
        workPrice = data.offerPrice;
        approverAddress = _approveraddress;
        approverStatus = true;
        isBNB = true;
    }
    
    function selectOfferWithToken(
        address _freelancerAddress,
        uint256 _index,
        address _approveraddress
    ) public onlyApprover {
        require(CyberToken.balanceOf(_approveraddress) >= deployedFromContract.approverMinCyberLimit(), "Incorrect Token balance!");
        require(msg.sender == employerAddress, "Incorrect employerAddress!");
        Offer storage data = offers[_freelancerAddress][_index];
        require(IERC20(data.offerTokenContract).allowance(msg.sender, address(this)) >= data.offerPrice, "Value should be bigger than offer price!");
        require(IERC20(data.offerTokenContract).balanceOf(msg.sender) >= data.offerPrice, "Value should be bigger than offer price!");
        freelancerAddress = data.freelancerAddress;
        workStatus = true;
        workStartDate = now;
        deadLine = data.deadline;
        isWorkFreelancer = true;
        workPrice = data.offerPrice;
        approverAddress = _approveraddress;
        approverStatus = true;
        isBNB = false;
        tokenContractAddress = data.offerTokenContract;
        IERC20(data.offerTokenContract).transferFrom(msg.sender, address(this), data.offerPrice);
    }

    function freelancerSendFile(string _workFilesLink) public {
        require(msg.sender == freelancerAddress, "Incorrect freelancerAddress!");
        freelancerSendFiles = true;
        workFilesLink = _workFilesLink;
        freelancerSendFilesDate = now;
    }

    function employerReceiveFile(uint256 _puan) public onlyApprover {
        require(msg.sender == employerAddress, "Incorrect employerAddress!");
        if (isBNB) {
        freelancerAddress.transfer(workPrice);
        } else {
            IERC20(tokenContractAddress).transfer(freelancerAddress, workPrice);
        }
        deployedFromContract.setPuan(_puan, freelancerAddress);
        workEndDate = now;
    }

    function employerCancel(string _depscription) public {
        require(msg.sender == employerAddress, "Incorrect employerAddress!");
        approverConfirmStatus = 0;
        employerCancelDescription = _depscription;
        deployedFromContract.setApproverWorkAddress(this, approverAddress);
    }

    function confirmApprover(string _description) public onlyApprover {
        require(CyberToken.balanceOf(msg.sender) >= deployedFromContract.approverMinCyberLimit(), "Incorrect Token balance!");
        require(msg.sender == approverAddress, "User should be approvee address!");
        require(approverConfirmStatus == 0, "ApproverConfirmStatus should be 0!");
        approverConfirmStatus = 1;
        if(isBNB) {
        freelancerAddress.transfer(workPrice);
        } else {
            IERC20(tokenContractAddress).transfer(freelancerAddress, workPrice);
        }
        deployedFromContract.deleteApproverWorkAddress(this, approverAddress);
        approverReport = _description;
        workEndDate = now;
        deployedFromContract.sendApproverCyberCoin(approverAddress);
    }

    function cancelApprover(string _description) public onlyApprover {
        require(CyberToken.balanceOf(msg.sender) >= deployedFromContract.approverMinCyberLimit(), "Incorrect!");
        require(msg.sender == approverAddress, "User should be approvee address!");
        require(approverConfirmStatus == 0, "ApproverConfirmStatus should be 0!");
        approverConfirmStatus = 2;
        if (isBNB) {
        employerAddress.transfer(workPrice);
        } else {
            IERC20(tokenContractAddress).transfer(employerAddress, workPrice);
        }
        deployedFromContract.deleteApproverWorkAddress(this, approverAddress);
        approverReport = _description;
        deployedFromContract.sendApproverCyberCoin(approverAddress);
    }

    function sendDeadline() public onlyApprover nonReentrant returns (uint256) {
        require(now > deadLine, "Before deadLine now!");
        if(isBNB) {
            employerAddress.transfer(workPrice);
        } else {
            IERC20(tokenContractAddress).transfer(employerAddress, workPrice);
        }
        
        return 2;
    }
}
