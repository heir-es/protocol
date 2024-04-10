pragma solidity 0.8.20;

//import IERC721
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Heirloom} from "../src/Heirloom.sol";
import {MockERC20} from "./MockERC20.sol";
import "forge-std/Test.sol";

contract HeirloomTest is Test {
    Heirloom heirloom;
    MockERC20 token;

    address father = 0xC5518DfB40870Fc5F08AB726Ff646Cb99a2F1Cc7;
    address daughter = address(3);
    uint256 father_module0_tokenId = 43;
    address father_module0_tokenId_account = 0x13038fC10B77272f17803bD37eCEc5700C2909a3;
    address nft_buyer = address(2);

    address densityModule0 = 0x388F65b210314C5052969b669a60C5b8a9983FdF;
    address densityModule1 = 0xEEF78a3baA3132B954f3Ad73b20aff070a489E1E;
    address densityModule2 = 0x70aC7f95A8D29E6a2b7d6C71B3001114BE156D3e;
    address densityModule3 = 0x66705a07fa726e19BB132c8d8BEcBe6713670160;
    address densityModule4 = 0x5335F23eBeef15906D348Cda4Fba6Abcb584Ac3B;

    uint256 will_timer = 1 days;
    uint256 money_amount = 100 ether;

    function setUp() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"));

        token = new MockERC20("SOPH", "SOPH");
        token.mint(father, money_amount);

        heirloom = new Heirloom(densityModule0, densityModule1, densityModule2, densityModule3, densityModule4);
    }

    //////////////////////////////////////////   setModule    //////////////////////////////////////////

    function test_setModule() public {

        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(heirloom), true);
        heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        token.transfer(father_module0_tokenId_account, money_amount);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        //console.log(beneficiary, "==", daughter);
        //assertEq(beneficiary, daughter, "Beneficiary should be daughter");
        require(beneficiary == daughter, "Beneficiary should be daughter");
        //console.log(timer, "==", will_timer + block.timestamp);
        //assertEq(timer, will_timer + block.timestamp, "Timer should be 1 day from now");
        require(timer == will_timer + block.timestamp, "Timer should be 1 day from now");
    }

    function test_setModule_Again() public {

        uint256 new_will_timer = 2 days;
        address son = address(4);
        
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(heirloom), true);
        heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        heirloom.setModule(densityModule0, father_module0_tokenId, new_will_timer, son);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        //console.log(beneficiary, "==", daughter);
        //assertEq(beneficiary, daughter, "Beneficiary should be daughter");
        require(beneficiary == son, "Beneficiary should be daughter");
        //console.log(timer, "==", will_timer + block.timestamp);
        //assertEq(timer, will_timer + block.timestamp, "Timer should be 1 day from now");
        require(timer == new_will_timer + block.timestamp, "Timer should be 1 day from now");

    }

    function test_setModule_WrongModule() public {
        //"DMS: This contract is not supported."
        
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        vm.expectRevert(/*"DMS: This contract is not supported."*/);
        Heirloom.setModule(address(1), father_module0_tokenId, will_timer, daughter);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == address(0), "Beneficiary should be 0");
        require(timer == 0, "Timer should be 0");
    }

    function test_setModule_TimerExpired() public {
        //"Module: The module timer has expired"
        
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        vm.warp(will_timer + block.timestamp + 1);

        vm.expectRevert("Module: The module timer has expired");
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == daughter, "Beneficiary should be daughter");
        require(timer == block.timestamp - 1, "Timer should be now");

    }

    function test_setModule_NotOwner() public {
        //"Module: Only the owner of the module can call this function"
        
        vm.startPrank(daughter);

        //IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        vm.expectRevert("Module: Only the owner of the module can call this function");
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == address(0), "Beneficiary should be 0");
        require(timer == 0, "Timer should be 0");
    }

    function test_setModule_NotApproved() public {
        //"Module: User has not approved the densityModule to this contract"
        
        vm.startPrank(father);

        //IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        vm.expectRevert("Module: User has not approved the densityModule to this contract");
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == address(0), "Beneficiary should be 0");
        require(timer == 0, "Timer should be 0");
    }

    function test_setModule_BeneficiaryZero() public {
        //"Beneficiary cannot be address(0)"
        
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        vm.expectRevert("Beneficiary cannot be address(0)");
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, address(0));

        vm.stopPrank();

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == address(0), "Beneficiary should be 0");
        require(timer == 0, "Timer should be 0");
    }

    function test_setModule_OwnerTransferred() public {
        //"Module: The module owner has transferred the module"
        address nft_buyer_son = address(4);
        uint256 nft_buyer_timer = 2 days;

        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        IERC721(densityModule0).safeTransferFrom(father, nft_buyer, father_module0_tokenId, "");

        vm.stopPrank();

        vm.startPrank(nft_buyer);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, nft_buyer_timer, nft_buyer_son);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == nft_buyer_son, "Beneficiary should be nft_buyer_son");
        require(timer == nft_buyer_timer + block.timestamp, "Timer should be 2 day from now");

    }

    //////////////////////////////////////////   claimModule    //////////////////////////////////////////

    function test_claimModule() public {
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        vm.stopPrank();

        vm.warp(will_timer + block.timestamp + 1);

        Heirloom.claimModule(densityModule0, father_module0_tokenId);

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == address(0), "Beneficiary should be 0");
        require(timer == 0, "Timer should be 0");

        //check if the token is transferred to the beneficiary
        //console.log(IERC721(densityModule0).ownerOf(father_module0_tokenId), "==", daughter);
        require(IERC721(densityModule0).ownerOf(father_module0_tokenId) == daughter, "Token should be transferred to the beneficiary");
    }

    function test_claimModule_TimerNotExpired() public {
        //"Module: The module timer has not expired yet"
        
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        vm.stopPrank();

        vm.warp(will_timer + block.timestamp - 2);
        vm.expectRevert("Module: The module timer has not expired yet");
        Heirloom.claimModule(densityModule0, father_module0_tokenId);

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == daughter, "Beneficiary should be daughter");
        require(timer != 0, "Timer should not be 0");
    }

    function test_claimModule_OwnerTransferred() public {
        //"Module: The module owner has transferred the module"
        
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        IERC721(densityModule0).safeTransferFrom(father, nft_buyer, father_module0_tokenId, "");

        vm.stopPrank();

        vm.warp(will_timer + block.timestamp + 1);
        Heirloom.claimModule(densityModule0, father_module0_tokenId);

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == address(0), "Beneficiary should be 0");
        require(timer == 0, "Timer should be 0");
        require(IERC721(densityModule0).ownerOf(father_module0_tokenId) == nft_buyer, "Token should be transferred to the beneficiary");

    }

    function test_claimModule_ApproveRevoked() public {
        //"Module: The module owner has revoked the approval"
        
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);
        
        IERC721(densityModule0).setApprovalForAll(address(Heirloom), false);

        vm.stopPrank();

        vm.warp(will_timer + block.timestamp + 1);

        Heirloom.claimModule(densityModule0, father_module0_tokenId);

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == address(0), "Beneficiary should be 0");
        require(timer == 0, "Timer should be 0");
        //console.log(IERC721(densityModule0).ownerOf(father_module0_tokenId), "!=", daughter);
        require(IERC721(densityModule0).ownerOf(father_module0_tokenId) == father, "Token should not be transferred to the beneficiary");
    }

    //////////////////////////////////////////   resetModuleTimer    //////////////////////////////////////////

    function test_resetModuleTimer() public {
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);


        vm.warp(will_timer + block.timestamp - 2);

        uint256 new_timer = 2 days;
        Heirloom.resetModuleTimer(densityModule0, father_module0_tokenId, new_timer);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == daughter, "Beneficiary should be daughter");
        require(timer == new_timer + block.timestamp, "Timer should be 2 day from now");
        require(IERC721(densityModule0).ownerOf(father_module0_tokenId) == father, "Token should not be transferred to the beneficiary");
    }

    function test_resetModuleTimer_ModuleNotSet() public {
        //"Module: The module is not set"
        
        vm.startPrank(father);

        vm.expectRevert("Module: Module settings requirements not met.");
        Heirloom.resetModuleTimer(densityModule0, father_module0_tokenId, will_timer);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == address(0), "Beneficiary should be 0");
        require(timer == 0, "Timer should be 0");
    }

    function test_resetModuleTimer_TimerExpired() public {
        //"Module: The module timer has expired"
        
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        vm.warp(will_timer + block.timestamp + 1);

        vm.expectRevert("Module: The module timer has expired");
        Heirloom.resetModuleTimer(densityModule0, father_module0_tokenId, will_timer);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == daughter, "Beneficiary should be daughter");
        require(timer == block.timestamp - 1, "Timer should be now");
    }

    function test_resetModuleTimer_NotOwner() public {
        //"Module: Only the owner of the module can call this function"
        
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        vm.stopPrank();

        vm.expectRevert("Module: Only the owner of the module can call this function");
        Heirloom.resetModuleTimer(densityModule0, father_module0_tokenId, will_timer);


        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == daughter, "Beneficiary should be daughter");
        require(timer == will_timer + block.timestamp, "Timer should be 1 day from now");
    }

    function test_resetModuleTimer_NotApproved() public {
        //"Module: User has not approved the densityModule to this contract"
        
        vm.startPrank(father);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), true);
        Heirloom.setModule(densityModule0, father_module0_tokenId, will_timer, daughter);

        IERC721(densityModule0).setApprovalForAll(address(Heirloom), false);

        vm.expectRevert("Module: User has not approved the densityModule to this contract");
        Heirloom.resetModuleTimer(densityModule0, father_module0_tokenId, will_timer);

        vm.stopPrank();

        (address beneficiary, uint256 timer) = Heirloom.viewModuleInformation(densityModule0, father_module0_tokenId);
        require(beneficiary == daughter, "Beneficiary should be daughter");
        require(timer == will_timer + block.timestamp, "Timer should be 1 day from now");
    }

}