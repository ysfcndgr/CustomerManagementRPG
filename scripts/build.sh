#!/bin/bash

# Customer Information Update System - Docker Build Script
# This script builds and deploys the entire stack

set -e

echo "🚀 Building Customer Information Update System with Docker"
echo "============================================================"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Stop and remove existing containers
echo "🧹 Cleaning up existing containers..."
docker-compose down --remove-orphans

# Remove old images (optional)
read -p "🗑️  Remove old Docker images? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker system prune -f
    docker image prune -f
fi

# Build and start services
echo "🔨 Building and starting services..."
docker-compose up --build -d

# Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 30

# Check service health
echo "🔍 Checking service health..."

# Check database
if docker-compose exec -T database pg_isready -h localhost -p 5432; then
    echo "✅ Database is ready"
else
    echo "❌ Database failed to start"
    exit 1
fi

# Check backend API
if curl -f http://localhost:5001/api/health >/dev/null 2>&1; then
    echo "✅ Backend API is ready"
else
    echo "❌ Backend API failed to start"
    echo "📋 Backend logs:"
    docker-compose logs backend
    exit 1
fi

# Check frontend
if curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo "✅ Frontend is ready"
else
    echo "❌ Frontend failed to start"
    echo "📋 Frontend logs:"
    docker-compose logs frontend
    exit 1
fi

echo ""
echo "🎉 Successfully deployed Customer Information Update System!"
echo "============================================================"
echo "📱 Frontend:  http://localhost:3000"
echo "🔧 Backend:   http://localhost:5001"
echo "📊 API Docs:  http://localhost:5001/swagger"
echo "🗄️  Database: localhost:5432 (customerdb/admin/password123)"
echo ""
echo "🔧 AS400 Configuration:"
echo "   • Mock Mode: Enabled (for development)"
echo "   • To enable real AS400: Set AS400__UseRealConnection=true"
echo "   • RPG Program: CUSTLIB.MUSTVALID (simulated)"
echo ""
echo "📋 Management Commands:"
echo "   • View logs:     docker-compose logs -f [service]"
echo "   • Stop system:   docker-compose down"
echo "   • Restart:       docker-compose restart [service]"
echo "   • Shell access:  docker-compose exec [service] /bin/bash"
echo ""

# Show running containers
echo "🐳 Running containers:"
docker-compose ps 