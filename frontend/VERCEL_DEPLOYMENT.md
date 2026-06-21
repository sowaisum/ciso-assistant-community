# Vercel frontend deployment

The SvelteKit frontend runs on Vercel. The Django API, PostgreSQL database, Huey
worker, Qdrant, and evidence volume run on an Oracle Cloud Always Free Ampere A1
VM using the files in `deploy/oracle`.

## Vercel project settings

- Framework preset: `SvelteKit`
- Root directory: `frontend`
- Install command: `pnpm install --frozen-lockfile`
- Build command: `pnpm run build`
- Production branch: `codex/vercel-deployment-v3.18.2`

The checked-in `vercel.json` pins the install and build commands so the required
Paraglide translation compilation runs before Vite builds the application.

## Required environment variables

After the Oracle VM is running, set these values for Vercel Production:

```text
PUBLIC_BACKEND_API_URL=https://203-0-113-10.sslip.io/api
PUBLIC_BACKEND_API_EXPOSED_URL=https://203-0-113-10.sslip.io/api
NODE_OPTIONS=--max-old-space-size=8192
```

Replace the example address with the sslip.io hostname derived from the Oracle
VM public IP. Both URLs must use HTTPS.

The Oracle backend must set:

```text
CISO_ASSISTANT_URL=https://ciso-assistant-sowaisum.vercel.app
DJANGO_DEBUG=False
ALLOWED_HOSTS=203-0-113-10.sslip.io,backend,localhost
```

See `deploy/oracle/README.md` for VM provisioning, GitHub secrets, deployment,
and backup guidance.
