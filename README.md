## Demo Voting App

This is a demo voting app running natively on Oasis Sapphire. The app is a fork
of the [OPL Secret Ballot](https://github.com/oasisprotocol/playground/tree/main/opl-secret-ballot).

### Backend

This repo is set up for `pnpm` but other NodeJS package managers should work.

Install dependencies
```sh
pnpm install
```

Build smart contracts
```sh
pnpm build
```

### Frontend

Install dependencies

```sh
pnpm install
```

Compile and Hot-Reload for Development
```sh
pnpm dev
```

Build assets for deployment
```sh
pnpm build
```

### Local Development

We will use [Hardhat](https://hardhat.org/hardhat-runner/docs/getting-started#overview) and [Hardhat-deploy](https://github.com/wighawag/hardhat-deploy) to simplify development.

Start local Hardhat network
```sh
npx hardhat node
```

Deploy smart contracts locally
```sh
npx hardhat deploy-local --network localhost
```

We can now reference the deployed contracts in our frontend Vue app.

Modify the `.env.development` file with the appropriate addresses:
```yaml
VITE_BALLOT_BOX_V1_ADDR=0x5FbDB2315678afecb367f032d93F642f64180aa3
```
and
```yaml
VITE_DAO_V1_ADDR=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
```

Additionally, we will need a [Pinata](https://www.pinata.cloud) API [key](https://docs.pinata.cloud/pinata-api/authentication) to access the pinning
service with which we store our ballots as JSON.

```yaml
VITE_PINATA_JWT=
```

Start Vue app
```sh
pnpm dev
```

Navigate to http://localhost:5173, and you should be able to create a new poll.

You can use one of the deployed test accounts and associated private key with MetaMask.
