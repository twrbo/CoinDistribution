pragma solidity >=0.4.22 <0.6.0;

contract CoinDistribution{
    address owner;
    uint public NumOfAccounts;
    mapping(address => uint256) accountid;
    address payable[] accounts;
    uint PriceLimit=100 ether;
    
    constructor()public payable{
        owner=msg.sender;
    }
    
    modifier OnlyOwner(){
        require(msg.sender==owner);
        _;
    }
    
    function Deposit() public payable{
        require(msg.value>0 && msg.value < PriceLimit,"Deposit at most 100 ether!");
    }
    
    function SplitAllMoney()public payable OnlyOwner{
        uint ShareMoney=address(this).balance/(accounts.length);
        for (uint i=0; i<accounts.length;i++){
            accounts[i].transfer(ShareMoney);
        }
    }
    
    
    function ReturnAllMoney()public payable OnlyOwner{
        msg.sender.transfer(address(this).balance);
    }
    
    function GetBalance() public view OnlyOwner returns(uint)  {
         return address(this).balance;
    }

    //input format ["0x000000000,0x000000000"]
    function AddAccount(address payable[]memory _accountAddress) OnlyOwner public {
        //account repeat or not
        for (uint i=0; i<accounts.length;i++){
            for (uint u=0; u<_accountAddress.length;u++){
                require(_accountAddress[u]!=accounts[i],"repaet account");
            }
        }
        for (uint i=0;i<_accountAddress.length;i++){
            uint id = accountid[_accountAddress[i]];
            if (id == 0) {
                accountid[_accountAddress[0]] = accounts.length;
                id = accounts.length++;
            }
            accounts[id] = _accountAddress[i];
            NumOfAccounts++;
            //accounts[id].transfer(1 ether); //give 1 ether after add account
        }
        
    }
    
    //input format 0x000000000
    function RemoveAccount(address _accountAddress) OnlyOwner public {
        for (uint i=0; i<accounts.length;i++){
            if(accounts[i]==_accountAddress){
                delete accounts[i];
                delete accountid[_accountAddress];
                NumOfAccounts--;
                for (uint u = i; u<accounts.length-1; u++){
                    accounts[u] = accounts[u+1];
                }
                accounts.length--;
            }
        }
    }
   
   function AllAccountID()public view returns(address payable[] memory){
           return accounts;
   }

}