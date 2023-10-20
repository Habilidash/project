// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import {IHabilidashTkn} from "../interface/IHTKN.sol"; 
import {IDashSupreme} from "../interface/IDashSupreme.sol"; 

contract Subasta {
    address addHBTkn =0xF02d3e4D8A514C27E29115Af9176617584d24cCB; 
    IHabilidashTkn public htkn =IHabilidashTkn(addHBTkn);
    address addDashNft =0x6a64B8863396eDBbFa60f00F22429E44Eed9bcd3;
    IDashSupreme public dashSupreme = IDashSupreme(addDashNft);
    
    struct Auction {
        uint256 startTime;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid; 
    }

    uint256 private startTime;
    uint256 private endTime;

    event SubastaCreada(bytes32 indexed _auctionId, address indexed _creator);
    event OfertaPropuesta(address indexed _bidder, uint256 _bid);
    event SubastaFinalizada(address indexed _winner, uint256 _bid);

    error CantidadIncorrectaEth();
    error TiempoInvalido();
    error SubastaInexistente();
    error FueraDeTiempo();
    error OfertaInvalida();
    error SubastaEnMarcha();

    mapping(bytes32 => Auction) public subastas;
    bytes32[] public listaSubastasActivas;
    mapping(bytes32 => uint256) listaSubastasMapping;
    mapping(bytes32 => mapping(address => uint256)) public ofertasGuardadas;
    

    uint256 contador; // 0
    function creaSubasta() public {
        startTime = block.timestamp;
        endTime = startTime + 55 minutes;
        bytes32 _auctionId = _createId(startTime, endTime);

        if ((address(this).balance) == 0){
            revert CantidadIncorrectaEth();
        }else if (endTime < startTime) {
            revert TiempoInvalido();
        }
        subastas[_auctionId]= Auction(startTime, endTime, address(0), 0);
        listaSubastasActivas.push(_auctionId);
        listaSubastasMapping[_auctionId] =contador;
        contador++;

        emit SubastaCreada(_auctionId, msg.sender);        
    }

    function proponerOferta(bytes32 _auctionId) public payable {
// emit OfertaPropuesta(msg.sender, auction.offers[msg.sender]);
        if (listaSubastasActivas[listaSubastasMapping[_auctionId]] != _auctionId) {
            revert SubastaInexistente();
        }
        if (block.timestamp < subastas[_auctionId].startTime || subastas[_auctionId].endTime < block.timestamp ){
            revert FueraDeTiempo();
        }
        if (subastas[_auctionId].highestBid > msg.value) {
            revert OfertaInvalida();
        }
        emit OfertaPropuesta(msg.sender, msg.value); 
        
        subastas[_auctionId].highestBidder = msg.sender;
        subastas[_auctionId].highestBid = msg.value;

        if((subastas[_auctionId].endTime - block.timestamp) < 1 minutes) {
            subastas[_auctionId].endTime += 90;
        }
        ofertasGuardadas[_auctionId][msg.sender] += msg.value;
    }

    function finalizarSubasta(bytes32 _auctionId) public {
        if (listaSubastasActivas[listaSubastasMapping[_auctionId]] != _auctionId) {
            revert SubastaInexistente();
        }
        if (block.timestamp <= subastas[_auctionId].endTime ){
            revert SubastaEnMarcha();
        }
        for (uint i = 0; i < listaSubastasActivas.length; i++) {
            if (listaSubastasActivas[i] == _auctionId) {
                delete listaSubastasActivas[i];
            }
        }
        emit SubastaFinalizada(subastas[_auctionId].highestBidder, subastas[_auctionId].highestBid);
        dashSupreme.setUser(0, subastas[_auctionId].highestBidder, 30 days);
    }
    function recuperarOferta(bytes32 _auctionId) public {

        if (block.timestamp <= subastas[_auctionId].endTime ){
            revert SubastaEnMarcha();
        }
        // payable(msg.sender).transfer(ofertasGuardadas[msg.sender]);
        payable(msg.sender).transfer(ofertasGuardadas[_auctionId][msg.sender]);
        ofertasGuardadas[_auctionId][msg.sender] = 0;
    }

    function verSubastasActivas() public view returns (bytes32[] memory) {
        return listaSubastasActivas;
    }
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////   INTERNAL METHODS  ///////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
    function _createId(
        uint256 _startTime,
        uint256 _endTime
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    _startTime,
                    _endTime,
                    msg.sender,
                    block.timestamp
                )
            );
    }
}