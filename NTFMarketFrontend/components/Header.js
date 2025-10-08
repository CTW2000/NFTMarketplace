import { ConnectButton } from "web3uikit";
import Link from "next/link";

export default function Header() {
    return (
        <nav className=" border-b-2 flex flex-row justify-between items-center p-5">
        <h1 className="py-4 px-4 font-bold text-3xl"> NFT Marketplace </h1>
        <div className="flex flex-row items-center" >
        <Link href="/" className="mr-4 p-6">  Home </Link>
        <Link href="/sell-nft" className="mr-4 p-6"> Sell NFT</Link>
            
        </div>
        <div className="ml-auto py-2 px-4">
            <ConnectButton moralisAuth={false} />
        </div>
        </nav>
        
    )
}