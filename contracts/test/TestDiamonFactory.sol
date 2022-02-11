pragma solidity 0.6.7;

// ====== BITKUB ADMIN ======

import "./interfaces/IKAP20.sol";
import "./interfaces/IKAP20Committee.sol";
import "./interfaces/IAdminProjectRouter.sol";
import "./interfaces/IKAP20KYC.sol";
import "./interfaces/IKAP20AdminApprove.sol";
import "./interfaces/IKAP20Blacklist.sol";
import "./interfaces/IKYCBitkubChain.sol";
import "./interfaces/IDiamonFactory.sol";
import "./libraries/Math.sol";
import "./libraries/UQ112x112.sol";
import "./libraries/SafeMath.sol";
import "./interfaces/IDiamonPair.sol";

contract Authorization {
    IAdminProjectRouter public adminRouter;
    string public PROJECT = "diamon-lp";

    modifier onlySuperAdmin() {
        require(
            adminRouter.isSuperAdmin(msg.sender, PROJECT),
            "Restricted only super admin"
        );
        _;
    }

    function setAdmin(address _adminRouter) external onlySuperAdmin {
        adminRouter = IAdminProjectRouter(_adminRouter);
    }
}

contract DiamonKAP20 is Authorization {
    using SafeMath for uint256;

    string public constant name = "Diamon LPs";
    string public constant symbol = "DM-LP";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Accepted KYC level
    uint256 public acceptedKYCLevel;
    string public project;

    IKYCBitkubChain public kyc;

    address public committee;

    modifier onlyCommittee() {
        require(msg.sender == committee, "Restricted only committee");
        _;
    }

    modifier onlySuperAdminOrAdmin() {
        require(
            adminRouter.isSuperAdmin(msg.sender, project) ||
                adminRouter.isAdmin(msg.sender, project),
            "Restricted only super admin or admin"
        );
        _;
    }

    //   constructor(
    //     address _adminRouter,
    //     address _kyc,
    //     address _committee,
    //     uint256 _acceptedKYCLevel
    //   ) public {
    //     adminRouter = IAdminProjectRouter(_adminRouter);
    //     kyc = IKYCBitkubChain(_kyc);
    //     committee = _committee;
    //     acceptedKYCLevel = _acceptedKYCLevel;
    //     project = PROJECT;
    //   }

    constructor() public {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function setProject(string calldata _project) external onlyCommittee {
        project = _project;
    }

    function setCommittee(address _committee) external onlyCommittee {
        committee = _committee;
    }

    function setKYC(address _kyc) external onlyCommittee {
        kyc = IKYCBitkubChain(_kyc);
    }

    function activateOnlyKycAddress() external onlyCommittee {}

    function setAcceptedKycLevel(uint256 _kycLevel) external onlyCommittee {
        acceptedKYCLevel = _kycLevel;
    }

    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        if (allowance[from][msg.sender] != uint256(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(
                value
            );
        }
        _transfer(from, to, value);
        return true;
    }

    function adminApprove(
        address _owner,
        address _spender,
        uint256 _amount
    ) external onlySuperAdminOrAdmin returns (bool) {
        require(
            kyc.kycsLevel(_owner) >= acceptedKYCLevel &&
                kyc.kycsLevel(_spender) >= acceptedKYCLevel,
            "KAP20: Owner or spender address is not a KYC user"
        );

        _approve(_owner, _spender, _amount);
        return true;
    }

    function adminTransfer(
        address from,
        address to,
        uint256 value
    ) external onlyCommittee returns (bool) {
        require(balanceOf[from] >= value);
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);

        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "Diamon: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner]++,
                        deadline
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "Diamon: INVALID_SIGNATURE"
        );
        _approve(owner, spender, value);
    }
}

