import hre, { ethers } from 'hardhat';
import address from '../addressUtils';
import time from '../timeUtils';
import { KKUB__factory, YESToken__factory, SwapFactory__factory, SwapRouter__factory, SwapPair__factory, SlidingWindowOracle__factory, MintableToken__factory, YESPriceOracle__factory } from '../../typechain';

const poolReserves = {
    'KUBYES': [
        hre.ethers.utils.parseEther('1000'),      // 1 KUB = 25 THB = 0.75 USD
        hre.ethers.utils.parseEther('9375')    // 1 YES = 26.74 THB = 0.8 USD
    ],
    'KBTCYES': [
        hre.ethers.utils.parseEther('4.399'),  // 1 KBTC = 1,465,000 THB = 43,645 USD
        hre.ethers.utils.parseEther('240000')   // 1 YES = 26.74 THB = 0.8 USD
    ],
    'KETHYES': [
        hre.ethers.utils.parseEther('63.6815'),    // 1 ETH = 101.201.50 THB = 3,015 USD
        hre.ethers.utils.parseEther('240000')       // 1 DAI = 33.43 THB = 1 USD
    ],
    'KDAIYES': [
        hre.ethers.utils.parseEther('192000'),      // 1 UST = 33.43 THB = 1 USD
        hre.ethers.utils.parseEther('240000')       // 1 YES = 26.74 THB = 0.8 USD
    ],
    'KUSDCYES': [
        hre.ethers.utils.parseEther('4000'),      // 1 UST = 33.43 THB = 1 USD
        hre.ethers.utils.parseEther('5000')       // 1 YES = 26.74 THB = 0.8 USD
    ],
    'KUSDTYES': [
        hre.ethers.utils.parseEther('4000'),      // 1 UST = 33.43 THB = 1 USD
        hre.ethers.utils.parseEther('5000')       // 1 YES = 26.74 THB = 0.8 USD
    ],
}

