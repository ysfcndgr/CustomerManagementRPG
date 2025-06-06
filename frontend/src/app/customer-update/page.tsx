'use client'

import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { ArrowLeft, Save, AlertCircle, CheckCircle, Loader2 } from 'lucide-react'
import Link from 'next/link'
import { apiService, CustomerCreateRequest } from '@/lib/api'

// Validation schema matching AS400 business rules
const customerUpdateSchema = z.object({
  name: z.string()
    .min(2, "Name must be at least 2 characters")
    .max(100, "Name must not exceed 100 characters")
    .regex(/^[a-zA-Z\s'-]+$/, "Name can only contain letters, spaces, hyphens, and apostrophes"),
  
  phone: z.string()
    .optional()
    .refine((phone) => {
      if (!phone || phone.trim() === '') return true;
      const cleaned = phone.replace(/[\s\-\(\)\+]/g, '');
      return /^\d{10,}$/.test(cleaned);
    }, "Phone number must contain at least 10 digits"),
  
  email: z.string()
    .optional()
    .refine((email) => {
      if (!email || email.trim() === '') return true;
      return /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(email);
    }, "Please enter a valid email address"),
  
  address: z.string()
    .min(5, "Address must be at least 5 characters")
    .max(255, "Address must not exceed 255 characters"),
  
  taxId: z.string()
    .length(11, "Tax ID must be exactly 11 digits")
    .regex(/^\d{11}$/, "Tax ID must contain only digits")
});

type CustomerUpdateForm = z.infer<typeof customerUpdateSchema>;

interface ApiResponse {
  success: boolean;
  message: string;
  data?: any;
  errors?: Array<{ field: string; message: string }>;
  error?: string;
}

export default function CustomerUpdatePage() {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitResult, setSubmitResult] = useState<ApiResponse | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    watch
  } = useForm<CustomerUpdateForm>({
    resolver: zodResolver(customerUpdateSchema)
  });

  const watchedFields = watch();

  const onSubmit = async (data: CustomerUpdateForm) => {
    setIsSubmitting(true);
    setSubmitResult(null);

    try {
      // Create customer request object
      const customerRequest: CustomerCreateRequest = {
        name: data.name,
        phone: data.phone || undefined,
        email: data.email || undefined,
        address: data.address,
        taxId: data.taxId
      };

      // Call the real API
      const response = await apiService.createCustomer(customerRequest);

      if (response.success) {
        setSubmitResult({
          success: true,
          message: "Customer information created successfully",
          data: response.data
        });
        reset(); // Clear form on success
      } else {
        setSubmitResult({
          success: false,
          message: response.message || "Failed to create customer",
          error: response.error,
          errors: response.errors
        });
      }
    } catch (error) {
      console.error('Error creating customer:', error);
      setSubmitResult({
        success: false,
        message: "Network error",
        error: "Failed to connect to the server. Please check if the backend API is running."
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
      {/* Header */}
      <div className="mb-8">
        <Link 
          href="/" 
          className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to Home
        </Link>
        <h1 className="text-3xl font-bold text-gray-900">Update Customer Information</h1>
        <p className="mt-2 text-gray-600">
          Update customer details with real-time AS400 validation and comprehensive business rule enforcement.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Main Form */}
        <div className="lg:col-span-2">
          <div className="card">
            <div className="card-header">
              <div className="card-title">Customer Details</div>
              <div className="card-description">
                All fields are validated against AS400 business rules
              </div>
            </div>
            <div className="card-content">
              <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
                {/* Customer Name */}
                <div className="form-field">
                  <label htmlFor="name" className="form-label">
                    Customer Name *
                  </label>
                  <input
                    id="name"
                    type="text"
                    {...register('name')}
                    className={`form-input ${errors.name ? 'border-red-500' : ''}`}
                    placeholder="Enter customer full name"
                  />
                  {errors.name && (
                    <p className="form-error">{errors.name.message}</p>
                  )}
                </div>

                {/* Phone Number */}
                <div className="form-field">
                  <label htmlFor="phone" className="form-label">
                    Phone Number
                  </label>
                  <input
                    id="phone"
                    type="tel"
                    {...register('phone')}
                    className={`form-input ${errors.phone ? 'border-red-500' : ''}`}
                    placeholder="(555) 123-4567"
                  />
                  {errors.phone && (
                    <p className="form-error">{errors.phone.message}</p>
                  )}
                  <p className="text-xs text-gray-500 mt-1">
                    Format: (XXX) XXX-XXXX or XXX-XXX-XXXX
                  </p>
                </div>

                {/* Email Address */}
                <div className="form-field">
                  <label htmlFor="email" className="form-label">
                    Email Address
                  </label>
                  <input
                    id="email"
                    type="email"
                    {...register('email')}
                    className={`form-input ${errors.email ? 'border-red-500' : ''}`}
                    placeholder="customer@example.com"
                  />
                  {errors.email && (
                    <p className="form-error">{errors.email.message}</p>
                  )}
                </div>

                {/* Address */}
                <div className="form-field">
                  <label htmlFor="address" className="form-label">
                    Mailing Address *
                  </label>
                  <textarea
                    id="address"
                    rows={3}
                    {...register('address')}
                    className={`form-input resize-none ${errors.address ? 'border-red-500' : ''}`}
                    placeholder="123 Main Street, City, State, ZIP Code"
                  />
                  {errors.address && (
                    <p className="form-error">{errors.address.message}</p>
                  )}
                </div>

                {/* Tax ID */}
                <div className="form-field">
                  <label htmlFor="taxId" className="form-label">
                    Tax ID Number *
                  </label>
                  <input
                    id="taxId"
                    type="text"
                    {...register('taxId')}
                    className={`form-input ${errors.taxId ? 'border-red-500' : ''}`}
                    placeholder="12345678901"
                    maxLength={11}
                  />
                  {errors.taxId && (
                    <p className="form-error">{errors.taxId.message}</p>
                  )}
                  <p className="text-xs text-gray-500 mt-1">
                    Exactly 11 digits, must be unique in the system
                  </p>
                </div>

                {/* Submit Button */}
                <div className="flex items-center gap-4 pt-4">
                  <button
                    type="submit"
                    disabled={isSubmitting}
                    className="btn btn-primary flex items-center gap-2"
                  >
                    {isSubmitting ? (
                      <>
                        <Loader2 className="h-4 w-4 animate-spin" />
                        Processing...
                      </>
                    ) : (
                      <>
                        <Save className="h-4 w-4" />
                        Update Customer
                      </>
                    )}
                  </button>
                  <button
                    type="button"
                    onClick={() => reset()}
                    disabled={isSubmitting}
                    className="btn btn-secondary"
                  >
                    Clear Form
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Validation Status */}
          <div className="card">
            <div className="card-header">
              <div className="card-title text-lg">Validation Status</div>
            </div>
            <div className="card-content space-y-3">
              <div className="flex items-center gap-2">
                <CheckCircle className={`h-4 w-4 ${watchedFields.name && !errors.name ? 'text-green-600' : 'text-gray-300'}`} />
                <span className="text-sm">Customer Name</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle className={`h-4 w-4 ${watchedFields.phone && !errors.phone ? 'text-green-600' : 'text-gray-300'}`} />
                <span className="text-sm">Phone Number</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle className={`h-4 w-4 ${watchedFields.email && !errors.email ? 'text-green-600' : 'text-gray-300'}`} />
                <span className="text-sm">Email Address</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle className={`h-4 w-4 ${watchedFields.address && !errors.address ? 'text-green-600' : 'text-gray-300'}`} />
                <span className="text-sm">Address</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle className={`h-4 w-4 ${watchedFields.taxId && !errors.taxId ? 'text-green-600' : 'text-gray-300'}`} />
                <span className="text-sm">Tax ID</span>
              </div>
            </div>
          </div>

          {/* Business Rules */}
          <div className="card">
            <div className="card-header">
              <div className="card-title text-lg">Validation Rules</div>
            </div>
            <div className="card-content">
              <ul className="text-sm text-gray-600 space-y-2">
                <li>• Name: 2-100 characters, letters only</li>
                <li>• Phone: Minimum 10 digits (optional)</li>
                <li>• Email: Valid format (optional)</li>
                <li>• Address: 5-255 characters (required)</li>
                <li>• Tax ID: Exactly 11 digits (unique)</li>
              </ul>
            </div>
          </div>

          {/* Test Cases */}
          <div className="card">
            <div className="card-header">
              <div className="card-title text-lg">Test Cases</div>
            </div>
            <div className="card-content">
              <div className="text-sm text-gray-600 space-y-2">
                <p><strong>Duplicate Test:</strong> Use Tax ID <code>99999999999</code></p>
                <p><strong>System Error:</strong> Use Tax ID <code>00000000000</code></p>
                <p><strong>Success:</strong> Any other valid Tax ID</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Result Message */}
      {submitResult && (
        <div className={`mt-8 p-4 rounded-lg border ${
          submitResult.success 
            ? 'bg-green-50 border-green-200 text-green-800' 
            : 'bg-red-50 border-red-200 text-red-800'
        }`}>
          <div className="flex items-start gap-3">
            {submitResult.success ? (
              <CheckCircle className="h-5 w-5 text-green-600 mt-0.5" />
            ) : (
              <AlertCircle className="h-5 w-5 text-red-600 mt-0.5" />
            )}
            <div>
              <p className="font-medium">{submitResult.message}</p>
              {submitResult.error && (
                <p className="mt-1 text-sm">{submitResult.error}</p>
              )}
              {submitResult.success && submitResult.data && (
                <div className="mt-2 text-sm">
                  <p>Customer ID: {submitResult.data.customerId}</p>
                  <p>Updated: {new Date(submitResult.data.updatedAt).toLocaleString()}</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
} 