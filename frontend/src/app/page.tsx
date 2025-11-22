'use client'

import { useState } from 'react'
import Sidebar from '@/components/Sidebar'
import Dashboard from '@/components/Dashboard'
import UploadSection from '@/components/UploadSection'
import DocumentsSection from '@/components/DocumentsSection'
import Form103Section from '@/components/Form103Section'
import Form104Section from '@/components/Form104Section'

export default function Home() {
  const [activeSection, setActiveSection] = useState('dashboard')
  const [refreshTrigger, setRefreshTrigger] = useState(0)

  const handleUploadSuccess = () => {
    // Trigger refresh of documents list
    setRefreshTrigger(prev => prev + 1)
    // Switch to documents view
    setActiveSection('documents')
  }

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Sidebar */}
      <Sidebar 
        activeSection={activeSection} 
        setActiveSection={setActiveSection} 
      />

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto">
        <div className="p-8">
          {/* Header */}
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900">
              {activeSection === 'dashboard' && 'Dashboard'}
              {activeSection === 'upload' && 'Upload Forms'}
              {activeSection === 'documents' && 'All Documents'}
              {activeSection === 'form103' && 'Form 103 - Retenciones'}
              {activeSection === 'form104' && 'Form 104 - IVA'}
            </h1>
            <p className="text-gray-600 mt-1">
              {activeSection === 'dashboard' && 'Overview of your tax forms'}
              {activeSection === 'upload' && 'Upload Form 103 and Form 104 PDFs'}
              {activeSection === 'documents' && 'View and manage all uploaded documents'}
              {activeSection === 'form103' && 'View structured data from Form 103 declarations'}
              {activeSection === 'form104' && 'View structured data from Form 104 declarations'}
            </p>
          </div>

          {/* Content Sections */}
          {activeSection === 'dashboard' && (
            <Dashboard onNavigate={setActiveSection} />
          )}
          
          {activeSection === 'upload' && (
            <UploadSection onUploadSuccess={handleUploadSuccess} />
          )}
          
          {activeSection === 'documents' && (
            <DocumentsSection refreshTrigger={refreshTrigger} />
          )}
          
          {activeSection === 'form103' && (
            <Form103Section />
          )}
          
          {activeSection === 'form104' && (
            <Form104Section />
          )}
        </div>
      </main>
    </div>
  )
}
