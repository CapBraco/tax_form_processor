'use client'

import { useState, useCallback, useEffect } from 'react'
import { useDropzone } from 'react-dropzone'
import { uploadSinglePDF, uploadMultiplePDFs } from '@/lib/api'
import { Upload, FileText, CheckCircle, XCircle, Loader, AlertCircle, LogIn, X } from 'lucide-react'
import { useAuth } from '@/contexts/AuthContext'
import { useRouter } from 'next/navigation'

interface UploadSectionProps {
  onUploadSuccess?: () => void
}

interface UploadedFile {
  file: File
  status: 'uploading' | 'success' | 'error' | 'duplicate' | 'blocked'
  message?: string
  formId?: number
  isDuplicate?: boolean
}

interface GuestInfo {
  documents_remaining: number
  document_count: number
  limit: number
}

export default function UploadSection({ onUploadSuccess }: UploadSectionProps) {
  const [uploadedFiles, setUploadedFiles] = useState<UploadedFile[]>([])
  const [isUploading, setIsUploading] = useState(false)
  const [showLimitModal, setShowLimitModal] = useState(false)
  const [guestInfo, setGuestInfo] = useState<GuestInfo | null>(null)
  const { isAuthenticated } = useAuth()
  const router = useRouter()

  // Fetch guest info on mount and after uploads
  const fetchGuestInfo = useCallback(async () => {
    if (!isAuthenticated) {
      try {
        const response = await fetch('http://localhost:8000/api/upload/guest/info', {
          credentials: 'include'
        })
        if (response.ok) {
          const data = await response.json()
          setGuestInfo({
            documents_remaining: data.documents_remaining || 5,
            document_count: data.document_count || 0,
            limit: data.limit || 5
          })
        }
      } catch (error) {
        console.error('Error fetching guest info:', error)
      }
    }
  }, [isAuthenticated])

  useEffect(() => {
    fetchGuestInfo()
  }, [fetchGuestInfo])

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    // Filter only PDF files
    const pdfFiles = acceptedFiles.filter(file => 
      file.type === 'application/pdf' || file.name.toLowerCase().endsWith('.pdf')
    )

    if (pdfFiles.length === 0) {
      alert('Please upload only PDF files')
      return
    }

    // ✅ GUEST LIMIT CHECK: Calculate how many files can be uploaded
    let filesToUpload = pdfFiles
    let blockedFiles: File[] = []

    if (!isAuthenticated && guestInfo) {
      const remaining = guestInfo.documents_remaining

      if (remaining <= 0) {
        // ❌ No uploads allowed - show modal
        setShowLimitModal(true)
        return
      }

      if (pdfFiles.length > remaining) {
        // ⚠️ Some files will be blocked
        filesToUpload = pdfFiles.slice(0, remaining)
        blockedFiles = pdfFiles.slice(remaining)
        
        // Show modal to inform about blocked files
        setShowLimitModal(true)
      }
    }

    // Add ALL files to state (including blocked ones)
    const newFiles: UploadedFile[] = [
      ...filesToUpload.map(file => ({
        file,
        status: 'uploading' as const
      })),
      ...blockedFiles.map(file => ({
        file,
        status: 'blocked' as const,
        message: `Bloqueado: límite de ${guestInfo?.limit || 5} documentos alcanzado`
      }))
    ]
    
    setUploadedFiles(prev => [...newFiles, ...prev])
    setIsUploading(true)

    try {
      if (filesToUpload.length === 1) {
        // Single file upload
        const result = await uploadSinglePDF(filesToUpload[0])
        
        setUploadedFiles(prev => 
          prev.map(f => 
            f.file === filesToUpload[0]
              ? { 
                  ...f, 
                  status: result.is_duplicate ? 'duplicate' : 'success',
                  message: result.message,
                  formId: result.form_id,
                  isDuplicate: result.is_duplicate
                }
              : f
          )
        )
        
        if (!result.is_duplicate) {
          onUploadSuccess?.()
          // ✅ Refresh guest info after successful upload
          await fetchGuestInfo()
        }
      } else if (filesToUpload.length > 1) {
        // Bulk upload (only uploading allowed files)
        const result = await uploadMultiplePDFs(filesToUpload)
        
        // Update status for each file
        setUploadedFiles(prev => 
          prev.map(f => {
            // Skip blocked files
            if (f.status === 'blocked') return f

            const uploaded = result.uploaded?.find((u: any) => u.filename === f.file.name)
            const failed = result.failed?.find((u: any) => u.filename === f.file.name)
            
            if (uploaded) {
              return {
                ...f,
                status: uploaded.is_duplicate ? 'duplicate' : 'success',
                message: uploaded.message,
                formId: uploaded.form_id,
                isDuplicate: uploaded.is_duplicate
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
        
        // Only trigger refresh if there were new (non-duplicate) uploads
        const newUploads = result.uploaded?.filter((u: any) => !u.is_duplicate) || []
        if (newUploads.length > 0) {
          onUploadSuccess?.()
        }

        // ✅ Update guest info after bulk upload
        if (!isAuthenticated) {
          if (result.summary?.session_info) {
            setGuestInfo({
              documents_remaining: result.summary.session_info.documents_remaining || 0,
              document_count: result.summary.session_info.document_count || 0,
              limit: result.summary.session_info.limit || 5
            })
          } else {
            // Fallback: refresh from API
            await fetchGuestInfo()
          }
        }
      }
    } catch (error: any) {
      console.error('Upload error:', error)
      
      // ✅ Handle 403 Forbidden - show modal
      if (error.response?.status === 403) {
        setShowLimitModal(true)
        
        // Mark files as blocked
        setUploadedFiles(prev =>
          prev.map(f =>
            filesToUpload.includes(f.file) && f.status === 'uploading'
              ? { ...f, status: 'blocked', message: 'Límite de documentos alcanzado' }
              : f
          )
        )
      } else {
        // Mark files as error
        setUploadedFiles(prev =>
          prev.map(f =>
            filesToUpload.includes(f.file)
              ? { ...f, status: 'error', message: error.response?.data?.detail || error.message || 'Upload failed' }
              : f
          )
        )
      }
    } finally {
      setIsUploading(false)
    }
  }, [onUploadSuccess, isAuthenticated, guestInfo, fetchGuestInfo])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'application/pdf': ['.pdf']
    },
    multiple: true,
    maxFiles: 20,
    disabled: isUploading || (!isAuthenticated && guestInfo?.documents_remaining === 0)
  })

  const clearFiles = () => {
    setUploadedFiles([])
  }

  const handleLoginRedirect = () => {
    setShowLimitModal(false)
    router.push('/login')
  }

  const handleRegisterRedirect = () => {
    setShowLimitModal(false)
    router.push('/register')
  }

  const isLimitReached = !isAuthenticated && guestInfo && guestInfo.documents_remaining <= 0

  // Calculate blocked files count
  const blockedCount = uploadedFiles.filter(f => f.status === 'blocked').length

  return (
    <div className="space-y-6">
      {/* ✅ LIMIT REACHED MODAL */}
      {showLimitModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-md w-full mx-4 p-6 animate-in fade-in zoom-in duration-200">
            {/* Close button */}
            <button
              onClick={() => setShowLimitModal(false)}
              className="float-right text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
            >
              <X className="h-5 w-5" />
            </button>

            {/* Icon */}
            <div className="flex justify-center mb-4">
              <div className="rounded-full bg-red-100 dark:bg-red-900/30 p-3">
                <AlertCircle className="h-8 w-8 text-red-600 dark:text-red-400" />
              </div>
            </div>

            {/* Title */}
            <h3 className="text-xl font-semibold text-center text-gray-900 dark:text-white mb-2">
              {isLimitReached ? 'Límite de Documentos Alcanzado' : 'Algunos Archivos Bloqueados'}
            </h3>

            {/* Message */}
            <p className="text-center text-gray-600 dark:text-gray-300 mb-6">
              {isLimitReached ? (
                <>
                  Has alcanzado el límite de <strong>5 documentos</strong> para usuarios invitados.
                  <br />
                  ¡Crea una cuenta gratuita para <strong>documentos ilimitados</strong>!
                </>
              ) : blockedCount > 0 ? (
                <>
                  Solo se procesarán <strong>{guestInfo?.documents_remaining || 0} de {blockedCount + (guestInfo?.documents_remaining || 0)} archivos</strong>.
                  <br />
                  {blockedCount} archivo{blockedCount > 1 ? 's' : ''} bloqueado{blockedCount > 1 ? 's' : ''} por límite de invitado.
                  <br />
                  ¡Regístrate para documentos ilimitados!
                </>
              ) : (
                <>
                  Estás cerca del límite de <strong>5 documentos</strong> para invitados.
                  <br />
                  ¡Crea una cuenta gratuita para continuar!
                </>
              )}
            </p>

            {/* Benefits */}
            <div className="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4 mb-6">
              <p className="text-sm font-medium text-blue-900 dark:text-blue-200 mb-2">
                Beneficios de Cuenta Gratuita:
              </p>
              <ul className="text-sm text-blue-800 dark:text-blue-300 space-y-1">
                <li className="flex items-center gap-2">
                  <CheckCircle className="h-4 w-4 flex-shrink-0" />
                  <span>Documentos ilimitados</span>
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle className="h-4 w-4 flex-shrink-0" />
                  <span>Almacenamiento permanente</span>
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle className="h-4 w-4 flex-shrink-0" />
                  <span>Gestión de clientes</span>
                </li>
                <li className="flex items-center gap-2">
                  <CheckCircle className="h-4 w-4 flex-shrink-0" />
                  <span>Exportar a Excel y PDF</span>
                </li>
              </ul>
            </div>

            {/* Actions */}
            <div className="flex flex-col gap-3">
              <button
                onClick={handleRegisterRedirect}
                className="w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors flex items-center justify-center gap-2"
              >
                <LogIn className="h-5 w-5" />
                Crear Cuenta Gratis
              </button>
              <button
                onClick={handleLoginRedirect}
                className="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
              >
                Ya tengo cuenta
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ✅ WARNING BANNER - Shows remaining uploads */}
      {!isAuthenticated && guestInfo && (
        <div className={`border-2 rounded-lg p-4 ${
          guestInfo.documents_remaining === 0
            ? 'bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800'
            : guestInfo.documents_remaining <= 2
            ? 'bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800'
            : 'bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800'
        }`}>
          <div className="flex items-start gap-3">
            <AlertCircle className={`h-5 w-5 mt-0.5 flex-shrink-0 ${
              guestInfo.documents_remaining === 0
                ? 'text-red-600 dark:text-red-400'
                : guestInfo.documents_remaining <= 2
                ? 'text-yellow-600 dark:text-yellow-400'
                : 'text-blue-600 dark:text-blue-400'
            }`} />
            <div className="flex-1">
              <p className={`text-sm font-medium ${
                guestInfo.documents_remaining === 0
                  ? 'text-red-900 dark:text-red-200'
                  : guestInfo.documents_remaining <= 2
                  ? 'text-yellow-900 dark:text-yellow-200'
                  : 'text-blue-900 dark:text-blue-200'
              }`}>
                {guestInfo.documents_remaining === 0 ? (
                  'Límite alcanzado - No puedes subir más documentos'
                ) : (
                  `Modo invitado: ${guestInfo.documents_remaining} de ${guestInfo.limit} documentos restantes`
                )}
              </p>
              <p className={`text-sm mt-1 ${
                guestInfo.documents_remaining === 0
                  ? 'text-red-800 dark:text-red-300'
                  : guestInfo.documents_remaining <= 2
                  ? 'text-yellow-800 dark:text-yellow-300'
                  : 'text-blue-800 dark:text-blue-300'
              }`}>
                {guestInfo.documents_remaining === 0 ? (
                  <>
                    <button
                      onClick={handleRegisterRedirect}
                      className="font-medium underline hover:no-underline"
                    >
                      Crea una cuenta gratuita
                    </button>
                    {' '}para documentos ilimitados.
                  </>
                ) : (
                  <>
                    <button
                      onClick={handleRegisterRedirect}
                      className="font-medium underline hover:no-underline"
                    >
                      Crea una cuenta gratuita
                    </button>
                    {' '}para subidas ilimitadas y almacenamiento permanente.
                  </>
                )}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Upload Dropzone */}
      <div
        {...getRootProps()}
        className={`
          border-2 border-dashed rounded-lg p-12 text-center
          transition-colors duration-200
          ${isLimitReached 
            ? 'opacity-50 cursor-not-allowed bg-gray-100 dark:bg-gray-900 border-gray-300 dark:border-gray-700' 
            : isUploading 
            ? 'opacity-50 cursor-not-allowed' 
            : isDragActive 
            ? 'border-blue-500 bg-blue-50 dark:bg-blue-900/20 cursor-pointer' 
            : 'border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 hover:border-blue-400 hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer'
          }
        `}
      >
        <input {...getInputProps()} disabled={isLimitReached ?? false} />
        <div className="flex flex-col items-center space-y-4">
          <div className={`
            p-4 rounded-full
            ${isDragActive ? 'bg-blue-100 dark:bg-blue-900/40' : 'bg-gray-100 dark:bg-gray-700'}
          `}>
            <Upload className={isDragActive ? 'text-blue-600 dark:text-blue-400' : 'text-gray-600 dark:text-gray-400'} size={40} />
          </div>
          
          {isLimitReached ? (
            <div>
              <p className="text-lg font-medium text-gray-500 dark:text-gray-400">
                Límite de documentos alcanzado
              </p>
              <p className="text-sm text-gray-400 dark:text-gray-500 mt-1">
                Crea una cuenta para continuar
              </p>
            </div>
          ) : isDragActive ? (
            <p className="text-lg font-medium text-blue-600 dark:text-blue-400">
              Suelta los archivos PDF aquí...
            </p>
          ) : (
            <>
              <div>
                <p className="text-lg font-medium text-gray-900 dark:text-gray-100">
                  Arrastra y suelta archivos PDF aquí
                </p>
                <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
                  o haz clic para seleccionar archivos
                </p>
              </div>
              <p className="text-xs text-gray-400 dark:text-gray-500">
                Soporta archivos individuales o múltiples (máx. 20 archivos)
              </p>
            </>
          )}
        </div>
      </div>

      {/* Upload Progress/Results */}
      {uploadedFiles.length > 0 && (
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
              Resultados de Carga ({uploadedFiles.length})
            </h3>
            {!isUploading && (
              <button
                onClick={clearFiles}
                className="text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200"
              >
                Limpiar
              </button>
            )}
          </div>

          <div className="space-y-3">
            {uploadedFiles.map((item, index) => (
              <div
                key={index}
                className={`flex items-center justify-between p-4 border rounded-lg ${
                  item.status === 'duplicate' 
                    ? 'border-yellow-200 dark:border-yellow-800 bg-yellow-50 dark:bg-yellow-900/20'
                    : item.status === 'blocked'
                    ? 'border-red-200 dark:border-red-800 bg-red-50 dark:bg-red-900/20'
                    : 'border-gray-200 dark:border-gray-700'
                }`}
              >
                <div className="flex items-center space-x-3 flex-1">
                  <FileText className="text-gray-400 dark:text-gray-500" size={24} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">
                      {item.file.name}
                    </p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">
                      {(item.file.size / 1024 / 1024).toFixed(2)} MB
                    </p>
                    {item.message && (
                      <p className={`text-xs mt-1 ${
                        item.status === 'error' || item.status === 'blocked'
                          ? 'text-red-600 dark:text-red-400' 
                          : item.status === 'duplicate'
                          ? 'text-yellow-600 dark:text-yellow-400'
                          : 'text-green-600 dark:text-green-400'
                      }`}>
                        {item.message}
                      </p>
                    )}
                  </div>
                </div>

                <div className="ml-4">
                  {item.status === 'uploading' && (
                    <Loader className="animate-spin text-blue-600 dark:text-blue-400" size={20} />
                  )}
                  {item.status === 'success' && (
                    <CheckCircle className="text-green-600 dark:text-green-400" size={20} />
                  )}
                  {item.status === 'duplicate' && (
                    <AlertCircle className="text-yellow-600 dark:text-yellow-400" size={20} />
                  )}
                  {(item.status === 'error' || item.status === 'blocked') && (
                    <XCircle className="text-red-600 dark:text-red-400" size={20} />
                  )}
                </div>
              </div>
            ))}
          </div>

          {/* Summary */}
          {!isUploading && (
            <div className="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
              <div className="flex items-center justify-between text-sm">
                <span className="text-green-600 dark:text-green-400">
                  Exitosos: {uploadedFiles.filter(f => f.status === 'success').length}
                </span>
                <span className="text-yellow-600 dark:text-yellow-400">
                  Duplicados: {uploadedFiles.filter(f => f.status === 'duplicate').length}
                </span>
                <span className="text-red-600 dark:text-red-400">
                  Fallidos: {uploadedFiles.filter(f => f.status === 'error').length}
                </span>
                {blockedCount > 0 && (
                  <span className="text-red-600 dark:text-red-400 font-semibold">
                    Bloqueados: {blockedCount}
                  </span>
                )}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Upload Tips */}
      <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-6">
        <h4 className="font-semibold text-blue-900 dark:text-blue-100 mb-2">Consejos de Carga</h4>
        <ul className="text-sm text-blue-800 dark:text-blue-200 space-y-1">
          <li>• Solo se aceptan archivos PDF</li>
          <li>• Tamaño máximo de archivo: 50 MB por archivo</li>
          <li>• Puedes subir hasta 20 archivos a la vez</li>
          {!isAuthenticated && (
            <li className="font-semibold">• Usuarios invitados: máximo 5 documentos en total (no por subida)</li>
          )}
          <li>• El sistema clasificará y extraerá datos automáticamente de tus formularios</li>
          <li>• Los documentos duplicados (mismo cliente + período + tipo) serán detectados automáticamente</li>
        </ul>
      </div>
    </div>
  )
}
