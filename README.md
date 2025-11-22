### **Step 2: Backend Setup**
```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/Scripts/activate  # Windows Git Bash
# OR
venv\Scripts\activate  # Windows CMD

# Install dependencies
pip install -r requirements.txt

# Create .env file
copy .env.example .env

# Create uploads directory
mkdir uploads
```

### **Step 3: Start Database**
```bash
# Start PostgreSQL
docker-compose up -d

# Wait 10 seconds, then initialize
python init_db.py
```

### **Step 4: Start Backend**
```bash
python main.py
```

✅ Backend: http://localhost:8000
✅ API Docs: http://localhost:8000/docs

### **Step 5: Frontend Setup**
```bash
# New terminal
cd frontend

# Install dependencies
npm install

# Create .env.local
copy .env.example .env.local

# Start frontend
npm run dev
```

✅ Frontend: http://localhost:3000

---

## 🎯 **Usage Guide**

### **1. Upload PDFs**
1. Click **"Upload"** in sidebar
2. Drag your Form 103 or Form 104 PDFs
3. Wait for processing (5-10 seconds)
4. Forms are automatically classified!

### **2. View Form 103 Data**
1. Click **"Form 103"** in sidebar
2. Click on any document card
3. See interactive table with:
   - Concepto
   - Código Base
   - **BASE IMPONIBLE** (blue)
   - Código Retención
   - **VALOR RETENIDO** (green)
4. Click **"Export CSV"** to download

### **3. View Form 104 Data**
1. Click **"Form 104"** in sidebar
2. Click on any document card
3. See structured data:
   - **Ventas** (Sales) - gross, net, tax
   - **Compras** (Purchases) - acquisitions, tax credit
   - **Retenciones IVA** - by percentage
   - **Totals** - consolidated IVA, total paid
4. Click **"Export CSV"** to download

---

## 📊 **What Gets Extracted**

### **Form 103 Table**
| Concepto | Código | BASE IMPONIBLE | Código | VALOR RETENIDO |
|----------|---------|----------------|---------|----------------|
| Honorarios profesionales | 303 | $2,050.00 | 353 | $205.00 |
| Transporte privado | 310 | $127.85 | 360 | $1.28 |
| Transferencia de bienes | 312 | $9,352.89 | 362 | $163.68 |
| **TOTAL** | | **$27,710.90** | | **$374.18** |

### **Form 104 Data Cards**
**Ventas:**
- Ventas Tarifa ≠ 0 (Bruto): $36,088.15
- Ventas Tarifa ≠ 0 (Neto): $36,080.04
- Impuesto Generado: $5,412.01

**Compras:**
- Adquisiciones: $9,622.70
- Impuesto Compras: $1,427.28
- Crédito Tributario: $1,427.28

**Retenciones IVA:**
- 30%: $111.66
- 70%: $11.18
- 100%: $342.31

**Totals:**
- Total Consolidado IVA: $2,958.17
- **Total Pagado: $2,958.17**

---

## 🗂️ **Application Structure**

```
enhanced/
├── backend/                    # FastAPI Backend
│   ├── app/
│   │   ├── api/
│   │   │   ├── upload.py      # Upload PDFs
│   │   │   ├── documents.py   # List documents
│   │   │   └── forms_data.py  # Get structured data
│   │   ├── models/
│   │   │   └── base.py        # 3 database tables
│   │   ├── services/
│   │   │   ├── pdf_service.py           # Extract text
│   │   │   ├── form_103_parser.py       # Parse Form 103
│   │   │   ├── form_104_parser.py       # Parse Form 104
│   │   │   └── enhanced_form_processing_service.py
│   │   └── core/
│   ├── main.py                # App entry
│   ├── init_db.py             # DB initialization
│   └── requirements.txt
│
├── frontend/                   # Next.js Frontend
│   └── src/
│       ├── app/
│       │   └── page.tsx       # Main page with routing
│       ├── components/
│       │   ├── Sidebar.tsx
│       │   ├── Dashboard.tsx
│       │   ├── UploadSection.tsx
│       │   ├── Form103Section.tsx  # 📊 Form 103 Table View
│       │   └── Form104Section.tsx  # 📊 Form 104 Data View
│       └── lib/
│           └── api.ts         # API client
│
└── docker-compose.yml          # PostgreSQL
```

---

## 🔌 **API Endpoints**

