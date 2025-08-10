let web3;
let contract;
const contractAddress = "0x57F880e6e326c9e913C38c876cAD0D6b8892a019";
const contractABI = [
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            }
        ],
        "name": "closeStall",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "FundsWithdrawn",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "payer",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "PaymentMade",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            }
        ],
        "name": "payStall",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            },
            {
                "internalType": "address",
                "name": "to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "refund",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "to",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "RefundIssued",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "string",
                "name": "name",
                "type": "string"
            },
            {
                "internalType": "enum CCNCarnival2025.Duration",
                "name": "duration",
                "type": "uint8"
            }
        ],
        "name": "registerStall",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "time",
                "type": "uint256"
            },
            {
                "indexed": false,
                "internalType": "string",
                "name": "reason",
                "type": "string"
            }
        ],
        "name": "StallClosed",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            },
            {
                "indexed": true,
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "string",
                "name": "name",
                "type": "string"
            },
            {
                "indexed": false,
                "internalType": "enum CCNCarnival2025.Duration",
                "name": "duration",
                "type": "uint8"
            }
        ],
        "name": "StallRegistered",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            }
        ],
        "name": "withdraw",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "carnivalStart",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            }
        ],
        "name": "getPayers",
        "outputs": [
            {
                "internalType": "address[]",
                "name": "",
                "type": "address[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            },
            {
                "internalType": "address",
                "name": "user",
                "type": "address"
            }
        ],
        "name": "getPayment",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "stallId",
                "type": "uint256"
            }
        ],
        "name": "getStall",
        "outputs": [
            {
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "internalType": "string",
                "name": "name",
                "type": "string"
            },
            {
                "internalType": "enum CCNCarnival2025.Duration",
                "name": "duration",
                "type": "uint8"
            },
            {
                "internalType": "uint256",
                "name": "totalFunds",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "withdrawTime",
                "type": "uint256"
            },
            {
                "internalType": "enum CCNCarnival2025.Status",
                "name": "status",
                "type": "uint8"
            },
            {
                "internalType": "bool",
                "name": "withdrawn",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "oneDay",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "stallCount",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "stallExists",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "stalls",
        "outputs": [
            {
                "internalType": "address",
                "name": "owner",
                "type": "address"
            },
            {
                "internalType": "string",
                "name": "name",
                "type": "string"
            },
            {
                "internalType": "enum CCNCarnival2025.Duration",
                "name": "duration",
                "type": "uint8"
            },
            {
                "internalType": "uint256",
                "name": "totalFunds",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "withdrawTime",
                "type": "uint256"
            },
            {
                "internalType": "enum CCNCarnival2025.Status",
                "name": "status",
                "type": "uint8"
            },
            {
                "internalType": "bool",
                "name": "withdrawn",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];


async function connectMetaMask() {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        try {
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            contract = new web3.eth.Contract(contractABI, contractAddress);
            loadStalls();
            document.getElementById('connectBtn').innerText = 'Connected';
            document.getElementById('connectBtn').disabled = true;
        } catch (err) {
            alert('Connection rejected.');
        }
    } else {
        alert('Please install MetaMask!');
    }
}

window.addEventListener('load', () => {
    document.getElementById('connectBtn').onclick = connectMetaMask;
});

document.getElementById('registerForm').onsubmit = async (e) => {
    e.preventDefault();
    const name = document.getElementById('stallName').value;
    const duration = document.getElementById('stallDuration').value;
    const accounts = await web3.eth.getAccounts();
    contract.methods.registerStall(name, duration).send({ from: accounts[0] })
        .on('receipt', () => {
            loadStalls();
            document.getElementById('registerForm').reset();
        })
        .on('error', err => alert(err.message));
};

async function loadStalls() {
    const stallList = document.getElementById('stallList');
    stallList.innerHTML = '';
    const count = await contract.methods.stallCount().call();
    for (let i = 1; i <= count; i++) {
        const exists = await contract.methods.stallExists(i).call();
        if (!exists) continue;
        const s = await contract.methods.getStall(i).call();
        const div = document.createElement('div');
        div.className = 'stall';
        let paymentsHtml = '';
        let ownerActionsHtml = '';
        let accounts = [];
        try {
            accounts = await web3.eth.getAccounts();
        } catch { }
        // Status: 0=Open, 1=ClosedByOwner, 2=ClosedByTime, 3=Withdrawn
        let statusText = '';
        let statusColor = '';
        if (s[5] == '0') { statusText = 'Open'; statusColor = 'green'; }
        else if (s[5] == '1' || s[5] == '2') { statusText = 'Closed'; statusColor = 'red'; }
        else if (s[5] == '3') { statusText = 'Withdrawn'; statusColor = 'goldenrod'; }

        // Only show payments and owner actions if the connected user is the owner
        if (accounts.length > 0 && accounts[0].toLowerCase() === s[0].toLowerCase()) {
            // Fetch payers and their payments
            const payers = await contract.methods.getPayers(i).call();
            if (payers.length > 0) {
                paymentsHtml = '<div class="payments"><b>Payments:</b><ul>';
                for (const payer of payers) {
                    const amount = await contract.methods.getPayment(i, payer).call();
                    paymentsHtml += `<li>${payer}: ${web3.utils.fromWei(amount, 'ether')} ETH <button onclick="refundStall(${i}, '${payer}')">Refund</button></li>`;
                }
                paymentsHtml += '</ul></div>';
            } else {
                paymentsHtml = '<div class="payments"><b>Payments:</b> None</div>';
            }
            // Owner actions: closeStall if open
            if (s[5] == '0') {
                ownerActionsHtml += `<button onclick="closeStall(${i})">Close Stall</button>`;
            }
        }

        div.innerHTML = `<h3>${s[1]}</h3>
	  <p><b>Owner:</b> ${s[0]}</p>
	  <p><b>Status:</b> <span style="color:${statusColor};font-weight:bold;">${statusText}</span></p>
	  <p><b>Duration:</b> ${['Friday', 'Friday & Saturday', 'Friday, Saturday & Sunday'][s[2]]}</p>
	  <p><b>Total Funds:</b> ${web3.utils.fromWei(s[3], 'ether')} ETH</p>
	  <p><b>Withdraw Time:</b> ${new Date(s[4] * 1000).toLocaleString()}</p>
	  <p><b>Withdrawn:</b> ${s[6] ? 'Yes' : 'No'}</p>
	  ${paymentsHtml}
	  <div class="stall-actions">
		<button onclick="payStall(${i})">Pay</button>
		<button onclick="withdrawStall(${i})">Withdraw</button>
		${ownerActionsHtml}
	  </div>`;
        stallList.appendChild(div);
    }
}

window.payStall = async (stallId) => {
    const amount = prompt('Enter amount in ETH to pay:');
    if (!amount) return;
    const accounts = await web3.eth.getAccounts();
    contract.methods.payStall(stallId).send({ from: accounts[0], value: web3.utils.toWei(amount, 'ether') })
        .on('receipt', loadStalls)
        .on('error', err => alert(err.message));
};

window.withdrawStall = async (stallId) => {
    const accounts = await web3.eth.getAccounts();
    contract.methods.withdraw(stallId).send({ from: accounts[0] })
        .on('receipt', loadStalls)
        .on('error', err => alert(err.message));
};

window.refundStall = async (stallId, payer) => {
    const amount = prompt('Enter amount in ETH to refund to ' + payer + ':');
    if (!amount) return;
    const accounts = await web3.eth.getAccounts();
    contract.methods.refund(stallId, payer, web3.utils.toWei(amount, 'ether')).send({ from: accounts[0] })
        .on('receipt', loadStalls)
        .on('error', err => alert(err.message));
};

window.closeStall = async (stallId) => {
    if (!confirm('Are you sure you want to close this stall?')) return;
    const accounts = await web3.eth.getAccounts();
    contract.methods.closeStall(stallId).send({ from: accounts[0] })
        .on('receipt', loadStalls)
        .on('error', err => alert(err.message));
};
