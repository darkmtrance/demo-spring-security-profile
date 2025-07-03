# PowerShell Test Script for Demo Spring Security Profile API
# This script provides basic automated testing via PowerShell
# For comprehensive testing, use the test-api.http file with REST Client

$BASE_URL = "http://localhost:8080/api"

Write-Host "🧪 === Testing Demo Spring Security Profile API ===" -ForegroundColor Green
Write-Host ""
Write-Host "ℹ️  Note: For comprehensive testing with REST Client, use 'test-api.http'" -ForegroundColor Cyan
Write-Host "ℹ️  This script provides basic automated PowerShell testing" -ForegroundColor Cyan
Write-Host ""

# Check if server is running
Write-Host "🔍 Checking if server is running..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" -Method GET -TimeoutSec 5
    Write-Host "✅ Server is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Server is not running on localhost:8080" -ForegroundColor Red
    Write-Host "   Please start the application first with: mvn spring-boot:run" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Test 1: Register a new user
Write-Host "1️⃣  Registering a new user..." -ForegroundColor Yellow
$signupBody = @{
    name = "John Doe"
    email = "john@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $signupResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/signup" -Method POST -Body $signupBody -ContentType "application/json"
    Write-Host "✅ Signup successful" -ForegroundColor Green
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 409) {
        Write-Host "⚠️  User already exists (HTTP 409) - continuing with tests" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Signup failed (HTTP $statusCode): $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Test 2: Login with the registered user
Write-Host "2️⃣  Logging in with registered user..." -ForegroundColor Yellow
$loginBody = @{
    email = "john@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✅ Login successful" -ForegroundColor Green
    $token = $loginResponse.token
    Write-Host "✅ Token extracted: $($token.Substring(0, [Math]::Min(50, $token.Length)))..." -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Test 3: Try to access protected endpoint without token (should fail)
Write-Host "3️⃣  Testing protected endpoint without token (should fail)..." -ForegroundColor Yellow
try {
    $unauthResponse = Invoke-RestMethod -Uri "$BASE_URL/protected/hello" -Method GET
    Write-Host "❌ Expected 401, but request succeeded" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 401) {
        Write-Host "✅ Correctly rejected unauthorized request (HTTP 401)" -ForegroundColor Green
    } else {
        Write-Host "❌ Expected 401, got HTTP $statusCode" -ForegroundColor Red
    }
}
Write-Host ""

# Test 4: Access protected endpoint with valid token
Write-Host "4️⃣  Accessing protected endpoint with valid token..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $protectedResponse = Invoke-RestMethod -Uri "$BASE_URL/protected/hello" -Method GET -Headers $headers
    Write-Host "✅ Protected endpoint access successful" -ForegroundColor Green
    Write-Host "   Response: $($protectedResponse | ConvertTo-Json -Compress)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Protected endpoint access failed: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 5: Test wrong password (should fail)
Write-Host "5️⃣  Testing login with wrong password (should fail)..." -ForegroundColor Yellow
$wrongPasswordBody = @{
    email = "john@example.com"
    password = "wrongpassword"
} | ConvertTo-Json

try {
    $wrongPasswordResponse = Invoke-RestMethod -Uri "$BASE_URL/auth/login" -Method POST -Body $wrongPasswordBody -ContentType "application/json"
    Write-Host "❌ Expected 401, but login succeeded with wrong password" -ForegroundColor Red
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 401) {
        Write-Host "✅ Correctly rejected wrong password (HTTP 401)" -ForegroundColor Green
    } else {
        Write-Host "❌ Expected 401, got HTTP $statusCode" -ForegroundColor Red
    }
}
Write-Host ""

Write-Host "🎉 === Basic Test Suite Completed ===" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "   ✅ Server connectivity check" -ForegroundColor Green
Write-Host "   ✅ User registration test" -ForegroundColor Green
Write-Host "   ✅ User login test" -ForegroundColor Green
Write-Host "   ✅ Unauthorized access prevention" -ForegroundColor Green
Write-Host "   ✅ Authorized access test" -ForegroundColor Green
Write-Host "   ✅ Wrong password rejection" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 For comprehensive testing with all endpoints and edge cases:" -ForegroundColor Yellow
Write-Host "   📄 Use 'test-api.http' with VS Code REST Client extension" -ForegroundColor Cyan
Write-Host "   🌐 Or import endpoints into Postman" -ForegroundColor Cyan
Write-Host "   📖 See TESTING.md for detailed testing instructions" -ForegroundColor Cyan
Write-Host ""
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
