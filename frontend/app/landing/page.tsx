'use client'

import type { NextPage } from "next";
import { redirect } from 'next/navigation';

import { useWeb3Modal } from '@web3modal/wagmi/react'
import { useAccount } from 'wagmi'
const landing: NextPage = () => {
    const { open } = useWeb3Modal()
    const { address } = useAccount()
  return (<>
    {!address ?(<div className="relative bg-[#201F1F] w-full h-screen overflow-hidden text-left text-[18px] text-white font-montserrat">
      <div className="absolute top-[-241px] left-[0px] w-full h-[1200px] overflow-hidden">
        <div className="absolute top-[0px] left-[0px] bg-[#201F1F] w-[1366px] h-[1250px] overflow-hidden flex flex-col items-end justify-start">
          <div className="relative w-[1366px] h-[1009px] [transform:_rotate(180deg)]" />
        </div>
        <div className="absolute top-[397px] left-[150px] w-[703px] h-[676px] overflow-hidden flex flex-col items-center justify-end">
          <div className="relative text-justify font-medium inline-block w-[703px] opacity-[0.55]">{`GHOFundMe is a custom Lens Module which acts as a feature for Lens creators to create a subscription based revenue. The Lens module is initialized for each content creator after a few eligibility checks like followers count, post interactions etc. On initializing the module for the Lens account, a new vault is deployed where the users can supply GHO tokens and get ERC1155 Fan Mint Tokens and ERC1155 Fan Trade Tokens in return. Mint Tokens are soulbound and non-tradeable(burnable when user terminates subscription). By owning these fan tokens, users can view exclusive content created by creators. The supplied GHO tokens are staked for a certain duration during which the user owns the Fan tokens. The vault can also act as an escrow because the users can burn their fan tokens to get back the GHO supplied if they did not like the content/value provided by the creator `}</div>
        </div>
        <div className="absolute top-[220px] left-[923px] w-[1080px] h-[1920px] overflow-hidden flex flex-col items-center justify-start">
          <img
            className="relative w-[1080px] h-[1920px] "
            alt=""
            src="/2303w018n0021741ap30-1@2x.png"
          />
        </div>
        <div className="absolute top-[489px] left-[388px] w-[971px] h-[352px] overflow-hidden flex flex-col items-center justify-start">
          <img
            className="relative w-[978px] h-[285px] overflow-hidden shrink-0"
            alt=""
            src="/ghfundme-1.svg"
          />
        </div>
        <div className="absolute top-[110px] left-[597px] w-[845px] h-[684px] overflow-hidden flex flex-col items-center justify-end ">
          <div className="bg-forestgreen-200 w-[645px] h-14 flex flex-row items-end justify-end pt-7 px-[5px] pb-0 box-border relative border-2 border-green-700 
                                cursor-pointer py-6 rounded-lg 
                                transform transition duration-500 
                                hover:scale-105" onClick={() => open()}>
            <img
              className="relative rounded-6xs w-6 h-6 z-[0]"
              alt=""
              src="/arrowbigcornerlinedown.svg"
            />
            <img
              className="absolute my-0 mx-[!important] top-[14px] left-[30px] w-[582.9px] h-[25.9px] z-[1]"
              alt=""
              src="/signin-with-metamask.svg"
            />
          </div>
        </div>
      </div>
    </div>):(redirect('/createmodel'))}
    </>
  );
};

export default landing;
