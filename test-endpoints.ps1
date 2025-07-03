# PowerShell script to test Spring Boot JWT Demo Application endpoints

$BaseUrl = "http://localhost:8080"

Write-Host "=== Testing Spring Boot JWT Demo Application ===" -ForegroundColor Blue
Write-Host "Base URL: $BaseUrl" -ForegroundColor Blue
Write-Host

# Function for colored output
function Write-Status {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

# Test 1: Register a new user
Write-Status "1. Testing user registration..."
$signupBody = @{
    name = "John Doe"
    email = "john@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $signupResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/signup" -Method POST -Body $signupBody -ContentType "application/json"
    Write-Host "Signup Response: $($signupResponse | ConvertTo-Json -Depth 3)"
} catch {
    Write-Error "Signup failed: $($_.Exception.Message)"
}
Write-Host

# Test 2: Login with the created user
Write-Status "2. Testing user login..."
$loginBody = @{
    email = "john@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "Login Response: $($loginResponse | ConvertTo-Json -Depth 3)"
    $token = $loginResponse.token
    Write-Host "Extracted Token: $token"
} catch {
    Write-Error "Login failed: $($_.Exception.Message)"
    $token = $null
}
Write-Host

# Test 3: Try to access protected endpoint without token (should fail)
Write-Status "3. Testing protected endpoint without token (should fail)..."
try {
    $protectedResponse = Invoke-RestMethod -Uri "$BaseUrl/api/protected/hello" -Method GET -ContentType "application/json"
    Write-Host "Protected Response (no token): $($protectedResponse | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Protected endpoint without token failed as expected: $($_.Exception.Message)"
}
Write-Host

# Test 4: Access protected endpoint with token (should succeed)
Write-Status "4. Testing protected endpoint with token (should succeed)..."
if ($token) {
    try {
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        $protectedWithTokenResponse = Invoke-RestMethod -Uri "$BaseUrl/api/protected/hello" -Method GET -Headers $headers
        Write-Host "Protected Response (with token): $($protectedWithTokenResponse | ConvertTo-Json -Depth 3)"
    } catch {
        Write-Error "Protected endpoint with token failed: $($_.Exception.Message)"
    }
} else {
    Write-Error "No token available for authenticated request"
}
Write-Host

# Test 5: Test profile endpoint with token
Write-Status "5. Testing profile endpoint with token..."
if ($token) {
    try {
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        $profileResponse = Invoke-RestMethod -Uri "$BaseUrl/api/protected/profile" -Method GET -Headers $headers
        Write-Host "Profile Response: $($profileResponse | ConvertTo-Json -Depth 3)"
    } catch {
        Write-Error "Profile endpoint failed: $($_.Exception.Message)"
    }
} else {
    Write-Error "No token available for profile request"
}
Write-Host

# Test 6: Test invalid login
Write-Status "6. Testing invalid login..."
$invalidLoginBody = @{
    email = "john@example.com"
    password = "wrongpassword"
} | ConvertTo-Json

try {
    $invalidLoginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -Body $invalidLoginBody -ContentType "application/json"
    Write-Host "Invalid Login Response: $($invalidLoginResponse | ConvertTo-Json -Depth 3)"
} catch {
    Write-Host "Invalid login failed as expected: $($_.Exception.Message)"
}
Write-Host

Write-Success "=== All tests completed ==="
