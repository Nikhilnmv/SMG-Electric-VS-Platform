#!/bin/bash

# Script to create an admin user
# Usage: ./scripts/create-admin-user.sh [email] [password] [name]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values
EMAIL="${1:-admin@example.com}"
PASSWORD="${2:-admin123}"
NAME="${3:-Admin User}"
API_URL="${NEXT_PUBLIC_API_URL:-http://localhost:3001}"

echo "🔐 Creating Admin User"
echo "======================"
echo ""
echo "Email: $EMAIL"
echo "Name: $NAME"
echo "API URL: $API_URL"
echo ""

# Check if PostgreSQL is accessible
echo "1️⃣  Checking database connection..."
if ! docker ps | grep -q vs-platform-postgres; then
    echo -e "${YELLOW}⚠️  PostgreSQL container not found. Trying direct connection...${NC}"
    DB_METHOD="direct"
else
    DB_METHOD="docker"
    echo -e "${GREEN}✅ PostgreSQL container found${NC}"
fi
echo ""

# Check if user already exists
echo "2️⃣  Checking if user already exists..."
if [ "$DB_METHOD" == "docker" ]; then
    EXISTING_USER=$(docker exec -i vs-platform-postgres psql -U postgres -d vs_platform -t -c \
        "SELECT email, role FROM users WHERE email = '$EMAIL';" 2>&1 | grep -v "^$" | grep -v "email" | head -1)
    
    if [ -n "$EXISTING_USER" ] && echo "$EXISTING_USER" | grep -q "$EMAIL"; then
        echo -e "${YELLOW}⚠️  User already exists${NC}"
        echo "   $EXISTING_USER"
        
        # Check if already admin
        if echo "$EXISTING_USER" | grep -q "ADMIN"; then
            echo -e "${GREEN}✅ User is already an ADMIN${NC}"
            echo ""
            echo "📋 You can log in with:"
            echo "   Email: $EMAIL"
            echo "   Password: $PASSWORD"
            echo ""
            echo "   Navigate to: http://localhost:3000/login"
            exit 0
        else
            echo -e "${YELLOW}   Updating role to ADMIN...${NC}"
            UPDATE_RESULT=$(docker exec -i vs-platform-postgres psql -U postgres -d vs_platform -t -c \
                "UPDATE users SET role = 'ADMIN' WHERE email = '$EMAIL' RETURNING id, email, role;" 2>&1)
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ User role updated to ADMIN${NC}"
                echo "$UPDATE_RESULT" | grep -v "UPDATE" | grep -v "^$" || true
            else
                echo -e "${RED}❌ Failed to update role${NC}"
                echo "$UPDATE_RESULT"
                exit 1
            fi
        fi
    else
        echo -e "${GREEN}✅ User does not exist, will create new admin user${NC}"
        CREATE_NEW=true
    fi
else
    echo -e "${YELLOW}⚠️  Cannot check existing users with direct connection${NC}"
    echo "   Will attempt to create user (will fail if already exists)"
    CREATE_NEW=true
fi
echo ""

# Generate password hash using Node.js
echo "3️⃣  Generating password hash..."
if command -v node &> /dev/null; then
    PASSWORD_HASH=$(node -e "const bcrypt = require('bcryptjs'); bcrypt.hash('$PASSWORD', 10).then(hash => console.log(hash));" 2>/dev/null)
    
    if [ -z "$PASSWORD_HASH" ] || [ "$PASSWORD_HASH" == "undefined" ]; then
        echo -e "${RED}❌ Failed to generate password hash${NC}"
        echo "   Please ensure bcryptjs is installed:"
        echo "   cd backend && pnpm install bcryptjs"
        echo ""
        echo "   Or use an online bcrypt generator:"
        echo "   https://bcrypt-generator.com/"
        echo "   (Use 10 rounds, then paste the hash manually)"
        read -p "   Enter password hash manually: " PASSWORD_HASH
    else
        echo -e "${GREEN}✅ Password hash generated${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Node.js not found. Please generate password hash manually:${NC}"
    echo "   Visit: https://bcrypt-generator.com/"
    echo "   Use 10 rounds"
    echo "   Password: $PASSWORD"
    read -p "   Enter password hash: " PASSWORD_HASH
fi
echo ""

