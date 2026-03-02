# Architecture Overview
## VS Platform - Technical Architecture Documentation

**Version:** 1.0.0  
**Date:** January 2025

---

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Component Overview](#component-overview)
3. [Data Flow](#data-flow)
4. [Technology Stack](#technology-stack)
5. [Infrastructure Architecture](#infrastructure-architecture)
6. [Security Architecture](#security-architecture)
7. [Scalability & Performance](#scalability--performance)
8. [Deployment Architecture](#deployment-architecture)

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Users (Browser)                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │   CloudFront CDN       │ (Global Content Delivery)
         └───────────┬───────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│    Frontend      │    │    Backend API   │
│   (Next.js)      │◄───┤   (Express)      │
│   Port 3000      │    │   Port 3001      │
└─────────────────┘    └────────┬──────────┘
                                 │
                    ┌────────────┼────────────┐
                    │            │            │
                    ▼            ▼            ▼
            ┌───────────┐ ┌──────────┐ ┌──────────┐
            │PostgreSQL  │ │  Redis   │ │ClickHouse│
            │   (RDS)    │ │(ElastiCache)│  (Cloud) │
            └───────────┘ └──────────┘ └──────────┘
                    │            │
                    │            │
                    ▼            ▼
            ┌─────────────────────────┐
            │      Worker Service      │
            │      (BullMQ/FFmpeg)    │
            └────────────┬────────────┘
                         │
                         ▼
                  ┌──────────┐
                  │   S3     │
                  │  Storage │
                  └──────────┘
```

### Service Architecture

The platform follows a **microservices architecture** with three main services:

1. **Frontend Service** (Next.js)
   - Client-side application
   - Server-side rendering
   - Static asset serving

2. **Backend Service** (Express)
   - RESTful API
   - Authentication & authorization
   - Business logic
   - File upload handling

3. **Worker Service** (BullMQ)
   - Background job processing
   - Video transcoding
   - Queue management

---

## Component Overview

### Frontend (Next.js)

**Responsibilities:**
- User interface rendering
- Video playback (HLS)
- Admin panel
- Analytics dashboard
- Authentication UI

**Key Features:**
- Server-side rendering (SSR)
- Static site generation (SSG)
- API route handlers
- Image optimization
- Responsive design

**Technology:**
- Next.js 14
- React 18
- TypeScript
- Video.js / hls.js
- Tailwind CSS

### Backend (Express)

**Responsibilities:**
- RESTful API endpoints
- Authentication (JWT)
- Authorization (RBAC + categories)
- Business logic
- Database operations
- File upload handling

**Key Features:**
- Express.js framework
- Prisma ORM
- JWT authentication
- Rate limiting
- Input validation
- Error handling

**Technology:**
- Node.js
- Express.js
- TypeScript
- Prisma
- BullMQ (queue client)
- AWS SDK

### Worker (BullMQ)

**Responsibilities:**
- Video transcoding (HLS)
- Background job processing
- Queue management
- File storage operations

**Key Features:**
- FFmpeg integration
- HLS generation
- Retry logic
- Dead-letter queue
- Progress tracking

**Technology:**
- Node.js
- BullMQ
- FFmpeg
- AWS SDK
- Prisma

---

## Data Flow

### Video Upload Flow

```
1. User uploads video via Frontend
   ↓
2. Frontend requests presigned URL from Backend
   ↓
3. Backend generates presigned URL (S3) or accepts direct upload (local)
   ↓
4. Frontend uploads video to S3 or Backend
   ↓
5. Backend creates video record in PostgreSQL
   ↓
6. Backend queues transcoding job in Redis
   ↓
7. Worker picks up job from queue
   ↓
8. Worker downloads video (S3) or reads from local storage
   ↓
9. Worker transcodes video to HLS using FFmpeg
   ↓
10. Worker uploads HLS files to S3 or local storage
   ↓
11. Worker updates video status in PostgreSQL
   ↓
12. Video is ready for playback via CloudFront (S3) or direct backend path (local)
```

### Video Playback Flow

```
1. User requests video via Frontend
   ↓
2. Frontend requests video metadata from Backend API
   ↓
3. Backend checks user permissions (category-based)
   ↓
4. Backend returns video metadata including HLS URL
   ↓
5. Frontend loads HLS manifest from CloudFront (S3) or backend (local)
   ↓
6. Video player requests segments from CDN/backend
   ↓
7. Video plays with adaptive bitrate streaming
```

### Analytics Flow

```
1. User interacts with video (play, pause, progress, etc.)
   ↓
2. Frontend sends analytics event to Backend API
   ↓
3. Backend validates and stores event in ClickHouse
   ↓
4. ClickHouse materialized views aggregate data
   ↓
5. Admin queries analytics via Backend API
   ↓
6. Backend queries ClickHouse for aggregated data
   ↓
7. Analytics displayed in admin dashboard
```

---

## Technology Stack

### Frontend Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Next.js | 14.x |
| UI Library | React | 18.x |
| Language | TypeScript | 5.x |
| Video Player | Video.js / hls.js | Latest |
| Styling | Tailwind CSS | 3.x |
| State Management | React Context | Built-in |

### Backend Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Runtime | Node.js | 18+ |
| Framework | Express.js | 4.x |
| Language | TypeScript | 5.x |
| ORM | Prisma | 7.x |
| Authentication | JWT | jsonwebtoken |
| Validation | Zod | 3.x |
| Queue Client | BullMQ | 5.x |

### Worker Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| Runtime | Node.js | 18+ |
| Language | TypeScript | 5.x |
| Queue | BullMQ | 5.x |
| Transcoding | FFmpeg | Latest |
| Storage | AWS SDK | 3.x |

### Data Layer

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Primary DB | PostgreSQL 15 | Application data |
| Cache/Queue | Redis 7 | Job queue, caching |
| Analytics | ClickHouse | Analytics data warehouse |
| Storage | AWS S3 | Video files, thumbnails |

### Infrastructure

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Containerization | Docker | Local development |
| Orchestration | Kubernetes (EKS) | Cloud deployment |
| Infrastructure | Terraform | IaC |
| CDN | CloudFront | Content delivery |
| Email | AWS SES | Email delivery |

---

## Infrastructure Architecture

### AWS Cloud Architecture

```
┌───────────────────────────────────────────────────────-──┐
│                    Internet / Users                      │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │   CloudFront CDN       │
         │  (Global Distribution) │
         └───────────┬────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│  Application     │    │   Load Balancer │
│  Load Balancer   │    │   (ALB/NLB)     │
└────────┬─────────┘    └────────┬────────┘
         │                       │
    ┌────┴────┐            ┌──────┴──────┐
    │         │            │            │
    ▼         ▼            ▼            ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Frontend│ │Backend │ │ Worker │ │ Worker │
│  Pod   │ │  Pod   │ │  Pod   │ │  Pod   │
└────────┘ └────────┘ └────────┘ └────────┘
    │         │            │            │
    └─────────┴────────────┴────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│   RDS PostgreSQL │    │ ElastiCache     │
│   (Multi-AZ)     │    │   Redis         │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────┬───────────┘
                     │
                     ▼
            ┌─────────────────┐
            │   S3 Buckets    │
            │  (Video Storage)│
            └─────────────────┘
```

### Network Architecture

- **VPC**: Isolated network environment
- **Subnets**: Public and private subnets
- **Security Groups**: Network access control
- **NAT Gateway**: Outbound internet access for private subnets
- **Internet Gateway**: Public internet access

### Storage Architecture

- **S3 Buckets**:
  - `vs-platform-uploads`: Raw videos and HLS files
  - Versioning enabled
  - Lifecycle policies for cost optimization

- **CloudFront**:
  - Origin: S3 bucket
  - Global edge locations
  - Caching policies
  - HTTPS only

---

## Security Architecture

### Authentication

- **JWT Tokens**: Stateless authentication
- **Refresh Tokens**: Long-lived session management
- **Password Hashing**: bcrypt with 12 rounds
- **Token Expiration**: Configurable (default: 7 days)

### Authorization

- **Role-Based Access Control (RBAC)**:
  - Admin: Full system access
  - Editor: Content management
  - User: Standard access

- **Category-Based Access Control**:
  - Dealer
  - Employee
  - Technician & Service
  - Stakeholder
  - Intern
  - Vendor

### Network Security

- **HTTPS Only**: All traffic encrypted
- **Security Headers**: Helmet.js configuration
- **CORS**: Configured allowed origins
- **Rate Limiting**: Protection against abuse
- **CSRF Protection**: Token-based protection

### Data Security

- **Encryption at Rest**: S3 server-side encryption
- **Encryption in Transit**: TLS/SSL for all connections
- **Database Security**: RDS encryption enabled
- **Secrets Management**: AWS Secrets Manager

---

## Scalability & Performance

### Horizontal Scaling

- **Frontend**: Stateless, can scale horizontally
- **Backend**: Stateless API, can scale horizontally
- **Worker**: Can scale based on queue depth

### Caching Strategy

- **Redis**: Session data, frequently accessed data
- **CloudFront**: Static assets, video files
- **Browser Cache**: Static assets with proper headers

### Performance Optimizations

- **CDN**: Global content delivery
- **HLS Adaptive Streaming**: Optimal quality based on bandwidth
- **Database Indexing**: Optimized queries
- **Connection Pooling**: Efficient database connections
- **Lazy Loading**: Frontend code splitting

### Monitoring

- **Application Metrics**: Custom metrics endpoint
- **Database Monitoring**: RDS performance insights
- **CDN Analytics**: CloudFront reports
- **Error Tracking**: Application logs

---

## Deployment Architecture

### Local Development

- Docker Compose for databases
- Local filesystem storage
- MailHog for email testing
- Direct service connections

### Staging Cloud

- EKS/ECS cluster
- RDS PostgreSQL
- ElastiCache Redis
- ClickHouse Cloud
- S3 + CloudFront
- AWS SES

### Production Cloud

- Same as staging with:
  - Multi-AZ deployment
  - Enhanced monitoring
  - Automated backups
  - Disaster recovery
  - Higher resource allocation

### CI/CD Pipeline

- **Source**: GitHub/GitLab
- **Build**: Docker images
- **Test**: Automated test suite
- **Deploy**: Staging → Production (with approval)
- **Rollback**: Quick rollback capability

---

## Diagrams

### Component Interaction

```
┌──────────┐      ┌──────────┐      ┌──────────┐
│ Frontend │◄────►│ Backend  │◄────►│PostgreSQL│
└────┬─────┘      └────┬─────┘      └──────────┘
     │                 │
     │                 ├─────────────┐
     │                 │             │
     │                 ▼             ▼
     │            ┌────────┐    ┌────────┐
     │            │ Redis   │   │ClickHouse│
     │            └────┬────┘   └────────┘
     │                 │
     │                 ▼
     │            ┌────────┐
     │            │ Worker  │
     │            └────┬────┘
     │                 │
     └─────────────────┴─────────────┐
                                     │
                                     ▼
                              ┌──────────┐
                              │    S3    │
                              └──────────┘
```

---

**Document Status:** Final  
**Last Updated:** January 2025
