import { ethers, network } from "hardhat";
import addressUtils from "../../utils/addressUtils";
import { YESToken__factory } from "../../typechain/factories/YESToken__factory";
import { formatEther, Interface, parseEther } from "ethers/lib/utils";
import { YESToken } from "../../typechain";

const PAGE_SIZE = 50000;

const getPastAirdrop = async (yesToken: YESToken, yesTokenInterface: Interface, offset: number) => {
  if (yesToken && yesTokenInterface) {
    const filter = yesToken.filters.Released() as any;
    const latestBlock = await ethers.provider.getBlockNumber();
    filter.toBlock = latestBlock - offset; // 200000-0
    filter.fromBlock = filter.toBlock - PAGE_SIZE; // 200000-50000
    const logs = await ethers.provider.getLogs(filter);
    const result = logs.map(
      (log) => ({ address: yesTokenInterface.parseLog(log).args[1], amount: yesTokenInterface.parseLog(log).args[2] })
    );
    return { data: result, hasNext: filter.fromBlock > 0 };
  }
};

const getAirdropTillLast = async (
  yesToken: YESToken,
  yesTokenInterface: Interface,
  offset: number
) => {
  let hasNext = true;
  let results = [];
  let tmpOffset = offset;
  while (hasNext) {
    const data = await getPastAirdrop(yesToken, yesTokenInterface, tmpOffset);
    results = [...results, ...data.data];
    tmpOffset += PAGE_SIZE;
    hasNext = data.hasNext;
  }
  return results;
};

//formatEther
async function fetchAirdropData() {
  const addressList = await addressUtils.getAddressList(network.name);
  const [wallet] = await ethers.getSigners()
  const yesTokenInterface = await new ethers.utils.Interface(YESToken__factory.abi);
  const yes = YESToken__factory.connect(addressList.yesToken, wallet);
  const yesairdrop = await getAirdropTillLast(yes, yesTokenInterface, 0);
  // console.log("show", yesairdrop)
  const result = yesairdrop.reduce((acc, cur) => {
    if (!acc[cur.address]) acc[cur.address] = 0;
    acc[cur.address] += Number(formatEther(cur.amount));
    return acc;
  }, {} as Record<string, number>);
  return result;
}

async function main() {
  const [signer] = await ethers.getSigners();
  const addressList = await addressUtils.getAddressList(network.name);
  const yesToken = YESToken__factory.connect(addressList.yesToken, signer);

  // fetch airdropAdresses (account, amount)
  const airdropAdresses = await fetchAirdropData();

  const airdropArr = Object.entries<Record<string, number>>(airdropAdresses).filter(([address]) => ![
    '0x4D46D2807a3f20bB59FF135A767C576708589E13',
    '0x7cCa31bD772654b66A188aFbBaC63BAa069865A5',
    '0xcbDC1F21308B6080D7bD31E9A0699E62090AAf7d',
    '0x95e1908fDC7b12a50cf1D56A0EEd191d82eB0448',
    '0x1B66703B7213841E32993E4c385a5f24D6238CbC',
    '0xB3683BA175D2c2d6962B49E96b87393DC380C552',
    '0xf3480FE912c9bb8a92c272A8E22F55bfFc89155a',
    '0x2FCBc7fB70Fd7CE7032dF3Ac50c06f1C4eF5Ae69',
    '0xc45E8d41e09be04a590Cba7Bc8E6a2Ae02582c26',
    '0x244E3a25f101Fc4d8Ca5DCC53129360037098524',
    '0x3D30F151EAFe3a52F805a056a73e2D952c99d633',
    '0xE797643C0f998Ae88e920AC3b7b42825C9CACb59',
    '0x11a6195206c096D6478DC1C6c56A9f399a09c7f5',
    '0x8F3467cF73A7cb60B30f5eF8512dd3b1fE40e056',
    '0xE16D2B01ca6D4E7DAB685F9e58db9821e25a2d1d',
    '0x73D8F731eC0d3945d807a904Bf93954B82b0d594',
    '0xe0fa1A297bA820691906b4dd3233836D94dd5246',
    '0x3d0605F858aee38105Eb2c2924E9ba8ad1B3cdA3',
    '0xfB00fB6360979af06c3FB554f0FFca55Fbc00c44',
    '0xDDE97e76e584b4C97a020A86DfAd8E0e9d55d3aC',
    '0x65581F7a73bE0F94B482A05d543AfA7db9e36643',
    '0x06bCE71DB967dd17E940FF677E7434b7315096F6',
    '0xb83517C3B5497cAAB2A5b92bd754756BDb5967E9',
    '0x1a7FfC176d81e79bFCa705Dd3F74e0C8A186DECd',
    '0x6E39C1d0Bd6A612f213B31d8A5C1f801E05b5765',
    '0x36469b79C39CAC169712D524394Fd19Bb1f72899',
    '0xdDDE0F33c82b56d04fC1E0C3cc486a9b3b5E05D4',
    '0x0ea06a147C7c4a0E5b3f07081D139e950dDCd600',
    '0xBE73ebfe22A8030A22a4CadDE21771eCD4B275Fd',
    '0xDe0b1495C170E5bF011b7651ea1dFa60Efa99613',
    '0x8F3Fd485a4A5b8027440A3FdcAbCe38B4365A009',
    '0xa90AbFCfB3DF831Ef02b0A3d23A8752f97F16477',
    '0x951B764994B1f297c88F9975c56D80F17B8f742B',
    '0x31c2544178f8E8F7F4317247e1dE14591945f1CB',
    '0x76b52399AB5EA0dfdAB3007251A5C7B3584Bd64A',
    '0xda80Ae551aF4444d5595aC3fEE6a21E3DfEaCa1e',
    '0x695052d0706542B13ce65a91eb5DD47F8a8428aF',
    '0xe6bF22F7C718683070299572baD0accA7B3424D5',
    '0x07F68A62290E75093477F164724823DAc36Be415',
    '0x8292c18338c3cFc8B761AD24509D279a20b68978'
  ].includes(address))

  // loop release
  let totalRelease = 0;
  for (let i = 0; i < airdropArr.length; i++) {
    const [address, amount] = airdropArr[i];
    await yesToken.transfer(address, parseEther(amount.toString())).then(res => res.wait());
    // totalRelease += Number(amount);
    console.log(`'${address}',`);
  }

  console.log("Finished");
  // await yesToken.transfer(yesToken.address, totalRelease).then(res => res.wait()).then(res => console.log(res.transactionHash));
  // console.log("Transfer: " + totalRelease)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
