'use client';

import { useState, useRef, useCallback } from 'react';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

interface FileUploaderProps {
  bucket: string;
  folder: string;
  accept?: string;
  maxSize?: number;
  onUploadComplete: (url: string) => void;
  onError?: (error: string) => void;
}

export function FileUploader({
  bucket,
  folder,
  accept = '*',
  maxSize = 500 * 1024 * 1024, // 500MB default
  onUploadComplete,
  onError,
}: FileUploaderProps) {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const uploadFile = async (file: File) => {
    if (file.size > maxSize) {
      const errorMsg = `File size exceeds ${maxSize / 1024 / 1024}MB limit`;
      setError(errorMsg);
      onError?.(errorMsg);
      return;
    }

    setUploading(true);
    setError(null);
    setProgress(0);

    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Not authenticated');

      const fileName = `${folder}/${Date.now()}_${file.name.replace(/[^a-zA-Z0-9.-]/g, '_')}`;
      
      const { data, error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false,
        });

      if (uploadError) throw uploadError;

      // Simulate progress for better UX (Supabase doesn't provide upload events)
      for (let i = 0; i <= 100; i += 10) {
        await new Promise(resolve => setTimeout(resolve, 100));
        setProgress(i);
      }

      const { data: { publicUrl } } = supabase.storage
        .from(bucket)
        .getPublicUrl(fileName);

      onUploadComplete(publicUrl);
    } catch (err: any) {
      const errorMsg = err.message || 'Upload failed';
      setError(errorMsg);
      onError?.(errorMsg);
    } finally {
      setUploading(false);
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      uploadFile(file);
    }
  };

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    const file = e.dataTransfer.files[0];
    if (file) {
      uploadFile(file);
    }
  }, [folder, bucket, maxSize, onUploadComplete, onError]);

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
  }, []);

  return (
    <div className="space-y-2">
      <div
        className={`border-2 border-dashed rounded-lg p-4 text-center cursor-pointer transition-colors ${
          uploading
            ? 'border-primary-300 bg-gray-50 cursor-not-allowed'
            : 'border-gray-300 hover:border-primary-400'
        }`}
        onClick={() => !uploading && fileInputRef.current?.click()}
        onDrop={handleDrop}
        onDragOver={handleDragOver}
      >
        <input
          ref={fileInputRef}
          type="file"
          accept={accept}
          className="hidden"
          onChange={handleFileChange}
          disabled={uploading}
        />
        
        {uploading ? (
          <div className="space-y-2">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600 mx-auto"></div>
            <p className="text-sm text-gray-500">جاري الرفع... {progress}%</p>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-primary-600 h-2 rounded-full transition-all"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>
        ) : (
          <div>
            <svg className="mx-auto h-8 w-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
            </svg>
            <p className="mt-2 text-sm text-gray-500">
              اضغط للرفع أو اسحب الملف هنا
            </p>
            <p className="text-xs text-gray-400">
              الحد الأقصى: {maxSize / 1024 / 1024}MB
            </p>
          </div>
        )}
      </div>
      
      {error && (
        <p className="text-sm text-red-600">{error}</p>
      )}
    </div>
  );
}

// Video Uploader with more features
interface VideoUploaderProps {
  folder: string;
  onUploadComplete: (url: string) => void;
  onError?: (error: string) => void;
}

export function VideoUploader({ folder, onUploadComplete, onError }: VideoUploaderProps) {
  return (
    <FileUploader
      bucket="course-videos"
      folder={folder}
      accept="video/*"
      maxSize={500 * 1024 * 1024}
      onUploadComplete={onUploadComplete}
      onError={onError}
    />
  );
}

// File Uploader (PDFs, etc)
interface DocumentUploaderProps {
  folder: string;
  onUploadComplete: (url: string) => void;
  onError?: (error: string) => void;
}

export function DocumentUploader({ folder, onUploadComplete, onError }: DocumentUploaderProps) {
  return (
    <FileUploader
      bucket="course-files"
      folder={folder}
      accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx"
      maxSize={100 * 1024 * 1024}
      onUploadComplete={onUploadComplete}
      onError={onError}
    />
  );
}

// Image Uploader
interface ImageUploaderProps {
  folder: string;
  onUploadComplete: (url: string) => void;
  onError?: (error: string) => void;
}

export function ImageUploader({ folder, onUploadComplete, onError }: ImageUploaderProps) {
  return (
    <FileUploader
      bucket="course-images"
      folder={folder}
      accept="image/*"
      maxSize={10 * 1024 * 1024}
      onUploadComplete={onUploadComplete}
      onError={onError}
    />
  );
}