contract DiamonPair is DiamonKAP20 {
    using SafeMath for uint256;
    using UQ112x112 for uint224;

    uint256 public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant _SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    address public factory;
    address public token0;
    address public token1;

    uint112 private _reserve0; // uses single storage slot, accessible via getReserves
    uint112 private _reserve1; // uses single storage slot, accessible via getReserves
    uint32 private _blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint256 private _unlocked = 1;
    bool public fee100;
    modifier lock() {
        require(_unlocked == 1, "Diamon: LOCKED");
        _unlocked = 0;
        _;
        _unlocked = 1;
    }

    function getReserves()
        public
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        )
    {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
        blockTimestampLast = _blockTimestampLast;
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(_SELECTOR, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "Diamon: TRANSFER_FAILED"
        );
    }

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() public {
        factory = msg.sender;

        adminRouter = IAdminProjectRouter(
            IDiamonFactory(factory).getAdminRounter()
        );
        kyc = IKYCBitkubChain(IDiamonFactory(factory).getKYC());
        committee = IDiamonFactory(factory).getCommittee();
        acceptedKYCLevel = IDiamonFactory(factory).getAcceptedLV();
        project = PROJECT;
    }

    function setFee100(bool _active) external {
        require(msg.sender == factory, "Only Factoy Can Set it");
        fee100 = _active;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "Diamon: FORBIDDEN"); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 reserve0_,
        uint112 reserve1_
    ) private {
        require(
            balance0 <= uint112(-1) && balance1 <= uint112(-1),
            "Diamon: OVERFLOW"
        );
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - _blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && reserve0_ != 0 && reserve1_ != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast +=
                uint256(UQ112x112.encode(reserve1_).uqdiv(reserve0_)) *
                timeElapsed;
            price1CumulativeLast +=
                uint256(UQ112x112.encode(reserve0_).uqdiv(reserve1_)) *
                timeElapsed;
        }
        _reserve0 = uint112(balance0);
        _reserve1 = uint112(balance1);
        _blockTimestampLast = blockTimestamp;
        emit Sync(_reserve0, _reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/2th of the growth in sqrt(k)
    // we sprite 50/50 from 0.3 % to LP and Platform

    function _mintFee(uint112 reserve0_, uint112 reserve1_)
        private
        returns (bool feeOn)
    {
        address feeTo = IDiamonFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(reserve0_).mul(reserve1_));
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint256 denominator = rootK.add(rootKLast);
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // This function Call only for Whitelist Bitkub LP No Share
    function _mintFee100(uint112 reserve0_, uint112 reserve1_)
        private
        returns (bool feeOn)
    {
        address feeTo = IDiamonFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(reserve0_).mul(reserve1_));
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint256 denominator = rootKLast; // because it multiply by Zero
                    uint256 liquidity = numerator / denominator;

                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint256 liquidity) {
        (uint112 reserve0_, uint112 reserve1_, ) = getReserves(); // gas savings
        uint256 balance0 = IKAP20(token0).balanceOf(address(this));
        uint256 balance1 = IKAP20(token1).balanceOf(address(this));
        uint256 amount0 = balance0.sub(reserve0_);
        uint256 amount1 = balance1.sub(reserve1_);

        bool feeOn = (fee100 == true)
            ? _mintFee100(reserve0_, reserve1_)
            : _mintFee(reserve0_, reserve1_);

        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(
                amount0.mul(_totalSupply) / reserve0_,
                amount1.mul(_totalSupply) / reserve1_
            );
        }
        require(liquidity > 0, "Diamon: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(balance0, balance1, reserve0_, reserve1_);
        if (feeOn) kLast = uint256(_reserve0).mul(_reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to)
        external
        lock
        returns (uint256 amount0, uint256 amount1)
    {
        (uint112 reserve0_, uint112 reserve1_, ) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint256 balance0 = IKAP20(_token0).balanceOf(address(this));
        uint256 balance1 = IKAP20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];

        bool feeOn = (fee100 == true)
            ? _mintFee100(reserve0_, reserve1_)
            : _mintFee(reserve0_, reserve1_);

        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(
            amount0 > 0 && amount1 > 0,
            "Diamon: INSUFFICIENT_LIQUIDITY_BURNED"
        );
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IKAP20(_token0).balanceOf(address(this));
        balance1 = IKAP20(_token1).balanceOf(address(this));

        _update(balance0, balance1, reserve0_, reserve1_);
        if (feeOn) kLast = uint256(_reserve0).mul(_reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to
    ) external lock {
        require(
            amount0Out > 0 || amount1Out > 0,
            "Diamon: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        (uint112 reserve0_, uint112 reserve1_, ) = getReserves(); // gas savings
        require(
            amount0Out < reserve0_ && amount1Out < reserve1_,
            "Diamon: INSUFFICIENT_LIQUIDITY"
        );

        uint256 balance0;
        uint256 balance1;
        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "Diamon: INVALID_TO");
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer
            // Remove Flash loan
            balance0 = IKAP20(_token0).balanceOf(address(this));
            balance1 = IKAP20(_token1).balanceOf(address(this));
        }

        uint256 amount0In = balance0 > reserve0_ - amount0Out
            ? balance0 - (reserve0_ - amount0Out)
            : 0;
        uint256 amount1In = balance1 > reserve1_ - amount1Out
            ? balance1 - (reserve1_ - amount1Out)
            : 0;
        require(
            amount0In > 0 || amount1In > 0,
            "Diamon: INSUFFICIENT_INPUT_AMOUNT"
        );
        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint256 balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
            uint256 balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
            require(
                balance0Adjusted.mul(balance1Adjusted) >=
                    uint256(reserve0_).mul(reserve1_).mul(1000**2),
                "Diamon: K"
            );
        }

        _update(balance0, balance1, reserve0_, reserve1_);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(
            _token0,
            to,
            IKAP20(_token0).balanceOf(address(this)).sub(_reserve0)
        );
        _safeTransfer(
            _token1,
            to,
            IKAP20(_token1).balanceOf(address(this)).sub(_reserve1)
        );
    }

    // force reserves to match balances
    function sync() external lock {
        _update(
            IKAP20(token0).balanceOf(address(this)),
            IKAP20(token1).balanceOf(address(this)),
            _reserve0,
            _reserve1
        );
    }
}

