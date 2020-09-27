# CoinDistribution

## Introduction
This smart contract aims to distribute cryptocurrency.
According to the number of members joining the smart contract and the total number of cryptocurrencies, the smart contract will allocate the same amount of cryptocurrency to the members.

## Pre-declaration
The smart contract is compiled with [solidity](https://solidity.readthedocs.io) and the detail of this program is as follows.
### Compiler version

```javascript
pragma solidity >=0.4.22 <0.6.0;
```

- Set compiler version.


### Variables
```javascript
address owner;
uint NumOfAccounts;
mapping(address => uint256) accountid;
address payable[] accounts;
uint PriceLimit=100 ether;
```

- `address` is a type to store address.
- `mapping` is a type to transform type and store hash value.
- `payable` means it is permitted to transfer cryptocurrency.


### Modifier

```javascript
modifier OnlyOwner(){
    require(msg.sender==owner,"Admin only!");
    _;
}
    
modifier OnlyMember(){
    if (accounts.length==0){
        require(msg.sender==owner,"Member only!");
    }
    else{
        for(uint i=0; i<accounts.length;i++){
            require(msg.sender==accounts[i] || msg.sender==owner,"Member only!"); 
        }
    }
    _;
}
```
- The modifier is usually used as checks before executing functions and check if the user's permissions or balance are sufficient.
- `_;` must be declared at the end of modifier to indicate return.


## Function details

There are three types of functions in the solidity as follows:

![](https://i.imgur.com/RkagAnV.png)
Orange means **Not Payable** type.

![](https://i.imgur.com/OQBYSLV.png)
Red means **Payable** type. 
As long as the function is related to cryptocurrency transactions, it belong to this type.

![](https://i.imgur.com/NbxKO3O.png)
Blue means **Call** type.

**Not Payable** and **Payable** types must pay gas to initiate the transaction except **Call** type.

### Add multiple member accounts
![](https://i.imgur.com/aY6uGz1.png)

![](https://i.imgur.com/pThZmKI.png)
```javascript
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
    }
}
```
- The owner can add multiple members by entering their addresses.
- Input format: `["0xFF","...","0xFF"]`


### Remove a member account
![](https://i.imgur.com/sh2DOXf.png)

![](https://i.imgur.com/NJJ5nQA.png)
```javascript
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
```
- The owner can delete a member by entering his address.
- Input format: `0xFF`




### Remove all member accounts
![](https://i.imgur.com/z1NgBxT.png)


![](https://i.imgur.com/ViqYSCU.png)
```javascript
function _RemoveAllAccount() OnlyOwner public {
    require(NumOfAccounts>0,"No accounts!");
    for (uint i=0; i<accounts.length;i++){
        delete accountid[accounts[i]];
        NumOfAccounts--;
    }
    delete accounts;
}
```
- The owner can delete all the members.





### Withdraw all the cryptocurrency
![](https://i.imgur.com/N1A79Ty.png)

![](https://i.imgur.com/OHlnVJl.png)
```javascript
function _ReturnAllMoney()public payable OnlyOwner{
    require(address(this).balance > 0,"No money!");
    msg.sender.transfer(address(this).balance);
}
```

- The owner can withdraw all the cryptocurrency.





### Split the cryptocurrency
![](https://i.imgur.com/k7dCZMG.png)

![](https://i.imgur.com/KKkpstM.png)
```javascript
function _SplitAllMoney()public payable OnlyOwner{
    require(address(this).balance > 0,"No money!");
    uint ShareMoney=address(this).balance/(accounts.length);
    for (uint i=0; i<accounts.length;i++){
        accounts[i].transfer(ShareMoney);
    }
}
```

- The owner can split the cryptocurrency to each member equally.




### Join the membership yourself
![](https://i.imgur.com/S0T2Pr5.png)

![](https://i.imgur.com/53iTkZa.png)
```javascript
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
```
- Everyone can join the membership yourself.




### Delete the membership yourself
![](https://i.imgur.com/s8RSvQ2.png)

![](https://i.imgur.com/gX2jSrV.png)
```javascript
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
```
- Everyone can delete the membership yourself.




### Deposit the cryptocurrency
![](https://i.imgur.com/Sc1jHxc.png)

![](https://i.imgur.com/5XTKs2d.png)

```javascript
function Deposit() public payable{
    require(msg.value>0 && msg.value < PriceLimit,"Deposit at most 100 ether!");
}
```
- Everyone can deposit the cryptocurrency into smart contract.




### Get all the member accounts
![](https://i.imgur.com/5PgqMQK.png)


![](https://i.imgur.com/Oml6oeY.png)
```javascript
function GetAllAccountID()public OnlyMember view returns(address payable[] memory){
    return accounts;
}
```
- The members can view all the membership's ID.




### Get the balance from the smart contract
![](https://i.imgur.com/FFy3Fz7.png)


![](https://i.imgur.com/lkzhHM8.png)
```javascript
function GetBalance() public OnlyMember view returns(uint)  {
    return address(this).balance;
}
```
- The members can view all the balance from the smart contract.



### Get the number of members
![](https://i.imgur.com/2zcezru.png)


![](https://i.imgur.com/wBuOsFV.png)
```javascript
function GetNumOfAccounts() public OnlyMember view returns(uint)  {
    return NumOfAccounts;
}
```
- The members can view all the number of members.

