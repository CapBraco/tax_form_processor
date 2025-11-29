'use client'

import { useState, useCallback } from 'react'
import { useDropzone } from 'react-dropzone'
import { uploadSinglePDF, uploadMultiplePDFs } from '@/lib/api'
import { Upload, FileText, CheckCircle, XCircle, Loader } from 'lucide-react'

interface UploadSectionProps {
  onUploadSuccess: () => void
}

interface UploadedFile {
  file: File
  status: 'uploading' | 'success' | 'error'
  message?: string
  formId?: number
}

export default function UploadSection({ onUploadSuccess }: UploadSectionProps) {
  const [uploadedFiles, setUploadedFiles] = useState<UploadedFile[]>([])
  
  const [isUploading, setIsUploading] = useState(false)

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    // Filter only PDF files
    const pdfFiles = acceptedFiles.filter(file => 
      file.type === 'application/pdf' || file.name.toLowerCase().endsWith('.pdf')
    )

    if (pdfFiles.length === 0) {
      alert('Please upload only PDF files')
      return
    }

    // Add files to state with uploading status
    const newFiles: UploadedFile[] = pdfFiles.map(file => ({
      file,
      status: 'uploading'
    }))
    setUploadedFiles(prev => [...newFiles, ...prev])
    setIsUploading(true)

    try {
      if (pdfFiles.length === 1) {
        // Single file upload
        const result = await uploadSinglePDF(pdfFiles[0])
        
        setUploadedFiles(prev => 
          prev.map(f => 
            f.file === pdfFiles[0]
              ? { 
                  ...f, 
                  status: 'success', 
                  message: result.message,
                  formId: result.form_id 
                }
              : f
          )
        )
        onUploadSuccess()
      } else {
        // Bulk upload
        const result = await uploadMultiplePDFs(pdfFiles)
        
        // Update status for each file
        setUploadedFiles(prev => 
          prev.map(f => {
            const uploaded = result.uploaded.find((u: any) => u.filename === f.file.name)
            const failed = result.failed.find((u: any) => u.filename === f.file.name)
            
            if (uploaded) {
              return {
                ...f,
                status: 'success',
                message: uploaded.message,
                formId: uploaded.form_id
              }
            } else if (failed) {
              return {
                ...f,
                status: 'error',
                message: failed.error
              }
            }
            return f
          })
        )
        
        if (result.uploaded.length > 0) {
          onUploadSuccess()
        }
      }
    } catch (error: any) {
      console.error('Upload error:', error)
      
      // Mark all files as error
      setUploadedFiles(prev =>
        prev.map(f =>
          pdfFiles.includes(f.file)
            ? { ...f, status: 'error', message: error.message || 'Upload failed' }
            : f
        )
      )
    } finally {
      setIsUploading(false)
    }
  }, [onUploadSuccess])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'application/pdf': ['.pdf']
    },
    multiple: true,
    maxFiles: 20
  })

  const clearFiles = () => {
    setUploadedFiles([])
  }

  return (
    <div className="space-y-6">
      {/* Upload Dropzone */}
      <div
        {...getRootProps()}
        className={`
          border-2 border-dashed rounded-lg p-12 text-center cursor-pointer
          transition-colors duration-200
          ${isDragActive 
            ? 'border-blue-500 bg-blue-50' 
            : 'border-gray-300 bg-white hover:border-blue-400 hover:bg-gray-50'
          }
        `}
      >
        <input {...getInputProps()} />
        <div className="flex flex-col items-center space-y-4">
          <div className={`
            p-4 rounded-full
            ${isDragActive ? 'bg-blue-100' : 'bg-gray-100'}
          `}>
            <Upload className={isDragActive ? 'text-blue-600' : 'text-gray-600'} size={40} />
          </div>
          
          {isDragActive ? (
            <p className="text-lg font-medium text-blue-600">
              Drop the PDF files here...
            </p>
          ) : (
            <>
              <div>
                <p className="text-lg font-medium text-gray-900">
                  Drag & drop PDF files here
                </p>
                <p className="text-sm text-gray-500 mt-1">
                  or click to select files
                </p>
              </div>
              <p className="text-xs text-gray-400">
                Supports single or multiple PDF files (max 20 files)
              </p>
            </>
          )}
        </div>
      </div>

      {/* Upload Progress/Results */}
      {uploadedFiles.length > 0 && (
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">
              Upload Results ({uploadedFiles.length})
            </h3>
            {!isUploading && (
              <button
                onClick={clearFiles}
                className="text-sm text-gray-600 hover:text-gray-900"
              >
                Clear
              </button>
            )}
          </div>

          <div className="space-y-3">
            {uploadedFiles.map((item, index) => (
              <div
                key={index}
                className="flex items-center justify-between p-4 border rounded-lg"
              >
                <div className="flex items-center space-x-3 flex-1">
                  <FileText className="text-gray-400" size={24} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 truncate">
                      {item.file.name}
                    </p>
                    <p className="text-xs text-gray-500">
                      {(item.file.size / 1024 / 1024).toFixed(2)} MB
                    </p>
                    {item.message && (
                      <p className={`text-xs mt-1 ${
                        item.status === 'error' ? 'text-red-600' : 'text-green-600'
                      }`}>
                        {item.message}
                      </p>
                    )}
                  </div>
                </div>

                <div className="ml-4">
                  {item.status === 'uploading' && (
                    <Loader className="animate-spin text-blue-600" size={20} />
                  )}
                  {item.status === 'success' && (
                    <CheckCircle className="text-green-600" size={20} />
                  )}
                  {item.status === 'error' && (
                    <XCircle className="text-red-600" size={20} />
                  )}
                </div>
              </div>
            ))}
          </div>

          {/* Summary */}
          {!isUploading && (
            <div className="mt-4 pt-4 border-t">
              <div className="flex items-center justify-between text-sm">
                <span className="text-gray-600">
                  Success: {uploadedFiles.filter(f => f.status === 'success').length}
                </span>
                <span className="text-gray-600">
                  Failed: {uploadedFiles.filter(f => f.status === 'error').length}
                </span>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Upload Tips */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
        <h4 className="font-semibold text-blue-900 mb-2">Upload Tips</h4>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• Only PDF files are accepted</li>
          <li>• Maximum file size: 50 MB per file</li>
          <li>• You can upload up to 20 files at once</li>
          <li>• The system will automatically classify and extract data from your forms</li>
          <li>• Processing may take a few seconds per file</li>
        </ul>
      </div>
    </div>
  )
}
