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

    function mintXRC20Token(address to, uint256 amount) external;
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
        // voters - a mapping of address to booleans indicating whether that user has already cast a vote or not
        mapping(address => bool) voters;
        //total vote count
        uint256 voteCount;
    }

    struct Stakeholder {
        address addr;
    }

    // Create an enum named Vote containing possible options for a vote
    enum Vote {
        YAY,
        NAY
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
                isStakeHolder(msg.sender) == true ||
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
                    isStakeHolder(msg.sender) == true ||
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
    Stakeholder[] public stakeholders;
    bool public proposalOwner;

    event ProposalCreated(uint256 indexed id, string title, address creator);
    event Voted(uint256 indexed id, address voter);

    constructor(
        string memory _title,
        string memory _description,
        address _tokenAddress,
        address _nftAddress,
        address[] memory _addresses,
        bool _proposalOwner
    ) payable {
        title = _title;
        description = _description;
        tokenAddress = _tokenAddress;
        nftAddress = _nftAddress;
        proposalOwner = _proposalOwner;

        for (uint256 i = 0; i < _addresses.length; i++) {
            stakeholders.push(Stakeholder(_addresses[i]));
        }
    }

    /// @dev createProposal allows a token holder to create a new proposal in the DAO
    /// @return Returns the proposal index for the newly created proposal
    function createProposal(
        string memory _title,
        string memory _description,
        uint256 _deadline
    ) external HolderOnlyProposal returns (uint256) {
        require(block.timestamp < _deadline, "ZeroXDAO: Deadline already passed");
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
    /// @param _vote - the type of vote they want to cast
    function voteOnProposal(
        uint256 proposalIndex,
        bool _vote
    ) external HolderOnlyVoting activeProposalOnly(proposalIndex) {
        Proposal storage proposal = proposals[proposalIndex];

        require(
            !proposal.voters[msg.sender],
            "ZeroXDAO: Already voted for this proposal"
        );

        if (_vote == true) {
            proposal.yayVotes++;
            proposal.voters[msg.sender] = _vote;
        } else {
            proposal.nayVotes++;
            proposal.voters[msg.sender] = _vote;
        }

        proposal.voteCount++;

        emit Voted(proposalIndex, msg.sender);
    }

    /// @dev executeProposal allows any CryptoDevsNFT holder to execute a proposal after it's deadline has been exceeded
    /// @param proposalIndex - the index of the proposal to execute in the proposals array
    function executeProposal(
        uint256 proposalIndex,
        bool _execute
    ) external HolderOnlyProposal inactiveProposalOnly(proposalIndex) {
        Proposal storage proposal = proposals[proposalIndex];
        proposal.executed = _execute;
    }

    /// @dev isStakeHolder checks if an address is a stakeholder
    /// @param _address the address to be checked as a stakeholder
    function isStakeHolder(
        address _address
    ) public view returns (bool) {
        for (uint256 i = 0; i < stakeholders.length; i++) {
            if (stakeholders[i].addr == _address) {
                return true; // Address is found in stakeholders
            }
        }
        return false; // Address is not found in stakeholders
    }
}