pragma solidity ^0.4.17;

contract Apuestas {

   struct Apuesta {
       uint256 id;
       
       uint256 ganar;
       uint256 perder;
       address creador;
       address consumidor;
       
       uint8 golesLocal;
       uint8 golesVisitante;
       
       bool procesado;
   }
   
   struct Partido {
       uint256 idPartido;
       string local;
       string visitante;
   }
   
   uint256 currentApuestaId = 1;
   
   mapping(uint256 => mapping (uint256 => Apuesta)) public apuestas;
   
   mapping(uint256 => Partido) public partidos;
   
   address authorized;
   
   function Apuestas() public payable {
       authorized = msg.sender;
       partidos[1] = Partido(1, "Madrid", "Barcelona");
       partidos[2] = Partido(2, "Atletico de Madrid", "Athletic de Bilbao");
   }

   event IdApuesta(uint256 idApuesta);   
    
   function crearApuesta(uint256 beneficio, uint256 perdidas, uint8 golesLocal, uint8 golesVisitante, uint256 idPartido) public payable {
       require(msg.value == perdidas);
       require(existsMatch(idPartido));
       
       apuestas[idPartido][currentApuestaId] = Apuesta(
               currentApuestaId,
               beneficio,
               perdidas,
               msg.sender,
               address(0),
               golesLocal,
               golesVisitante,
               false
           );
           IdApuesta(currentApuestaId);
           currentApuestaId++;
           
   }
   
   function aceptarApuesta(uint256 idPartido, uint256 idApuesta) public payable {
       
       require(existsMatch(idPartido));
       require(apuestas[idPartido][idApuesta].id != 0);
       require(apuestas[idPartido][idApuesta].consumidor == address(0));
       
       require(msg.value == apuestas[idPartido][idApuesta].ganar);
       
       apuestas[idPartido][idApuesta].consumidor = msg.sender;
   }
   
   function solveApuestas(uint256 idPartido, uint8 golesLocal, uint8 golesVisitante) public {
       require(msg.sender == authorized);
       require(existsMatch(idPartido));
   
       for(uint i=1;i<currentApuestaId;i++){
           Apuesta ap = apuestas[idPartido][i];
           if(!ap.procesado){
               ap.procesado = true;
               if(ap.golesLocal == golesLocal && ap.golesVisitante == golesVisitante ){
                   ap.creador.transfer(ap.ganar + ap.perder);
               } else {
                   ap.consumidor.transfer(ap.perder + ap.perder);
               }
           }
       }
   }
   
   function startMatch(uint256 idPartido){
       require(msg.sender == authorized);
       require(existsMatch(idPartido));
       
       for(uint i=1;i<currentApuestaId;i++){
           Apuesta ap = apuestas[idPartido][i];
           if(!ap.procesado && ap.consumidor == address(0)){
               ap.procesado = true;
               ap.creador.transfer(ap.perder);
           }
       }
          }
   
   function existsMatch(uint256 idPartido) private returns (bool){
       return partidos[idPartido].idPartido == idPartido && idPartido > 0;
   }
}