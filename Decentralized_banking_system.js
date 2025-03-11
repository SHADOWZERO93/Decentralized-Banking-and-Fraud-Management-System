let contract;
let account;
const contractAddress = "https://mainnet.infura.io/v3/f63c721dd5064566967232109622bbe9";  
const contractABI = [f63c721dd5064566967232109622bbe9]; 

// Connect MetaMask Wallet
async function connectWallet() {
    if (window.ethereum) {
        try {
            const web3 = new Web3(window.ethereum);
            await window.ethereum.request({ method: "eth_requestAccounts" });

            const accounts = await web3.eth.getAccounts();
            account = accounts[0];

            document.getElementById("wallet-address").innerText = "Connected: " + account;

            contract = new web3.eth.Contract(contractABI, contractAddress);
            alert("Wallet Connected: " + account);
        } catch (error) {
            console.error("Connection Error:", error);
            alert("User denied wallet connection.");
        }
    } else {
        alert("MetaMask not detected. Please install MetaMask.");
    }
}


async function depositFunds() {
    const amount = document.getElementById("amount").value;
    if (contract && account) {
        await contract.methods.deposit().send({ 
            from: account, 
            value: Web3.utils.toWei(amount, "ether") 
        });
        alert("Deposit successful!");
    } else {
        alert("Please connect your wallet first.");
    }
}


async function checkBalance() {
    if (contract) {
        const balance = await contract.methods.getBalance().call();
        document.getElementById("balance").innerText = 
            "Bank Balance: " + Web3.utils.fromWei(balance, "ether") + " ETH";
    } else {
        alert("Please connect your wallet first.");
    }
}


async function withdrawFunds() {
    const amount = document.getElementById("withdrawAmount").value;
    if (contract && account) {
        await contract.methods.withdraw(Web3.utils.toWei(amount, "ether")).send({ from: account });
        alert("Withdrawal successful!");
    } else {
        alert("Please connect your wallet first.");
    }
}
