"use client";
import type { NextPage } from "next";
import { useContractRead, useDisconnect } from "wagmi";
import { useAccount } from "wagmi";
import { redirect } from "next/navigation";
import { use, useEffect, useState } from "react";
import { useProfiles } from "@lens-protocol/react-web";
import { LensClient, development } from "@lens-protocol/client";
import { useContractWrite } from "wagmi";
import { DEPLOYMENTS, LINK_ABI, MODULE_ABI } from "@/lib/constants";
import { encodeAbiParameters, parseAbiParameters } from "viem";

const useAccountData = () => {
  const { address } = useAccount();
  return { address };
};

const lensClient = new LensClient({
  environment: development,
});

const page: NextPage = () => {
  const { disconnect } = useDisconnect();
  const { isConnecting, isDisconnected } = useAccount();
  const [address, setAddress] = useState("");
  const [profiles, setProfiles] = useState<any>([]);
  const [mintTokenName, setMintTokenName] = useState("");
  const [mintTokenSymbol, setMintTokenSymbol] = useState("");
  const [tradeTokenName, setTradeTokenName] = useState("");
  const [tradeTokenSymbol, setTradeTokenSymbol] = useState("");
  const [mintTokenURI, setMintTokenURI] = useState("");
  const [tradeTokenURI, setTradeTokenURI] = useState("");
  const [mintPrice, setMintPrice] = useState("");
  const [minMintAmount, setMinMintAmount] = useState("");
  const [isapproved, setisapproved] = useState(false);

  const { writeAsync: createFanToken } = useContractWrite({
    address: DEPLOYMENTS.ghoFundMeModule as `0x${string}`,
    functionName: "createFanToken",
    abi: MODULE_ABI,
  });
  // Fetch account data using the custom hook
  const { address: accountAddress } = useAccountData();
  const { writeAsync: approveTokens } = useContractWrite({
    address: DEPLOYMENTS.polygonLINK as `0x${string}`,
    abi: LINK_ABI,
    functionName: "approve",
  });

  const { data: tokenIdCounter } = useContractRead({
    address: DEPLOYMENTS.ghoFundMeModule as `0x${string}`,
    abi: MODULE_ABI,
    functionName: "getLatestTokenId",
    args: [],
  });
  console.log("aaa"+parseAbiParameters("uint, uint, address, uint, uint"));
  console.log("bbb",tokenIdCounter,profiles && profiles.length > 0 && profiles[0].id,accountAddress as `0x${string}`,mintPrice as any,minMintAmount as any);
  const { data: fee, refetch: getFee } = useContractRead({
    address: DEPLOYMENTS.ghoFundMeModule as `0x${string}`,
    abi: MODULE_ABI,
    functionName: "getFee",
    args: [
      profiles && profiles.length > 0 && profiles[0].id,
      DEPLOYMENTS.ethereumSelector,
      
      encodeAbiParameters(
        parseAbiParameters("uint, uint, address, uint, uint"),
        [
          tokenIdCounter?tokenIdCounter:"" as any,
          profiles && profiles.length > 0 && profiles[0].id,
          accountAddress as `0x${string}`,
          mintPrice as any,
          minMintAmount as any,
        ]
      ),
    ],
  });

  useEffect(() => {
    if (isDisconnected) {
      redirect("/");
    }
  }, [isDisconnected]);

  useEffect(() => {}, []);

  useEffect(() => {
    if (accountAddress) {
      setAddress(accountAddress);
      (async function () {
        const allOwnedProfiles = await lensClient.profile.fetchAll({
          where: { ownedBy: [accountAddress] },
        });
        console.log(allOwnedProfiles.items);
        setProfiles(allOwnedProfiles.items);
      })();
    }
  }, [accountAddress]);

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
        <div className="absolute top-[0px] left-[100px] rounded-xl bg-[#599E40] opacity-25 w-[563px] h-[612px]" />
        <img
          className="absolute h-[121px] w-[181px] top-[11.59%] right-[17.61%] bottom-[56.89%] left-[40.17%] max-w-full overflow-hidden max-h-full"
          alt=""
          src="/vectorlens.svg"
        />
        {profiles.length > 0 && (
          <div className=" flex gap-2 absolute top-[258px] left-[175px] w-[599px] h-[72px] text-justify">
            <div>
              <p className="m-0 text-3xl text">Lens ID </p>
              <p className="m-0 text-3xl">Username</p>
            </div>
            <div>
              <p className="m-0 text-3xl">
                &nbsp;{parseInt(profiles[0].id, 16)}
              </p>
              <p className="m-0 text-3xl">
                &nbsp;{profiles[0].handle.localName}
              </p>
            </div>
          </div>
        )}
        <div className="absolute top-[213px] left-[209px] text-xl inline-block w-[246px] h-6">
          {!isConnecting ? (
            address?.substring(0, 10) +
            "......." +
            address?.substring(address?.length - 8)
          ) : (
            <div className="flex space-x-2 absolute top-[0px] left-[109px] text-xl w-[246px] h-6">
              <div className="h-8 w-8 bg-white rounded-full animate-bounce [animation-delay:-0.3s]"></div>
              <div className="h-8 w-8 bg-white rounded-full animate-bounce [animation-delay:-0.15s]"></div>
              <div className="h-8 w-8 bg-white rounded-full animate-bounce"></div>
            </div>
          )}
        </div>
        <img
          className="absolute h-[121px] w-[181px] top-[80.59%] right-[67.61%] bottom-[56.89%] left-[35.17%] max-w-full overflow-hidden max-h-full transform transition duration-500 
          hover:scale-105"
          alt=""
          src="/logoutbutton.svg"
          onClick={() => {
            disconnect();
          }}
        />
      </div>

      <div className="absolute top-[231px] left-[1016px] w-[615px] h-[603px] text-xl text-gray-100 font-sans">
        <div className="absolute top-[0px] left-[0px] rounded-xl  box-border w-[794px] h-[603px] border-[2px] border-dashed border-[#025231]" />
        <div className="absolute top-[49px] left-[56px] text-[28px] text-white inline-block w-full h-[68px]">
          Create Subscription Model
        </div>

        <form>
          <div className="absolute top-14">
            <input
              type="number"
              name="price"
              placeholder="Mint Price"
              value={mintPrice}
              onChange={(e) => {
                setMintPrice(e.target.value);
              }}
              className="absolute leading-[1.6] top-[404px] left-[66px] w-[353px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
            />
            <div>
              <p className="absolute leading-[1.6] top-[404px] left-[430px] text-lg">
                GHO
              </p>
            </div>
          </div>
          <div className="absolute">
            <input
              type="text"
              name="mtname"
              placeholder="Mint Token Name"
              value={mintTokenName}
              onChange={(e) => setMintTokenName(e.target.value)}
              className="absolute top-[159px] left-[66px] w-[317px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
            />
            <input
              type="text"
              name="mtsymbol"
              placeholder="Mint Token Symbol"
              value={mintTokenSymbol}
              onChange={(e) => setMintTokenSymbol(e.target.value)}
              className="absolute top-[221px] left-[66px] w-[317px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
            />
          </div>
          <div className="absolute left-32">
            <input
              type="text"
              name="ttname"
              placeholder="Trade Token Name"
              value={tradeTokenName}
              onChange={(e) => setTradeTokenName(e.target.value)}
              className="absolute top-[159px] left-[303px] w-[330px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
            />
            <input
              type="text"
              name="ttsymbol"
              placeholder="Trade Token Symbol"
              value={tradeTokenSymbol}
              onChange={(e) => setTradeTokenSymbol(e.target.value)}
              className="absolute top-[221px] left-[303px] w-[330px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
            />
          </div>
          <input
            type="url"
            name="mintTokenURI"
            placeholder=" Mint Token URI"
            value={mintTokenURI}
            onChange={(e) => setMintTokenURI(e.target.value)}
            className="absolute top-[280px] left-[66px] w-[574px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
          />
          <input
            type="url"
            name="tradeTokenURI"
            placeholder="Trade Token URI"
            value={tradeTokenURI}
            onChange={(e) => setTradeTokenURI(e.target.value)}
            className="absolute top-[340px] left-[66px] w-[574px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
          />
          <input
            type="number"
            name="desc"
            placeholder=" Minimum Mint Amount"
            value={minMintAmount}
            onChange={(e) => {
              setMinMintAmount(e.target.value);
            }}
            className="absolute top-[400px] left-[66px] w-[574px] h-8 px-4 py-2 border-b-2 border-white outline-none  focus:white bg-transparent"
          />
        </form>

        {/* <div className=" w-[199px] h-[193px] text-center text-[15px]">
          <div className="absolute flex top-[0px] left-[32px] rounded-[31px] bg-forestgreen-100 w-[132px] h-[132px]" />
          <p>FUND LINK</p>
          <img
            className="absolute top-[10px] left-[35px] w-[140px] h-[140px] cursor-pointer py-6 rounded-lg 
            transform transition duration-500 
            hover:scale-105"
            alt=""
            src="/plus.svg"
            onClick={async () => {
              await getFee();
              await approveTokens({
                args: [DEPLOYMENTS.ghoFundMeModule, fee],
              });
            }}
          />
        </div> */}
        <button
          onClick={async () => {
            await createFanToken({
              args: [
                [
                  mintTokenName,
                  tradeTokenName,
                  mintTokenSymbol,
                  tradeTokenSymbol,
                  mintTokenURI,
                  tradeTokenURI,
                  profiles && profiles.length > 0 && profiles[0].id,
                  mintPrice,
                  minMintAmount,
                ],
              ],
            });
          }}
          className="absolute top-[497px] left-[283px] w-[199px] h-[41] transform transition duration-500 
            hover:scale-105"
        >
          <div className="absolute top-[0px] left-[0px] bg-forestgreen-200 w-[199px] h-[41]" />
          <img
            className="absolute top-[15px] left-[17px] rounded-[1px] w-[199px] h-[41]"
            alt=""
            src="/approve.svg"
          />
        </button>
        <button
          className={`absolute top-[497px] left-[283px] w-[199px] h-[41] transform ${isapproved?`transition duration-500 hover:scale-105`:`cursor-not-allowed`}`}
        >
          <div className="absolute top-[0px] left-[0px] bg-forestgreen-200 w-[199px] h-[41]" />
          <img
            className="absolute top-[15px] left-[257px] rounded-[1px] w-[199px] h-[41]"
            alt=""
            src={isapproved?`/createactive`:`/createinactive.svg`}
          />
        </button>
      </div>
    </div>
  );
};

export default page;
