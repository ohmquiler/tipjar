// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;

contract tips {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    // 1. Put fund in smart contract
    function addtips() public payable {}

    // 2. View balance
    function viewtips() public view returns(uint) {
        return address(this).balance;
    }

    // 3. Structure for a Waitress
    struct Waitress {
        address payable walletAddress;
        string name;
        uint percent; // 0 - 100
    }

    Waitress[] public waitress;

    // 4. View waitress
    function viewWaitress() public view returns(Waitress[] memory) {
        return waitress;
    }

    // 🔹 helper: คำนวณ percent รวม
    function totalPercent() public view returns(uint total) {
        for (uint i = 0; i < waitress.length; i++) {
            total += waitress[i].percent;
        }
    }

    // 5. Add waitress (percent รวมต้องไม่เกิน 100)
    function addWaitress(
        address payable walletAddress,
        string memory name,
        uint percent
    ) public onlyOwner {

        require(walletAddress != address(0), "Invalid address");
        require(percent <= 100, "Percent > 100");
        require(totalPercent() + percent <= 100, "Total percent exceed 100");

        // check duplicate
        for(uint i = 0; i < waitress.length; i++) {
            require(
                waitress[i].walletAddress != walletAddress,
                "Waitress already exists"
            );
        }

        waitress.push(Waitress(walletAddress, name, percent));
    }

    // 6. Remove waitress
    function removeWaitress(address walletAddress) public onlyOwner {
        for(uint i = 0; i < waitress.length; i++){
            if(waitress[i].walletAddress == walletAddress){
                for (uint j = i; j < waitress.length - 1; j++) {
                    waitress[j] = waitress[j + 1];
                }
                waitress.pop();
                return;
            }
        }
        revert("Waitress not found");
    }

    // 7. Distribute balance
    function distributeBalance() public onlyOwner {
        require(address(this).balance > 0, "No Money");

        uint totalamount = address(this).balance;

        for(uint j = 0; j < waitress.length; j++){
            uint distributeAmount =
                (totalamount * waitress[j].percent) / 100;

            _transferFunds(waitress[j].walletAddress, distributeAmount);
        }
    }

    function _transferFunds(address payable recipient, uint amount) internal {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
    }
}