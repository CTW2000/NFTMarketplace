const hre = require("hardhat");
const { ethers, getNamedAccounts, deployments } = hre;

const PRICE = ethers.parseEther("0.1");


//npx hardhat run scripts/mint-and-list.js --network sepolia
async function mintAndList() {
    const { deployer } = await getNamedAccounts();
    const nftMarketplaceDeployment = await deployments.get("NftMarketplace");
    const basicNftDeployment = await deployments.get("BasicNft");
    const nftMarketplace = await ethers.getContractAt("NftMarketplace", nftMarketplaceDeployment.address, await ethers.getSigner(deployer));
    const basicNft = await ethers.getContractAt("BasicNft", basicNftDeployment.address, await ethers.getSigner(deployer));
    const mintTx = await basicNft.mintNft();
    await mintTx.wait(1);
    const tokenId = await basicNft.getTokenCounter();
    console.log("Token ID:", tokenId.toString());

    const approveTx = await basicNft.approve(nftMarketplace.target, tokenId);
   await approveTx.wait(1);
   console.log("Approved");

   const listTx = await nftMarketplace.listItem(basicNft.target, tokenId, PRICE);
   await listTx.wait(1);
   console.log("Item listed");
}


mintAndList()
.then(()=>process.exit(0))
.catch((error)=>{
    console.error(error);
    process.exit(1);
});