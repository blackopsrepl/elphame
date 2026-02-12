#!/bin/bash
# Elphame Health Check Script
# Run this daily before making any changes

cd /srv/elphame

echo "=== Elphame Health Check ==="
echo "Timestamp: $(date)"
echo ""

# 1. Check database exists and is accessible
echo "1. Database File Check:"
if [ -f storage/development.sqlite3 ]; then
    SIZE=$(ls -lh storage/development.sqlite3 | awk '{print $5}')
    echo "   ✓ Database exists (${SIZE})"
else
    echo "   ✗ DATABASE MISSING!"
    exit 1
fi

# 2. Check database integrity
echo "2. Database Integrity:"
INTEGRITY=$(sqlite3 storage/development.sqlite3 "PRAGMA integrity_check;")
if [ "$INTEGRITY" = "ok" ]; then
    echo "   ✓ Integrity OK"
else
    echo "   ✗ INTEGRITY FAILED: ${INTEGRITY}"
    exit 1
fi

# 3. Check record counts
echo "3. Record Counts:"
DISCUSSIONS=$(sqlite3 storage/development.sqlite3 "SELECT COUNT(*) FROM discussions;")
POSTS=$(sqlite3 storage/development.sqlite3 "SELECT COUNT(*) FROM posts;")
USERS=$(sqlite3 storage/development.sqlite3 "SELECT COUNT(*) FROM users;")
echo "   - Discussions: ${DISCUSSIONS}"
echo "   - Posts: ${POSTS}"
echo "   - Users: ${USERS}"

# 4. Check last activity
echo "4. Last Activity:"
LAST_POST=$(sqlite3 storage/development.sqlite3 "SELECT created_at FROM posts ORDER BY created_at DESC LIMIT 1;" 2>/dev/null)
if [ -n "$LAST_POST" ]; then
    echo "   - Last post: ${LAST_POST}"
else
    echo "   - No posts yet"
fi

# 5. Check server status
echo "5. Server Status:"
if pgrep -f "puma.*elphame" > /dev/null; then
    PID=$(pgrep -f "puma.*elphame")
    echo "   ✓ Server running (PID: ${PID})"
else
    echo "   ✗ SERVER NOT RUNNING"
fi

# 6. Check HTTP response
echo "6. HTTP Health:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)
if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✓ HTTP 200 OK"
elif [ "$HTTP_CODE" = "302" ]; then
    echo "   ✓ HTTP 302 (redirect, server working)"
else
    echo "   ✗ HTTP ${HTTP_CODE}"
fi

echo ""
echo "=== Health Check Complete ==="
