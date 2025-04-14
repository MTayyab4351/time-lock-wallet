
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;




/*
 Time Lock Wallet Smart Contract
 Create a smart contract that locks crypto assets for a
 predetermined time, preventing early withdrawals. The
 wallet will ensure that users cannot sell their assets
 prematurely, promoting long-term investment
 strategies. Solidity’s time functions will be used to
 enforce the locking mechanism securely.*/






contract timeLockWallet{
    address  public owner;
    uint public startingTime;
    uint public endingTime;
    address public benificary; // the person who can withdraw the funds or sends funds to other address after the lock time period is complete
    bool public isLock;
    string public description;
    uint public lockduration;  //120 is in second and its 2 min
    
    mapping(address=>uint) public totalDeposit;

    event deposit( address depositer,uint amount);
    event setBenificary( address benificary,address owner);
    event setTimeLock(address benificary,uint startingTime, uint endingTime,string  descripton);
    event setTimeLockUpdate( uint updatedTime,address benificary,string  descripton);
    event withdraw(string  descripton, uint amount);



     constructor(){
        owner=msg.sender;
        benificary=address(0);
        startingTime=0;
        endingTime=0;
        isLock=true;
     }

     modifier onlyowner(){
        require(msg.sender==owner,"only owner can call this function");
        _;
     }



//function for set benificary address by owner

function setbenificary(address _benificary) public  onlyowner  {
    require(msg.sender==owner,"only owner can call this function");
    benificary=_benificary;
    emit  setBenificary(  _benificary, msg.sender);

}


//function for deposit the amount
function depositvalue() public   payable {
   require( startingTime!=0,"time not started yet");
   require(msg.value>0,"deposite amount must be positive");
   totalDeposit[msg.sender]+=msg.value;
   emit  deposit( msg.sender,msg.value);

}


//function for time lock
function lock(uint _lockduration,string memory _description) public onlyowner returns(bool ){
   startingTime=block.timestamp;
   require(endingTime==0,"time is not unlock yet");
   lockduration=_lockduration;
   endingTime=startingTime+lockduration;
   description=_description;
   emit  setTimeLock( benificary,block.timestamp, endingTime,  _description);
   if(lockduration==0){
      return true;
   }
     else {
         return false;
      }
   
}



//function for update time lock
function updatetime(uint _updatedTime,string memory _description) public onlyowner {
   require(endingTime>0,"time is not unlock yet");
   endingTime=_updatedTime;
   require(_updatedTime>block.timestamp,"new ending time must be greater than current time stamp");
   emit  setTimeLockUpdate( _updatedTime,benificary,_description);


}



// function for funds withdraw
function withdrawcash() public payable{
   require(block.timestamp>endingTime,"time not ended yet");
   require(msg.sender==benificary,"only benificary");
   require(totalDeposit[benificary]>0,"can withdraw funds");
   payable(benificary).transfer(totalDeposit[benificary]);
   emit withdraw(description, totalDeposit[benificary]);

}



}


