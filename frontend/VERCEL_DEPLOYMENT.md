# Vercel frontend deployment

This deployment runs the CISO Assistant SvelteKit frontend on Vercel. The Django
API, PostgreSQL database, Huey worker, and optional Qdrant service must run on a
separate container-capable host.

This branch includes a root-level `render.yaml` Blueprint for the Django API,
Huey worker, and managed PostgreSQL database. Create the Render Blueprint first,
then use its public API URL in the Vercel variables below.

## Vercel project settings

- Framework preset: `SvelteKit`
- Root directory: `frontend`
- Install command: `pnpm install --frozen-lockfile`
- Build command: `pnpm run build`
- Production branch: `codex/vercel-deployment-v3.18.2`

The checked-in `vercel.json` pins the install and build commands so the required
Paraglide translation compilation runs before Vite builds the application.

## Required environment variables

Set these variables for Production, Preview, and Development in Vercel:

```text
PUBLIC_BACKEND_API_URL=https://api.example.com/api
PUBLIC_BACKEND_API_EXPOSED_URL=https://api.example.com/api
NODE_OPTIONS=--max-old-space-size=8192
```

Both URLs must use HTTPS and point to the public Django API. Do not deploy with
the default `http://localhost:8000/api` value.

## Backend requirements

Configure the backend host with at least:

```text
CISO_ASSISTANT_URL=https://your-project.vercel.app
DJANGO_DEBUG=False
DJANGO_SECRET_KEY=<persistent-random-secret>
ALLOWED_HOSTS=api.example.com
```

Use PostgreSQL and S3-compatible or Azure Blob storage for production. Run the
Huey worker as a separate long-lived process. The backend URL must allow HTTPS
requests from the Vercel frontend and must use the same public application URL
for authentication and SSO callbacks.

The provided Render Blueprint prompts for the public Vercel URL and initial
administrator credentials. Attach S3-compatible or Azure Blob storage before
using evidence uploads in production; Render service filesystems are ephemeral
unless a persistent disk is attached.
