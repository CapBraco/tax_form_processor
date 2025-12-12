'use client'

import { ReactNode } from 'react'
import PresentationCard from './PresentationCard'

interface MainLayoutWrapperProps {
  children: ReactNode
}

export default function MainLayoutWrapper({ children }: MainLayoutWrapperProps) {
  return (
    <>
      {children}
      {/* ✅ Global Presentation Card - Appears on all pages */}
      <PresentationCard />
    </>
  )
}
