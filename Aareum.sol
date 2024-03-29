// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.7.0;

// ------------------------------------------------------------------------------
//
// Aareum (REM) Fixed Supply Token
//
// Dedicated to the preservation and advancement of life (on Earth and beyond).
//
// Thank you to the Ethereum community.
// 
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// ERC Token Standa9rd #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ------------------------------------------------------------------------------

contract ERC20Interface {
      function totalSupply() public view returns (uint256);
      function balanceOf(address tokenOwner) public view returns (uint256 balance);
      function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
      function transfer(address to, uint256 tokens) public returns (bool success);
      function approve(address spender, uint256 tokens) public returns (bool success);
      function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
      function approveAndCall(address spender, uint256 tokens, bytes memory data) public returns (bool success);

      event Transfer(address indexed from, address indexed to, uint256 tokens);
      event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
  }
  
// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------

contract Owned {
      address public owner;
      address public newOwner;

      event OwnershipTransferred(address indexed _from, address indexed _to);

      constructor() public {
          owner = msg.sender;
      }

      modifier onlyOwner {
          require(msg.sender == owner);
          _;
      }

      function transferOwnership(address _newOwner) public onlyOwner {
          newOwner = _newOwner;
      }
      function acceptOwnership() public {
          require(msg.sender == newOwner);
          emit OwnershipTransferred(owner, newOwner);
          owner = newOwner;
          newOwner = address(0);
      }
  }


// ----------------------------------------------------------------------------
// ERC20 Token name, symbol, decimals and total supply
//
// Name        : Aareum
// Symbol      : REM
// 
// ----------------------------------------------------------------------------

contract AareumToken is ERC20Interface, Owned {

     string public symbol;
     string public  name;
     uint8 public decimals;
     uint256 _totalSupply;

     mapping(address => uint256) balances;
     mapping(address => mapping(address => uint256)) allowed;
     
     // ------------------------------------------------------------------------
     // Constructor
     // ------------------------------------------------------------------------

     constructor() public {
         name = "Aareum";
         symbol = "REM";
         decimals = 18;
         _totalSupply = 2000000000000 * 10**uint256(decimals);
         balances[owner] = _totalSupply;
         emit Transfer(address(0), owner, _totalSupply);
     }


     // ------------------------------------------------------------------------
     // Total supply
     // ------------------------------------------------------------------------
     function totalSupply() public view returns (uint256) {
         return _totalSupply.sub(balances[address(0)]);
     }


     // ------------------------------------------------------------------------
     // Get the token balance for account `tokenOwner`
     // ------------------------------------------------------------------------
     function balanceOf(address tokenOwner) public view returns (uint256 balance) {
         return balances[tokenOwner];
     }


     // ------------------------------------------------------------------------
     // Transfer the balance from token owner's account to `to` account
     // - Owner's account must have sufficient balance to transfer
     // - 0 value transfers are allowed
     // ------------------------------------------------------------------------
     function transfer(address to, uint256 tokens) public returns (bool success) {
         balances[msg.sender] = balances[msg.sender].sub(tokens);
         balances[to] = balances[to].add(tokens);
         emit Transfer(msg.sender, to, tokens);
         return true;
     }


     // ------------------------------------------------------------------------
     // Token owner can approve for `spender` to transferFrom(...) `tokens`
     // from the token owner's account
     //
     // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
     // recommends that there are no checks for the approval double-spend attack
     // as this should be implemented in user interfaces
     // ------------------------------------------------------------------------
     function approve(address spender, uint256 tokens) public returns (bool success) {
         allowed[msg.sender][spender] = tokens;
         emit Approval(msg.sender, spender, tokens);
         return true;
     }


     // ------------------------------------------------------------------------
     // Transfer `tokens` from the `from` account to the `to` account
     //
     // The calling account must already have sufficient tokens approve(...)-d
     // for spending from the `from` account and
     // - From account must have sufficient balance to transfer
     // - Spender must have sufficient allowance to transfer
     // - 0 value transfers are allowed
     // ------------------------------------------------------------------------
     function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {
         balances[from] = balances[from].sub(tokens);
         allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
         balances[to] = balances[to].add(tokens);
         emit Transfer(from, to, tokens);
         return true;
     }


     // ------------------------------------------------------------------------
     // Returns the amount of tokens approved by the owner that can be
     // transferred to the spender's account
     // ------------------------------------------------------------------------
     function allowance(address tokenOwner, address spender) public view returns (uint256 remaining) {
         return allowed[tokenOwner][spender];
     }


     // ------------------------------------------------------------------------
     // Token owner can approve `spender` to transferFrom(...) `tokens`
     // from the token owner's account. The `spender` contract function
     // `receiveApproval(...)` is then executed
     // ------------------------------------------------------------------------
     function approveAndCall(address spender, uint256 tokens, bytes memory data) public returns (bool success) {
         allowed[msg.sender][spender] = tokens;
         emit Approval(msg.sender, spender, tokens);
         ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
         return true;
     }


     // ------------------------------------------------------------------------
     // Don't accept ETH
     // ------------------------------------------------------------------------
     fallback () external payable {
         revert();
     }


     // ------------------------------------------------------------------------
     // Owner can transfer out any accidentally sent ERC20 tokens
     // ------------------------------------------------------------------------
     function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
         return ERC20Interface(tokenAddress).transfer(owner, tokens);
     }
 }
