// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "./VRFConsumerBaseV2Upgradeable.sol";

import { ERC721URIStorageUpgradeable, ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @notice A Chainlink VRF consumer which uses randomness to mimic the rolling
 * of a 20 sided dice
 */

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract Random is Initializable, VRFConsumerBaseV2Upgradeable, ERC721URIStorageUpgradeable {
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Sepolia coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 s_keyHash;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 40,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations;

    // For this example, retrieve 1 random value in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords;
    address s_owner;

    // map rollers to requestIds
    mapping(uint256 => uint256) private s_rollers;
    // map vrf results to rollers
    // mapping(address => uint256) private s_results;

    event DiceRolled(uint256 indexed requestId, address indexed roller);
    event DiceLanded(uint256 indexed requestId, uint256 indexed result);

    string[] private attributes1;
    uint8[] private attributeWeights1;
    string[] private attributes2;
    uint8[] private attributeWeights2;

    uint256 private _nextTokenId;

    /**
     * @notice Constructor inherits VRFConsumerBaseV2
     *
     * @dev NETWORK: Sepolia
     */
    function initialize() public initializer {
        s_owner = msg.sender;
        s_subscriptionId = 6641;
        vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
        s_keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
        callbackGasLimit = 500000;
        requestConfirmations = 3;
        numWords = 1;
        attributes1 = ["neko", "inu", "usagi", "kitsune", "tanuki"];
        attributeWeights1 = [30, 30, 5, 25, 10]; 
        attributes2 = ["ancient", "traditional", "fantasy", "cyberpunk", "steampunk"];
        attributeWeights2 = [10, 20, 40, 20, 10]; 
    
        _nextTokenId = 0;
        __VRFConsumerBaseV2Upgradeable_init(vrfCoordinator);
        __ERC721_init("The Luck Game", "LUCK");
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    }

    /**
     * @notice Requests randomness
     * @dev Warning: if the VRF response is delayed, avoid calling requestRandomness repeatedly
     * as that would give miners/VRF operators latitude about which VRF response arrives first.
     * @dev You must review your implementation details with extreme care.
     *
     */
    function rollDice() public returns (uint256 requestId) {
        // require(s_results[_nextTokenId++] == 0, "Already rolled"); // not set yet
        
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        
        _safeMint(msg.sender, _nextTokenId);

        s_rollers[requestId] = _nextTokenId++;

        emit DiceRolled(requestId, msg.sender);
    }

    /**
     * @notice Callback function used by VRF Coordinator to return the random number to this contract.
     *
     * @dev Some action on the contract state should be taken here, like storing the result.
     * @dev WARNING: take care to avoid having multiple VRF requests in flight if their order of arrival would result
     * in contract states with different outcomes. Otherwise miners or the VRF operator would could take advantage
     * by controlling the order.
     * @dev The VRF Coordinator will only send this function verified responses, and the parent VRFConsumerBaseV2
     * contract ensures that this method only receives randomness from the designated VRFCoordinator.
     *
     * @param requestId uint256
     * @param randomWords  uint256[] The random result returned by the oracle.
     */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        // first get msg.sender out
        // address recipient = s_results[s_rollers[requestId]];

        uint256 a1 = ((randomWords[0] % 536) % 100) + 1;
        uint256 a2 = ((randomWords[0] % 825) % 100) + 1;
        
        // s_results[s_rollers[requestId]] = randomWords[0];
        
        emit DiceLanded(requestId, randomWords[0]);

        // Pick attribute options based on random number and probabilities
        uint8 b1 = pickAttributeOption(false, a1);
        uint8 b2 = pickAttributeOption(true, a2);
        
        /*
        string memory metadata = string(abi.encodePacked(
            '{"name": "The Luck Game",',
            '"description": "The Universe provably and randomly forged this NFT. Only ~', (attributeWeights1[b1] * attributeWeights2[b2] / 100), ' of these will ever exist.",',
            '"attribute1": "', attributes1[b1], '", ',
            '"attribute2": "', attributes2[b2], '"}'
        )); */

        // Mint NFT and set metadata
        // _safeMint(recipient, _nextTokenId);
        _setTokenURI(s_rollers[requestId], string(abi.encodePacked("https://djsucnsf.vercel.app/", attributes1[b1], "/", attributes2[b2], ".json")));
    }

    function pickAttributeOption(bool attribute, uint256 randomNumber) internal view returns (uint8) {
        uint256 totalProbability = 0;
        string[] memory attributeOptions;
        uint8[] memory attributeWeights;
        if (!attribute) {
            attributeOptions = attributes1;
            attributeWeights = attributeWeights1;
        } else if (attribute) {
            attributeOptions = attributes2;
            attributeWeights = attributeWeights2;
        }
        for (uint8 i = 0; i < attributeWeights.length; i++) {
            totalProbability += attributeWeights[i];
            if (randomNumber <= totalProbability) {
                return i;
            }
        }
        return 0;
    }


    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }
}
