# dc-crms-docker
cRMS traction Docker

## How to run
- `git clone https://github.com/DigiCred-Holdings/traction-docker-compose`
- `cd traction-docker-compose/digicred`
- Update `.env` file with correct values (see details below)
- `docker compose up -d`

### Configuring the .env File

The following values **must be updated** before running the system:

#### Core Configuration
- `TRACTION_ACAPY_SEED`: Generate a random 32-character seed for your agent's DID
- `ACAPY_ENDPOINT`: Set to your public domain (e.g., `http://your-domain.com:8030` for testing or `https://your-domain.com/agent/` for https with nginx reverse proxy)

#### Endorser Configuration
- `ACAPY_ENDORSER_SEED`: Set the seed for the first endorser agent
- `ACAPY_ENDORSER_SEED_1`: Set the seed for the second endorser agent
- `ACAPY_ENDORSER_PUBLIC_DID`: The public DID for the first endorser
- `ACAPY_ENDORSER_1_PUBLIC_DID`: The public DID for the second endorser

#### URL Configuration
- `SERVER_TRACTION_URL`: Set to your public domain (e.g., `http://your-domain.com:8032` for testing or `https://your-domain.com/proxy` for https with nginx reverse proxy)
- `FRONTEND_TENANT_PROXY_URL`: Same as SERVER_TRACTION_URL
- `API_BASE_URL`: Same as SERVER_TRACTION_URL
- `SWAGGER_API_URL`: Same as SERVER_TRACTION_URL

#### Authentication
- `BEARER_TOKEN`:  a secure token for API authentication copy from CRMS Interface
- `API_KEY`:  a secure API key copy from CRMS Interface

Additionally, you should update the `ledgers.yml` file to configure proper endorser DIDs:

```yaml
- id: digicred-test
  is_production: true
  is_write: true
  genesis_url: 'http://genesis.digicred.services:9000/genesis'
  endorser_did: '6f5Q4P6wbBz18NWagTUXNL'  # Update with your endorser DID
  endorser_alias: 'digicred-test-endorser'
- id: digicred-test-1
  is_production: true
  is_write: true
  genesis_url: 'http://genesis.digicred.services:9000/genesis'
  endorser_did: 'SStjc7Ykg493TQPC4BVgDV'  # Update with your second endorser DID
  endorser_alias: 'digicred-test-endorser-1'
```

### Production Deployment

For production environments, you should additionally update all security-related variables:

- All password fields (replace all instances of `change-me`)
- Database credentials
- JWT secrets
- Admin API keys
- Wallet encryption keys

Remember that using default values in production is a security risk.