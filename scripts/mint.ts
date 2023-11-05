import { ethers } from "hardhat";

async function main() {
    let contract : any;
    // address: 0x75e101A316a6280539e927c0EE1361CEECaF8b80
    // contract is Random.sol
    contract = await ethers.getContractAt("Random", "0x54a7D5D45930F6894ccBC90d989759a048Db9816");

    // call rollDice() function, print the tx hash and the return value
    let tx = await contract.rollDice();
    console.log(tx.hash);
    let result = await tx.wait();
    console.log(result?.getResult());
}

main()