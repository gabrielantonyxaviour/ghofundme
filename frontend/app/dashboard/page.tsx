'use client'
import type { NextPage } from "next";
import { useDisconnect } from "wagmi";
import { useAccount } from 'wagmi'
import { redirect } from 'next/navigation';
import { useEffect, useState } from "react";
import TransactionList from "@/components/Transaction";

const page: NextPage = () => {
    const { address, isConnecting, isDisconnected } = useAccount()
    const { disconnect } = useDisconnect()
    const [lensid, setislensid] = useState("")
    useEffect(() => {
      if(isDisconnected){redirect('/')}
    }, [isDisconnected])
    const [totalClaimableGho, setTotalClaimableGho] = useState(0)
    const [claimableWindow, setClaimableWindow] = useState(0)
    const [volumeOfFanTokenTraded, setVolumeOfFanTokenTraded] = useState(0)
    const [totalGhoStaked, setTotalGhoStaked] = useState(0)
  return (
    <div className="relative bg-gray-200 w-full h-screen overflow-hidden text-left text-5xl text-white font-monument-extended">
      {/* <div className="absolute top-[-241px] left-[1366px] w-[1366px] h-[1009px] [transform:_rotate(180deg)] [transform-origin:0_0]" /> */}
      <img
        className="absolute top-[1px] left-[0px] w-screen h-screen object-cover"
        alt=""
        src="/2303w018n0021741ap30-1@2x.png"
      />
      <div className="absolute top-[0px] left-[0px] bg-[#131212] w-screen    h-screen" />
      
      <img
        className="absolute top-[28px] left-[51px] w-[422px] h-[123px] overflow-hidden"
        alt=""
        src="/ghfundme-1.svg"
      />
      <div className="absolute left-32">
      <div className="absolute top-[42px] left-[1810px] w-14 h-14">
        <div className="absolute top-[0px] left-[0px]w-14 h-14" />
        <div className="absolute top-[21px] left-[14px] w-[29px] h-3.5">
          <div className="absolute top-[-1.5px] left-[-1.5px] box-border w-8 h-[3px] border-t-[3px] border-solid border-white" />
          <div className="absolute top-[5.5px] left-[-1.5px] box-border w-8 h-[3px] border-t-[3px] border-solid border-white" />
          <div className="absolute top-[12.5px] left-[-1.5px] box-border w-8 h-[3px] border-t-[3px] border-solid border-white" />
        </div>
      </div>
      <div className="absolute top-[230px] left-[110px] w-[763px] h-[612px] font-sans">
        <div className="absolute top-[0px] left-[0px] rounded-xl bg-[#599E40] opacity-25 w-[463px] h-[612px]" />

        <img
          className="absolute h-[121px] w-[181px] top-[11.59%] right-[17.61%] bottom-[56.89%] left-[20.17%] max-w-full overflow-hidden max-h-full"
          alt=""
          src="/vectorlens.svg"
        />
        <div className=" flex gap-2 absolute top-[258px] left-[75px] w-[599px] h-[72px] text-justify">
          <div> 
          <p className="m-0 text-3xl text">Lens ID  </p><p className="m-0 text-3xl">Username</p>
          </div>
          <div>
          <p className="m-0 text-3xl">: 1</p><p className="m-0 text-3xl">: Lens</p>
          </div>
        </div>
        <div className="absolute top-[213px] left-[59px] text-xl inline-block w-[246px] h-6">
        {!isConnecting?(address?.substring(0, 10) + "......." + address?.substring(address?.length - 8)):
        (<div className='flex space-x-2 absolute top-[0px] left-[109px] text-xl w-[246px] h-6'>
        <span className='sr-only'>Loading...</span>
         <div className='h-8 w-8 bg-white rounded-full animate-bounce [animation-delay:-0.3s]'></div>
       <div className='h-8 w-8 bg-white rounded-full animate-bounce [animation-delay:-0.15s]'></div>
       <div className='h-8 w-8 bg-white rounded-full animate-bounce'></div>
   </div>)}
        </div>
        <img
          className="absolute h-[121px] w-[181px] top-[80.59%] right-[67.61%] bottom-[56.89%] left-[20.17%] max-w-full overflow-hidden max-h-full transform transition duration-500 
          hover:scale-105"
          alt=""
          src="/logoutbutton.svg"
          onClick={() =>
            {   disconnect()
            }}
        />
      </div>
      </div>
      <div className="absolute top-[231px] left-[816px] w-[894px] h-[603px] text-xl text-gray-100 font-sans">
      
        <div className="absolute top-[0px] left-[0px] rounded-xl  box-border w-[894px] h-[603px] border-[2px] border-dashed border-[#025231]" />
        <div className="absolute top-[49px] left-[56px] text-[28px] text-white inline-block w-[379px] h-[68px]">
          Dashboard
        </div>
        <div className="absolute top-[49px] left-[510px] text-[28px] text-white inline-block w-[379px] h-[68px]">
         Transactions
        </div>
        <div className="absolute left-[510px] h-[603px] top-24">
        <TransactionList />
        </div>
        <div className="absolute top-[100px] left-[50px] text-white text-lg bg-gray-800 p-6 rounded-xl shadow-md">
  <div className="grid grid-cols-1 gap-4">
    <div>
      <p className="text-gray-400">Total GHO Staked</p>
      <p className="text-3xl font-bold">{totalGhoStaked}</p>
    </div>
    <div>
      <p className="text-gray-400">Total Claimable GHO</p>
      <p className="text-3xl font-bold">{totalClaimableGho}</p>
    </div>
    <div>
      <p className="text-gray-400">Claimable Window</p>
      <p className="text-3xl font-bold">{claimableWindow}</p>
    </div>
    <div>
      <p className="text-gray-400">Volume of Fan Token Traded</p>
      <p className="text-3xl font-bold">{volumeOfFanTokenTraded}</p>
    </div>
  </div>

</div>


<div className="absolute top-[435px] left-[60px] h-[100px] w-[160px] transform transition duration-500 
            hover:scale-105">
          <img
          className="h-[120px] w-[160px] top-[40.59%] right-[67.61%] bottom-[56.89%] left-[20.17%] max-w-full overflow-hidden max-h-full transform transition duration-500 
          hover:scale-105"
          alt=""
          src="/claim1.svg"
        //   onClick={() =>
        //     {  
        //     }}
        />
        </div>
        <div className="absolute top-[400px] left-[200px] h-[140px] w-[200px] transform transition duration-500 
            hover:scale-105">
          <img
          className="absolute h-[140px] w-[209px] top-[10.59%] right-[67.61%] bottom-[56.89%] left-[20.17%] max-w-full overflow-hidden max-h-full transform transition duration-500 
          hover:scale-105"
          alt=""
          src="/terminate.svg"
        //   onClick={() =>
        //     {  
        //     }}
        />
        </div>
      </div>
    </div>
  );
};

export default page;
