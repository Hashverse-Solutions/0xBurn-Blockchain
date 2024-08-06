// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function burnOxBurnToken(address to, uint256 amount) external;
}

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

contract ZeroXDAO is Ownable {
    // Create a struct named Proposal containing all relevant information
    struct Proposal {
        // proposal title
        uint256 id;
        // proposal title
        string title;
        // proposal description
        string description;
        // deadline - the UNIX timestamp until which this proposal is active. Proposal can be executed after the deadline has been exceeded.
        uint256 deadline;
        // yayVotes - number of yay votes for this proposal
        uint256 yayVotes;
        // nayVotes - number of nay votes for this proposal
        uint256 nayVotes;
        // executed - whether or not this proposal has been executed yet. Cannot be executed before the deadline has been exceeded.
        bool executed;
        // result - whether this proposal has has passed or failed.
        string result;
        // voters - a mapping of address to booleans indicating whether that user has already cast a vote or not
        mapping(address => bool) voters;
        //total vote count
        uint256 voteCount;
        // Votes Struct call
        VoteStruct voteStruct;
    }

    struct VoteStruct {
        //community vote yes count
        uint256 communityYes;
        //team vote yes count
        uint256 teamYes;
        //partner vote yes count
        uint256 partnerYes;
        //community vote yes count
        uint256 communityNo;
        //team vote yes count
        uint256 teamNo;
        //partner vote yes count
        uint256 partnerNo;
    }

    struct Team {
        address addr;
    }

    struct Partner {
        address addr;
    }

    // Create a mapping of ID to Proposal
    mapping(uint256 => Proposal) public proposals;
    // Number of proposals that have been created
    uint256 public numProposals;

    // Create a modifier which only allows a function to be
    // called by someone who owns at least 1 token/NFT/Owner
    modifier HolderOnlyProposal() {
        require(
            IERC721(nftAddress).balanceOf(msg.sender) > 0 ||
                isTeam(msg.sender) == true ||
                owner() == msg.sender,
            "ZeroXDAO: Mint partner NFT to create a proposal"
        );
        _;
    }

    // Create a modifier which only allows a function to be
    // called by someone who owns at least 1 token/NFT/Owner
    modifier HolderOnlyVoting() {
        require(
            IERC20(tokenAddress).balanceOf(msg.sender) > 0 ||
                IERC721(nftAddress).balanceOf(msg.sender) > 0 ||
                isTeam(msg.sender) == true ||
                owner() == msg.sender,
            "ZeroXDAO: You must have 0xBurn tokens to vote"
        );
        _;
    }

    // Create a modifier which only allows a function to be
    // called if the given proposal's deadline has not been exceeded yet
    modifier activeProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline > block.timestamp,
            "ZeroXDAO: DEADLINE_EXCEEDED"
        );
        _;
    }

    // Create a modifier which only allows a function to be
    // called if the given proposals' deadline HAS been exceeded
    // and if the proposal has not yet been executed
    modifier inactiveProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline <= block.timestamp,
            "ZeroXDAO: DEADLINE_NOT_EXCEEDED"
        );
        require(
            proposals[proposalIndex].executed == false,
            "ZeroXDAO: PROPOSAL_ALREADY_EXECUTED"
        );
        _;
    }

    // The payable allows this constructor to accept an ETH deposit when it is being deployed
    string public title;
    string public description;
    address public nftAddress;
    address public tokenAddress;
    Team[] public teams;
    Partner[] public partners;

    event ProposalCreated(uint256 indexed id, string title, address creator);
    event Voted(uint256 indexed id, address voter);
    event Executed(uint256 indexed id, string indexed result);

    constructor(
        string memory _title,
        string memory _description,
        address _tokenAddress,
        address _nftAddress,
        address[] memory _addresses
    ) payable {
        title = _title;
        description = _description;
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;

        for (uint256 i = 0; i < _addresses.length; i++) {
            teams.push(Team(_addresses[i]));
        }
    }

    /// @dev createProposal allows a token holder to create a new proposal in the DAO
    /// @return Returns the proposal index for the newly created proposal
    function createProposal(
        string memory _title,
        string memory _description,
        uint256 _deadline
    ) external HolderOnlyProposal returns (uint256) {
        require(
            block.timestamp < _deadline,
            "ZeroXDAO: Deadline already passed"
        );
        Proposal storage proposal = proposals[numProposals];
        proposal.id = numProposals + 1;
        proposal.title = _title;
        proposal.description = _description;
        proposal.deadline = _deadline;
        numProposals++;

        emit ProposalCreated(numProposals + 1, _title, msg.sender);

        return numProposals - 1;
    }

    /// @dev voteOnProposal allows a CryptoDevsNFT holder to cast their vote on an active proposal
    /// @param proposalIndex - the index of the proposal to vote on in the proposals array
    /// @param votingFee - 1 0xBurn voting fee which will be burned
    /// @param _vote - the type of vote they want to cast
    function voteOnProposal(
        uint256 proposalIndex,
        uint256 votingFee,
        bool _vote
    ) external HolderOnlyVoting activeProposalOnly(proposalIndex) {
        require(votingFee >= 1 ether, "ZeroXDAO: Invalid voting fee");

        // IERC20(tokenAddress).transfer(address(0), votingFee);
        IERC20(tokenAddress).burnOxBurnToken(msg.sender, votingFee);

        Proposal storage proposal = proposals[proposalIndex];

        require(
            !proposal.voters[msg.sender],
            "ZeroXDAO: Already voted for this proposal"
        );

        bool teamWallet = isTeam(msg.sender);
        bool partnerWallet = isPartner(msg.sender);

        if (_vote == true) {
            if (teamWallet == true) {
                proposal.voteStruct.teamYes++;
                proposal.yayVotes++;
                proposal.voters[msg.sender] = _vote;
                proposal.voteCount++;
                emit Voted(proposalIndex, msg.sender);
                return;
            } else if (partnerWallet == true) {
                proposal.voteStruct.partnerYes++;
                proposal.yayVotes++;
                proposal.voters[msg.sender] = _vote;
                proposal.voteCount++;
                emit Voted(proposalIndex, msg.sender);
                return;
            } else {
                proposal.voteStruct.communityYes++;
                proposal.yayVotes++;
                proposal.voters[msg.sender] = _vote;
                proposal.voteCount++;
                emit Voted(proposalIndex, msg.sender);
                return;
            }
        } else {
            if (teamWallet == true) {
                proposal.voteStruct.teamNo++;
                proposal.nayVotes++;
                proposal.voters[msg.sender] = _vote;
                proposal.voteCount++;
                emit Voted(proposalIndex, msg.sender);
                return;
            } else if (partnerWallet == true) {
                proposal.voteStruct.partnerNo++;
                proposal.nayVotes++;
                proposal.voters[msg.sender] = _vote;
                proposal.voteCount++;
                emit Voted(proposalIndex, msg.sender);
                return;
            } else {
                proposal.voteStruct.communityNo++;
                proposal.nayVotes++;
                proposal.voters[msg.sender] = _vote;
                proposal.voteCount++;
                emit Voted(proposalIndex, msg.sender);
                return;
            }
        }
    }

    /// @dev executeProposal allows any CryptoDevsNFT holder to execute a proposal after it's deadline has been exceeded
    /// @param proposalIndex - the index of the proposal to execute in the proposals array
    /// @param _execute - string to match the reult of proposal
    function executeProposal(
        uint256 proposalIndex,
        string memory _execute
    ) external HolderOnlyProposal inactiveProposalOnly(proposalIndex) {
        Proposal storage proposal = proposals[proposalIndex];

        uint256 teamYesCount = proposal.voteStruct.teamYes;
        uint256 partnerYesCount = proposal.voteStruct.partnerYes;
        uint256 communityYesCount = proposal.voteStruct.communityYes;
        uint256 teamNoCount = proposal.voteStruct.teamNo;
        uint256 partnerNoCount = proposal.voteStruct.partnerNo;
        uint256 communityNoCount = proposal.voteStruct.communityNo;
        uint256 weightedYesVotes = 0;
        uint256 weightedNoVotes = 0;

        if (communityYesCount + communityNoCount > 9) {
            // Calculate the weighted yes votes
            weightedYesVotes =
                (teamYesCount * 20) +
                (partnerYesCount * 20) +
                (communityYesCount * 60);
            // Calculate the weighted no votes
            weightedNoVotes =
                (teamNoCount * 20) +
                (partnerNoCount * 20) +
                (communityNoCount * 60);
        } else {
            // Calculate the weighted yes votes
            weightedYesVotes = (teamYesCount * 20) + (partnerYesCount * 20);
            // Calculate the weighted no votes
            weightedNoVotes = (teamNoCount * 20) + (partnerNoCount * 20);
        }

        // Calculate the weighted total votes
        uint256 totalWeightedVotes = weightedYesVotes + weightedNoVotes;

        // Ensure the total weighted votes are non-zero to avoid division by zero
        require(totalWeightedVotes > 0, "ZeroXDAO: No votes cast");

        // Determine the result based on the majority of weighted votes
        if (
            keccak256(abi.encodePacked(_execute)) ==
            keccak256(abi.encodePacked("PASS"))
        ) {
            // Calculate the percentage of yes votes
            uint256 yesVotePercentage = (weightedYesVotes * 100) /
                totalWeightedVotes;
            // Pass if yes votes are greater than or equal to 50%
            if (yesVotePercentage >= 50) {
                proposal.result = "PASS";
            } else {
                proposal.result = "FAIL";
            }
        } else {
            proposal.result = "FAIL";
        }

        proposal.executed = true;
        emit Executed(proposalIndex, proposal.result);
    }

    /// @dev isTeam checks if an address is a team
    /// @param _address the address to be checked as a team
    function isTeam(address _address) public view returns (bool) {
        for (uint256 i = 0; i < teams.length; i++) {
            if (teams[i].addr == _address) {
                return true; // Address is found in teams
            }
        }
        return false; // Address is not found in teams
    }

    /// @dev isPartner checks if an address is a partner
    /// @param _address the address to be checked as a partner
    function isPartner(address _address) public view returns (bool) {
        for (uint256 i = 0; i < partners.length; i++) {
            if (partners[i].addr == _address) {
                return true; // Address is found in teams
            }
        }
        return false; // Address is not found in teams
    }

    /// @dev addPartner checks if an address is a partner
    /// @param _address the address to be checked as a partner
    function addPartner(address _address) external {
        partners.push(Partner(_address));
    }
}
