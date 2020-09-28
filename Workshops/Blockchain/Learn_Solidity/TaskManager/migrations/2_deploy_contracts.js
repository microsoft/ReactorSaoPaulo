var TaskManager = artifacts.require("TaskManager");
 
module.exports = function(deployer) {
  deployer.deploy(TaskManager);
};