'use client';

import { ReactNode, useState } from 'react';
import Image from 'next/image';

interface AuthLayoutProps {
  children: ReactNode;
  subtitle?: string;
}

export default function AuthLayout({
  children,
  subtitle = 'Login with username',
}: AuthLayoutProps) {
  const [imageError, setImageError] = useState(false);

  return (
    <div className="min-h-screen flex flex-col lg:flex-row">
      {/* Left Segment (50%) - Login Functionality */}
      <div className="w-full lg:w-1/2 flex items-center justify-center bg-white pl-8 lg:pl-[120px] pr-8 py-12 lg:py-0">
        <div className="max-w-md w-full">
          {/* Branding Section */}
          <div className="text-center mb-10">
            {/* LOGO IMAGE (replaces SMG text) */}
            <div className="flex justify-center mb-0">
              <div className="relative w-[480px] h-[128px]">
                <Image
                  src="/smg-logo.png"   // ⬅️ replace with your logo path
                  alt="SMG Logo"
                  fill
                  priority
                  className="object-contain"
                  onError={() => setImageError(true)}
                />
              </div>
            </div>

            {/* Portal Heading */}
            <h2 className="font-sans text-[36px] font-extrabold text-[#0A1A3A] mb-6">
              Training Platform
            </h2>

            {/* Welcome Text */}
            <p className="font-sans text-[21px] font-normal text-[#0A1A3A] mb-1">
              Welcome
            </p>

            {/* Login Subtext */}
            <p className="font-sans text-[13.5px] font-light text-[#7A7A7A]">
              Login with username
            </p>
          </div>

          {/* Form Content */}
          <div className="space-y-6">{children}</div>
        </div>
      </div>

      {/* Right Segment (50%) - Image Container */}
      <div className="hidden lg:block w-1/2 relative overflow-hidden bg-gray-200">
        <img
          src="/auth-background.jpg"
          alt="Authentication Background"
          className="absolute inset-0 w-full h-full object-cover"
          onError={(e) => {
            e.currentTarget.style.display = 'none';
            setImageError(true);
          }}
        />

        {imageError && (
          <div className="absolute inset-0 bg-gradient-to-br from-gray-200 to-gray-300 flex flex-col items-center justify-center">
            <p className="text-gray-400 text-lg">Background Image</p>
            <p className="text-gray-400 text-sm mt-2">
              (Add /public/auth-background.jpg)
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
