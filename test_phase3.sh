#!/bin/bash
# Phase 3 Testing Script - User Data Isolation
# Tests that users can only see their own data

BASE_URL="http://localhost:8000"
COOKIES_USER1="cookies_user1.txt"
COOKIES_USER2="cookies_user2.txt"

echo "=========================================="
echo "PHASE 3: USER DATA ISOLATION TESTING"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASS=0
FAIL=0

test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASS${NC}: $2"
        ((PASS++))
    else
        echo -e "${RED}✗ FAIL${NC}: $2"
        ((FAIL++))
    fi
}

echo "Step 1: Register two test users"
echo "================================"

# Register User 1
USER1_DATA=$(curl -s -X POST "${BASE_URL}/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"testuser1_$(date +%s)\",
    \"email\": \"user1_$(date +%s)@test.com\",
    \"password\": \"TestPass123!\"
  }")

USER1_NAME=$(echo $USER1_DATA | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
echo "User 1 registered: $USER1_NAME"

# Register User 2
USER2_DATA=$(curl -s -X POST "${BASE_URL}/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"username\": \"testuser2_$(date +%s)\",
    \"email\": \"user2_$(date +%s)@test.com\",
    \"password\": \"TestPass123!\"
  }")

USER2_NAME=$(echo $USER2_DATA | grep -o '"username":"[^"]*"' | cut -d'"' -f4)
echo "User 2 registered: $USER2_NAME"
echo ""

echo "Step 2: Login both users"
echo "========================="

# Login User 1
USER1_LOGIN=$(curl -s -X POST "${BASE_URL}/api/auth/login" \
  -c $COOKIES_USER1 \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=${USER1_NAME}&password=TestPass123!")

echo "User 1 logged in"

# Login User 2
USER2_LOGIN=$(curl -s -X POST "${BASE_URL}/api/auth/login" \
  -c $COOKIES_USER2 \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=${USER2_NAME}&password=TestPass123!")

echo "User 2 logged in"
echo ""

# Create test PDF file
echo "%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj
2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj
3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
>>
endobj
xref
0 4
0000000000 65535 f 
0000000009 00000 n 
0000000058 00000 n 
0000000115 00000 n 
trailer
<<
/Size 4
/Root 1 0 R
>>
startxref
197
%%EOF" > test_user1.pdf

cp test_user1.pdf test_user2.pdf

echo "Step 3: User 1 uploads a document"
echo "==================================="

USER1_UPLOAD=$(curl -s -X POST "${BASE_URL}/api/upload/bulk" \
  -b $COOKIES_USER1 \
  -F "files=@test_user1.pdf")

USER1_DOC_ID=$(echo $USER1_UPLOAD | grep -o '"document_id":[0-9]*' | head -1 | cut -d':' -f2)
echo "User 1 uploaded document ID: $USER1_DOC_ID"
echo ""

echo "Step 4: User 2 uploads a document"
echo "==================================="

USER2_UPLOAD=$(curl -s -X POST "${BASE_URL}/api/upload/bulk" \
  -b $COOKIES_USER2 \
  -F "files=@test_user2.pdf")

USER2_DOC_ID=$(echo $USER2_UPLOAD | grep -o '"document_id":[0-9]*' | head -1 | cut -d':' -f2)
echo "User 2 uploaded document ID: $USER2_DOC_ID"
echo ""

echo "=========================================="
echo "TESTING DATA ISOLATION"
echo "=========================================="
echo ""

echo "Test 1: User 1 can access their own document"
echo "---------------------------------------------"
USER1_GET_OWN=$(curl -s -b $COOKIES_USER1 "${BASE_URL}/api/documents/${USER1_DOC_ID}")
if echo "$USER1_GET_OWN" | grep -q '"id"'; then
    test_result 0 "User 1 can access their own document"
else
    test_result 1 "User 1 CANNOT access their own document"
fi
echo ""

echo "Test 2: User 2 can access their own document"
echo "---------------------------------------------"
USER2_GET_OWN=$(curl -s -b $COOKIES_USER2 "${BASE_URL}/api/documents/${USER2_DOC_ID}")
if echo "$USER2_GET_OWN" | grep -q '"id"'; then
    test_result 0 "User 2 can access their own document"
else
    test_result 1 "User 2 CANNOT access their own document"
fi
echo ""

echo "Test 3: User 1 CANNOT access User 2's document"
echo "-----------------------------------------------"
USER1_GET_USER2=$(curl -s -b $COOKIES_USER1 "${BASE_URL}/api/documents/${USER2_DOC_ID}")
if echo "$USER1_GET_USER2" | grep -q '"detail":.*"not found"'; then
    test_result 0 "User 1 correctly blocked from User 2's document"
else
    test_result 1 "User 1 CAN ACCESS User 2's document (SECURITY ISSUE!)"
fi
echo ""

echo "Test 4: User 2 CANNOT access User 1's document"
echo "-----------------------------------------------"
USER2_GET_USER1=$(curl -s -b $COOKIES_USER2 "${BASE_URL}/api/documents/${USER1_DOC_ID}")
if echo "$USER2_GET_USER1" | grep -q '"detail":.*"not found"'; then
    test_result 0 "User 2 correctly blocked from User 1's document"
else
    test_result 1 "User 2 CAN ACCESS User 1's document (SECURITY ISSUE!)"
fi
echo ""

echo "Test 5: User 1's document list only shows their documents"
echo "----------------------------------------------------------"
USER1_LIST=$(curl -s -b $COOKIES_USER1 "${BASE_URL}/api/documents/")
USER1_LIST_COUNT=$(echo "$USER1_LIST" | grep -o '"total":[0-9]*' | cut -d':' -f2)
if [ "$USER1_LIST_COUNT" = "1" ]; then
    test_result 0 "User 1 sees only their 1 document"
else
    test_result 1 "User 1 sees $USER1_LIST_COUNT documents (should be 1)"
fi
echo ""

echo "Test 6: User 2's document list only shows their documents"
echo "----------------------------------------------------------"
USER2_LIST=$(curl -s -b $COOKIES_USER2 "${BASE_URL}/api/documents/")
USER2_LIST_COUNT=$(echo "$USER2_LIST" | grep -o '"total":[0-9]*' | cut -d':' -f2)
if [ "$USER2_LIST_COUNT" = "1" ]; then
    test_result 0 "User 2 sees only their 1 document"
else
    test_result 1 "User 2 sees $USER2_LIST_COUNT documents (should be 1)"
fi
echo ""

echo "Test 7: User 1 CANNOT delete User 2's document"
echo "-----------------------------------------------"
USER1_DELETE_USER2=$(curl -s -X DELETE -b $COOKIES_USER1 "${BASE_URL}/api/documents/${USER2_DOC_ID}")
if echo "$USER1_DELETE_USER2" | grep -q '"detail":.*"not found"'; then
    test_result 0 "User 1 correctly blocked from deleting User 2's document"
else
    test_result 1 "User 1 CAN DELETE User 2's document (SECURITY ISSUE!)"
fi
echo ""

# Cleanup
rm -f test_user1.pdf test_user2.pdf $COOKIES_USER1 $COOKIES_USER2

echo "=========================================="
echo "TEST SUMMARY"
echo "=========================================="
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED - Data isolation is working!${NC}"
    exit 0
else
    echo -e "${RED}✗ SOME TESTS FAILED - Data isolation has issues!${NC}"
    exit 1
fi
