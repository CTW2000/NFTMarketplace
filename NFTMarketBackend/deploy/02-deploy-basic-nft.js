const {network} = require("hardhat");
const {developmentChains} = require("../helper-hardhat-config");
const {verify} = require("../utils/verify");


//npx hardhat deploy --network localhost

module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy,log} = deployments;
    const {deployer} = await getNamedAccounts();

    const args = [];
    const basicNft = await deploy("BasicNft", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });
    log("BasicNft deployed to:", basicNft.address);
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(basicNft.address, args);
    }
};

module.exports.tags = ["all", "basicnft"];