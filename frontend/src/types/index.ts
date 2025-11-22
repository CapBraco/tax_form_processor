// Document Types
export interface Document {
  id: number
  filename: string
  file_size: number
  total_pages?: number
  total_characters?: number
  processing_status: 'pending' | 'processing' | 'completed' | 'failed'
  uploaded_at: string
  processed_at?: string
}

export interface DocumentDetail extends Document {
  original_filename: string
  processing_error?: string
  extracted_text?: string
}

// Upload Types
export interface UploadResponse {
  success: boolean
  message: string
  document_id: number
  filename: string
  processing_status: string
}

export interface BulkUploadResponse {
  success: boolean
  total_files: number
  uploaded: UploadResponse[]
  failed: { filename: string; error: string }[]
}

// Stats Types
export interface DocumentsStats {
  total_documents: number
  by_status: {
    processing: number
    completed: number
    failed: number
    pending: number
  }
  total_pages_extracted: number
  total_characters_extracted: number
}

// API Response Types
export interface PaginatedResponse<T> {
  total: number
  page: number
  page_size: number
  items: T[]
}

export interface HealthCheckResponse {
  status: 'healthy' | 'degraded'
  database: string
}
