// Just a standard hardhat-deploy deployment definition file!
const func = async (hre) => {
    const { deployments, getNamedAccounts } = hre
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
  
    const initialSupply = 1000000
    const name = 'My Optimistic Token'
  
    await deploy('ERC20', {
      from: deployer,
      args: [initialSupply, name],
      gasPrice: hre.ethers.BigNumber.from('0'),
      gasLimit: 8999999,
      log: true
    })
  }
  
  func.tags = ['ERC20']
  module.exports = func
  