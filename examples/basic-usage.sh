#!/bin/bash

# Basic Tadween CLI Usage Example
# Make sure to set your API key first: export TADWEEN_API_KEY=your_key

echo "🚀 Tadween CLI Example Workflow"
echo ""

# Check if API key is set
if [ -z "$TADWEEN_API_KEY" ]; then
    echo "❌ TADWEEN_API_KEY is not set!"
    echo "Set it with: export TADWEEN_API_KEY=your_api_key"
    exit 1
fi

echo "✅ API key is set"
echo ""

# 1. List integrations
echo "📋 Step 1: Listing connected integrations..."
tadween integrations:list
echo ""

# 2. Create a post
echo "📝 Step 2: Creating a test post..."
tadween posts:create \
  -c "Hello from Tadween CLI! This is an automated test post." \
  -s "$(date -u -v+1H +%Y-%m-%dT%H:%M:%SZ)" # Schedule 1 hour from now
echo ""

# 3. List posts
echo "📋 Step 3: Listing recent posts..."
tadween posts:list -l 5
echo ""

echo "✅ Example workflow completed!"
echo ""
echo "💡 Tips:"
echo "  - Use -i flag to specify integrations when creating posts"
echo "  - Upload images with: tadween upload ./path/to/image.png"
echo "  - Delete posts with: tadween posts:delete <post-id>"
echo "  - Get help: tadween --help"
