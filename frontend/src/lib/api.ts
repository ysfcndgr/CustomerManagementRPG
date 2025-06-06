const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5001/api';

export interface Customer {
  customerId: number;
  name: string;
  phone?: string;
  email?: string;
  address: string;
  taxId: string;
  createdAt: string;
  updatedAt: string;
  status: 'Active' | 'Inactive';
}

export interface CustomerCreateRequest {
  name: string;
  phone?: string;
  email?: string;
  address: string;
  taxId: string;
}

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  errors?: Array<{ field: string; message: string }>;
  error?: string;
}

class ApiService {
  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    const url = `${API_BASE_URL}${endpoint}`;
    
    const defaultOptions: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        ...options.headers,
      },
    };

    try {
      const response = await fetch(url, { ...defaultOptions, ...options });
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error('API request failed:', error);
      throw error;
    }
  }

  // Get all customers
  async getCustomers(): Promise<ApiResponse<Customer[]>> {
    return this.request<Customer[]>('/customers');
  }

  // Get customer by ID
  async getCustomer(id: number): Promise<ApiResponse<Customer>> {
    return this.request<Customer>(`/customers/${id}`);
  }

  // Create new customer
  async createCustomer(customer: CustomerCreateRequest): Promise<ApiResponse<Customer>> {
    return this.request<Customer>('/customers', {
      method: 'POST',
      body: JSON.stringify(customer),
    });
  }

  // Update existing customer
  async updateCustomer(id: number, customer: CustomerCreateRequest): Promise<ApiResponse<Customer>> {
    return this.request<Customer>(`/customers/${id}`, {
      method: 'PUT',
      body: JSON.stringify(customer),
    });
  }

  // Delete customer
  async deleteCustomer(id: number): Promise<ApiResponse<void>> {
    return this.request<void>(`/customers/${id}`, {
      method: 'DELETE',
    });
  }

  // Health check
  async healthCheck(): Promise<ApiResponse<{ status: string; timestamp: string }>> {
    return this.request<{ status: string; timestamp: string }>('/health');
  }

  // Validate Tax ID
  async validateTaxId(taxId: string): Promise<ApiResponse<{ isValid: boolean; exists: boolean }>> {
    return this.request<{ isValid: boolean; exists: boolean }>(`/customers/validate-tax-id/${taxId}`);
  }
}

export const apiService = new ApiService(); 