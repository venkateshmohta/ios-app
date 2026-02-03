#!/bin/bash

# ============================================
# Git Hooks Setup - iOS
# ============================================

echo ""
echo "🔧 Setting up Git hooks for iOS project..."
echo ""

git config core.hooksPath .githooks

chmod +x .githooks/*
chmod +x scripts/*.sh

echo "✅ Git hooks configured!"
echo ""
echo "Hooks installed:"
echo "  • commit-msg   - Validates version keyword in commits"
echo "  • post-commit  - Auto-bumps version after commit"
echo "  • pre-push     - Validates before push"
echo ""
echo "Supported branches: main, beta"
echo ""
echo "Version keywords:"
echo "  release:major  → Sprint release (x.0.0)"
echo "  release:minor  → Feature release (0.x.0)"
echo "  release:patch  → Bug fix (0.0.x)"
echo ""