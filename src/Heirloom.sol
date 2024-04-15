// SPDX-License-Identifier: MIT
///@title Heirloom
///@notice A contract to set the beneficiary of the Sentience Module, which can be claimed after the timer expires
///@author SophiaVerse 
///@dev This contract requires the previous approval of the Sentience Module contract to this contract

pragma solidity 0.8.20;

//import IERC721
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//import ReentrancyGuard 
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Heirloom is ReentrancyGuard {
    // Contract variables and state
    address public densityModule0;
    address public densityModule1;
    address public densityModule2;
    address public densityModule3;
    address public densityModule4;

    event ModuleSet(address indexed _densityModule, uint256 indexed _moduleId, address _beneficiary, uint256 _timer);
    event ModuleBenefiaryReplaced(address indexed _densityModule, uint256 indexed _moduleId, address _previousBeneficiary, address _newBeneficiary);
    event ModuleReset(address indexed _densityModule, uint256 indexed _moduleId, uint256 _timer);
    event ModuleClaimed(address indexed _densityModule, uint256 indexed _moduleId, address _beneficiary);
    event ModuleCanceled(address indexed _densityModule, uint256 indexed _moduleId, uint256 _timer);

    // Mapping of densityModule to module id to beneficiary
    mapping(address densityModule => mapping(uint256 moduleId => address beneficiary)) densityModule_beneficiary;
    // Mapping of densityModule to module id to timer
    mapping(address densityModule => mapping(uint256 moduleId => uint256 timer)) densityModule_timer;
    // Mapping of densityModule to module id to owner
    mapping(address densityModule => mapping(uint256 moduleId => address owner)) densityModule_owner;

    ///@notice Checks if the module is supported by the contract, if there is timer is not expired, if the user is the owner of the module and if the user has approved the module to this contract
    modifier moduleSupportedRequirements(address _densityModule, uint256 _moduleId) {
        address ownerOfModule = IERC721(_densityModule).ownerOf(_moduleId);
        address ownerOfWill = densityModule_owner[_densityModule][_moduleId];

        //Check if _densityModule is one of the approved densityModules
        require(_densityModule == densityModule0 || _densityModule == densityModule1 || _densityModule == densityModule2 || _densityModule == densityModule3 || _densityModule == densityModule4, "Heirloom: This contract is not supported.");

        //Check if the module is not set previously, 
        //and if set, 
        //then check if the owner is the same, i.e., the module was not transferred
        if(ownerOfWill != address(0) && ownerOfWill == ownerOfModule){
            
            if(densityModule_timer[_densityModule][_moduleId] != 0){
                //Check if the module timer is not expired
                require(block.timestamp < densityModule_timer[_densityModule][_moduleId], "Module: The module timer has expired");
            }

        }

        //Check if the user is the owner of the module
        require(msg.sender == ownerOfModule, "Module: Only the owner of the module can call this function");

        //Check if user approved the densityModule to this contract; //isApprovedForAll(address owner, address operator)
        require(IERC721(_densityModule).isApprovedForAll(msg.sender, address(this)), "Module: User has not approved the densityModule to this contract");

        _;
    }

    ///@notice Checks if the module was set previously
    modifier moduleSetRequirements(address _densityModule, uint256 _moduleId) {
        //Check if the module timer is not 0
        require(densityModule_timer[_densityModule][_moduleId] != 0, "Module: Module settings requirements not met.");
        _;
    }

    ///@param _densityModule0 The address of the first densityModule
    ///@param _densityModule1 The address of the second densityModule
    ///@param _densityModule2 The address of the third densityModule
    ///@param _densityModule3 The address of the fourth densityModule
    ///@param _densityModule4 The address of the fifth densityModule
    constructor(address _densityModule0, address _densityModule1, address _densityModule2, address _densityModule3, address _densityModule4) {
        // Initialize contract state
        densityModule0 = _densityModule0;
        densityModule1 = _densityModule1;
        densityModule2 = _densityModule2;
        densityModule3 = _densityModule3;
        densityModule4 = _densityModule4;
    }

    ///@notice This function allows the user to set the beneficiary of the module, which can be claimed after the timer expires
    ///@notice This function can be called by the owner of the module only, anytime before the timer expires
    ///@dev This function requires previous approval of Sentience Module contract to this contract
    ///@param _densityModule The address of the densityModule
    ///@param _moduleId The id of the module
    ///@param _timer The time in seconds after which the module can be claimed
    ///@param _beneficiary The address of the beneficiary
    function setModule(address _densityModule, uint256 _moduleId, uint256 _timer, address _beneficiary) external moduleSupportedRequirements(_densityModule, _moduleId) {
        
        //Check if the beneficiary is not address(0)
        require(_beneficiary != address(0), "Beneficiary cannot be address(0)");

        address _previousBeneficiary = densityModule_beneficiary[_densityModule][_moduleId];
        if(_previousBeneficiary != _beneficiary){
            //Set the beneficiary of the module
            densityModule_beneficiary[_densityModule][_moduleId] = _beneficiary;
            if(_previousBeneficiary != address(0)){
                //Emit event
                emit ModuleBenefiaryReplaced(_densityModule, _moduleId, _previousBeneficiary, _beneficiary);
            }
        }

        //Set the timer of the module
        densityModule_timer[_densityModule][_moduleId] = block.timestamp + _timer;

        //Set the owner of the module
        densityModule_owner[_densityModule][_moduleId] = msg.sender;
        
        //Emit event
        emit ModuleSet(_densityModule, _moduleId, _beneficiary, _timer);
    }

    ///@notice This function allows the user to reset the timer of the module
    ///@notice This function can be called by the owner of the module only, anytime before the timer expires
    ///@dev This function requires previous set of the module
    ///@param _densityModule The address of the densityModule
    ///@param _moduleId The id of the module
    ///@param _timer The time in seconds after which the module can be claimed
    function resetModuleTimer(address _densityModule, uint256 _moduleId, uint256 _timer) external moduleSetRequirements(_densityModule, _moduleId) moduleSupportedRequirements(_densityModule, _moduleId) {
            
        //Reset the timer of the module
        densityModule_timer[_densityModule][_moduleId] = block.timestamp + _timer;

        //Emit event
        emit ModuleReset(_densityModule, _moduleId, _timer);
    }

    ///@notice This function allows the user to claim the module after the timer expires, and the module can be claimed for the beneficiary
    ///@dev This function requires previous set of the module, and if module changes ownership
    function claimModule(address _densityModule, uint256 _moduleId) external nonReentrant {
        
        //Check if the module timer is expired
        require(block.timestamp >= densityModule_timer[_densityModule][_moduleId], "Module: The module timer has not expired yet");

        //Check if the module owner is the same, and the module was not transferred
        address _owner = densityModule_owner[_densityModule][_moduleId];
        address _beneficiary = densityModule_beneficiary[_densityModule][_moduleId];

        //Reset the timer of the module
        densityModule_timer[_densityModule][_moduleId] = 0;

        //Reset the beneficiary of the module
        densityModule_beneficiary[_densityModule][_moduleId] = address(0);

        //Reset the owner of the module
        densityModule_owner[_densityModule][_moduleId] = address(0);

        //If the module is not approved for this contract or owner transferred module, then reset module mappings
        if(IERC721(_densityModule).isApprovedForAll(_owner, address(this)) && IERC721(_densityModule).ownerOf(_moduleId) == _owner){
           
            //Safe transfer the module to the beneficiary
            IERC721(_densityModule).safeTransferFrom(_owner, _beneficiary, _moduleId);
            
            //Emit event
            emit ModuleClaimed(_densityModule, _moduleId, _beneficiary);
        }

        else {
            //Emit event
            emit ModuleCanceled(_densityModule, _moduleId, densityModule_timer[_densityModule][_moduleId]);
        }

    }

    ///@notice This function allows the user to view the information of the module, i.e., the beneficiary and the timer
    ///@param _densityModule The address of the densityModule
    ///@param _moduleId The id of the module
    ///@return The address of the beneficiary and the timer of the module
    function viewModuleInformation(address _densityModule, uint256 _moduleId) external view returns(address, uint256) {
        return (densityModule_beneficiary[_densityModule][_moduleId], densityModule_timer[_densityModule][_moduleId]);
    }
}