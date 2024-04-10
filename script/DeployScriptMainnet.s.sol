pragma solidity 0.8.20;

import {Heirloom} from "../src/Heirloom.sol";

import "forge-std/Script.sol";

contract DeployScript is Script {
    address densityModule0 = 0x388F65b210314C5052969b669a60C5b8a9983FdF;
    address densityModule1 = 0xEEF78a3baA3132B954f3Ad73b20aff070a489E1E;
    address densityModule2 = 0x70aC7f95A8D29E6a2b7d6C71B3001114BE156D3e;
    address densityModule3 = 0x66705a07fa726e19BB132c8d8BEcBe6713670160;
    address densityModule4 = 0x5335F23eBeef15906D348Cda4Fba6Abcb584Ac3B;

    function deploy() public returns(Heirloom heirloom) {
        
        heirloom = new Heirloom(densityModule0, densityModule1, densityModule2, densityModule3, densityModule4);
        
    }

}