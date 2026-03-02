# Local Development Guide

Complete guide for setting up and running the VS Platform locally on your development machine.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Starting Services](#starting-services)
4. [Development Workflow](#development-workflow)
5. [Common Tasks](#common-tasks)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** >= 18.0.0
- **pnpm** >= 8.0.0
- **Docker Desktop** (for PostgreSQL, Redis, ClickHouse)
- **Git**

### Installing Prerequisites

#### Node.js and pnpm

```bash
# Install Node.js (using nvm recommended)
nvm install 18
nvm use 18

# Install pnpm
npm install -g pnpm
```

#### Docker Desktop

- **macOS**: Download from [docker.com](https://www.docker.com/products/docker-desktop)
- **Windows**: Download from [docker.com](https://www.docker.com/products/docker-desktop)
- **Linux**: Install Docker Engine and Docker Compose

Verify Docker is running:
```bash
docker --version
docker compose version
```

## Initial Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd "VS platform"
```

### 2. Install Dependencies

```bash
pnpm install
```

This installs dependencies for:
- Backend
- Frontend
- Worker
- Shared types package

### 3. Configure Environment Variables

#### Backend

```bash
cd backend
cp env.local.example .env
```

The `.env` file should contain:
```env
NODE_ENV=development
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/vs_platform
REDIS_HOST=localhost
REDIS_PORT=6379
CLICKHOUSE_HOST=localhost
STORAGE_MODE=local
```

#### Worker

```bash
cd ../worker
cp env.local.example .env
```

#### Frontend

```bash
cd ../frontend
cp env.local.example .env.local
```

### 4. Start Docker Services

```bash
# From project root
docker compose up -d postgres redis clickhouse
```

Wait for services to be healthy (about 10-20 seconds):
```bash
docker compose ps
```

All services should show "Up" status:
- ✅ `vs-platform-postgres`
- ✅ `vs-platform-redis`
- ✅ `vs-platform-clickhouse`

### 5. Run Database Migrations

```bash
pnpm --filter backend prisma migrate dev
```

This creates the database schema.

### 6. Create Admin User

```bash
chmod +x scripts/create-admin-user.sh
./scripts/create-admin-user.sh admin@example.com SecurePassword123
```

## Starting Services

### Option 1: Start All Services (Recommended)

Open **4 separate terminal windows**:

**Terminal 1 - Docker Services:**
```bash
docker compose up -d postgres redis clickhouse
```

**Terminal 2 - Backend:**
```bash
pnpm --filter backend dev
```

**Terminal 3 - Worker:**
```bash
pnpm --filter worker dev
```

**Terminal 4 - Frontend:**
```bash
pnpm --filter frontend dev
```

### Option 2: Start Services Individually

You can start services one at a time as needed:

```bash
# Backend only
pnpm --filter backend dev

# Worker only
pnpm --filter worker dev

# Frontend only
pnpm --filter frontend dev
```

### Verify Services Are Running

- **Backend**: http://localhost:3001/health
- **Frontend**: http://localhost:3000
- **Worker**: Check terminal logs for "Worker service started"

## Development Workflow

### Making Code Changes

The development servers use hot-reload:

- **Backend**: `tsx watch` automatically restarts on file changes
- **Frontend**: Next.js Fast Refresh updates UI instantly
- **Worker**: Restart manually after changes (Ctrl+C, then restart)

### Database Changes

When you modify the Prisma schema:

```bash
# Create a new migration
pnpm --filter backend prisma migrate dev --name your_migration_name

# Apply migrations
pnpm --filter backend prisma migrate deploy
```

### Testing Changes

```bash
# Run backend tests
pnpm --filter backend test

# Run frontend tests
pnpm --filter frontend test

# Run all tests
pnpm test
```

## Common Tasks

### Upload a Video

1. Log in to http://localhost:3000
2. Navigate to "Upload Video"
3. Select a video file
4. Fill in title and description
5. Click "Upload"
6. Wait for processing (check worker logs)

### View Analytics

1. Navigate to "Analytics" in the sidebar
2. View video statistics, user activity, etc.

### Check Worker Status

```bash
# View worker logs
# (Check the terminal where worker is running)

# Or check Redis for job status
docker exec -it vs-platform-redis redis-cli
> KEYS bull:video-processing:*
```

### Reset Database

```bash
# Stop services
docker compose down

# Remove volumes
docker compose down -v

# Restart services
docker compose up -d postgres redis clickhouse

# Run migrations
pnpm --filter backend prisma migrate dev
```

### View Local Storage Files

```bash
# View uploaded videos
ls -la backend/uploads/raw/

# View HLS files
ls -la backend/uploads/hls/

# View thumbnails
ls -la backend/uploads/thumbnails/
```

### Test Email (MailHog)

1. Start MailHog (if not already running):
   ```bash
   docker run -d -p 1025:1025 -p 8025:8025 mailhog/mailhog
   ```

2. Trigger a password reset email
3. View emails at http://localhost:8025

## Troubleshooting

### Port Already in Use

**Error:** `EADDRINUSE: address already in use`

**Solution:**
```bash
# Find process using port 3001 (backend)
lsof -ti:3001 | xargs kill -9

# Find process using port 3000 (frontend)
lsof -ti:3000 | xargs kill -9
```

### Docker Services Won't Start

**Problem:** Docker daemon not running

**Solution:**
1. Open Docker Desktop
2. Wait for it to fully start
3. Try again: `docker compose up -d`

### Database Connection Failed

**Problem:** Cannot connect to PostgreSQL

**Solution:**
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Check logs
docker logs vs-platform-postgres

# Restart PostgreSQL
docker restart vs-platform-postgres
```

### Worker Not Processing Jobs

**Problem:** Videos stuck in "processing" status

**Solution:**
1. Check worker logs for errors
2. Verify Redis is running: `docker ps | grep redis`
3. Check job queue:
   ```bash
   docker exec -it vs-platform-redis redis-cli
   > KEYS bull:*
   ```
4. Restart worker

### Frontend Build Errors

**Problem:** Next.js build fails

**Solution:**
```bash
cd frontend
rm -rf .next
pnpm install
pnpm dev
```

### ClickHouse Connection Issues

**Problem:** Analytics not working

**Solution:**
```bash
# Check ClickHouse is running
docker ps | grep clickhouse

# Check logs
docker logs vs-platform-clickhouse

# Test connection
curl http://localhost:8123
```

### Storage Issues

**Problem:** Uploads fail or files not found

**Solution:**
```bash
# Check uploads directory exists
ls -la backend/uploads/

# Create if missing
mkdir -p backend/uploads/{raw,hls,thumbnails}

# Check permissions
chmod -R 755 backend/uploads/
```

## Development Tips

1. **Use VS Code** with recommended extensions:
   - Prisma
   - ESLint
   - Prettier
   - TypeScript

2. **Enable TypeScript strict mode** for better type safety

3. **Use Git hooks** (pre-commit) to run linters before committing

4. **Monitor logs** in separate terminal windows for easier debugging

5. **Use Docker Compose logs** to debug service issues:
   ```bash
   docker compose logs postgres
   docker compose logs redis
   docker compose logs clickhouse
   ```

6. **Keep dependencies updated**:
   ```bash
   pnpm update
   ```

## Next Steps

- See [ENVIRONMENT_SWITCHING.md](./ENVIRONMENT_SWITCHING.md) for switching to cloud environments
- See [API_REFERENCE.md](./API_REFERENCE.md) for API documentation
- See [TESTING.md](./TESTING.md) for testing guidelines
