import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "@/contexts/AuthContext";
import { ThemeProvider } from "@/contexts/ThemeContext";
import Script from 'next/script'
import MainLayoutWrapper from "@/components/MainLayoutWrapper";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: {
    default: "Pan Tributario - Gestión de Formularios 103 & 104",
    template: "%s | Pan Tributario"
  },
  description: "Sistema profesional de procesamiento y análisis de formularios tributarios 103 (Retenciones) y 104 (IVA) de Ecuador. Organiza tus declaraciones fiscales por cliente y período con resúmenes anuales automáticos.",
  keywords: [
    "formularios tributarios Ecuador",
    "Forma 103",
    "Forma 104",
    "SRI Ecuador",
    "declaraciones fiscales",
    "retenciones en la fuente",
    "IVA Ecuador",
    "gestión tributaria",
    "contabilidad Ecuador",
    "procesamiento de formularios",
    "contabilidad Quito",
    "contadores Ecuador"
  ],
  authors: [{ name: "Braco || Capbraco.com", url: "https://capbraco.com" }],
  creator: "Braco",
  publisher: "Capbraco",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || 'https://capbraco.com'),
  alternates: {
    canonical: '/',
  },
  openGraph: {
    type: "website",
    locale: "es_EC",
    url: "https://tax.capbraco.com",
    siteName: "Pan Tributario || Gestion Tributaria",
    title: "Pan Tributario - Gestión de Formularios Tributarios",
    description: "Sistema profesional de procesamiento de formularios tributarios ecuatorianos 103 y 104",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "Pan Tributario",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Pan Tributario",
    description: "Sistema profesional de gestión de formularios tributarios de Ecuador",
    images: ["/og-image.png"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  icons: {
    icon: [
      { url: '/favicon-16x16.png', sizes: '16x16', type: 'image/png' },
      { url: '/favicon-32x32.png', sizes: '32x32', type: 'image/png' },
    ],
    apple: [
      { url: '/apple-touch-icon.png', sizes: '180x180', type: 'image/png' },
    ],
    other: [
      {
        rel: 'mask-icon',
        url: '/safari-pinned-tab.svg',
      },
    ],
  },
  manifest: '/site.webmanifest',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="es" className="h-full">
      <head>
        {/* ✅ Google Fonts - WindSong & Playfair Display */}
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link 
          href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=WindSong:wght@400;500&display=swap" 
          rel="stylesheet" 
        />

        {/* ✅ Google Analytics */}
        <Script
          src={`https://www.googletagmanager.com/gtag/js?id=G-150223665`}
          strategy="afterInteractive"
        />
        <Script id="google-analytics" strategy="afterInteractive">
          {`
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', 'G-150223665');
          `}
        </Script>
      </head>
      <body className={`${inter.className} h-full bg-gray-100 dark:bg-gray-900`}>
        <ThemeProvider>
          <AuthProvider>
            <MainLayoutWrapper>
              {children}
            </MainLayoutWrapper>
          </AuthProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
