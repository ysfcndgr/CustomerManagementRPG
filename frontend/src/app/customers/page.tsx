'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { Search, Plus, Eye, Edit, Trash2, ArrowLeft, Download, Filter, RefreshCw } from 'lucide-react'
import { apiService, Customer } from '@/lib/api'

export default function CustomersPage() {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [filteredCustomers, setFilteredCustomers] = useState<Customer[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'All' | 'Active' | 'Inactive'>('All');
  const [isLoading, setIsLoading] = useState(false);
  const [lastSyncTime, setLastSyncTime] = useState<string>('');
  const [error, setError] = useState<string>('');

  // Load customers from API on component mount
  useEffect(() => {
    loadCustomers();
  }, []);

  const loadCustomers = async () => {
    try {
      setIsLoading(true);
      setError('');
      
      const response = await apiService.getCustomers();
      
      if (response.success && response.data) {
        setCustomers(response.data);
        setFilteredCustomers(response.data);
        setLastSyncTime(new Date().toLocaleString('en-US'));
      } else {
        setError(response.error || 'Failed to load customers');
      }
    } catch (error) {
      console.error('Error loading customers:', error);
      setError('Failed to connect to the server. Please check if the backend API is running.');
    } finally {
      setIsLoading(false);
    }
  };

  // Filter customers based on search term and status
  useEffect(() => {
    let filtered = customers;

    // Filter by search term
    if (searchTerm) {
      filtered = filtered.filter(customer => 
        customer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        customer.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        customer.taxId.includes(searchTerm) ||
        customer.phone?.includes(searchTerm)
      );
    }

    // Filter by status
    if (statusFilter !== 'All') {
      filtered = filtered.filter(customer => customer.status === statusFilter);
    }

    setFilteredCustomers(filtered);
  }, [searchTerm, statusFilter, customers]);

  const handleDeleteCustomer = async (customerId: number) => {
    if (window.confirm('Are you sure you want to delete this customer?')) {
      try {
        setIsLoading(true);
        
        const response = await apiService.deleteCustomer(customerId);
        
        if (response.success) {
          // Reload customers after successful deletion
          await loadCustomers();
        } else {
          setError(response.error || 'Failed to delete customer');
        }
      } catch (error) {
        console.error('Error deleting customer:', error);
        setError('Failed to delete customer. Please try again.');
      } finally {
        setIsLoading(false);
      }
    }
  };

  const handleExportCustomers = () => {
    // Simple CSV export
    const csvContent = [
      'Customer ID,Name,Phone,Email,Address,Tax ID,Status,Created,Updated',
      ...filteredCustomers.map(customer => 
        `${customer.customerId},"${customer.name}","${customer.phone || ''}","${customer.email || ''}","${customer.address}","${customer.taxId}","${customer.status}","${new Date(customer.createdAt).toLocaleDateString('en-US')}","${new Date(customer.updatedAt).toLocaleDateString('en-US')}"`
      )
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `customers-${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      {/* Header */}
      <div className="mb-8">
        <Link 
          href="/" 
          className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to Home
        </Link>
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Customer Management</h1>
            <p className="mt-2 text-gray-600">
              View and manage all customer records from the AS400 database
            </p>
          </div>
          <div className="mt-4 sm:mt-0">
            <Link
              href="/customer-update"
              className="btn btn-primary flex items-center gap-2"
            >
              <Plus className="h-4 w-4" />
              Add New Customer
            </Link>
          </div>
        </div>
      </div>

      {/* Filters and Search */}
      <div className="card mb-6">
        <div className="card-content">
          <div className="flex flex-col sm:flex-row gap-4">
            {/* Search */}
            <div className="flex-1">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search by name, email, tax ID, or phone..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="form-input pl-10"
                />
              </div>
            </div>

            {/* Status Filter */}
            <div className="flex items-center gap-2">
              <Filter className="h-4 w-4 text-gray-400" />
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value as 'All' | 'Active' | 'Inactive')}
                className="form-input w-32"
              >
                <option value="All">All Status</option>
                <option value="Active">Active</option>
                <option value="Inactive">Inactive</option>
              </select>
            </div>

            {/* Refresh Button */}
            <button
              onClick={loadCustomers}
              className="btn btn-secondary flex items-center gap-2"
            >
              <RefreshCw className="h-4 w-4" />
              Refresh
            </button>

            {/* Export Button */}
            <button
              onClick={handleExportCustomers}
              className="btn btn-secondary flex items-center gap-2"
            >
              <Download className="h-4 w-4" />
              Export CSV
            </button>
          </div>
        </div>
      </div>

      {/* Error Message */}
      {error && (
        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
          <div className="flex items-center gap-2">
            <div className="h-2 w-2 bg-red-500 rounded-full"></div>
            <span className="text-sm font-medium text-red-800">Connection Error</span>
          </div>
          <p className="text-xs text-red-600 mt-1">{error}</p>
        </div>
      )}

      {/* Loading State */}
      {isLoading && (
        <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div className="flex items-center gap-2">
            <RefreshCw className="h-4 w-4 text-blue-600 animate-spin" />
            <span className="text-sm font-medium text-blue-800">Loading customers...</span>
          </div>
        </div>
      )}

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="card">
          <div className="card-content">
            <div className="flex items-center">
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-600">Total Customers</p>
                <p className="text-2xl font-bold text-gray-900">{customers.length}</p>
              </div>
            </div>
          </div>
        </div>
        <div className="card">
          <div className="card-content">
            <div className="flex items-center">
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-600">Active</p>
                <p className="text-2xl font-bold text-green-600">
                  {customers.filter(c => c.status === 'Active').length}
                </p>
              </div>
            </div>
          </div>
        </div>
        <div className="card">
          <div className="card-content">
            <div className="flex items-center">
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-600">Inactive</p>
                <p className="text-2xl font-bold text-red-600">
                  {customers.filter(c => c.status === 'Inactive').length}
                </p>
              </div>
            </div>
          </div>
        </div>
        <div className="card">
          <div className="card-content">
            <div className="flex items-center">
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-600">This Month</p>
                <p className="text-2xl font-bold text-blue-600">
                  {customers.filter(c => 
                    new Date(c.createdAt) > new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
                  ).length}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Customer Table */}
      <div className="card">
        <div className="card-header">
          <div className="card-title">
            Customer Records ({filteredCustomers.length})
          </div>
          <div className="card-description">
            Real-time data from AS400 DB2 database
          </div>
        </div>
        <div className="card-content p-0">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Customer
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Contact Info
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Tax ID
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Last Updated
                  </th>
                  <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredCustomers.map((customer) => (
                  <tr key={customer.customerId} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div>
                        <div className="text-sm font-medium text-gray-900">
                          {customer.name}
                        </div>
                        <div className="text-sm text-gray-500">
                          ID: {customer.customerId}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="text-sm text-gray-900">
                        {customer.phone && (
                          <div className="flex items-center gap-1">
                            📞 {customer.phone}
                          </div>
                        )}
                        {customer.email && (
                          <div className="flex items-center gap-1 mt-1">
                            📧 {customer.email}
                          </div>
                        )}
                        <div className="text-xs text-gray-500 mt-1 max-w-xs truncate">
                          📍 {customer.address}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <code className="text-sm bg-gray-100 px-2 py-1 rounded">
                        {customer.taxId}
                      </code>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        customer.status === 'Active' 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {customer.status}
                      </span>
                    </td>
                                         <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                       <div>
                         {new Date(customer.updatedAt).toLocaleDateString('en-US')}
                       </div>
                       <div className="text-xs">
                         {new Date(customer.updatedAt).toLocaleTimeString('en-US')}
                       </div>
                     </td>
                    <td className="px-6 py-4 whitespace-nowrap text-center">
                      <div className="flex items-center justify-center gap-2">
                        <button
                          onClick={() => alert(`View details for ${customer.name}`)}
                          className="text-blue-600 hover:text-blue-900 p-1"
                          title="View Details"
                        >
                          <Eye className="h-4 w-4" />
                        </button>
                        <Link
                          href={`/customer-update?id=${customer.customerId}`}
                          className="text-green-600 hover:text-green-900 p-1"
                          title="Edit Customer"
                        >
                          <Edit className="h-4 w-4" />
                        </Link>
                        <button
                          onClick={() => handleDeleteCustomer(customer.customerId)}
                          disabled={isLoading}
                          className="text-red-600 hover:text-red-900 p-1 disabled:opacity-50"
                          title="Delete Customer"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            {filteredCustomers.length === 0 && (
              <div className="text-center py-12">
                <div className="text-gray-500 mb-4">
                  {searchTerm || statusFilter !== 'All' 
                    ? 'No customers found matching your criteria.' 
                    : 'No customers available.'}
                </div>
                {searchTerm || statusFilter !== 'All' ? (
                  <button
                    onClick={() => {
                      setSearchTerm('');
                      setStatusFilter('All');
                    }}
                    className="btn btn-secondary"
                  >
                    Clear Filters
                  </button>
                ) : (
                  <Link href="/customer-update" className="btn btn-primary">
                    Add First Customer
                  </Link>
                )}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* AS400 Integration Status */}
      <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <div className="flex items-center gap-2">
          <div className="h-2 w-2 bg-green-500 rounded-full animate-pulse"></div>
          <span className="text-sm font-medium text-blue-800">
            Connected to AS400 DB2 Database
          </span>
        </div>
        <p className="text-xs text-blue-600 mt-1">
          Last sync: {lastSyncTime || 'Loading...'} • All data is real-time from CUSTDATA.CUSTOMER table
        </p>
      </div>
    </div>
  );
} 