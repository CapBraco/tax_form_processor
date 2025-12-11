import axios from 'axios'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

const api = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Health Check
export const checkHealth = async () => {
  const response = await api.get('/health')
  return response.data
}

// Upload APIs
export const uploadSinglePDF = async (file: File) => {
  const formData = new FormData()
  formData.append('file', file)
  
  // ✅ Use axios instance with explicit config merge
  const response = await api.post('/api/upload/single', formData, {
    withCredentials: true,  // ✅ Explicit
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  })
  return response.data
}

export const uploadMultiplePDFs = async (files: File[]) => {
  const formData = new FormData()
  files.forEach(file => {
    formData.append('files', file)
  })
  
  // ✅ Use axios instance with explicit config merge
  const response = await api.post('/api/upload/bulk', formData, {
    withCredentials: true,  // ✅ Explicit
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  })
  return response.data
}

// Alternative approach if above doesn't work:
// Create FormData requests directly with fetch API

export const uploadMultiplePDFsWithFetch = async (files: File[]) => {
  const formData = new FormData()
  files.forEach(file => {
    formData.append('files', file)
  })
  
  const response = await fetch('http://localhost:8000/api/upload/bulk', {
    method: 'POST',
    body: formData,
    credentials: 'include',  // ✅ This is equivalent to withCredentials
  })
  
  if (!response.ok) {
    throw new Error(`Upload failed: ${response.status}`)
  }
  
  return response.json()
}

export const getUploadStatus = async (documentId: number) => {
  const response = await api.get(`/api/upload/status/${documentId}`)
  return response.data
}

// Documents APIs
export const getDocuments = async (params?: {
  page?: number
  page_size?: number
  status?: string
}) => {
  const response = await api.get('/api/documents/', { params })
  return response.data
}

export const getDocumentDetail = async (documentId: number) => {
  const response = await api.get(`/api/documents/${documentId}`)
  return response.data
}

export const deleteDocument = async (documentId: number) => {
  const response = await api.delete(`/api/documents/${documentId}`)
  return response.data
}

export const getDocumentsStats = async () => {
  const response = await api.get('/api/documents/stats/overview')
  return response.data
}

// Forms Data APIs - NEW!
export const getForm103Data = async (documentId: number) => {
  const response = await api.get(`/api/forms-data/form-103/${documentId}`)
  return response.data
}

export const getForm104Data = async (documentId: number) => {
  const response = await api.get(`/api/forms-data/form-104/${documentId}`)
  return response.data
}

export const listDocumentsByFormType = async (formType: 'form_103' | 'form_104') => {
  const response = await api.get(`/api/forms-data/list-by-form-type/${formType}`)
  return response.data
}

import type {
  ClientSummary,
  ClientDocuments,
  YearlySummary,
  YearValidation,
  PDFBranding
} from '@/types'

// ===== AUTHENTICATION =====
export async function checkAuth() {
  const response = await api.get('/api/auth/check')
  return response.data
}

export async function login(username: string, password: string) {
  const response = await api.post('/api/auth/login', { username, password })
  return response.data
}

export async function logout() {
  const response = await api.post('/api/auth/logout')
  return response.data
}

// Get all clients
export const getAllClients = async (): Promise<ClientSummary[]> => {
  const response = await api.get('/api/clientes/')
  return response.data
}

// Get client documents organized by year/month
export const getClientDocuments = async (razonSocial: string): Promise<ClientDocuments> => {
  const response = await api.get(`/api/clientes/${encodeURIComponent(razonSocial)}`)
  return response.data
}

// Get yearly summary with optional month exclusions
export const getYearlySummary = async (
  razonSocial: string,
  year: string,
  excludeMonths?: number[]
): Promise<YearlySummary> => {
  const params = excludeMonths && excludeMonths.length > 0
    ? { exclude_months: excludeMonths.join(',') }
    : {}
  
  const response = await api.get(
    `/api/clientes/${encodeURIComponent(razonSocial)}/yearly-summary/${year}`,
    { params }
  )
  return response.data
}

// Validate year completeness
export const validateYearCompleteness = async (
  razonSocial: string,
  year: string
): Promise<YearValidation> => {
  const response = await api.get(
    `/api/clientes/${encodeURIComponent(razonSocial)}/validation/${year}`
  )
  return response.data
}

// Export to Excel
export const exportYearlyExcel = async (
  razonSocial: string,
  year: string,
  excludeMonths?: number[]
): Promise<void> => {
  const params = excludeMonths && excludeMonths.length > 0
    ? { exclude_months: excludeMonths.join(',') }
    : {}
  
  const response = await api.post(
    `/api/clientes/${encodeURIComponent(razonSocial)}/export-excel/${year}`,
    {},
    {
      params,
      responseType: 'blob'
    }
  )
  
  // Create download link
  const url = window.URL.createObjectURL(new Blob([response.data]))
  const link = document.createElement('a')
  link.href = url
  link.setAttribute('download', `${razonSocial.replace(/\s+/g, '_')}_${year}_summary.xlsx`)
  document.body.appendChild(link)
  link.click()
  link.remove()
  window.URL.revokeObjectURL(url)
}

// Export to PDF with branding
export const exportYearlyPDF = async (
  razonSocial: string,
  year: string,
  branding: PDFBranding,
  excludeMonths?: number[]
): Promise<void> => {
  const params = excludeMonths && excludeMonths.length > 0
    ? { exclude_months: excludeMonths.join(',') }
    : {}
  
  const response = await api.post(
    `/api/clientes/${encodeURIComponent(razonSocial)}/export-pdf/${year}`,
    branding,
    {
      params,
      responseType: 'blob'
    }
  )
  
  // Create download link
  const url = window.URL.createObjectURL(new Blob([response.data]))
  const link = document.createElement('a')
  link.href = url
  link.setAttribute('download', `${razonSocial.replace(/\s+/g, '_')}_${year}_summary.pdf`)
  document.body.appendChild(link)
  link.click()
  link.remove()
  window.URL.revokeObjectURL(url)
}

// ===== PASSWORD MANAGEMENT =====
export async function register(username: string, email: string, password: string, confirmPassword: string, recaptchaToken?: string) {
  const response = await api.post('/api/auth/register', {
    username,
    email,
    password,
    confirm_password: confirmPassword,
    recaptcha_token: recaptchaToken
  })
  return response.data
}

export async function requestPasswordReset(email: string) {
  const response = await api.post('/api/auth/password-reset-request', { email })
  return response.data
}

export async function resetPassword(token: string, newPassword: string, confirmPassword: string) {
  const response = await api.post('/api/auth/password-reset', {
    token,
    new_password: newPassword,
    confirm_password: confirmPassword
  })
  return response.data
}

export async function changePassword(currentPassword: string, newPassword: string, confirmPassword: string) {
  const response = await api.post('/api/auth/change-password', {
    current_password: currentPassword,
    new_password: newPassword,
    confirm_password: confirmPassword
  })
  return response.data
}


export default api
