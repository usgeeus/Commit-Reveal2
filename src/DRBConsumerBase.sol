// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {ICommitReveal2} from "./ICommitReveal2.sol";

/**
 * @notice Interface for contracts using VRF randomness
 * @dev USAGE
 *
 * @dev Consumer contracts must inherit from VRFConsumerBase, and can
 * @dev initialize Coordinator address in their constructor as
 */
abstract contract DRBConsumerBase {
    error OnlyCoordinatorCanFulfill(address have, address want);
    error InvalidRequest(uint256 requestId);

    /// @dev The RNGCoordinator contract
    ICommitReveal2 internal immutable i_commitreveal2;

    /**
     * @param rngCoordinator The address of the RNGCoordinator contract
     */
    constructor(address rngCoordinator) {
        i_commitreveal2 = ICommitReveal2(rngCoordinator);
    }

    receive() external payable virtual {}

    /**
     * @return requestId The ID of the request
     * @dev Request Randomness to the Coordinator
     */
    function _requestRandomNumber(
        uint32 callbackGasLimit
    ) internal returns (uint256) {
        uint256 requestId = i_commitreveal2.requestRandomNumber{
            value: msg.value
        }(callbackGasLimit);
        return requestId;
    }

    /**
     * @param round The round of the randomness
     * @param randomNumber the random number
     * @dev Callback function for the Coordinator to call after the request is fulfilled.  Override this function in your contract
     */
    function fulfillRandomWords(
        uint256 round,
        uint256 randomNumber
    ) internal virtual;

    /**
     * @param requestId The round of the randomness
     * @param randomNumber The random number
     * @dev Callback function for the Coordinator to call after the request is fulfilled. This function is called by the Coordinator
     */
    function rawFulfillRandomWords(
        uint256 requestId,
        uint256 randomNumber
    ) external {
        require(
            msg.sender == address(i_commitreveal2),
            OnlyCoordinatorCanFulfill(msg.sender, address(i_commitreveal2))
        );
        fulfillRandomWords(requestId, randomNumber);
    }
}
