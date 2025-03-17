import { ethers } from "hardhat";

const srcRPC = "http://localhost:8545";
const destRPC = "http://localhost:8546";
const privateKeySigner = process.env.OWNER_SIGNER_KEY;

async function main() {
    const srcProvider = new ethers.providers.JsonRpcProvider(srcRPC);
    const destProvider = new ethers.providers.JsonRpcProvider(destRPC);

    const signer = new ethers.Wallet(privateKeySigner, srcProvider);
    const destSigner = signer.connect(destProvider);
    // network socket address
    
    
    // contract instance
    const UpNativeVault = await ethers.getContractFactory("UpNativeVault");
    const NativePool = await ethers.getContractFactory("NativePool");
    const Vault = await ethers.getContractFactory("Vault");
    const Connector = await ethers.getContractFactory("ConnectorPlug");

    // deploy contracts on the destination network


    
}  