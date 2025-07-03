#!/bin/bash

# Test endpoints for the Spring Boot JWT Demo Application

BASE_URL="http://localhost:8080"

echo "=== Testing Spring Boot JWT Demo Application ==="
echo "Base URL: $BASE_URL"
echo

# Function to print colored output
print_status() {
    echo -e "\033[1;34m$1\033[0m"
}

print_success() {
    echo -e "\033[1;32m$1\033[0m"
}

print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

# Test 1: Register a new user
print_status "1. Testing user registration..."
SIGNUP_RESPONSE=$(curl -s -X POST \
  "$BASE_URL/api/auth/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }')

echo "Signup Response: $SIGNUP_RESPONSE"
echo

# Test 2: Login with the created user
print_status "2. Testing user login..."
LOGIN_RESPONSE=$(curl -s -X POST \
  "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }')

echo "Login Response: $LOGIN_RESPONSE"

# Extract JWT token
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*' | cut -d'"' -f4)
echo "Extracted Token: $TOKEN"
echo

# Test 3: Try to access protected endpoint without token (should fail)
print_status "3. Testing protected endpoint without token (should fail)..."
PROTECTED_RESPONSE=$(curl -s -X GET \
  "$BASE_URL/api/protected/hello" \
  -H "Content-Type: application/json")

echo "Protected Response (no token): $PROTECTED_RESPONSE"
echo

# Test 4: Access protected endpoint with token (should succeed)
print_status "4. Testing protected endpoint with token (should succeed)..."
if [ -n "$TOKEN" ]; then
    PROTECTED_WITH_TOKEN_RESPONSE=$(curl -s -X GET \
      "$BASE_URL/api/protected/hello" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN")
    
    echo "Protected Response (with token): $PROTECTED_WITH_TOKEN_RESPONSE"
else
    print_error "No token available for authenticated request"
fi
echo

# Test 5: Test profile endpoint with token
print_status "5. Testing profile endpoint with token..."
if [ -n "$TOKEN" ]; then
    PROFILE_RESPONSE=$(curl -s -X GET \
      "$BASE_URL/api/protected/profile" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $TOKEN")
    
    echo "Profile Response: $PROFILE_RESPONSE"
else
    print_error "No token available for profile request"
fi
echo

# Test 6: Test invalid login
print_status "6. Testing invalid login..."
INVALID_LOGIN_RESPONSE=$(curl -s -X POST \
  "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "wrongpassword"
  }')

echo "Invalid Login Response: $INVALID_LOGIN_RESPONSE"
echo

print_success "=== All tests completed ==="