contract TestDiamonFactory is Authorization {
    uint256 acceptedKYCLevel;
    address kyc;
    address committee;

    bytes32 public constant INIT_CODE_PAIR_HASH =
        keccak256(abi.encodePacked(type(DiamonPair).creationCode));

    address public feeTo;
    address public feeToSetter;
    address owner;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    modifier onlyCommittee() {
        require(msg.sender == committee, "Restricted only committee");
        _;
    }

    constructor() public {
        feeToSetter = msg.sender;
        owner = msg.sender;
        feeTo = msg.sender;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        if (chainId == 96) {
            // MAIN NET Bitkub Chain
            adminRouter = IAdminProjectRouter(
                0x15122c945763da4435b45E082234108361B64eBA
            );
            committee = 0xEE4464a2055d2346FacF7813E862B92ffa91dcaE;
            kyc = 0x409CF41ee862Df7024f289E9F2Ea2F5d0D7f3eb4;
        } else if (chainId == 25925) {
            // TEST NET Bitkub Chain
            adminRouter = IAdminProjectRouter(
                0xE4088E1f199287B1146832352aE5Fc3726171d41
            );
            committee = 0xEE4464a2055d2346FacF7813E862B92ffa91dcaE;
            kyc = 0x2C8aBd9c61D4E973CA8db5545C54c90E44A2445c;
        }
        acceptedKYCLevel = 4;
    }

    function setFee100(address _addr, bool _active) external returns (bool) {
        require(msg.sender == owner);
        IDiamonPair(_addr).setFee100(_active);
        return true;
    }

    function getAcceptedLV() external view returns (uint256) {
        return acceptedKYCLevel;
    }

    function getCommittee() external view returns (address) {
        return committee;
    }

    function getAdminRounter() external view returns (address) {
        return address(adminRouter);
    }

    function getKYC() external view returns (address) {
        return address(kyc);
    }

    function setCommittee(address _committee) external onlyCommittee {
        committee = _committee;
    }

    function setKYC(address _kyc) external onlyCommittee {
        kyc = _kyc;
    }

    function setAcceptedKycLevel(uint256 _kycLevel) external onlyCommittee {
        acceptedKYCLevel = _kycLevel;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair)
    {
        require(tokenA != tokenB, "Diamon: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "Diamon: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "Diamon: PAIR_EXISTS"); // single check is sufficient

        bytes memory bytecode = type(DiamonPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));

        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IDiamonPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "Diamon: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "Diamon: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}
