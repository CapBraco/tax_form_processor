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

// Client Summary
export interface ClientSummary {
  razon_social: string
  document_count: number
  first_year: string
  last_year: string
}

// Form Info
export interface FormInfo {
  id: number
  filename: string
  uploaded_at: string
  identificacion_ruc: string | null
}

// Month Data
export interface MonthData {
  month: number
  periodo_fiscal: string | null
  forms: {
    form_103: FormInfo | null
    form_104: FormInfo | null
  }
}

// Year Data
export interface YearData {
  year: string
  months: MonthData[]
}

// Client Documents Response
export interface ClientDocuments {
  razon_social: string
  years: YearData[]
}

// Form 103 Monthly Detail
export interface Form103MonthlyDetail {
  month: number
  periodo_fiscal: string
  subtotal_operaciones_pais: number
  total_retencion: number
  total_impuesto_pagar: number
  total_pagado: number
}

// Form 103 Summary
export interface Form103Summary {
  subtotal_operaciones_pais: number
  total_retencion: number
  total_impuesto_pagar: number
  total_pagado: number
  monthly_details: Form103MonthlyDetail[]
}

// Form 104 Monthly Detail
export interface Form104MonthlyDetail {
  month: number
  periodo_fiscal: string
  total_ventas_neto: number
  total_impuesto_generado: number
  total_adquisiciones: number
  credito_tributario_aplicable: number
  total_impuesto_retenido: number
  total_pagado: number
}

// Form 104 Summary
export interface Form104Summary {
  total_ventas_neto: number
  total_impuesto_generado: number
  total_adquisiciones: number
  credito_tributario_aplicable: number
  total_impuesto_retenido: number
  total_pagado: number
  monthly_details: Form104MonthlyDetail[]
}

// Yearly Summary Response
export interface YearlySummary {
  razon_social: string
  year: string
  form_103_summary: Form103Summary
  form_104_summary: Form104Summary
  missing_months: {
    form_103: number[]
    form_104: number[]
  }
  excluded_months: number[]
}

// Validation Detail
export interface ValidationDetail {
  month: number
  month_name: string
  has_form_103: boolean
  has_form_104: boolean
  form_103_id: number | null
  form_104_id: number | null
  is_complete: boolean
}

// Year Validation Response
export interface YearValidation {
  razon_social: string
  year: string
  complete_months: number
  total_months: number
  is_fully_complete: boolean
  validation_details: ValidationDetail[]
}

// PDF Branding Config
export interface PDFBranding {
  company_name: string
  logo_url?: string
  primary_color?: string
  secondary_color?: string
  footer_text: string
}
