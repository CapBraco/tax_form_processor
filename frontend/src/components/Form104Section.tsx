'use client'

import { useState, useEffect } from 'react'
import { listDocumentsByFormType, getForm104Data } from '@/lib/api'
import { FileText } from 'lucide-react'
import Form104Display from './Form104Display'

export default function Form104Section() {
  const [documents, setDocuments] = useState<any[]>([])
  const [selectedDoc, setSelectedDoc] = useState<any>(null)
  const [formData, setFormData] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [detailLoading, setDetailLoading] = useState(false)

  useEffect(() => {
    loadDocuments()
  }, [])

  const loadDocuments = async () => {
    setLoading(true)
    try {
      const data = await listDocumentsByFormType('form_104')
      setDocuments(data)
    } catch (error) {
      console.error('Error loading Form 104 documents:', error)
      setDocuments([])
    } finally {
      setLoading(false)
    }
  }

  const handleViewForm = async (doc: any) => {
    setSelectedDoc(doc)
    setDetailLoading(true)
    try {
      const data = await getForm104Data(doc.id)
      console.log('📊 Form 104 data loaded:', data)
      setFormData(data)
    } catch (error) {
      console.error('❌ Error loading form data:', error)
      setFormData(null)
    } finally {
      setDetailLoading(false)
    }
  }

  const handleBack = () => {
    setSelectedDoc(null)
    setFormData(null)
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  // Document List View
  if (!selectedDoc) {
    return (
      <div className="space-y-6">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-gray-100 mb-4">
            Form 104 - Declaración de IVA
          </h2>
          
          {!documents || documents.length === 0 ? (
            <div className="text-center py-12 text-gray-500 dark:text-gray-400">
              <FileText size={48} className="mx-auto mb-4" />
              <p>No Form 104 documents uploaded yet</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {documents.map((doc) => (
                <div
                  key={doc.id}
                  onClick={() => handleViewForm(doc)}
                  className="border-2 rounded-lg p-4 cursor-pointer transition-all
                    bg-white dark:bg-gray-700
                    border-gray-200 dark:border-gray-600
                    hover:border-purple-400 dark:hover:border-purple-500
                    hover:shadow-lg"
                >
                  <div className="flex items-start justify-between mb-2">
                    <FileText className="text-purple-600 dark:text-purple-400" size={24} />
                    <span className="text-xs text-gray-500 dark:text-gray-400 bg-gray-100 dark:bg-gray-600 px-2 py-1 rounded">
                      {doc.periodo}
                    </span>
                  </div>
                  <h3 className="font-medium text-gray-900 dark:text-gray-100 mb-1 truncate" title={doc.filename}>
                    {doc.filename}
                  </h3>
                  <p className="text-sm text-gray-600 dark:text-gray-300 truncate">{doc.razon_social}</p>
                  <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
                    {doc.uploaded_at ? `Uploaded: ${new Date(doc.uploaded_at).toLocaleDateString()}` : ''}
                  </p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    )
  }

  // Detail View - Now uses reusable Form104Display component
  if (detailLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (!formData) {
    return (
      <div className="text-center py-12 text-gray-500 dark:text-gray-400">
        Error loading form data
      </div>
    )
  }

  return <Form104Display formData={formData} onBack={handleBack} showBackButton={true} />
}
