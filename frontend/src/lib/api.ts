import axios from 'axios'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

const api = axios.create({
  baseURL: API_BASE_URL,
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
  
  const response = await api.post('/api/upload/single', formData, {
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
  
  const response = await api.post('/api/upload/bulk', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  })
  return response.data
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

export default api
