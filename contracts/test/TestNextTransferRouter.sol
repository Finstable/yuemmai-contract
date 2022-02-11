// SPDX-License-Identifier: MIT
// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File contracts/shared/abstracts/Committee.sol


pragma solidity 0.8.11;

abstract contract Committee {
  address public committee;

  event CommitteeSet(address indexed oldCommittee, address indexed newCommittee, address indexed caller);

  modifier onlyCommittee() {
    require(msg.sender == committee, "Committee: restricted only committee");
    _;
  }

  function setCommittee(address _committee) public virtual onlyCommittee {
    emit CommitteeSet(committee, _committee, msg.sender);
    committee = _committee;
  }
}


// File contracts/shared/interfaces/IKAP20/IKAP20.sol

pragma solidity >=0.6.0;

interface IKAP20 {
  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  function adminTransfer(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool success);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/shared/interfaces/IAdminKAP20Router.sol

pragma solidity >=0.6.0;

interface IAdminKAP20Router {
  function setKKUB(address _KKUB) external;

  function isAllowedAddr(address _addr) external view returns (bool);

  function allowedAddrLength() external view returns (uint256);

  function allowedAddrByIndex(uint256 _index) external view returns (address);

  function allowedAddrByPage(uint256 _page, uint256 _limit) external view returns (address[] memory);

  function addAddress(address _addr) external;

  function revokeAddress(address _addr) external;

  function internalTransfer(
    address _token,
    address _feeToken,
    address _from,
    address _to,
    uint256 _value,
    uint256 _feeValue
  ) external returns (bool);

  function externalTransfer(
    address _token,
    address _feeToken,
    address _from,
    address _to,
    uint256 _value,
    uint256 _feeValue
  ) external returns (bool);

  function internalTransferKKUB(
    address _feeToken,
    address _from,
    address _to,
    uint256 _value,
    uint256 _feeValue
  ) external returns (bool);

  function externalTransferKKUB(
    address _feeToken,
    address _from,
    address _to,
    uint256 _value,
    uint256 _feeValue
  ) external returns (bool);

  function externalTransferKKUBToKUB(
    address _feeToken,
    address _from,
    address _to,
    uint256 _value,
    uint256 _feeValue
  ) external returns (bool);
}


// File contracts/shared/interfaces/IAdminProjectRouter.sol

pragma solidity >=0.6.0;

interface IAdminProjectRouter {
  function isSuperAdmin(address _addr, string calldata _project) external view returns (bool);

  function isAdmin(address _addr, string calldata _project) external view returns (bool);
}


// File contracts/shared/interfaces/INextTransferRouter.sol

pragma solidity >=0.6.0;

interface INextTransferRouter {
  function transferFrom(
    string memory _project,
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) external;
}


// File contracts/shared/libraries/EnumerableSetAddress.sol

pragma solidity >=0.6.0;

library EnumerableSetAddress {
  struct AddressSet {
    address[] _values;
    mapping(address => uint256) _indexes;
  }

  function add(AddressSet storage set, address value) internal returns (bool) {
    if (!contains(set, value)) {
      set._values.push(value);
      set._indexes[value] = set._values.length;
      return true;
    } else {
      return false;
    }
  }

  function remove(AddressSet storage set, address value) internal returns (bool) {
    uint256 valueIndex = set._indexes[value];
    if (valueIndex != 0) {
      uint256 toDeleteIndex = valueIndex - 1;
      uint256 lastIndex = set._values.length - 1;
      address lastvalue = set._values[lastIndex];
      set._values[toDeleteIndex] = lastvalue;
      set._indexes[lastvalue] = toDeleteIndex + 1;
      set._values.pop();
      delete set._indexes[value];
      return true;
    } else {
      return false;
    }
  }

  function contains(AddressSet storage set, address value) internal view returns (bool) {
    return set._indexes[value] != 0;
  }

  function length(AddressSet storage set) internal view returns (uint256) {
    return set._values.length;
  }

  function at(AddressSet storage set, uint256 index) internal view returns (address) {
    require(set._values.length > index, "EnumerableSet: index out of bounds");
    return set._values[index];
  }

  function getAll(AddressSet storage set) internal view returns (address[] memory) {
    return set._values;
  }

  function get(
    AddressSet storage set,
    uint256 _page,
    uint256 _limit
  ) internal view returns (address[] memory) {
    require(_page > 0 && _limit > 0);
    uint256 tempLength = _limit;
    uint256 cursor = (_page - 1) * _limit;
    uint256 _addressLength = length(set);
    if (cursor >= _addressLength) {
      return new address[](0);
    }
    if (tempLength > _addressLength - cursor) {
      tempLength = _addressLength - cursor;
    }
    address[] memory addresses = new address[](tempLength);
    for (uint256 i = 0; i < tempLength; i++) {
      addresses[i] = at(set, cursor + i);
    }
    return addresses;
  }
}


// File contracts/shared/libraries/TransferHelper.sol

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
  function safeApprove(
    address token,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes('approve(address,uint256)')));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
  }

  function safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes('transfer(address,uint256)')));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
  }

  function safeTransferFrom(
    address token,
    address from,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
  }

  function safeTransferKUB(address to, uint256 value) internal {
    (bool success, ) = to.call{ value: value }(new bytes(0));
    require(success, "TransferHelper: KUB_TRANSFER_FAILED");
  }
}