### **Upload**
- `POST /api/upload/single` - Upload PDF
- `POST /api/upload/bulk` - Bulk upload

### **Forms Data (NEW!)**
- `GET /api/forms-data/form-103/{id}` - Get Form 103 structured data
- `GET /api/forms-data/form-104/{id}` - Get Form 104 structured data
- `GET /api/forms-data/list-by-form-type/form_103` - List all Form 103s
- `GET /api/forms-data/list-by-form-type/form_104` - List all Form 104s

### **Documents**
- `GET /api/documents/` - List all documents
- `GET /api/documents/{id}` - Get document detail
- `DELETE /api/documents/{id}` - Delete document
- `GET /api/documents/stats/overview` - Statistics

---

## 📊 **Database Tables**

### **documents**
Stores header information:
- RUC, Razón Social
- Período (Month/Year)
- Fecha Recaudación
- Form Type
- Processing Status

### **form_103_line_items**
Stores each line item:
- Concepto
- Código Base
- **BASE IMPONIBLE**
- Código Retención
- **VALOR RETENIDO**

### **form_104_data**
Stores IVA data:
- Ventas (gross, net, tax)
- Compras (acquisitions, tax)
- Retenciones IVA (JSON)
- Totals

---

## 🎨 **UI Features**

### **Dashboard**
- Statistics cards
- Form type overview
- Quick actions
- Getting started guide

### **Form 103 View**
- Document cards with period info
- Click to view full table
- Color-coded BASE IMPONIBLE (blue) and VALOR RETENIDO (green)
- Calculated totals footer
- CSV export button

### **Form 104 View**
- Document cards
- Click to view structured data
- Cards for Ventas, Compras, Totals
- Retenciones table by percentage
- CSV export

### **Responsive Design**
- Works on desktop, tablet, mobile
- Scrollable tables
- Touch-friendly buttons

---

## 💾 **Export to CSV**

Click **"Export CSV"** in any form view:

**Form 103 CSV:**
```csv
Concepto,Código Base,BASE IMPONIBLE,Código Retención,VALOR RETENIDO
"Honorarios profesionales","303","2050.00","353","205.00"
"Transporte privado","310","127.85","360","1.28"
...
```

**Form 104 CSV:**
```csv
=== VENTAS (Sales) ===
Concepto,Valor
Ventas Tarifa Diferente Cero (Bruto),36088.15
...

=== COMPRAS (Purchases) ===
Concepto,Valor
...

=== RETENCIONES IVA ===
Porcentaje,Valor
30%,111.66
...
```

---

## 🔧 **Configuration**

### **Backend `.env`**
```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/pdf_extractor_db
HOST=0.0.0.0
PORT=8000
DEBUG=True
UPLOAD_DIR=./uploads
MAX_UPLOAD_SIZE=52428800
CORS_ORIGINS=http://localhost:3000
```

### **Frontend `.env.local`**
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

---

## 🐛 **Troubleshooting**

### **Backend won't start**
```bash
cd backend
source venv/Scripts/activate
pip install -r requirements.txt
python main.py
```

### **Database error**
```bash
docker-compose down
docker-compose up -d
sleep 10
python init_db.py
```

### **Frontend won't start**
```bash
cd frontend
rm -rf node_modules .next
npm install
npm run dev
```

### **No data extracted**
- Check PDF is Form 103 or 104
- Check processing_status in database
- View raw text at GET /api/documents/{id}
- Check backend logs for parsing errors

### **Wrong data extracted**
- Regex patterns are tuned for Ecuadorian SRI forms
- If format changed, update parsers in:
  - `backend/app/services/form_103_parser.py`
  - `backend/app/services/form_104_parser.py`

---

## 🧪 **Testing**

### **1. Upload Test Forms**
```bash
curl -X POST http://localhost:8000/api/upload/single \
  -F "file=@103_DECLARACION_ABRIL.pdf"
```

### **2. Get Form 103 Data**
```bash
curl http://localhost:8000/api/forms-data/form-103/1 | json_pp
```

### **3. Frontend Test**
1. Open http://localhost:3000
2. Upload both test PDFs
3. Navigate to Form 103
4. Click document card
5. Verify table shows correct data
6. Export CSV and check

---

## 📚 **Additional Documentation**

- **API Documentation**: http://localhost:8000/docs
- **Implementation Guide**: ENHANCED_IMPLEMENTATION_GUIDE.md
- **Parsers Details**: See source code comments

---