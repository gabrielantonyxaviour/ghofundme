'use client'
import type { NextPage } from "next";
import { useDisconnect } from "wagmi";
import { useAccount } from 'wagmi'
import { redirect } from 'next/navigation';
import { useEffect, useState } from "react";
import { useProfiles } from '@lens-protocol/react-web'


const page: NextPage = () => {
    const { address, isConnecting, isDisconnected } = useAccount()
    const { disconnect } = useDisconnect()
    const [lensid, setislensid] = useState("")
    useEffect(() => {
      if(isDisconnected){redirect('/')}
    }, [isDisconnected])

  
  return (
    <div className="relative bg-gray-200 w-full h-screen overflow-hidden text-left text-5xl text-white font-monument-extended">
      {/* <div className="absolute top-[-241px] left-[1366px] w-[1366px] h-[1009px] [transform:_rotate(180deg)] [transform-origin:0_0]" /> */}
      <img
        className="absolute top-[0px] left-[0px] w-screen h-screen object-cover"
        alt=""
        src="/2303w018n0021741ap30-1@2x.png"
      />
      <div className="absolute top-[0px] left-[930px] bg-[#131212] w-[1100px] h-screen" />
      <img
        className="absolute top-[28px] left-[51px] w-[422px] h-[123px] overflow-hidden"
        alt=""
        src="/ghfundme-1.svg"
      />
      <div className="absolute top-[42px] left-[1810px] w-14 h-14">
        <div className="absolute top-[0px] left-[0px]w-14 h-14" />
        <div className="absolute top-[21px] left-[14px] w-[29px] h-3.5">
          <div className="absolute top-[-1.5px] left-[-1.5px] box-border w-8 h-[3px] border-t-[3px] border-solid border-white" />
          <div className="absolute top-[5.5px] left-[-1.5px] box-border w-8 h-[3px] border-t-[3px] border-solid border-white" />
          <div className="absolute top-[12.5px] left-[-1.5px] box-border w-8 h-[3px] border-t-[3px] border-solid border-white" />
        </div>
      </div>
      <div className="absolute top-[230px] left-[110px] w-[763px] h-[612px] font-sans">
        <div className="absolute top-[0px] left-[0px] rounded-xl bg-[#599E40] opacity-25 w-[763px] h-[612px]" />
        <img
          className="absolute top-[37px] left-[205px] w-[151px] h-[159.9px] overflow-hidden"
          alt=""
          src="/metamask-1.svg"
        />
        <img
          className="absolute h-[121px] w-[181px] top-[11.59%] right-[17.61%] bottom-[56.89%] left-[54.17%] max-w-full overflow-hidden max-h-full"
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
        <div className="absolute top-[213px] left-[209px] text-xl inline-block w-[246px] h-6">
        {!isConnecting?(address?.substring(0, 10) + "......." + address?.substring(address?.length - 8)):
        (<div className='flex space-x-2 absolute top-[0px] left-[109px] text-xl w-[246px] h-6'>
        <span className='sr-only'>Loading...</span>
         <div className='h-8 w-8 bg-white rounded-full animate-bounce [animation-delay:-0.3s]'></div>
       <div className='h-8 w-8 bg-white rounded-full animate-bounce [animation-delay:-0.15s]'></div>
       <div className='h-8 w-8 bg-white rounded-full animate-bounce'></div>
   </div>)}
        </div>
        <img
          className="absolute h-[121px] w-[181px] top-[80.59%] right-[67.61%] bottom-[56.89%] left-[70.17%] max-w-full overflow-hidden max-h-full transform transition duration-500 
          hover:scale-105"
          alt=""
          src="/logoutbutton.svg"
          onClick={() =>
            {   disconnect()
            }}
        />
      </div>
      
      <div className="absolute top-[231px] left-[1116px] w-[615px] h-[603px] text-xl text-gray-100 font-sans">
      
        <div className="absolute top-[0px] left-[0px] rounded-xl  box-border w-[594px] h-[603px] border-[2px] border-dashed border-[#025231]" />
        <div className="absolute top-[49px] left-[56px] text-[28px] text-white inline-block w-[379px] h-[68px]">
          Create Subscription Model
        </div>
        
        
        <form>

        <input
                type="number"
                name="price"
                placeholder="Base Price"
                className="absolute leading-[1.6] top-[404px] left-[66px] w-[353px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
            />
            <div>
            <p className="absolute leading-[1.6] top-[404px] left-[430px] text-lg">
            GHO
            </p>    
            </div> 
        <input
                type="text"
                name="code"
                placeholder="Token Code"
                className="absolute top-[221px] left-[223px] w-[317px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
            /> 
            <input
                type="text"
                name="desc"
                placeholder="Token Description"
                className="absolute top-[320px] left-[66px] w-[474px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
            />        
            <input
                    type="text"
                    name="name"
                    placeholder="Token Name"
                    className="absolute top-[159px] left-[223px] w-[317px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
                />
                <select placeholder="Duration" className="absolute top-[489px] left-[66px] w-[352px] h-[46px] appearance-none bg-transparent border border-gray-200 text-[#9CA3AF] py-3 px-4 pr-8 rounded leading-tight focus:outline-none focus:bg-transparent focus:border-gray-500" id="grid-state">
                <option>Duration</option>
                <option>2 Months</option>
                <option>6 Months</option>
                </select>
        </form>
        
        <div className="absolute top-[141px] left-[24px] w-[199px] h-[193px] text-center text-[15px]">
          <div className="absolute top-[0px] left-[32px] rounded-[31px] bg-forestgreen-100 w-[132px] h-[132px]" />
          <img
            className="absolute top-[10px] left-[35px] w-[140px] h-[140px] cursor-pointer py-6 rounded-lg 
            transform transition duration-500 
            hover:scale-105"
            alt=""
            src="/plus.svg"
          />
        </div>
        <div className="absolute top-[497px] left-[483px] w-[76px] h-[72px] transform transition duration-500 
            hover:scale-105">
          <div className="absolute top-[0px] left-[0px] bg-forestgreen-200 w-[76px] h-[72px]" />
          <img
            className="absolute top-[15px] left-[17px] rounded-[1px] w-[42px] h-[42px]"
            alt=""
            src="/vector-27.svg"
          />
        </div>
      </div>
    </div>
  );
};

export default page;