// File contracts/periphery/NextTransferRouter.sol

pragma solidity 0.8.11;





abstract contract Authorization is Committee {
  IAdminProjectRouter public adminProjectRouter;
  string public constant PROJECT = "transfer-router";

  event AdminProjectRouterSet(address indexed _caller, address indexed _oldAddress, address indexed _newAddress);

  modifier onlySuperAdmin() {
    require(adminProjectRouter.isSuperAdmin(msg.sender, PROJECT), "Authorization: restricted only super admin");
    _;
  }

  modifier onlyAdmin() {
    require(adminProjectRouter.isAdmin(msg.sender, PROJECT), "Authorization: restricted only admin");
    _;
  }

  modifier onlySuperAdminOrAdmin() {
    require(
      adminProjectRouter.isSuperAdmin(msg.sender, PROJECT) || adminProjectRouter.isAdmin(msg.sender, PROJECT),
      "Authorization: restricted only super admin or admin"
    );
    _;
  }

  function setAdminProjectRouter(address _adminProjectRouter) external onlyCommittee {
    emit AdminProjectRouterSet(msg.sender, address(adminProjectRouter), _adminProjectRouter);
    adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
  }
}

contract TestNextTransferRouter is Authorization, INextTransferRouter {
  using EnumerableSetAddress for EnumerableSetAddress.AddressSet;

  mapping(string => EnumerableSetAddress.AddressSet) private _allowedTokens;
  mapping(string => EnumerableSetAddress.AddressSet) private _allowedAddresses;

  EnumerableSetAddress.AddressSet private _kTokens;
  IAdminKAP20Router public adminKAP20Router;

  address public KKUB;

  event KKUBSet(address indexed _caller, address indexed _oldAddress, address indexed _newAddress);
  event AdminKAP20RouterSet(address indexed _caller, address indexed _oldAddress, address indexed _newAddress);

  modifier allowedTransfer(string memory _project, address _token) {
    // require(_allowedAddresses[_project].contains(msg.sender), "NextTransferRouter: restricted only allowed address");
    // require(_allowedTokens[_project].contains(_token), "NextTransferRouter: restricted only allowed token");
    _;
  }

  constructor(
    address _adminProjectRouter,
    address _adminKAP20Router,
    address _KKUB,
    address _committee,
    address[] memory kTokens_
  ) {
    adminProjectRouter = IAdminProjectRouter(_adminProjectRouter);
    adminKAP20Router = IAdminKAP20Router(_adminKAP20Router);
    KKUB = _KKUB;
    committee = _committee;
    for (uint256 i = 0; i < kTokens_.length; i++) {
      _kTokens.add(kTokens_[i]);
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////

  function setKKUB(address _KKUB) external onlyCommittee {
    emit KKUBSet(msg.sender, KKUB, _KKUB);
    KKUB = _KKUB;
  }

  function setAdminKAP20Router(address _adminKAP20Router) external onlyCommittee {
    emit AdminKAP20RouterSet(msg.sender, address(adminKAP20Router), _adminKAP20Router);
    adminKAP20Router = IAdminKAP20Router(_adminKAP20Router);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////

  function addKToken(address _kToken) external onlySuperAdmin {
    require(_kToken != address(0) && _kToken != address(this), "NextTransferRouter: invalid address");
    require(_kTokens.add(_kToken), "NextTransferRouter: address already exists");
  }

  function removeKToken(address _kToken) external onlySuperAdmin {
    require(_kTokens.remove(_kToken), "NextTransferRouter: address does not exist");
  }

  function kTokenLength() external view returns (uint256) {
    return _kTokens.length();
  }

  function kTokenByIndex(uint256 _index) external view returns (address) {
    return _kTokens.at(_index);
  }

  function kTokenByPage(uint256 _page, uint256 _limit) external view returns (address[] memory) {
    return _kTokens.get(_page, _limit);
  }

  function isKToken(address _kToken) external view returns (bool) {
    return _kTokens.contains(_kToken);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////

  function isAllowedAddr(string memory _project, address _addr) external view returns (bool) {
    return _allowedAddresses[_project].contains(_addr);
  }

  function allowedAddrLength(string memory _project) external view returns (uint256) {
    return _allowedAddresses[_project].length();
  }

  function allowedAddrByIndex(string memory _project, uint256 _index) external view returns (address) {
    return _allowedAddresses[_project].at(_index);
  }

  function allowedAddrByPage(
    string memory _project,
    uint256 _page,
    uint256 _limit
  ) external view returns (address[] memory) {
    return _allowedAddresses[_project].get(_page, _limit);
  }

  function addAddress(string memory _project, address _addr) external onlySuperAdmin {
    require(_addr != address(0) && _addr != address(this), "NextTransferRouter: invalid address");
    require(_allowedAddresses[_project].add(_addr), "NextTransferRouter: address already exists");
  }

  function removeAddress(string memory _project, address _addr) external onlySuperAdmin {
    require(_allowedAddresses[_project].remove(_addr), "NextTransferRouter: address does not exist");
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////

  function isAllowedToken(string memory _project, address _token) external view returns (bool) {
    return _allowedTokens[_project].contains(_token);
  }

  function allowedTokenLength(string memory _project) external view returns (uint256) {
    return _allowedTokens[_project].length();
  }

  function allowedTokenByIndex(string memory _project, uint256 _index) external view returns (address) {
    return _allowedTokens[_project].at(_index);
  }

  function allowedTokenByPage(
    string memory _project,
    uint256 _page,
    uint256 _limit
  ) external view returns (address[] memory) {
    return _allowedTokens[_project].get(_page, _limit);
  }

  function addToken(string memory _project, address _token) external onlySuperAdmin {
    require(_token != address(0) && _token != address(this), "NextTransferRouter: invalid address");
    require(_allowedTokens[_project].add(_token), "NextTransferRouter: address already exists");
  }

  function removeToken(string memory _project, address _token) external onlySuperAdmin {
    require(_allowedTokens[_project].remove(_token), "NextTransferRouter: address does not exist");
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////

  function transferFrom(
    string memory _project,
    address _token,
    address _from,
    address _to,
    uint256 _amount
  ) external override allowedTransfer(_project, _token) {
    if (_token == KKUB) {
      adminKAP20Router.externalTransferKKUB(address(0), _from, _to, _amount, 0);
    } else if (_kTokens.contains(_token)) {
      adminKAP20Router.externalTransfer(_token, address(0), _from, _to, _amount, 0);
    } else {
      // TransferHelper.safeTransferFrom(_token, _from, _to, _amount);
      // IKAP20(_token).transferFrom(_from, _to, _amount);
      adminKAP20Router.externalTransfer(_token, address(0), _from, _to, _amount, 0);
    }
  }
}