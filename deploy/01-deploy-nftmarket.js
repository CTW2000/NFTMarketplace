
const {network} = require("hardhat");
const {developmentChains} = require("../helper-hardhat-config");
const {verify} = require("../utils/verify");


//npx hardhat deploy --network localhost

module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy,log} = deployments;
    const {deployer} = await getNamedAccounts();

    const args = [];
    const nftMarketplace = await deploy("NftMarketplace", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });
    log("NftMarketplace deployed to:", nftMarketplace.address);
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(nftMarketplace.address, args);
    }
};

module.exports.tags = ["all", "nftmarketplace"];




