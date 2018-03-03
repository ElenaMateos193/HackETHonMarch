App = {
  web3Provider: null,
  contracts: {},
  init: function() {
    // Load pets.
    return App.initWeb3();
  },

  initWeb3: function() {
      // Is there an injected web3 instance?
      if (typeof web3 !== 'undefined') {
          App.web3Provider = web3.currentProvider;
      } else {
          // If no injected web3 instance is detected, fall back to Ganache
          App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      }
      web3 = new Web3(App.web3Provider);
    return App.initContract();
  },

  initContract: function() {
      $.getJSON('Apuestas.json', function(data) {
          // Get the necessary contract artifact file and instantiate it with truffle-contract
          var AdoptionArtifact = data;
          App.contracts.Apuestas = TruffleContract(AdoptionArtifact);

          // Set the provider for our contract
          App.contracts.Apuestas.setProvider(App.web3Provider);

          // Use our contract to retrieve and mark the adopted pets
          return App.markAdopted();
      });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-adopt', App.handleAdopt);
  },

  markAdopted: function(adopters, account) {
      var apuestasInstance;

      App.contracts.Apuestas.deployed().then(function(instance) {
		apuestasInstance = instance;
	    var petTemplate = $('#petTemplate');
	    var petsRow = $('#petsRow');

		for (i = 0; i < 10; i++) {
			apuestasInstance.partidos.call(i).then(function(partidos) {
			  if (partidos[1]) {
				   petTemplate.find('.panel-title').text(partidos[1] + '-' + partidos[2]);
		           
				   petsRow.append(petTemplate.html());
			  }
			}).catch(function(err) {
					console.log(err.message);
				});
	  }});	
  },

  handleAdopt: function(event) {
    event.preventDefault();

    var petId = parseInt($(event.target).data('id'));

      var adoptionInstance;

      web3.eth.getAccounts(function(error, accounts) {
          if (error) {
              console.log(error);
          }

          var account = accounts[0];

          App.contracts.Adoption.deployed().then(function(instance) {
              adoptionInstance = instance;

              // Execute adopt as a transaction by sending account
              return adoptionInstance.adopt(petId, {from: account});
          }).then(function(result) {
              return App.markAdopted();
          }).catch(function(err) {
              console.log(err.message);
          });
      });

  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
