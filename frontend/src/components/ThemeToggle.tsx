'use client'

import { Moon, Sun } from 'lucide-react'
import { useTheme } from '@/contexts/ThemeContext'
import { useEffect, useState } from 'react'

export default function ThemeToggle() {
  const [mounted, setMounted] = useState(false)
  
  // Only access theme after component mounts to avoid hydration issues
  useEffect(() => {
    setMounted(true)
  }, [])

  // Try to get theme context, but handle if it's not available
  let theme: 'light' | 'dark' = 'light'
  let toggleTheme: (() => void) | undefined

  try {
    const context = useTheme()
    theme = context.theme
    toggleTheme = context.toggleTheme
  } catch (error) {
    // ThemeProvider not found - show error message
    console.error('ThemeToggle: ThemeProvider not found in layout.tsx')
    
    if (mounted) {
      return (
        <div className="px-3 py-2 rounded-lg border-2 border-red-300 bg-red-50 text-red-700 text-xs">
          <strong>Error:</strong> ThemeProvider missing in layout.tsx
        </div>
      )
    }
    return null
  }

  // Don't render until mounted to avoid hydration mismatch
  if (!mounted) {
    return (
      <div className="flex items-center gap-2 px-3 py-2 rounded-lg border-2 border-gray-300 bg-white">
        <div className="w-5 h-5 bg-gray-200 rounded animate-pulse"></div>
        <span className="text-sm font-medium text-gray-400">Loading...</span>
      </div>
    )
  }

  return (
    <button
      onClick={toggleTheme}
      className="flex items-center gap-2 px-3 py-2 rounded-lg border-2 transition-all hover:scale-105 dark:border-gray-600 dark:bg-gray-800 dark:hover:bg-gray-700 border-gray-300 bg-white hover:bg-gray-50"
      title={theme === 'light' ? 'Activar modo oscuro' : 'Activar modo claro'}
    >
      {theme === 'light' ? (
        <>
          <Moon className="w-5 h-5 text-gray-700" />
          <span className="text-sm font-medium text-gray-700">Modo Oscuro</span>
        </>
      ) : (
        <>
          <Sun className="w-5 h-5 text-yellow-400" />
          <span className="text-sm font-medium text-gray-100">Modo Claro</span>
        </>
      )}
    </button>
  )
}
