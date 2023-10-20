const accountId = context.accountId;
const authorId = "meta-pool-official.near";
const tokenDecimals = 24;
const wNearContractId = "0xC42C30aC6Cc15faC9bD938618BcaA1a1FaE8501d";
const stNearContractId = "0x07F9F7f963C5cD2BBFFd30CcfB964Be114332E30";

State.init({
  openModal: false,
  validation: "",
  nearUsdPrice: null,
  nearUsdPriceIsFetched: false,
  metrics: null,
  metricsIsFetched: false,
  wNearBalance: null,
  wNearBalanceIsFetched: false,
  stNearBalance: null,
  stNearBalanceIsFetched: false,
  dataIntervalStarted: false,
  action: "stake", // "
});

if (
  state.chainId === undefined &&
  ethers !== undefined &&
  Ethers.send("eth_requestAccounts", [])[0]
) {
  Ethers.provider()
    .getNetwork()
    .then((chainIdData) => {
      if (chainIdData?.chainId) {
        State.update({ chainId: chainIdData.chainId });
      }
    });
}
if (state.chainId !== undefined && state.chainId !== 1313161554) {
  return <p>Switch to Aurora</p>;
}

function isValid(a) {
  if (!a) return false;
  if (isNaN(Number(a))) return false;
  if (a === "") return false;
  return true;
}

const abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "approve",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "balanceOf",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        internalType: "address",
        name: "spender",
        type: "address",
      },
    ],
    name: "allowance",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];
const iface = new ethers.utils.Interface(abi);

const fetchMetrics = () => {
  asyncFetch("https://validators.narwallets.com/metrics_json").then((resp) => {
    if (resp) {
      console.log("@metrics", resp?.body);
      State.update({ metrics: resp?.body ?? "...", metricsIsFetched: true });
    }
  });
};

const fetchNearPrice = () => {
  asyncFetch(
    "https://api.coingecko.com/api/v3/simple/price?ids=near&vs_currencies=usd"
  ).then((resp) => {
    const nearUsdPrice = resp?.body?.near.usd;
    if (nearUsdPrice && !isNaN(nearUsdPrice)) {
      console.log("@nearPrice", nearUsdPrice);
      State.update({
        nearUsdPrice: Number(nearUsdPrice),
        nearUsdPriceIsFetched: true,
      });
    }
  });
};

const getstNearBalance = () => {
  const receiver = state.sender;
  const encodedData = iface.encodeFunctionData("balanceOf", [receiver]);

  return Ethers.provider()
    .call({
      to: stNearContractId,
      data: encodedData,
    })
    .then((rawBalance) => {
      const receiverBalanceHex = iface.decodeFunctionResult(
        "balanceOf",
        rawBalance
      );

      const balance = Big(receiverBalanceHex.toString())
        .div(Big(10).pow(tokenDecimals))
        .toFixed(2)
        .replace(/\d(?=(\d{3})+\.)/g, "$&,");
      console.log("stNEABALANCE", balance);
      State.update({
        stNearBalance: balance,
        stNearBalanceIsFetched: true,
      });
    });
};

const getwNearBalance = () => {
  const receiver = state.sender;
  const encodedData = iface.encodeFunctionData("balanceOf", [receiver]);

  return Ethers.provider()
    .call({
      to: wNearContractId,
      data: encodedData,
    })
    .then((rawBalance) => {
      const receiverBalanceHex = iface.decodeFunctionResult(
        "balanceOf",
        rawBalance
      );

      const balance = Big(receiverBalanceHex.toString())
        .div(Big(10).pow(tokenDecimals))
        .toFixed(2)
        .replace(/\d(?=(\d{3})+\.)/g, "$&,");
      console.log("wNEABALANCE", balance);
      State.update({
        wNearBalance: balance,
        wNearBalanceIsFetched: true,
      });
    });
};

const update = (state) => State.update({ state });

const handleInputwNear = (value) => {
  if (
    (parseFloat(value) < 1 && parseFloat(value) > 0) ||
    parseFloat(value) < 0
  ) {
    State.update({
      validation: "The minimum amount is 1 wNEAR.",
    });
  } else if (parseFloat(value) > parseFloat(state.wNearBalance)) {
    State.update({
      validation: "You don't have enough wNEAR.",
    });
  } else {
    State.update({
      validation: "",
    });
  }
  State.update({ value });
};

const handleInputstNear = (value) => {
  if (
    (parseFloat(value) < 1 && parseFloat(value) > 0) ||
    parseFloat(value) < 0
  ) {
    State.update({
      validation: "The minimum amount is 1 stNEAR.",
    });
  } else if (parseFloat(value) > parseFloat(state.stNearBalance)) {
    State.update({
      validation: "You don't have enough stNEAR.",
    });
  } else {
    State.update({
      validation: "",
    });
  }
  State.update({ value });
};

const getUserAddress = () => {
  return !state.sender
    ? ""
    : state.sender.substring(0, 8) +
        "..." +
        state.sender.substring(state.sender.length - 6, state.sender.length);
};

