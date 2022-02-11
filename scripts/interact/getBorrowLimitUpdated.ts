import { parseEther } from "@ethersproject/units";
import hre, { ethers } from "hardhat";
import { YESToken__factory } from "../../typechain";
import addressUtils from "../../utils/addressUtils";

const newAmount = '1888218';

async function main() {
    const addressList = await addressUtils.getAddressList(hre.network.name);
    const YESToken = await hre.ethers.getContractFactory('YESToken') as YESToken__factory;

    const yesToken = await YESToken.attach(addressList.yesToken);
    const yesTokenInterface = await new ethers.utils.Interface(YESToken__factory.abi);

    if (yesToken && yesTokenInterface) {
        // For lenders, edit `lToken.filters.Borrow()` to `lToken.filters.Mint()`
        const filter = yesToken.filters.BorrowLimitUpdated() as any;
        const latestBlock = await ethers.provider.getBlockNumber();
        //   filter.toBlock = latestBlock - offset;
        //   filter.fromBlock = filter.toBlock - PAGE_SIZE;
        filter.toBlock = latestBlock;
        filter.fromBlock = 0;

        const logs = await ethers.provider.getLogs(filter);
        // ['0xaaa', '0xsss'] => [{wallet: '0x000', amount: '10'}]
        const users = logs.map(
            (log) => yesTokenInterface.parseLog(log).args[0]
        );

        const filteredUsers = Array.from(new Set(users)).filter(addr => ![
            '0xe6bF22F7C718683070299572baD0accA7B3424D5',
            '0x07F68A62290E75093477F164724823DAc36Be415',
            '0x73D8F731eC0d3945d807a904Bf93954B82b0d594',
            '0x31c2544178f8E8F7F4317247e1dE14591945f1CB',
            '0xDe0b1495C170E5bF011b7651ea1dFa60Efa99613',
            '0x36469b79C39CAC169712D524394Fd19Bb1f72899',
            '0xdDDE0F33c82b56d04fC1E0C3cc486a9b3b5E05D4',
            '0x8292c18338c3cFc8B761AD24509D279a20b68978',
            '0xDDE97e76e584b4C97a020A86DfAd8E0e9d55d3aC',
            '0x6E39C1d0Bd6A612f213B31d8A5C1f801E05b5765',
            '0x3d0605F858aee38105Eb2c2924E9ba8ad1B3cdA3',
            '0x0ea06a147C7c4a0E5b3f07081D139e950dDCd600',
            '0xBE73ebfe22A8030A22a4CadDE21771eCD4B275Fd',
            '0x8F3Fd485a4A5b8027440A3FdcAbCe38B4365A009',
            '0xa90AbFCfB3DF831Ef02b0A3d23A8752f97F16477',
            '0x951B764994B1f297c88F9975c56D80F17B8f742B',
            '0x2FCBc7fB70Fd7CE7032dF3Ac50c06f1C4eF5Ae69',
            '0x76b52399AB5EA0dfdAB3007251A5C7B3584Bd64A',
            '0xf3480FE912c9bb8a92c272A8E22F55bfFc89155a',
            '0xda80Ae551aF4444d5595aC3fEE6a21E3DfEaCa1e',
            '0x8F3467cF73A7cb60B30f5eF8512dd3b1fE40e056',
            '0x695052d0706542B13ce65a91eb5DD47F8a8428aF',
            '0x3D30F151EAFe3a52F805a056a73e2D952c99d633',
            '0xE16D2B01ca6D4E7DAB685F9e58db9821e25a2d1d',
            '0xe0fa1A297bA820691906b4dd3233836D94dd5246',
            '0xE797643C0f998Ae88e920AC3b7b42825C9CACb59',
            '0xfB00fB6360979af06c3FB554f0FFca55Fbc00c44',
            '0x65581F7a73bE0F94B482A05d543AfA7db9e36643',
            '0x06bCE71DB967dd17E940FF677E7434b7315096F6',
            '0xb83517C3B5497cAAB2A5b92bd754756BDb5967E9',
            '0x1a7FfC176d81e79bFCa705Dd3F74e0C8A186DECd',
            '0x7cCa31bD772654b66A188aFbBaC63BAa069865A5',
            '0xcbDC1F21308B6080D7bD31E9A0699E62090AAf7d',
            '0x95e1908fDC7b12a50cf1D56A0EEd191d82eB0448',
            '0xB3683BA175D2c2d6962B49E96b87393DC380C552',
            '0xc45E8d41e09be04a590Cba7Bc8E6a2Ae02582c26',
            '0x11a6195206c096D6478DC1C6c56A9f399a09c7f5',
            '0x7Ceb3F38BdAAbF47401C64fD1C9759b31D7c46d9',
            '0x2797Da468AB6281AB9fa18e0D14A750923a33276',
            '0xDBFAEfAf98e2eACb5CD660152AC4D49640C8c96F',
            '0xFB191A957941449ed55F8fC55f50c184616dff42',
            '0x4561461B96e2b3D897A91f8c062ceABfC78D7f64',
            '0xe651e1536b5A6D2c1E3ABBa78394Fb66Acd3d140',
            '0x09D3AEEb96796dB930ecc49F152EBB43e3e56B44',
            '0x1e06e9527F9BFC5011eef5a9561A14807d91a381',
            '0x795cADf32B98A78bD5B890c8B2c4B01aC2A37232',
            '0xE305D9058C93962657aFcF4c59e137ABb464ac7e',
            '0x52Ab9c52054B6df51E00ffdDFd8B1Ad31493E621',
            '0x42c013565C92C4F78a4bfdF278127AAa228Ac05a',
            '0x237d26bDa3dA65540A03FE0CdA6369eE83Ff5dCD',
            '0x0bbb47883Fb92fffC3cf8118EF66D8eA5FAbF249',
            '0xA06Cfb49F2b68E2ac351968e6aeb4f408c6253b8',
            '0x3f59da782ca699B95F0cAd2b6fC72ADefa64d43F',
            '0xFC9a719CB747A3Fe4110782eFcf29206f3BD73b8',
            '0xd8d3EF5275b033b931dCc9254EF1F2FE52F835f4',
            '0x81990F0039a967746166FA236Bf6ed43Ec6A7854'
        ].includes(addr));

        console.log({ filteredUsers });

        for (let i = 0; i < filteredUsers.length; i++) {
            const user = filteredUsers[i];
            await yesToken.setBorrowLimit(user, parseEther(newAmount)).then(tx => tx.wait());
            console.log(user)
        }

    }

    // await yesToken.setBorrowLimit('0x73D8F731eC0d3945d807a904Bf93954B82b0d594', parseEther(newAmount)).then(res => res.wait());
    // console.log('Suuccess', await yesToken.borrowLimitOf('0x73D8F731eC0d3945d807a904Bf93954B82b0d594'))
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
