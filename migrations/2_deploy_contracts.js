var Apuestas = artifacts.require("Apuestas");
var Adoption = artifacts.require("Adoption");

module.exports = function(deployer) {
    deployer.deploy(Apuestas);
    deployer.deploy(Adoption);
};