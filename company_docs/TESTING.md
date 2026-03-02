# Testing Guide
## VS Platform - Testing Documentation

**Version:** 1.0.0  
**Date:** January 2025

---

## Testing Overview

The VS Platform includes comprehensive testing at multiple levels to ensure reliability and quality.

## Test Types

### Unit Tests

Test individual functions and components in isolation.

**Location:** `backend/src/**/*.test.ts`, `frontend/src/**/*.test.tsx`

**Run:**
```bash
pnpm test
```

### Integration Tests

Test API endpoints and database operations.

**Location:** `backend/src/**/*.integration.test.ts`

**Run:**
```bash
pnpm test:integration
```

### End-to-End Tests

Test complete user workflows.

**Location:** `e2e/`

**Run:**
```bash
pnpm test:e2e
```

## Test Coverage

Target coverage: >80% for critical paths.

## Running Tests

### All Tests
```bash
pnpm test
```

### Specific Service
```bash
pnpm --filter backend test
pnpm --filter frontend test
```

### Watch Mode
```bash
pnpm test:watch
```

## Test Environment

Tests use a separate test database and can be run in parallel.

## CI/CD Integration

Tests run automatically on:
- Pull requests
- Pushes to main/staging
- Before deployment

---

**Document Status:** Final  
**Last Updated:** January 2025
