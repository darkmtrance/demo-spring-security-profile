#!/bin/bash

# Test Script for Demo Spring Security Profile API

BASE_URL="http://localhost:8080/api"

echo "=== Testing Demo Spring Security Profile API ==="
echo ""

# Test 1: Register a new user
echo "1. Registering a new user..."
SIGNUP_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }')

echo "Signup Response: $SIGNUP_RESPONSE"
echo ""

# Test 2: Login with the registered user
echo "2. Logging in with registered user..."
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }')

echo "Login Response: $LOGIN_RESPONSE"
echo ""

# Extract token from login response
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to extract token from login response"
  exit 1
fi

echo "✅ Token extracted: ${TOKEN:0:50}..."
echo ""

# Test 3: Try to access protected endpoint without token (should fail)
echo "3. Trying to access protected endpoint without token (should fail)..."
UNAUTH_RESPONSE=$(curl -s -w "\nHTTP Status: %{http_code}" -X GET "${BASE_URL}/protected/hello")
echo "Unauthorized Response: $UNAUTH_RESPONSE"
echo ""

# Test 4: Access protected endpoint with valid token
echo "4. Accessing protected endpoint with valid token..."
PROTECTED_RESPONSE=$(curl -s -X GET "${BASE_URL}/protected/hello" \
  -H "Authorization: Bearer $TOKEN")

echo "Protected Response: $PROTECTED_RESPONSE"
echo ""

# Test 5: Access profile endpoint with valid token
echo "5. Accessing profile endpoint with valid token..."
PROFILE_RESPONSE=$(curl -s -X GET "${BASE_URL}/protected/profile" \
  -H "Authorization: Bearer $TOKEN")

echo "Profile Response: $PROFILE_RESPONSE"
echo ""

# Test 6: Try to register with same email (should fail)
echo "6. Trying to register with same email (should fail)..."
DUPLICATE_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Doe",
    "email": "john@example.com",
    "password": "password456"
  }')

echo "Duplicate Registration Response: $DUPLICATE_RESPONSE"
echo ""

# Test 7: Try to login with wrong password (should fail)
echo "7. Trying to login with wrong password (should fail)..."
WRONG_PASSWORD_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "wrongpassword"
  }')

echo "Wrong Password Response: $WRONG_PASSWORD_RESPONSE"
echo ""

echo "=== Test completed ==="