const setupSwapOracle = async (yesTokenAddress: string) => {
    const addressList = await address.getAddressList("kubchain_test");
    const [owner] = await hre.ethers.getSigners();

    const txDeadline = time.now() + time.duration.years(20);

    const KKUB = await hre.ethers.getContractFactory('KKUB') as KKUB__factory;
    const MintableToken = await hre.ethers.getContractFactory('MintableToken') as MintableToken__factory;
    const YESToken = (await hre.ethers.getContractFactory('YESToken')) as YESToken__factory;

    const SwapFactory = await hre.ethers.getContractFactory('SwapFactory') as SwapFactory__factory;
    const SwapRouter = await hre.ethers.getContractFactory('SwapRouter') as SwapRouter__factory;
    const SwapPairFactory = await hre.ethers.getContractFactory('SwapPair') as SwapPair__factory;

    const SlidingWindowOracle = await hre.ethers.getContractFactory('SlidingWindowOracle') as SlidingWindowOracle__factory;
    const YESPriceOracle = await hre.ethers.getContractFactory('YESPriceOracle') as YESPriceOracle__factory;

    const kkub = await KKUB.attach(addressList.kkub);
    const kdai = await MintableToken.attach(addressList.kdai);
    const keth = await MintableToken.attach(addressList.keth);
    const kusdt = await MintableToken.attach(addressList.kusdt);
    const kusdc = await MintableToken.attach(addressList.kusdc);
    const kbtc = await MintableToken.attach(addressList.kbtc);
    const yesToken = await YESToken.attach(yesTokenAddress);

    await kdai.connect(owner).mint(owner.address, poolReserves.KDAIYES[0]);
    await keth.connect(owner).mint(owner.address, poolReserves.KETHYES[0]);
    await kusdt.connect(owner).mint(owner.address, poolReserves.KUSDTYES[0]);
    await kusdc.connect(owner).mint(owner.address, poolReserves.KUSDCYES[0]);
    await kbtc.connect(owner).mint(owner.address, poolReserves.KBTCYES[0]);

    const swapFactory = await SwapFactory.attach(addressList.swapFactory);
    const swapRouter = await SwapRouter.attach(addressList.swapRouter);

    await kkub.connect(owner).approve(swapRouter.address, ethers.constants.MaxUint256).then(tx => tx.wait());
    await kdai.connect(owner).approve(swapRouter.address, ethers.constants.MaxUint256).then(tx => tx.wait());
    await keth.connect(owner).approve(swapRouter.address, ethers.constants.MaxUint256).then(tx => tx.wait());
    await kusdt.connect(owner).approve(swapRouter.address, ethers.constants.MaxUint256).then(tx => tx.wait());
    await kusdc.connect(owner).approve(swapRouter.address, ethers.constants.MaxUint256).then(tx => tx.wait());
    await kbtc.connect(owner).approve(swapRouter.address, ethers.constants.MaxUint256).then(tx => tx.wait());
    await yesToken.connect(owner).approve(swapRouter.address, ethers.constants.MaxUint256).then(tx => tx.wait());

    await swapRouter.connect(owner).addLiquidityETH(yesToken.address, poolReserves.KUBYES[1], poolReserves.KUBYES[1].mul(99).div(100), poolReserves.KUBYES[0].mul(99).div(100), owner.address, txDeadline, { value: poolReserves.KUBYES[0] }).then(tx => tx.wait());
    await swapRouter.connect(owner).addLiquidity(kdai.address, yesToken.address, poolReserves.KDAIYES[0], poolReserves.KDAIYES[1], poolReserves.KDAIYES[0].mul(99).div(100), poolReserves.KDAIYES[1].mul(99).div(100), owner.address, txDeadline).then(tx => tx.wait());
    await swapRouter.connect(owner).addLiquidity(keth.address, yesToken.address, poolReserves.KETHYES[0], poolReserves.KETHYES[1], poolReserves.KETHYES[0].mul(99).div(100), poolReserves.KETHYES[1].mul(99).div(100), owner.address, txDeadline).then(tx => tx.wait());
    await swapRouter.connect(owner).addLiquidity(kusdt.address, yesToken.address, poolReserves.KUSDTYES[0], poolReserves.KUSDTYES[1], poolReserves.KUSDTYES[0].mul(99).div(100), poolReserves.KUSDTYES[1].mul(99).div(100), owner.address, txDeadline).then(tx => tx.wait());
    await swapRouter.connect(owner).addLiquidity(kusdc.address, yesToken.address, poolReserves.KUSDCYES[0], poolReserves.KUSDCYES[1], poolReserves.KUSDCYES[0].mul(99).div(100), poolReserves.KUSDCYES[1].mul(99).div(100), owner.address, txDeadline).then(tx => tx.wait());
    await swapRouter.connect(owner).addLiquidity(kbtc.address, yesToken.address, poolReserves.KBTCYES[0], poolReserves.KBTCYES[1], poolReserves.KBTCYES[0].mul(99).div(100), poolReserves.KBTCYES[1].mul(99).div(100), owner.address, txDeadline).then(tx => tx.wait());

    const kdaiKUB = await SwapPairFactory.attach(await swapFactory.getPair(addressList.kdai, addressList.kkub));
    const kdaiKUSDT = await SwapPairFactory.attach(await swapFactory.getPair(addressList.kdai, addressList.kusdt));
    const kdaiKETH = await SwapPairFactory.attach(await swapFactory.getPair(addressList.kdai, addressList.keth));
    const kdaiYES = await SwapPairFactory.attach(await swapFactory.getPair(addressList.kdai, yesToken.address));

    const yesKUB = await SwapPairFactory.attach(await swapFactory.getPair(yesToken.address, addressList.kkub));
    const yesKUSDT = await SwapPairFactory.attach(await swapFactory.getPair(yesToken.address, addressList.kusdt));
    const yesKETH = await SwapPairFactory.attach(await swapFactory.getPair(yesToken.address, addressList.keth));
    const yesKBTC = await SwapPairFactory.attach(await swapFactory.getPair(yesToken.address, addressList.kbtc));
    const yesKUSDC = await SwapPairFactory.attach(await swapFactory.getPair(yesToken.address, addressList.kusdc));

    const slidingWindowOracle = await SlidingWindowOracle.deploy(swapFactory.address, time.duration.hours(24), 2);
    const swapPriceOracle = await YESPriceOracle.deploy(slidingWindowOracle.address, yesToken.address, kkub.address);

    await slidingWindowOracle.update(kkub.address, yesToken.address).then(tx => tx.wait());
    await slidingWindowOracle.update(kdai.address, yesToken.address).then(tx => tx.wait());
    await slidingWindowOracle.update(kusdt.address, yesToken.address).then(tx => tx.wait());
    await slidingWindowOracle.update(keth.address, yesToken.address).then(tx => tx.wait());
    await slidingWindowOracle.update(kbtc.address, yesToken.address).then(tx => tx.wait());
    await slidingWindowOracle.update(kusdc.address, yesToken.address).then(tx => tx.wait());

    await time.increase(time.duration.minutes(2));

    return {
        kkub,
        kdai,
        keth,
        kusdt,
        kbtc,
        kusdc,
        kdaiKUB,
        kdaiKETH,
        kdaiKUSDT,
        kdaiYES,
        yesKUB,
        yesKUSDT,
        yesKETH,
        yesKBTC,
        yesKUSDC,
        slidingWindowOracle,
        swapPriceOracle,
        swapFactory,
        swapRouter
    }
}

export default setupSwapOracle;