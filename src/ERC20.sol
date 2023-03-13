// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    uint256 private _totalSupply;
    string  private _name;
    string  private _symbol;
    uint8   private _decimals;
    // address private _owner;

    // Metadata: name, symbol, decimals, totalSupply, balances
    function name() public view returns (string memory){
        return _name;
    }
    function symbol() public view returns (string memory){
        return _symbol;
    }
    function decimals() public view returns (uint8){
        return _decimals;
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }
    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }

    // Event: transfer, approval
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(){
        _symbol = "DRM";
        _name = "DREAM";
        _decimals = 18;
        _totalSupply = 100 ether;
        balances[msg.sender] = _totalSupply;
    }

    // Transfer -> external: 컨트랙트 내부에서 호출 불가
    function transfer(address _to, uint256 _value) external returns (bool success){
        // Weakness #1: integer underflow can occur
        // after 0.8.0 -> revert if underflow
        // if wrap with unchecked{} & use require() => allow underflow // can lower gas fee
        require(balances[msg.sender] >= _value, "value exceeds balance");
        // Weakness #2: Do not send to zero address
        // if send to address 0x0 -> token cannot be used any more (usually sent for burning)
        require(_to != address(0), "transfer to the zero address");

        unchecked {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }
        // without event -> hard to track internal transaction
        emit Transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "approve to the zero address");

        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return allowances[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_from!= address(0) && _to != address(0), "zero address not allowed");

        uint256 currentAllowance = allowance(_from, msg.sender);
        require(currentAllowance >= _value, "insufficient allowance");
        unchecked {
            allowances[_from][msg.sender] -= _value;
        }
        require(balances[_from] >= _value, "not enough balance");
        
        unchecked{
            balances[_from] -= _value;
            balances[_to] += _value;
        }
        
        emit Transfer(_from, _to, _value);
    }

    function _mint(address _owner, uint256 _value) internal {
        require(_owner != address(0), "mint to the zero address");
        _totalSupply += _value;
        unchecked{
            balances[_owner] += _value;
        }
        emit Transfer(address(0), _owner, _value);
    }
    function _burn(address _owner, uint256 _value) internal {
        require(_owner != address(0), "burn from the zero address");
        require(balances[_owner] >= _value, "burn amount exceeds balance");
        unchecked{
            balances[_owner] -= _value;
            _totalSupply -= _value;
        }
        emit Transfer(_owner, address(0), _value);
    }
}