const onClickMaxwNear = () => {
  const value =
    state.wNearBalance > 0.1
      ? (parseFloat(state.wNearBalance) - 0.1).toFixed(2)
      : "0";
  handleInputwNear(value);
};

const onClickMaxstNear = () => {
  const value =
    state.stNearBalance > 0.1
      ? (parseFloat(state.stNearBalance) - 0.1).toFixed(2)
      : "0";
  handleInputstNear(value);
};

// UPDATE DATA

const updateData = () => {
  fetchNearPrice();
  fetchMetrics();
  getwNearBalance();
  getstNearBalance();
};

if (!state.dataIntervalStarted) {
  State.update({ dataIntervalStarted: true });

  setInterval(() => {
    updateData();
  }, 10000);
}

if (state.sender === undefined) {
  const accounts = Ethers.send("eth_requestAccounts", []);
  if (accounts.length) {
    State.update({ sender: accounts[0] });
    updateData();
  }
}

const SelectionContainer = styled.div`
    width: 100%;
    max-width: 600px;
    align-self: center;
    background-color: white;
    border-bottom-left-radius: 0px;
    border-bottom-right-radius: 0px;
    font-weight: 400;
    font-size: 12px;
    line-height: 1.6em;
    border-radius: 20px;
    padding: 12px 26px;
    box-shadow: none;
    color: #fff;    
    margin-bottom: 1em;
    padding: 12px 26px 32px 26px;
  `;

const ActionItem = styled.button`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  padding: 8px 16px;
  width: 14em;
  height:5em;;
  text-align: left;
  align-items: center;
  border: 0.8px solid rgb(215, 224, 228);
  background: rgb(247, 249, 251);
  opacity: 0.8;

  border-radius: 24px;

  ${({ active }) =>
    active
      ? `
    background: rgb(206, 255, 26);
  `
      : `
    :hover {
      background: rgb(215, 224, 228);
    }
  `}


  div {
    display: flex;
    flex-direction: column;
  }
`;

const Text = styled.p`
  color:#000000;
  font-size: 14px;
  line-height: 21px;
`;

const SelectAction = styled.div`
border-bottom-left-radius: 0px;
border-bottom-right-radius: 0px;
border-radius: 20px;
display: flex;
flex-direction: column;
width: 100%;
`;

const TokensList = styled.div`
  display: flex;
  flex-direction: row;
  gap: 10px;
`;

const renderActions = (
  <SelectAction>
    <Text>Select action</Text>
    <TokensList>
      <ActionItem
        onClick={() => {
          State.update({ action: "stake" });
        }}
        active={state.action == "stake"}
      >
        <div>Stake</div>
        <div>
          <svg
            focusable="false"
            preserveAspectRatio="xMidYMid meet"
            xmlns="http://www.w3.org/2000/svg"
            fill="currentColor"
            width="24"
            height="24"
            viewBox="0 0 32 32"
            aria-hidden="true"
          >
            <path d="M16,7,6,17l1.41,1.41L15,10.83V28H2v2H15a2,2,0,0,0,2-2V10.83l7.59,7.58L26,17Z"></path>
            <path d="M6,8V4H26V8h2V4a2,2,0,0,0-2-2H6A2,2,0,0,0,4,4V8Z"></path>
          </svg>
        </div>
      </ActionItem>
      <ActionItem
        onClick={() => {
          State.update({ action: "fast" });
        }}
        active={state.action == "fast"}
      >
        <div>Fast Unstake</div>
        <div>
          <svg
            focusable="false"
            preserveAspectRatio="xMidYMid meet"
            xmlns="http://www.w3.org/2000/svg"
            fill="currentColor"
            width="24"
            height="24"
            viewBox="0 0 32 32"
            aria-hidden="true"
          >
            <path d="M18,30H4a2,2,0,0,1-2-2V14a2,2,0,0,1,2-2H18a2,2,0,0,1,2,2V28A2,2,0,0,1,18,30ZM4,14V28H18V14Z"></path>
            <path d="M25,23H23V9H9V7H23a2,2,0,0,1,2,2Z"></path>
            <path d="M30,16H28V4H16V2H28a2,2,0,0,1,2,2Z"></path>
          </svg>
        </div>
      </ActionItem>
    </TokensList>
  </SelectAction>
);

const render = {
  stake: (
    <Widget
      src={`${authorId}/widget/MetaPoolStake.wNear.Stake`}
      props={{
        update,
        state,
        isSignedIn,
        handleInputwNear,
        onClickMaxwNear,
        updateData,
        sender: state.sender,
      }}
    />
  ),
  fast: (
    <Widget
      src={`${authorId}/widget/MetaPoolStake.wNear.FastUnstake`}
      props={{
        update,
        state,
        isSignedIn,
        handleInputstNear,
        onClickMaxstNear,
        updateData,
        sender: state.sender,
      }}
    />
  ),
}[state.action];

return (
  <>
    <SelectionContainer>{renderActions}</SelectionContainer>
    {render}
  </>
);
