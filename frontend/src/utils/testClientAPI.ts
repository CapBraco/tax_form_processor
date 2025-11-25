// API Test Utility
// Save this as: src/utils/testClientAPI.ts
// Run in browser console or as a standalone script

export async function testClientAPI() {
  const razonSocial = "GAMA EDITORES REYES MEDINA CIA. LTDA."
  
  console.group('🧪 Testing Client API')
  
  // Test 1: Get all clients
  console.log('\n📋 Test 1: Get All Clients')
  try {
    const response = await fetch('/api/clientes/')
    const data = await response.json()
    console.log('Status:', response.status)
    console.log('Clients found:', data.clients?.length || 0)
    console.table(data.clients)
    
    // Check if our client exists
    const clientExists = data.clients?.some((c: any) => 
      c.razon_social === razonSocial
    )
    console.log(`✓ Client "${razonSocial}" exists:`, clientExists)
  } catch (error) {
    console.error('❌ Test 1 Failed:', error)
  }
  
  // Test 2: Get client documents
  console.log('\n📄 Test 2: Get Client Documents')
  try {
    const url = `/api/clientes/${encodeURIComponent(razonSocial)}`
    console.log('URL:', url)
    
    const response = await fetch(url)
    const data = await response.json()
    
    console.log('Status:', response.status)
    console.log('Response:', data)
    
    if (data.years) {
      console.log(`✓ Years found: ${data.years.length}`)
      data.years.forEach((year: any) => {
        console.log(`  Year ${year.year}: ${year.months.length} months`)
        year.months.forEach((month: any) => {
          const has103 = month.forms.form_103 ? '✓' : '✗'
          const has104 = month.forms.form_104 ? '✓' : '✗'
          console.log(`    Month ${month.month}: Form103 ${has103} | Form104 ${has104}`)
        })
      })
    } else {
      console.warn('⚠️ No years data in response')
    }
  } catch (error) {
    console.error('❌ Test 2 Failed:', error)
  }
  
  // Test 3: Get Form 103 documents
  console.log('\n📊 Test 3: Get Form 103 Documents')
  try {
    const response = await fetch('/api/documents/form_103')
    const data = await response.json()
    console.log('Status:', response.status)
    console.log('Form 103 documents found:', data.documents?.length || 0)
    
    // Filter for our client
    const clientDocs = data.documents?.filter((d: any) => 
      d.razon_social === razonSocial
    )
    console.log(`✓ Form 103 for "${razonSocial}":`, clientDocs?.length || 0)
    console.table(clientDocs)
  } catch (error) {
    console.error('❌ Test 3 Failed:', error)
  }
  
  // Test 4: Get Form 104 documents
  console.log('\n📈 Test 4: Get Form 104 Documents')
  try {
    const response = await fetch('/api/documents/form_104')
    const data = await response.json()
    console.log('Status:', response.status)
    console.log('Form 104 documents found:', data.documents?.length || 0)
    
    // Filter for our client
    const clientDocs = data.documents?.filter((d: any) => 
      d.razon_social === razonSocial
    )
    console.log(`✓ Form 104 for "${razonSocial}":`, clientDocs?.length || 0)
    console.table(clientDocs)
  } catch (error) {
    console.error('❌ Test 4 Failed:', error)
  }
  
  // Test 5: Check recent uploads
  console.log('\n🆕 Test 5: Check All Documents (Recent First)')
  try {
    const response = await fetch('/api/documents')
    const data = await response.json()
    console.log('Status:', response.status)
    console.log('Total documents:', data.documents?.length || 0)
    
    // Show most recent 10
    const recent = data.documents?.slice(0, 10)
    console.log('Most recent 10 documents:')
    console.table(recent?.map((d: any) => ({
      id: d.id,
      razon_social: d.razon_social,
      tipo: d.form_type || 'unknown',
      periodo: d.periodo,
      fecha: d.created_at
    })))
  } catch (error) {
    console.error('❌ Test 5 Failed:', error)
  }
  
  console.groupEnd()
  
  console.log('\n📊 Summary:')
  console.log('If all tests passed, the API is working correctly.')
  console.log('If documents are in Form 103/104 but NOT in Client Documents,')
  console.log('the issue is in the /api/clientes/[razonSocial] endpoint.')
}

// Auto-run if in browser console
if (typeof window !== 'undefined') {
  console.log('🧪 API Test Utility loaded!')
  console.log('Run: testClientAPI()')
}

// Export for use in components
export default testClientAPI


// HOW TO USE:
// 
// Method 1: In Browser Console
// 1. Open browser console (F12)
// 2. Copy and paste this entire file
// 3. Run: testClientAPI()
//
// Method 2: In React Component
// import testClientAPI from '@/utils/testClientAPI'
// <button onClick={testClientAPI}>Test API</button>
//
// Method 3: Quick Test Button
// Add this to your Dashboard component:
// 
// {process.env.NODE_ENV === 'development' && (
//   <button 
//     onClick={() => import('@/utils/testClientAPI').then(m => m.default())}
//     className="fixed bottom-4 right-4 bg-red-600 text-white px-4 py-2 rounded-lg"
//   >
//     🧪 Test API
//   </button>
// )}
