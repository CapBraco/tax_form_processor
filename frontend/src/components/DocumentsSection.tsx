'use client'

import { useState, useEffect } from 'react'
import { getDocuments, deleteDocument, getDocumentDetail } from '@/lib/api'
import { FileText, Trash2, Eye, Filter } from 'lucide-react'
import { format } from 'date-fns'

interface DocumentsSectionProps {
  refreshTrigger: number
}

export default function DocumentsSection({ refreshTrigger }: DocumentsSectionProps) {
  const [documents, setDocuments] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [page, setPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)
  const [selectedDocument, setSelectedDocument] = useState<any>(null)
  
  // Filters
  const [status, setStatus] = useState('')

  useEffect(() => {
    loadDocuments()
  }, [page, status, refreshTrigger])

  const loadDocuments = async () => {
    setLoading(true)
    try {
      const params: any = { page, page_size: 10 }
      
      if (status) params.status = status
      
      const data = await getDocuments(params)
      setDocuments(data.documents)
      setTotalPages(Math.ceil(data.total / data.page_size))
    } catch (error) {
      console.error('Error loading documents:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleDeleteDocument = async (documentId: number) => {
    if (!confirm('Are you sure you want to delete this document?')) return
    
    try {
      await deleteDocument(documentId)
      loadDocuments()
      setSelectedDocument(null)
    } catch (error) {
      console.error('Error deleting document:', error)
      alert('Failed to delete document')
    }
  }

  const handleViewDocument = async (documentId: number) => {
    try {
      const data = await getDocumentDetail(documentId)
      setSelectedDocument(data)
    } catch (error) {
      console.error('Error loading document detail:', error)
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300'
      case 'processing':
        return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300'
      case 'failed':
        return 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300'
      default:
        return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
    }
  }

  return (
    <div className="space-y-6">
      {/* Filters */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <div className="flex items-center space-x-2 mb-4">
          <Filter size={20} className="text-gray-600 dark:text-gray-400" />
          <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Filters</h3>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Status
            </label>
            <select
              value={status}
              onChange={(e) => {
                setStatus(e.target.value)
                setPage(1)
              }}
              className="w-full border border-gray-300 dark:border-gray-600 rounded-lg px-3 py-2 
                bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100
                focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">All Status</option>
              <option value="completed">Completed</option>
              <option value="processing">Processing</option>
              <option value="failed">Failed</option>
              <option value="pending">Pending</option>
            </select>
          </div>
        </div>

        {status && (
          <button
            onClick={() => {
              setStatus('')
              setPage(1)
            }}
            className="mt-4 text-sm text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
          >
            Clear Filters
          </button>
        )}
      </div>

      {/* Documents List */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow">
        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          </div>
        ) : documents.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-64 text-gray-500 dark:text-gray-400">
            <FileText size={48} className="mb-4" />
            <p className="text-lg">No documents found</p>
            <p className="text-sm">Upload some PDFs to get started</p>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50 dark:bg-gray-700 border-b dark:border-gray-600">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">
                      Filename
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">
                      Size
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">
                      Pages
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">
                      Characters
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">
                      Uploaded
                    </th>
                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
                  {documents.map((doc) => (
                    <tr key={doc.id} className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                      <td className="px-6 py-4">
                        <div className="flex items-center">
                          <FileText className="text-gray-400 dark:text-gray-500 mr-2" size={16} />
                          <span className="text-sm text-gray-900 dark:text-gray-100">{doc.filename}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900 dark:text-gray-100">
                        {(doc.file_size / 1024 / 1024).toFixed(2)} MB
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900 dark:text-gray-100">
                        {doc.total_pages || '-'}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900 dark:text-gray-100">
                        {doc.total_characters?.toLocaleString() || '-'}
                      </td>
                      <td className="px-6 py-4">
                        <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(doc.processing_status)}`}>
                          {doc.processing_status}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-500 dark:text-gray-400">
                        {doc.uploaded_at ? format(new Date(doc.uploaded_at), 'MMM d, yyyy') : '-'}
                      </td>
                      <td className="px-6 py-4 text-right">
                        <div className="flex items-center justify-end space-x-2">
                          <button
                            onClick={() => handleViewDocument(doc.id)}
                            className="text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
                            title="View Text"
                          >
                            <Eye size={18} />
                          </button>
                          <button
                            onClick={() => handleDeleteDocument(doc.id)}
                            className="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
                            title="Delete"
                          >
                            <Trash2 size={18} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* ✅ FIXED: Pagination with proper colors */}
            {totalPages > 1 && (
              <div className="px-6 py-4 border-t dark:border-gray-700 flex items-center justify-between">
                <button
                  onClick={() => setPage(Math.max(1, page - 1))}
                  disabled={page === 1}
                  className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg 
                    bg-white dark:bg-gray-700 
                    text-gray-700 dark:text-gray-200
                    disabled:opacity-50 disabled:cursor-not-allowed 
                    hover:bg-gray-50 dark:hover:bg-gray-600
                    transition-colors"
                >
                  Previous
                </button>
                <span className="text-sm text-gray-600 dark:text-gray-400">
                  Page {page} of {totalPages}
                </span>
                <button
                  onClick={() => setPage(Math.min(totalPages, page + 1))}
                  disabled={page === totalPages}
                  className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg 
                    bg-white dark:bg-gray-700 
                    text-gray-700 dark:text-gray-200
                    disabled:opacity-50 disabled:cursor-not-allowed 
                    hover:bg-gray-50 dark:hover:bg-gray-600
                    transition-colors"
                >
                  Next
                </button>
              </div>
            )}
          </>
        )}
      </div>

      {/* Document Detail Modal */}
      {selectedDocument && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white dark:bg-gray-800 rounded-lg max-w-4xl w-full max-h-[80vh] overflow-y-auto">
            <div className="p-6 border-b dark:border-gray-700 sticky top-0 bg-white dark:bg-gray-800">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Extracted Text</h3>
                <button
                  onClick={() => setSelectedDocument(null)}
                  className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
                >
                  ✕
                </button>
              </div>
              <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">{selectedDocument.filename}</p>
            </div>

            <div className="p-6 space-y-4">
              <div className="grid grid-cols-3 gap-4 text-sm">
                <div>
                  <span className="text-gray-600 dark:text-gray-400">File Size:</span>
                  <p className="font-medium text-gray-900 dark:text-gray-100">
                    {(selectedDocument.file_size / 1024 / 1024).toFixed(2)} MB
                  </p>
                </div>
                <div>
                  <span className="text-gray-600 dark:text-gray-400">Pages:</span>
                  <p className="font-medium text-gray-900 dark:text-gray-100">
                    {selectedDocument.total_pages || '-'}
                  </p>
                </div>
                <div>
                  <span className="text-gray-600 dark:text-gray-400">Characters:</span>
                  <p className="font-medium text-gray-900 dark:text-gray-100">
                    {selectedDocument.total_characters?.toLocaleString() || '-'}
                  </p>
                </div>
              </div>

              {selectedDocument.processing_error && (
                <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded p-3">
                  <p className="text-sm text-red-800 dark:text-red-200">{selectedDocument.processing_error}</p>
                </div>
              )}

              {selectedDocument.extracted_text && (
                <div className="bg-gray-50 dark:bg-gray-900 rounded-lg p-4 max-h-96 overflow-y-auto">
                  <pre className="text-sm text-gray-800 dark:text-gray-200 whitespace-pre-wrap font-mono">
                    {selectedDocument.extracted_text}
                  </pre>
                </div>
              )}
            </div>

            <div className="p-6 border-t dark:border-gray-700 flex justify-end space-x-3">
              <button
                onClick={() => setSelectedDocument(null)}
                className="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg 
                  bg-white dark:bg-gray-700 
                  text-gray-700 dark:text-gray-200
                  hover:bg-gray-50 dark:hover:bg-gray-600"
              >
                Close
              </button>
              <button
                onClick={() => {
                  navigator.clipboard.writeText(selectedDocument.extracted_text || '')
                  alert('Text copied to clipboard!')
                }}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Copy Text
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
