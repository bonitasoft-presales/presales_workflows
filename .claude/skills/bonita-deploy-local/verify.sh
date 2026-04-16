#!/usr/bin/env bash

# Bonita Deployment Verification Script
# Usage: ./verify.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================"
echo "Bonita Deployment Verification"
echo -e "========================================${NC}"
echo ""

# 1. Check Docker containers
echo -e "${BLUE}1. Checking Docker containers...${NC}"
CONTAINER_COUNT=$(docker ps --filter "name=bonita" --format "{{.Names}}" | wc -l | tr -d ' ')

if [ "$CONTAINER_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Docker containers found${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "bonita|postgres|mail|NAMES"
else
    echo -e "${RED}✗ No Bonita containers running${NC}"
    echo "Run: cd infrastructure && ./build.sh"
    exit 1
fi
echo ""

# 2. Test Bonita server connectivity
echo -e "${BLUE}2. Testing Bonita server connectivity...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/bonita/loginservice")

if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Bonita server is responding (HTTP ${HTTP_CODE})${NC}"
else
    echo -e "${RED}✗ Bonita server is not accessible (HTTP ${HTTP_CODE})${NC}"
    exit 1
fi
echo ""

# 3. Test authentication
echo -e "${BLUE}3. Testing authentication...${NC}"
LOGIN_RESPONSE=$(curl -s -c /tmp/bonita-verify-cookies.txt \
    -d 'username=install&password=install&redirect=false' \
    http://localhost:8080/bonita/loginservice)

if [ -f /tmp/bonita-verify-cookies.txt ]; then
    echo -e "${GREEN}✓ Authentication successful${NC}"
else
    echo -e "${RED}✗ Authentication failed${NC}"
    exit 1
fi
echo ""

# 4. List deployed processes
echo -e "${BLUE}4. Listing deployed processes...${NC}"
API_TOKEN=$(grep X-Bonita-API-Token /tmp/bonita-verify-cookies.txt | awk '{print $7}')

if [ -z "$API_TOKEN" ]; then
    echo -e "${RED}✗ Could not extract API token${NC}"
    rm -f /tmp/bonita-verify-cookies.txt
    exit 1
fi

PROCESSES=$(curl -s -b /tmp/bonita-verify-cookies.txt \
    -H "X-Bonita-API-Token: $API_TOKEN" \
    http://localhost:8080/bonita/API/bpm/process)

PROCESS_COUNT=$(echo "$PROCESSES" | jq '. | length' 2>/dev/null || echo "0")

if [ "$PROCESS_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $PROCESS_COUNT process(es)${NC}"
    echo ""
    echo "$PROCESSES" | jq -r '.[] | "  - \(.name) v\(.version): \(.activationState)"'
else
    echo -e "${YELLOW}⚠ No processes found${NC}"
fi
echo ""

# 5. Check artifact file
echo -e "${BLUE}5. Checking build artifact...${NC}"
ARTIFACT=$(ls app/target/poc-cnaf-rh2026-*.zip 2>/dev/null | head -1)

if [ -n "$ARTIFACT" ]; then
    ARTIFACT_SIZE=$(ls -lh "$ARTIFACT" | awk '{print $5}')
    ARTIFACT_NAME=$(basename "$ARTIFACT")
    echo -e "${GREEN}✓ Artifact found: $ARTIFACT_NAME ($ARTIFACT_SIZE)${NC}"
else
    echo -e "${YELLOW}⚠ No artifact found in app/target/${NC}"
fi
echo ""

# Cleanup
rm -f /tmp/bonita-verify-cookies.txt

# Summary
echo -e "${BLUE}========================================"
echo "Verification Summary"
echo -e "========================================${NC}"
echo -e "${GREEN}✓ Docker containers: Running${NC}"
echo -e "${GREEN}✓ Bonita server: Accessible${NC}"
echo -e "${GREEN}✓ Authentication: Working${NC}"
echo -e "${GREEN}✓ Processes deployed: $PROCESS_COUNT${NC}"
if [ -n "$ARTIFACT" ]; then
    echo -e "${GREEN}✓ Build artifact: Present${NC}"
fi
echo ""
echo -e "${GREEN}All checks passed!${NC}"
echo ""
echo "Access URLs:"
echo "  - Bonita Portal: http://localhost:8080/bonita"
echo "  - Mail UI: http://localhost:8025"
echo "  - Credentials: install / install"
echo ""

exit 0
