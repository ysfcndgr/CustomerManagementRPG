import Link from 'next/link'
import { ArrowRight, CheckCircle, Globe, Zap, Shield, BarChart3 } from 'lucide-react'

export default function HomePage() {
  return (
    <div className="px-4 sm:px-6 lg:px-8">
      {/* Hero Section */}
      <div className="text-center py-12">
        <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
          Customer Information
          <span className="text-blue-600"> Update System</span>
        </h1>
        <p className="mt-6 text-lg leading-8 text-gray-600 max-w-2xl mx-auto">
          Modern web interface for customer data management with seamless AS400 integration. 
          Update customer information with real-time validation and comprehensive audit trails.
        </p>
        <div className="mt-10 flex items-center justify-center gap-x-6">
          <Link
            href="/customer-update"
            className="btn btn-primary flex items-center gap-2"
          >
            Add New Customer
            <ArrowRight className="h-4 w-4" />
          </Link>
          <Link
            href="/customers"
            className="btn btn-secondary flex items-center gap-2"
          >
            View All Customers
            <ArrowRight className="h-4 w-4" />
          </Link>
          <a 
            href="#features" 
            className="text-sm font-semibold leading-6 text-gray-900 hover:text-gray-700"
          >
            Learn more <span aria-hidden="true">→</span>
          </a>
        </div>
      </div>

      {/* Features Section */}
      <div id="features" className="py-16">
        <div className="mx-auto max-w-7xl">
          <div className="text-center">
            <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
              Enterprise-grade Features
            </h2>
            <p className="mt-4 text-lg text-gray-600">
              Built for reliability, security, and seamless integration with your existing systems
            </p>
          </div>

          <div className="mt-16 grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
            {/* Real-time Validation */}
            <div className="card">
              <div className="card-header">
                <CheckCircle className="h-8 w-8 text-green-600" />
                <div className="card-title text-lg">Real-time Validation</div>
              </div>
              <div className="card-content">
                <p className="text-gray-600">
                  Instant validation of customer data using AS400 RPG programs with comprehensive 
                  business rule enforcement and duplicate detection.
                </p>
              </div>
            </div>

            {/* AS400 Integration */}
            <div className="card">
              <div className="card-header">
                <Globe className="h-8 w-8 text-blue-600" />
                <div className="card-title text-lg">AS400 Integration</div>
              </div>
              <div className="card-content">
                <p className="text-gray-600">
                  Seamless integration with IBM AS400 systems through ODBC connections and 
                  native RPG program calls for enterprise-grade data processing.
                </p>
              </div>
            </div>

            {/* High Performance */}
            <div className="card">
              <div className="card-header">
                <Zap className="h-8 w-8 text-yellow-600" />
                <div className="card-title text-lg">High Performance</div>
              </div>
              <div className="card-content">
                <p className="text-gray-600">
                  Optimized API endpoints with caching, connection pooling, and efficient 
                  database operations for sub-second response times.
                </p>
              </div>
            </div>

            {/* Security First */}
            <div className="card">
              <div className="card-header">
                <Shield className="h-8 w-8 text-red-600" />
                <div className="card-title text-lg">Security First</div>
              </div>
              <div className="card-content">
                <p className="text-gray-600">
                  Comprehensive security with input validation, SQL injection prevention, 
                  and complete audit trails for all data modifications.
                </p>
              </div>
            </div>

            {/* Analytics & Monitoring */}
            <div className="card">
              <div className="card-header">
                <BarChart3 className="h-8 w-8 text-purple-600" />
                <div className="card-title text-lg">Analytics & Monitoring</div>
              </div>
              <div className="card-content">
                <p className="text-gray-600">
                  Built-in health checks, performance monitoring, and detailed logging 
                  for operational visibility and troubleshooting.
                </p>
              </div>
            </div>

            {/* Modern UI */}
            <div className="card">
              <div className="card-header">
                <Globe className="h-8 w-8 text-indigo-600" />
                <div className="card-title text-lg">Modern Interface</div>
              </div>
              <div className="card-content">
                <p className="text-gray-600">
                  Responsive, accessible web interface built with Next.js and TypeScript 
                  for an optimal user experience across all devices.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Architecture Overview */}
      <div className="py-16 bg-gray-50 -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          <h2 className="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
            System Architecture
          </h2>
          <p className="mt-4 text-lg text-gray-600">
            Three-tier architecture ensuring scalability, maintainability, and reliability
          </p>
        </div>

        <div className="mt-16 grid grid-cols-1 gap-8 lg:grid-cols-3">
          <div className="text-center">
            <div className="mx-auto h-16 w-16 bg-blue-100 rounded-lg flex items-center justify-center">
              <Globe className="h-8 w-8 text-blue-600" />
            </div>
            <h3 className="mt-4 text-lg font-semibold text-gray-900">Frontend Layer</h3>
            <p className="mt-2 text-gray-600">
              Next.js with TypeScript providing a modern, reactive user interface 
              with real-time validation and error handling.
            </p>
          </div>

          <div className="text-center">
            <div className="mx-auto h-16 w-16 bg-green-100 rounded-lg flex items-center justify-center">
              <Zap className="h-8 w-8 text-green-600" />
            </div>
            <h3 className="mt-4 text-lg font-semibold text-gray-900">API Layer</h3>
            <p className="mt-2 text-gray-600">
              .NET 8 Web API with clean architecture, comprehensive validation, 
              and robust error handling for reliable data processing.
            </p>
          </div>

          <div className="text-center">
            <div className="mx-auto h-16 w-16 bg-purple-100 rounded-lg flex items-center justify-center">
              <BarChart3 className="h-8 w-8 text-purple-600" />
            </div>
            <h3 className="mt-4 text-lg font-semibold text-gray-900">AS400 Layer</h3>
            <p className="mt-2 text-gray-600">
              IBM AS400 with RPG programs and DB2 database providing enterprise-grade 
              data validation and storage capabilities.
            </p>
          </div>
        </div>
      </div>

      {/* Call to Action */}
      <div className="py-16 text-center">
        <h2 className="text-3xl font-bold tracking-tight text-gray-900">
          Ready to manage customer information?
        </h2>
        <p className="mt-4 text-lg text-gray-600">
          Use our comprehensive customer management system with real-time AS400 integration.
        </p>
        <div className="mt-8 flex items-center justify-center gap-4">
          <Link
            href="/customer-update"
            className="btn btn-primary text-lg px-8 py-3"
          >
            Add New Customer
          </Link>
          <Link
            href="/customers"
            className="btn btn-secondary text-lg px-8 py-3"
          >
            View All Customers
          </Link>
        </div>
      </div>
    </div>
  )
} 