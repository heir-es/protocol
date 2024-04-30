pragma solidity 0.8.20;

import {Heiress} from "../src/Heiress.sol";

import "forge-std/Script.sol";
//forge verify-contract 0x84464897824C77C0Ef39Ea611bAD719B66b2e5c6 DeployScriptSepolia --chain-id 11155111 --etherscan-api-key $ETHERSCAN_API_KEY --watch --constructor-args $(cast abi-encode "constructor(address,address,address,address,address)" 0xb0FB186eE2dA2d13BF52Cf917559f5D576797D15 0x5d426CF009D91172AA0584935C59F28434fD572a 0xb8b6Fb00EaA741aa070954d55495616358a74A7d 0x9b031a4f8878Ad4E5F022678c0226704bf66e77c 0xF808252aab4D5aeD10C8a601198319084B0c7e6d)

contract DeployScriptSepolia is Script {
    address densityModule0 = 0xb0FB186eE2dA2d13BF52Cf917559f5D576797D15;
    address densityModule1 = 0x5d426CF009D91172AA0584935C59F28434fD572a;
    address densityModule2 = 0xb8b6Fb00EaA741aa070954d55495616358a74A7d;
    address densityModule3 = 0x9b031a4f8878Ad4E5F022678c0226704bf66e77c;
    address densityModule4 = 0xF808252aab4D5aeD10C8a601198319084B0c7e6d;

    function run() public returns (Heiress heiress) {
        vm.startBroadcast();
        heiress = new Heiress(densityModule0, densityModule1, densityModule2, densityModule3, densityModule4);
        vm.stopBroadcast();
    }
}
