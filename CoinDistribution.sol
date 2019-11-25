pragma solidity >=0.4.22 <0.6.0;
/////////
contract CoinDistribution{
    address owner;
    uint NumOfAccounts;
    mapping(address => uint256) accountid;
    address payable[] accounts;
    uint PriceLimit=100 ether;
    
    constructor()public payable{
        owner=msg.sender;
    }
    
    modifier OnlyOwner(){
        require(msg.sender==owner,"Admin only!");
        _;
    }
    
    modifier OnlyMember(){
        if (accounts.length==0){
            require(msg.sender==owner,"Member only!");
        }
        else    
        {
            for(uint i=0; i<accounts.length;i++){
                require(msg.sender==accounts[i] || msg.sender==owner,"Member only!"); 
            }
        }
        _;
    }
    
    //input format ["0x000000000","0x000000000"]
    function _AddAccount(address payable[]memory _accountAddress) OnlyOwner public {
        //account repeat or not
        for (uint i=0; i<accounts.length;i++){
            for (uint u=0; u<_accountAddress.length;u++){
                require(_accountAddress[u]!=accounts[i],"Repaet account!");
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
    function _RemoveAccount(address _accountAddress) OnlyOwner public {
        require(NumOfAccounts>0,"No accounts!");
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
    
    function _RemoveAllAccount() OnlyOwner public {
        require(NumOfAccounts>0,"No accounts!");
        for (uint i=0; i<accounts.length;i++){
            delete accountid[accounts[i]];
            NumOfAccounts--;
        }
        delete accounts;
    }
   
    function _ReturnAllMoney()public payable OnlyOwner{
        require(address(this).balance > 0,"No money!");
        msg.sender.transfer(address(this).balance);
    }
   
    function _SplitAllMoney()public payable OnlyOwner{
        require(address(this).balance > 0,"No money!");
        uint ShareMoney=address(this).balance/(accounts.length);
        for (uint i=0; i<accounts.length;i++){
            accounts[i].transfer(ShareMoney);
        }
    }
   
    function AddYourAccountOnly () public{
        for (uint i=0; i<accounts.length;i++){
            require(msg.sender!=accounts[i],"Repaet account!");
        }
        uint id = accountid[msg.sender];
        if (id == 0) {
            accountid[msg.sender] = accounts.length;
            id = accounts.length++;
        }
        accounts[id] = msg.sender;
        NumOfAccounts++;
    }
    
    function DeleteYourAccountOnly() public{
        require(accounts.length>0,"No accounts!");
        for (uint i=0; i<accounts.length;i++){
            require(accounts[i]==msg.sender,"Not in this contract!");
            if(accounts[i]==msg.sender){
                delete accounts[i];
                delete accountid[msg.sender];
                NumOfAccounts--;
                for (uint u = i; u<accounts.length-1; u++){
                    accounts[u] = accounts[u+1];
                }
                accounts.length--;
            }
        }
    }
    
    function Deposit() public payable{
        require(msg.value>0 && msg.value < PriceLimit,"Deposit at most 100 ether!");
    }
   
    function GetAllAccountID()public OnlyMember view returns(address payable[] memory){
           return accounts;
   }
   
       
    function GetBalance() public OnlyMember view returns(uint)  {
         return address(this).balance;
    }
    
    function GetNumOfAccounts() public OnlyMember view returns(uint)  {
         return NumOfAccounts;
    }

}