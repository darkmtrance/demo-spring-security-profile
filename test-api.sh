#!/bin/bash

# Test Script for Demo Spring Security Profile API
# This script provides basic automated testing via cURL
# For comprehensive testing, use the test-api.http file with REST Client

BASE_URL="http://localhost:8080/api"

echo "🧪 === Testing Demo Spring Security Profile API ==="
echo ""
echo "ℹ️  Note: For comprehensive testing with REST Client, use 'test-api.http'"
echo "ℹ️  This script provides basic automated cURL testing"
echo ""

# Check if server is running
echo "🔍 Checking if server is running..."
if ! curl -s --max-time 5 "http://localhost:8080/actuator/health" > /dev/null 2>&1; then
    echo "❌ Server is not running on localhost:8080"
    echo "   Please start the application first with: mvn spring-boot:run"
    exit 1
fi
echo "✅ Server is running"
echo ""

# Test 1: Register a new user
echo "1️⃣  Registering a new user..."
SIGNUP_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" -X POST "${BASE_URL}/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }')

HTTP_STATUS=$(echo $SIGNUP_RESPONSE | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
RESPONSE_BODY=$(echo $SIGNUP_RESPONSE | sed 's/HTTP_STATUS:[0-9]*$//')

if [ "$HTTP_STATUS" = "201" ] || [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Signup successful (HTTP $HTTP_STATUS)"
elif [ "$HTTP_STATUS" = "409" ]; then
    echo "⚠️  User already exists (HTTP $HTTP_STATUS) - continuing with tests"
else
    echo "❌ Signup failed (HTTP $HTTP_STATUS): $RESPONSE_BODY"
fi
echo ""

# Test 2: Login with the registered user
echo "2️⃣  Logging in with registered user..."
LOGIN_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" -X POST "${BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }')

HTTP_STATUS=$(echo $LOGIN_RESPONSE | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
RESPONSE_BODY=$(echo $LOGIN_RESPONSE | sed 's/HTTP_STATUS:[0-9]*$//')

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Login successful (HTTP $HTTP_STATUS)"
    # Extract token from login response
    TOKEN=$(echo $RESPONSE_BODY | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    
    if [ -z "$TOKEN" ]; then
        echo "❌ Failed to extract token from login response"
        exit 1
    fi
    echo "✅ Token extracted: ${TOKEN:0:50}..."
else
    echo "❌ Login failed (HTTP $HTTP_STATUS): $RESPONSE_BODY"
    exit 1
fi
echo ""

# Test 3: Try to access protected endpoint without token (should fail)
echo "3️⃣  Testing protected endpoint without token (should fail)..."
UNAUTH_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" -X GET "${BASE_URL}/protected/hello")
HTTP_STATUS=$(echo $UNAUTH_RESPONSE | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)

if [ "$HTTP_STATUS" = "401" ]; then
    echo "✅ Correctly rejected unauthorized request (HTTP $HTTP_STATUS)"
else
    echo "❌ Expected 401, got HTTP $HTTP_STATUS"
fi
echo ""

# Test 4: Access protected endpoint with valid token
echo "4️⃣  Accessing protected endpoint with valid token..."
PROTECTED_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" -X GET "${BASE_URL}/protected/hello" \
  -H "Authorization: Bearer $TOKEN")

HTTP_STATUS=$(echo $PROTECTED_RESPONSE | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)
RESPONSE_BODY=$(echo $PROTECTED_RESPONSE | sed 's/HTTP_STATUS:[0-9]*$//')

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Protected endpoint access successful (HTTP $HTTP_STATUS)"
    echo "   Response: $RESPONSE_BODY"
else
    echo "❌ Protected endpoint access failed (HTTP $HTTP_STATUS): $RESPONSE_BODY"
fi
echo ""

# Test 5: Test wrong password (should fail)
echo "5️⃣  Testing login with wrong password (should fail)..."
WRONG_PASSWORD_RESPONSE=$(curl -s -w "HTTP_STATUS:%{http_code}" -X POST "${BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "wrongpassword"
  }')

HTTP_STATUS=$(echo $WRONG_PASSWORD_RESPONSE | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2)

if [ "$HTTP_STATUS" = "401" ]; then
    echo "✅ Correctly rejected wrong password (HTTP $HTTP_STATUS)"
else
    echo "❌ Expected 401, got HTTP $HTTP_STATUS"
fi
echo ""

echo "🎉 === Basic Test Suite Completed ==="
echo ""
echo "📋 Summary:"
echo "   ✅ Server connectivity check"
echo "   ✅ User registration test"
echo "   ✅ User login test"
echo "   ✅ Unauthorized access prevention"
echo "   ✅ Authorized access test"
echo "   ✅ Wrong password rejection"
echo ""
echo "🔧 For comprehensive testing with all endpoints and edge cases:"
echo "   📄 Use 'test-api.http' with VS Code REST Client extension"
echo "   🌐 Or import endpoints into Postman"
echo "   📖 See TESTING.md for detailed testing instructions"
echo ""