# Create or update user
if [ "$CREATE_NEW" == "true" ]; then
    echo "4️⃣  Creating admin user in database..."
    
    if [ "$DB_METHOD" == "docker" ]; then
        CREATE_RESULT=$(docker exec -i vs-platform-postgres psql -U postgres -d vs_platform -t -c \
            "INSERT INTO users (id, email, \"passwordHash\", role, \"categoryRole\", \"tokenVersion\", \"createdAt\")
             VALUES (
               gen_random_uuid(),
               '$EMAIL',
               '$PASSWORD_HASH',
               'ADMIN',
               'EMPLOYEE',
               0,
               NOW()
             ) RETURNING id, email, role, \"categoryRole\";" 2>&1)
        
        if [ $? -eq 0 ] && echo "$CREATE_RESULT" | grep -q "$EMAIL"; then
            echo -e "${GREEN}✅ Admin user created successfully${NC}"
            echo "$CREATE_RESULT" | grep -v "INSERT" | grep -v "^$" | head -1
        else
            if echo "$CREATE_RESULT" | grep -q "duplicate key"; then
                echo -e "${YELLOW}⚠️  User already exists, updating role to ADMIN...${NC}"
                UPDATE_RESULT=$(docker exec -i vs-platform-postgres psql -U postgres -d vs_platform -t -c \
                    "UPDATE users SET role = 'ADMIN' WHERE email = '$EMAIL' RETURNING id, email, role;" 2>&1)
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ User role updated to ADMIN${NC}"
                else
                    echo -e "${RED}❌ Failed to update role${NC}"
                    echo "$UPDATE_RESULT"
                    exit 1
                fi
            else
                echo -e "${RED}❌ Failed to create user${NC}"
                echo "$CREATE_RESULT"
                exit 1
            fi
        fi
    else
        echo -e "${YELLOW}⚠️  Please create the user manually:${NC}"
        echo ""
        echo "Run this SQL command:"
        echo "  INSERT INTO users (id, email, \"passwordHash\", role, \"categoryRole\", \"tokenVersion\", \"createdAt\", \"updatedAt\")"
        echo "  VALUES ("
        echo "    gen_random_uuid(),"
        echo "    '$EMAIL',"
        echo "    '$PASSWORD_HASH',"
        echo "    'ADMIN',"
        echo "    'EMPLOYEE',"
        echo "    0,"
        echo "    NOW(),"
        echo "    NOW()"
        echo "  );"
        echo ""
        read -p "Press Enter after you've created the user..."
    fi
else
    echo "4️⃣  User already exists, skipping creation"
fi
echo ""

# Verify user
echo "5️⃣  Verifying admin user..."
if [ "$DB_METHOD" == "docker" ]; then
    VERIFY_RESULT=$(docker exec -i vs-platform-postgres psql -U postgres -d vs_platform -t -c \
        "SELECT email, role FROM users WHERE email = '$EMAIL';" 2>&1)
    
    if echo "$VERIFY_RESULT" | grep -q "ADMIN"; then
        echo -e "${GREEN}✅ Role verified: ADMIN${NC}"
        echo "$VERIFY_RESULT" | grep -v "^$" | head -1
    else
        echo -e "${RED}❌ Role update verification failed${NC}"
        echo "$VERIFY_RESULT"
    fi
fi
echo ""

# Get authentication token (if backend is running)
echo "6️⃣  Testing login (if backend is running)..."
if curl -s "$API_URL/health" > /dev/null 2>&1; then
    LOGIN_RESPONSE=$(curl -s -X POST "$API_URL/api/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
    
    if echo "$LOGIN_RESPONSE" | jq -e '.success' > /dev/null 2>&1; then
        TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.token')
        ROLE=$(echo "$LOGIN_RESPONSE" | jq -r '.data.user.role')
        
        if [ "$ROLE" == "ADMIN" ]; then
            echo -e "${GREEN}✅ Login successful with ADMIN role${NC}"
        else
            echo -e "${YELLOW}⚠️  Login successful but role is: $ROLE${NC}"
            echo "   You may need to logout and login again to get a new token."
        fi
    else
        echo -e "${YELLOW}⚠️  Could not test login (backend may not be running)${NC}"
        echo "   This is okay - you can test login after starting the backend"
    fi
else
    echo -e "${YELLOW}⚠️  Backend is not running - skipping login test${NC}"
    echo "   Start the backend with: pnpm --filter backend dev"
fi
echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. Start the backend (if not already running):"
echo "   pnpm --filter backend dev"
echo ""
echo "2. Navigate to: http://localhost:3000/login"
echo ""
echo "3. Log in with:"
echo "   Email: $EMAIL"
echo "   Password: $PASSWORD"
echo ""
echo "4. You'll have admin access and can create more users at:"
echo "   http://localhost:3000/admin/users/create"
echo ""

echo ""
echo -e "${GREEN}🎉 Admin user setup complete!${NC}"

