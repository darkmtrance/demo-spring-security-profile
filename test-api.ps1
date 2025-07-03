# PowerShell Test Script for Demo Spring Security Profile API

$BASE_URL = "http://localhost:8080/api"

Write-Host "=== Testing Demo Spring Security Profile API ===" -ForegroundColor Green
Write-Host ""

# Test 1: Register a new user
Write-Host "1. Registering a new user..." -ForegroundColor Yellow
$signupBody = @{
    name = "John Doe"
    email = "john@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $signupResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/signup" -Method POST -Body $signupBody -ContentType "application/json"
    Write-Host "Signup Response: $($signupResponse | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "Signup Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Login with the registered user
Write-Host "2. Logging in with registered user..." -ForegroundColor Yellow
$loginBody = @{
    email = "john@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "Login Response: $($loginResponse | ConvertTo-Json)" -ForegroundColor Green
    $token = $loginResponse.token
} catch {
    Write-Host "Login Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

if (-not $token) {
    Write-Host "❌ Failed to extract token from login response" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Token extracted: $($token.Substring(0, [Math]::Min(50, $token.Length)))..." -ForegroundColor Green
Write-Host ""

# Test 3: Try to access protected endpoint without token (should fail)
Write-Host "3. Trying to access protected endpoint without token (should fail)..." -ForegroundColor Yellow
try {
    $unauthResponse = Invoke-RestMethod -Uri "$BASE_URL/protected/hello" -Method GET
    Write-Host "Unexpected success: $($unauthResponse | ConvertTo-Json)" -ForegroundColor Red
} catch {
    Write-Host "Expected error (401): $($_.Exception.Message)" -ForegroundColor Green
}
Write-Host ""

# Test 4: Access protected endpoint with valid token
Write-Host "4. Accessing protected endpoint with valid token..." -ForegroundColor Yellow
$headers = @{
    Authorization = "Bearer $token"
}

try {
    $protectedResponse = Invoke-RestMethod -Uri "$BASE_URL/protected/hello" -Method GET -Headers $headers
    Write-Host "Protected Response: $($protectedResponse | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "Protected Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 5: Access profile endpoint with valid token
Write-Host "5. Accessing profile endpoint with valid token..." -ForegroundColor Yellow
try {
    $profileResponse = Invoke-RestMethod -Uri "$BASE_URL/protected/profile" -Method GET -Headers $headers
    Write-Host "Profile Response: $($profileResponse | ConvertTo-Json)" -ForegroundColor Green
} catch {
    Write-Host "Profile Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 6: Try to register with same email (should fail)
Write-Host "6. Trying to register with same email (should fail)..." -ForegroundColor Yellow
$duplicateBody = @{
    name = "Jane Doe"
    email = "john@example.com"
    password = "password456"
} | ConvertTo-Json

try {
    $duplicateResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/signup" -Method POST -Body $duplicateBody -ContentType "application/json"
    Write-Host "Unexpected success: $($duplicateResponse | ConvertTo-Json)" -ForegroundColor Red
} catch {
    Write-Host "Expected error (duplicate email): $($_.Exception.Message)" -ForegroundColor Green
}
Write-Host ""

# Test 7: Try to login with wrong password (should fail)
Write-Host "7. Trying to login with wrong password (should fail)..." -ForegroundColor Yellow
$wrongPasswordBody = @{
    email = "john@example.com"
    password = "wrongpassword"
} | ConvertTo-Json

try {
    $wrongPasswordResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $wrongPasswordBody -ContentType "application/json"
    Write-Host "Unexpected success: $($wrongPasswordResponse | ConvertTo-Json)" -ForegroundColor Red
} catch {
    Write-Host "Expected error (wrong password): $($_.Exception.Message)" -ForegroundColor Green
}
Write-Host ""

Write-Host "=== Test completed ===" -ForegroundColor Green
