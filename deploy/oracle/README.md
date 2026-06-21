# Oracle Cloud Always Free deployment

This deployment runs the CISO Assistant backend, Huey worker, PostgreSQL,
Qdrant, and Caddy on one Oracle Cloud Ampere A1 VM. The SvelteKit frontend stays
on Vercel.

## 1. Create the VM

In Oracle Cloud, create an Always Free eligible Ampere A1 VM with Ubuntu 24.04
ARM64. Allocate 2-4 OCPUs and 12-24 GB RAM within your Always Free allowance.
Assign a reserved public IPv4 address and keep the generated SSH private key.

Add ingress rules to the VM subnet or network security group:

| Source | Protocol | Port |
| --- | --- | --- |
| Your admin IP | TCP | 22 |
| `0.0.0.0/0` | TCP | 80 |
| `0.0.0.0/0` | TCP | 443 |
| `0.0.0.0/0` | UDP | 443 |

## 2. Bootstrap Ubuntu

Copy `bootstrap.sh` to the VM and run:

```bash
sudo bash bootstrap.sh
```

Sign out and back in so the `ubuntu` user receives Docker group membership.

## 3. Create the deployment environment

Convert the VM public IP to a free sslip.io hostname. For example,
`203.0.113.10` becomes `203-0-113-10.sslip.io`.

Copy `.env.example` to `.env` and set:

- `API_DOMAIN` and `ALLOWED_HOSTS` to the sslip.io hostname
- long random values for the PostgreSQL, Django, and admin passwords
- `CISO_ASSISTANT_URL=https://ciso-assistant-sowaisum.vercel.app`

Never commit `.env`.

## 4. Configure GitHub Actions

Add these repository secrets to `sowaisum/ciso-assistant-community`:

- `OCI_HOST`: VM public IPv4 address
- `OCI_USER`: `ubuntu`
- `OCI_SSH_PRIVATE_KEY`: complete private SSH key
- `OCI_SSH_KNOWN_HOSTS`: verified `known_hosts` line for the VM
- `OCI_DEPLOY_ENV`: complete contents of `deploy/oracle/.env`

Create the host-key value from a trusted first connection and verify its
fingerprint before saving it. Do not disable SSH host-key checking.

Run the `Deploy Oracle backend` workflow. It copies this directory to
`/opt/ciso-assistant`, pulls the pinned ARM64 images, starts the services, and
checks the public API health endpoint.

## 5. Connect Vercel

Set both Vercel production variables to the public API URL:

```text
PUBLIC_BACKEND_API_URL=https://203-0-113-10.sslip.io/api
PUBLIC_BACKEND_API_EXPOSED_URL=https://203-0-113-10.sslip.io/api
```

Redeploy the Vercel production project, then sign in with the configured initial
administrator credentials.

## Operations

On the VM:

```bash
cd /opt/ciso-assistant
docker compose ps
docker compose logs --tail=200 backend huey
docker compose pull
docker compose up -d --remove-orphans
```

Back up the PostgreSQL and attachment volumes regularly. Oracle Always Free does
not make this single-VM deployment highly available.
