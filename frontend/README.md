# Customer Update Frontend

🌐 **Modern Next.js Frontend for Customer Information Management**

## 🎯 Overview

This is the frontend component of the Customer Information Update System, built with Next.js 14, TypeScript, and Tailwind CSS. It provides a modern, responsive web interface for updating customer information with real-time validation and seamless AS400 integration.

## 🚀 Features

- ✅ **Modern UI/UX**: Clean, responsive design with Tailwind CSS
- ✅ **Real-time Validation**: Client-side form validation with Zod
- ✅ **Type Safety**: Full TypeScript support throughout
- ✅ **Form Management**: React Hook Form for optimal performance
- ✅ **Error Handling**: Comprehensive error states and user feedback
- ✅ **Accessibility**: WCAG compliant components
- ✅ **Progressive Enhancement**: Works without JavaScript

## 🛠️ Technology Stack

- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS + CSS Variables
- **Forms**: React Hook Form + Zod validation
- **HTTP Client**: Axios
- **UI Components**: Radix UI primitives
- **Icons**: Lucide React

## 📁 Project Structure

```
src/
├── app/                    # Next.js App Router
│   ├── customer-update/    # Customer update page
│   │   ├── page.tsx
│   │   └── loading.tsx
│   ├── globals.css         # Global styles
│   ├── layout.tsx          # Root layout
│   └── page.tsx            # Home page
├── components/             # Reusable UI components
│   ├── ui/                 # Base UI components
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── label.tsx
│   │   └── toast.tsx
│   ├── forms/              # Form components
│   │   └── customer-update-form.tsx
│   └── layout/             # Layout components
│       ├── header.tsx
│       └── navigation.tsx
├── lib/                    # Utility functions
│   ├── api.ts              # API client configuration
│   ├── utils.ts            # Helper utilities
│   └── validations.ts      # Zod schemas
└── types/                  # TypeScript type definitions
    ├── customer.ts
    └── api.ts
```

## 🔧 Installation & Setup

### Prerequisites
- Node.js 18+ 
- npm or yarn package manager

### Step 1: Install Dependencies
```bash
npm install
# or
yarn install
```

### Step 2: Environment Configuration
Create a `.env.local` file in the root directory:

```env
# Backend API Configuration
NEXT_PUBLIC_API_URL=http://localhost:5000
BACKEND_API_URL=http://localhost:5000

# Application Configuration
NEXT_PUBLIC_APP_NAME="Customer Update System"
NEXT_PUBLIC_APP_VERSION="1.0.0"

# Optional: Analytics & Monitoring
NEXT_PUBLIC_ANALYTICS_ID=your_analytics_id
```

### Step 3: Development Server
```bash
npm run dev
# or
yarn dev
```

Open [http://localhost:3000](http://localhost:3000) to view the application.

## 🌍 Available Scripts

```bash
# Development
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run lint         # Run ESLint
npm run type-check   # TypeScript type checking
```

## 📝 Key Components

### Customer Update Form
Located at `/customer-update`, this form allows users to:
- Update customer name, phone, email, address
- Validate Tax ID format
- Submit changes for AS400 processing
- View real-time validation feedback

### Form Validation Schema
```typescript
const customerUpdateSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  phone: z.string().regex(/^\+?[\d\s-()]+$/, "Invalid phone format"),
  email: z.string().email("Invalid email address"),
  address: z.string().min(5, "Address must be at least 5 characters"),
  taxId: z.string().length(11, "Tax ID must be 11 characters")
});
```

## 🔌 API Integration

### Customer Update Endpoint
```typescript
// POST /api/customer/update
const updateCustomer = async (data: CustomerUpdateData) => {
  const response = await axios.post('/api/customer/update', data);
  return response.data;
};
```

### Response Handling
```typescript
interface ApiResponse {
  success: boolean;
  message: string;
  data?: CustomerData;
  errors?: ValidationError[];
}
```

## 🎨 UI Components

### Custom Button Component
```tsx
import { Button } from "@/components/ui/button";

<Button variant="primary" size="lg" disabled={isLoading}>
  {isLoading ? "Updating..." : "Update Customer"}
</Button>
```

### Form Input with Validation
```tsx
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

<div className="space-y-2">
  <Label htmlFor="name">Customer Name</Label>
  <Input
    id="name"
    {...register("name")}
    placeholder="Enter customer name"
    className={errors.name ? "border-red-500" : ""}
  />
  {errors.name && (
    <p className="text-sm text-red-500">{errors.name.message}</p>
  )}
</div>
```

## 🛡️ Security Features

- **Input Sanitization**: All inputs sanitized before submission
- **CSRF Protection**: Built-in Next.js CSRF protection
- **XSS Prevention**: React's built-in XSS protection
- **Type Safety**: TypeScript prevents runtime errors
- **Validation**: Client and server-side validation

## 📱 Responsive Design

The application is fully responsive and works on:
- ✅ Desktop (1024px+)
- ✅ Tablet (768px - 1023px)
- ✅ Mobile (320px - 767px)

## 🧪 Testing

```bash
# Run unit tests
npm run test

# Run integration tests
npm run test:integration

# Run e2e tests
npm run test:e2e
```

## 🚀 Deployment

### Build for Production
```bash
npm run build
npm run start
```

### Environment Variables for Production
```env
NEXT_PUBLIC_API_URL=https://your-api-domain.com
BACKEND_API_URL=https://your-api-domain.com
NODE_ENV=production
```

## 📊 Performance Optimizations

- **Code Splitting**: Automatic route-based code splitting
- **Image Optimization**: Next.js Image component
- **Font Optimization**: Self-hosted Google Fonts
- **Bundle Analysis**: Webpack Bundle Analyzer
- **Static Generation**: Pre-rendered pages where possible

## 🤝 Contributing

1. Follow the TypeScript and ESLint configurations
2. Use conventional commit messages
3. Write tests for new features
4. Ensure responsive design compliance
5. Update documentation for API changes

## 🔗 Related Documentation

- [Backend API Documentation](../backend/README.md)
- [AS400 Integration Guide](../as400/README.md)
- [Database Schema](../docs/database-schema.md)
- [API Specification](../docs/api-specification.md)

## 📞 Support

For issues and questions:
- Check existing GitHub issues
- Create new issue with reproduction steps
- Include browser and Node.js versions

---

**Frontend URL**: http://localhost:3000  
**API Documentation**: http://localhost:5000/swagger 