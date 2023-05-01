import React, { useEffect, useState } from 'react';
import { ethers } from "ethers";
import Web3Modal from "web3modal";
import { contractABI, contractAddress } from './Constants';

//CREATING CONTEXT
export const InscribleContext = React.createContext();


const FetchContract = (signerProvider) =>
    new ethers.Contract(contractAddress, contractABI, signerProvider);

//FUNCTION TO CREATE CONTRACT
const CreateContract = async () => {
    try {
        //CREATING A ETHEREUM PROVIDER AND GETTING THE SIGNER
        const web3modal = new Web3Modal();
        const connection = await web3modal.connect();
        const provider = new ethers.providers.Web3Provider(connection);
        const signer = provider.getSigner();

        //SENDING THE SIGNER TO FetchContract FUNCTION TO GET THE SMART CONTRACT
        const contract = FetchContract(signer);

        return contract;
    } 
    catch (error) {
        console.log(error);
    }
};


//CREATING CONTEXT PROVIDER
export const InscribleProvider = ({ children }) => {

    const [isMetamask, setIsMetamask] = useState(true);
    const [connectedAccount, setConnectedAccount] = useState("");
    const [contract, setContract] = useState(null);
    const [isSignedin, setIsSignedin] = useState(false);

    //FUNCTION TO GET THE CONNECTED ACCOUNT
    const ConnectWallet = async () => {
        try {
            if (!window.ethereum) return setIsMetamask(false);

            window.ethereum.on("chainChanged", () => {
                window.location.reload(true);
            });
            window.ethereum.on("accountsChanged", () => {
                window.location.reload(true);
            });
            //GETTING ACCOUTNS ARRAY FROM ETHEREUM/METAMASK
            const accounts = await window.ethereum.request({
              method: "eth_requestAccounts",
            });

            //GETTING FIRST ACCOUNT FROM ACCOUNTS ARRAY
            const firstAccount = accounts[0];
            setConnectedAccount(firstAccount);

            const _contract = await CreateContract();

            setContract(_contract);
        } 
        catch (error) {
            console.log(error);
        }
    };

    const RegisterUser = async (username)=>{
        const createdUser = await contract.createAccount(username);
        await createdUser.wait();
    };

    const CheckIfUserIsRegistered = async (account)=>{
        const isUser = await contract.checkUser(account);
        console.log(isUser);
        if (isUser) {
            return true;
        }
        else{
            return false;
        }
    };

    const ValidateUsername = async (username)=>{
        const _username = await contract.getUsername(connectedAccount);

        console.log(_username);
        console.log(username);

        if (username === _username) {
            return true;
        }
        else{
            return false;
        }
    }

    useEffect(()=>{
        ConnectWallet();
    },[]);

    return (
        <InscribleContext.Provider
            value={{
              ConnectWallet,
              RegisterUser,
              CheckIfUserIsRegistered,
              ValidateUsername,
              setIsSignedin,
              isMetamask,
              connectedAccount,
              isSignedin
            }}
        >
            {children}
        </InscribleContext.Provider>
    );
};