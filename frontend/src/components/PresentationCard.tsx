'use client'

import { useState } from 'react'

export default function PresentationCard() {
  const [isActive, setIsActive] = useState(false)
  const [isOpen, setIsOpen] = useState(false)
  const [isDragging, setIsDragging] = useState(false)

  const handleToggle = () => {
    setIsActive(!isActive)
  }

  const handleDragStart = () => {
    setIsDragging(true)
  }

  const handleDragEnd = () => {
    setIsDragging(false)
    setIsOpen(!isOpen)
  }

  return (
    <>
      {/* ✅ Draggable Book Tab - Bottom Right Corner */}
      <div
        className={`book-tab ${isOpen ? 'open' : ''} ${isDragging ? 'dragging' : ''}`}
        onMouseDown={handleDragStart}
        onMouseUp={handleDragEnd}
        onTouchStart={handleDragStart}
        onTouchEnd={handleDragEnd}
      >
        <div className="book-spine">
          <div className="book-text">Developed by</div>
          <div className="book-line"></div>
        </div>
      </div>

      {/* ✅ Overlay Background */}
      {isOpen && (
        <div 
          className="card-overlay"
          onClick={() => setIsOpen(false)}
        />
      )}

      {/* ✅ Luminous Card Container */}
      <div className={`card-container ${isOpen ? 'visible' : ''}`}>
        <div className="portfolio-card-wrapper">
          <div className={`luminous-card ${isActive ? 'active' : ''}`}>
            {/* Light Layer */}
            <div className="light-layer">
              <div className="slit"></div>
              <div className="lumen">
                <div className="min"></div>
                <div className="mid"></div>
                <div className="hi"></div>
              </div>
              <div className="darken">
                <div className="sl"></div>
                <div className="ll"></div>
                <div className="slt"></div>
                <div className="srt"></div>
              </div>
            </div>

            {/* Card Content */}
            <div className="card-content">
              <div className="logo-section">
                <a
                  href="https://www.capbraco.com"
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label="Visit CapBraco Portfolio"
                >
                  <p className="cap-text">Cap</p>
                  <p className="braco-text">Braco</p>
                </a>
              </div>
              <div className="bottom">
                <h4>Developed by Braco</h4>
                <p>
                  © 2025 CapBraco<br />
                  All rights reserved
                </p>
                <div 
                  className={`toggle ${isActive ? 'active' : ''}`} 
                  onClick={handleToggle}
                >
                  <div className="handle"></div>
                  <span>Activate Lumen</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ✅ Embedded Styles */}
      <style jsx>{`
        /* =================================
           BOOK TAB - DRAGGABLE CORNER
        ================================= */
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=WindSong:wght@400;500&display=swap" rel="stylesheet">
        .book-tab {
          position: fixed;
          bottom: 20px;
          right: -60px;
          width: 180px;
          height: 60px;
          background: radial-gradient(circle at 50% 0%, #2a2a2a 0%, #141414 64%);
          border-radius: 8px 0 0 8px;
          cursor: grab;
          z-index: 9998;
          transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
          box-shadow: 
            -4px 4px 12px rgba(0, 0, 0, 0.3),
            inset 0 1px 0 rgba(255, 255, 255, 0.05),
            inset 0 -1px 0 rgba(0, 0, 0, 0.3),
            0 0 0 1px rgba(245, 245, 240, 0.1);
          border: 1px solid rgba(245, 245, 240, 0.1);
          border-right: none;
          animation: breathe 3s ease-in-out infinite;
        }

        @keyframes breathe {
          0%, 100% {
            transform: translateX(0) scale(1);
            box-shadow: 
              -4px 4px 12px rgba(0, 0, 0, 0.3),
              inset 0 1px 0 rgba(255, 255, 255, 0.05),
              0 0 15px rgba(59, 130, 246, 0.2);
          }
          50% {
            transform: translateX(-5px) scale(1.02);
            box-shadow: 
              -6px 6px 16px rgba(0, 0, 0, 0.4),
              inset 0 1px 0 rgba(255, 255, 255, 0.1),
              0 0 25px rgba(59, 130, 246, 0.4);
          }
        }

        .book-tab:hover {
          right: -55px;
          animation: breathe 2s ease-in-out infinite;
        }

        .book-tab.dragging {
          cursor: grabbing;
          right: -40px;
          transform: scale(1.05);
          animation: none;
          box-shadow: 
            -8px 8px 20px rgba(0, 0, 0, 0.5),
            0 0 30px rgba(59, 130, 246, 0.6);
        }

        .book-tab.open {
          right: -180px;
          opacity: 0;
          pointer-events: none;
        }

        .book-spine {
          position: relative;
          width: 100%;
          height: 100%;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          padding: 12px;
          background: linear-gradient(90deg, 
            rgba(0, 0, 0, 0.1) 0%,
            transparent 10%,
            transparent 90%,
            rgba(255, 255, 255, 0.1) 100%
          );
        }

        .book-spine::before {
          content: '';
          position: absolute;
          left: 8px;
          top: 10px;
          bottom: 10px;
          width: 2px;
          background: linear-gradient(180deg,
            rgba(255, 255, 255, 0.2) 0%,
            rgba(255, 255, 255, 0.05) 50%,
            rgba(0, 0, 0, 0.2) 100%
          );
        }

        .book-text {
          font-family: 'Inter', sans-serif;
          font-size: 11px;
          font-weight: 600;
          color: #d4d4d8;
          text-transform: uppercase;
          letter-spacing: 1.5px;
          writing-mode: vertical-rl;
          text-orientation: mixed;
          text-shadow: 0 1px 2px rgba(0, 0, 0, 0.5);
        }

        .book-line {
          width: 30px;
          height: 1px;
          background: rgba(245, 245, 240, 0.2);
          margin-top: 8px;
          transform: rotate(90deg);
        }

        /* =================================
           OVERLAY BACKGROUND
        ================================= */
        .card-overlay {
          position: fixed;
          inset: 0;
          background: rgba(0, 0, 0, 0.7);
          backdrop-filter: blur(4px);
          z-index: 9998;
          animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }

        /* =================================
           CARD CONTAINER
        ================================= */
        .card-container {
          position: fixed;
          bottom: 20px;
          right: 20px;
          z-index: 9999;
          opacity: 0;
          transform: translateX(100%) scale(0.8);
          transition: all 0.5s cubic-bezier(0.4, 0, 0.2, 1);
          pointer-events: none;
        }

        .card-container.visible {
          opacity: 1;
          transform: translateX(0) scale(1);
          pointer-events: auto;
        }

        .portfolio-card-wrapper {
          padding: 0;
          margin: 0;
        }

        /* =================================
           LUMINOUS CARD - BLUE NEON
        ================================= */
        .luminous-card {
          position: relative;
          background: radial-gradient(circle at 50% 0%, #2a2a2a 0%, #141414 64%);
          box-shadow: 
            inset 0 1.01rem 0.2rem -1rem rgba(59, 130, 246, 0),
            inset 0 -1.01rem 0.2rem -1rem #0000,
            0 -1.02rem 0.2rem -1rem rgba(59, 130, 246, 0),
            0 1rem 0.2rem -1rem #0000,
            0 0 0 1px rgba(245, 245, 240, 0.2),
            0 4px 4px 0 #0004,
            0 0 0 1px #333;
          width: 18rem;
          height: 24rem;
          border-radius: 1.8rem;
          color: #f5f5f0;
          padding: 1rem;
          display: flex;
          flex-direction: column;
          justify-content: flex-end;
          transition: all 0.4s ease-in-out;
          font-family: 'Inter', -apple-system, sans-serif;
        }

        .luminous-card::before {
          content: "";
          display: block;
          --offset: 1rem;
          width: calc(100% + 2 * var(--offset));
          height: calc(100% + 2 * var(--offset));
          position: absolute;
          left: calc(-1 * var(--offset));
          right: calc(-1 * var(--offset));
          top: calc(-1 * var(--offset));
          bottom: calc(-1 * var(--offset));
          margin: auto;
          box-shadow: inset 0 0 0px 0.06rem rgba(245, 245, 240, 0.1);
          border-radius: 2.6rem;
          --ax: 4rem;
          clip-path: polygon(
            var(--ax) 0, 0 0, 0 var(--ax), var(--ax) var(--ax),
            var(--ax) calc(100% - var(--ax)), 0 calc(100% - var(--ax)),
            0 100%, var(--ax) 100%,
            var(--ax) calc(100% - var(--ax)),
            calc(100% - var(--ax)) calc(100% - var(--ax)),
            calc(100% - var(--ax)) 100%, 100% 100%,
            100% calc(100% - var(--ax)),
            calc(100% - var(--ax)) calc(100% - var(--ax)),
            calc(100% - var(--ax)) var(--ax), 100% var(--ax),
            100% 0, calc(100% - var(--ax)) 0,
            calc(100% - var(--ax)) var(--ax), var(--ax) var(--ax)
          );
          transition: all 0.4s ease-in-out;
        }

        .luminous-card:hover {
          transform: translateY(-0.2rem);
        }

        .luminous-card:hover::before {
          --offset: 0.5rem;
          --ax: 8rem;
          border-radius: 2.2rem;
          box-shadow: inset 0 0 0 0.08rem rgba(245, 245, 240, 0.05);
        }

        .light-layer {
          position: absolute;
          left: 0;
          top: 0;
          height: 100%;
          width: 100%;
          transform-style: preserve-3d;
          perspective: 400px;
          pointer-events: none;
        }

        .slit {
          position: absolute;
          left: 0;
          right: 0;
          top: 0;
          bottom: 0;
          margin: auto;
          width: 64%;
          height: 1.2rem;
          transform: rotateX(-76deg);
          background: #121212;
          box-shadow: 0 0 4px 0 rgba(59, 130, 246, 0);
          transition: all 0.4s ease-in-out;
        }

        .lumen {
          position: absolute;
          left: 0;
          right: 0;
          top: 0;
          bottom: 0;
          margin: auto;
          width: 100%;
          height: 100%;
          pointer-events: none;
          perspective: 400px;
          opacity: 0;
          transition: opacity 0.4s ease-in-out;
        }

        .lumen .min {
          width: 70%;
          height: 3rem;
          background: linear-gradient(rgba(59, 130, 246, 0), rgba(96, 165, 250, 0.7));
          position: absolute;
          left: 0;
          right: 0;
          top: 0;
          bottom: 2.5rem;
          margin: auto;
          transform: rotateX(-42deg);
          opacity: 0.5;
        }

        .lumen .mid {
          width: 74%;
          height: 13rem;
          background: linear-gradient(rgba(59, 130, 246, 0), rgba(96, 165, 250, 0.8));
          position: absolute;
          left: 0;
          right: 0;
          top: 0;
          bottom: 10em;
          margin: auto;
          transform: rotateX(-42deg);
          filter: blur(1rem);
          opacity: 0.9;
          border-radius: 100% 100% 0 0;
        }

        .lumen .hi {
          width: 50%;
          height: 13rem;
          background: linear-gradient(rgba(59, 130, 246, 0), rgba(96, 165, 250, 0.7));
          position: absolute;
          left: 0;
          right: 0;
          top: 0;
          bottom: 12em;
          margin: auto;
          transform: rotateX(22deg);
          filter: blur(1rem);
          opacity: 0.7;
          border-radius: 100% 100% 0 0;
        }

        .darken {
          position: absolute;
          left: 0;
          right: 0;
          top: 0;
          bottom: 0;
          margin: auto;
          width: 100%;
          height: 100%;
          pointer-events: none;
          perspective: 400px;
          transition: opacity 0.4s ease-in-out;
          opacity: 0.5;
        }

        .darken > * {
          transition: opacity 0.4s ease-in-out;
        }

        .darken .sl {
          width: 64%;
          height: 10rem;
          background: linear-gradient(#000, #0000);
          position: absolute;
          left: 0;
          right: 0;
          top: 9.6em;
          bottom: 0;
          margin: auto;
          filter: blur(0.2rem);
          opacity: 0.1;
          border-radius: 0 0 100% 100%;
          transform: rotateX(-22deg);
        }

        .darken .ll {
          width: 62%;
          height: 10rem;
          background: linear-gradient(#000a, #0000);
          position: absolute;
          left: 0;
          right: 0;
          top: 11em;
          bottom: 0;
          margin: auto;
          filter: blur(0.8rem);
          opacity: 0.4;
          border-radius: 0 0 100% 100%;
          transform: rotateX(22deg);
        }

        .darken .slt,
        .darken .srt {
          width: 0.5rem;
          height: 4rem;
          background: linear-gradient(#0005, #0000);
          position: absolute;
          top: 3.9em;
          bottom: 0;
          margin: auto;
          opacity: 0.6;
          border-radius: 0 0 100% 100%;
        }

        .darken .slt {
          left: 0;
          right: 11.5rem;
          transform: skewY(42deg);
        }

        .darken .srt {
          right: 0;
          left: 11.5rem;
          transform: skewY(-42deg);
        }

        .card-content {
          position: relative;
          z-index: 1;
        }

        .logo-section {
          position: relative;
          top: -9em;
          left: 0;
          right: 0;
          margin: auto;
          width: fit-content;
          filter: drop-shadow(0 -1.2rem 1px transparent);
          transition: filter 0.4s ease-in-out;
        }

        .logo-section a {
          display: block;
          text-decoration: none;
          color: inherit;
        }

        .cap-text {
          font-family: 'Playfair Display', serif;
          font-size: 1.8rem;
          font-weight: 700;
          color: #d4d4d8;
          letter-spacing: 0.05em;
          margin: 0;
          line-height: 1;
          text-align: left;
          position: relative;
          text-shadow: 
            0 1px 0 rgba(0, 0, 0, 0.3),
            0 2px 0 rgba(0, 0, 0, 0.25),
            0 3px 0 rgba(0, 0, 0, 0.2),
            0 4px 0 rgba(0, 0, 0, 0.15),
            0 5px 0 rgba(0, 0, 0, 0.1),
            0 6px 2px rgba(0, 0, 0, 0.3),
            0 8px 4px rgba(0, 0, 0, 0.25),
            0 10px 6px rgba(0, 0, 0, 0.15),
            0 12px 8px rgba(0, 0, 0, 0.1);
          transform-style: preserve-3d;
          transition: text-shadow 0.4s ease-in-out, color 0.4s ease-in-out;
        }

        .braco-text {
          font-family: 'WindSong', cursive;
          font-size: 7vmin;
          font-weight: 400;
          font-style: normal;
          color: #d4d4d8;
          margin: -0.5rem 0 0 0;
          line-height: 1;
          letter-spacing: 0.02em;
          position: relative;
          text-shadow: 
            0 1px 0 rgba(0, 0, 0, 0.3),
            0 2px 0 rgba(0, 0, 0, 0.25),
            0 3px 0 rgba(0, 0, 0, 0.2),
            0 4px 0 rgba(0, 0, 0, 0.15),
            0 5px 0 rgba(0, 0, 0, 0.1),
            0 6px 2px rgba(0, 0, 0, 0.3),
            0 8px 4px rgba(0, 0, 0, 0.25),
            0 10px 6px rgba(0, 0, 0, 0.15),
            0 12px 8px rgba(0, 0, 0, 0.1);
          transform-style: preserve-3d;
          transition: text-shadow 0.4s ease-in-out, color 0.4s ease-in-out;
        }

        .bottom {
          position: relative;
        }

        .bottom h4 {
          margin: 0 0 0.4rem 0;
          font-size: 0.9rem;
          color: #d4d4d8;
          font-weight: 400;
        }

        .bottom p {
          margin: 0;
          padding-bottom: 0.6rem;
          color: rgba(245, 245, 240, 0.25);
          font-size: 0.55rem;
          font-weight: 100;
          line-height: 1.4;
          border-bottom: 1px solid rgba(245, 245, 240, 0.1);
          max-width: 64%;
        }

        .toggle {
          position: absolute;
          right: 0;
          bottom: 0;
          height: 2rem;
          width: 4.8rem;
          border-radius: 0.6rem;
          background: #000;
          box-shadow: 
            inset 0 -8px 8px 0.3rem #0004,
            inset 0 0 1px 0.3rem #ddd,
            inset 0 -2px 1px 0.3rem #fff,
            inset 0 1px 2px 0.3rem #0006,
            inset 0 0 1px 0.8rem #aaa;
          cursor: pointer;
          transition: all 0.4s ease-in-out;
        }

        .toggle::before {
          content: "";
          display: block;
          position: absolute;
          left: 0;
          right: 0;
          top: 0;
          bottom: 0;
          margin: auto;
          width: 3.4rem;
          height: 0.68rem;
          border-radius: 0.2rem;
          background: #000;
          transition: all 0.4s ease-in-out;
        }

        .toggle .handle {
          position: absolute;
          top: 0;
          bottom: 0.04rem;
          margin: auto;
          left: 0.68rem;
          width: 40%;
          height: 30%;
          background: #aaa;
          border-radius: 0.2rem;
          box-shadow: 
            inset 0 1px 4px 0 #fff,
            inset 0 -1px 1px 0 #000a,
            0 0 1px 1px #0003,
            1px 3px 6px 1px #000a;
          transition: all 0.4s ease-in-out;
        }

        .toggle.active .handle {
          transform: translateX(1.58rem);
        }

        .toggle span {
          pointer-events: none;
          text-align: center;
          position: absolute;
          left: 0;
          right: 0;
          margin: auto;
          bottom: calc(100% + 0.4rem);
          font-size: 0.6rem;
          font-weight: 100;
          color: #555;
          opacity: 0;
          transition: opacity 0.4s ease-in-out;
          white-space: nowrap;
        }

        .toggle:hover span {
          opacity: 1;
        }

        .toggle:not(.active):hover .handle {
          transform: translateX(0.2rem);
        }

        /* ✅ ACTIVE STATE - BLUE NEON */
        .luminous-card.active {
          box-shadow: 
            inset 0 1.01rem 0.1rem -1rem rgba(59, 130, 246, 0.8),
            inset 0 -4rem 3rem -3rem #000a,
            0 -1.02rem 0.2rem -1rem rgba(59, 130, 246, 0.8),
            0 1rem 0.2rem -1rem #000,
            0 0 0 1px rgba(245, 245, 240, 0.1),
            0 4px 4px 0 #0004,
            0 0 0 1px #333,
            0 0 40px rgba(59, 130, 246, 0.5);
        }

        .luminous-card.active .slit {
          background: #3b82f6;
          box-shadow: 
            0 0 30px #3b82f6,
            0 0 60px rgba(59, 130, 246, 0.5);
        }

        .luminous-card.active .lumen {
          opacity: 0.6;
        }

        .luminous-card.active .darken {
          opacity: 0.8;
        }

        .luminous-card.active .darken .sl {
          opacity: 0.2;
        }

        .luminous-card.active .darken .ll {
          opacity: 1;
        }

        .luminous-card.active .darken .slt,
        .luminous-card.active .darken .srt {
          opacity: 1;
        }

        .luminous-card.active .logo-section {
          filter: drop-shadow(0 -1.2rem 6px rgba(59, 130, 246, 0.4)) brightness(1.4);
        }

        .luminous-card.active .cap-text,
        .luminous-card.active .braco-text {
          color: #f5f5f0;
          text-shadow: 
            0 0 10px rgba(59, 130, 246, 0.8),
            0 0 20px rgba(59, 130, 246, 0.6),
            0 0 30px rgba(59, 130, 246, 0.4),
            0 1px 0 rgba(59, 130, 246, 0.3),
            0 2px 0 rgba(50, 120, 230, 0.25),
            0 3px 0 rgba(40, 110, 220, 0.2),
            0 4px 0 rgba(30, 100, 210, 0.15),
            0 5px 0 rgba(20, 90, 200, 0.1),
            0 6px 0 rgba(10, 80, 190, 0.08),
            0 8px 4px rgba(0, 0, 0, 0.6),
            0 12px 8px rgba(0, 0, 0, 0.5),
            0 16px 12px rgba(0, 0, 0, 0.4),
            0 20px 16px rgba(0, 0, 0, 0.3),
            0 24px 20px rgba(0, 0, 0, 0.2),
            0 30px 25px rgba(0, 0, 0, 0.15),
            0 36px 30px rgba(0, 0, 0, 0.1);
        }

        .luminous-card.active .toggle::before {
          background: #3b82f6;
          box-shadow: 0 0 0.4rem 0.3rem rgba(59, 130, 246, 0.6);
        }

        .luminous-card.active .toggle .handle {
          box-shadow: 
            inset 0 1px 12px 0 #fff,
            inset 0 -1px 1px 0 rgba(59, 130, 246, 0.8),
            0 0 2px 1px rgba(68, 68, 68, 0.2),
            1px 3px 6px 1px #0004;
        }

        /* ✅ MOBILE RESPONSIVE */
        @media (max-width: 640px) {
          .book-tab {
            bottom: 10px;
            right: -70px;
            width: 160px;
            height: 50px;
          }

          .book-text {
            font-size: 10px;
          }

          .luminous-card {
            width: 16rem;
            height: 21rem;
          }

          .card-container {
            bottom: 10px;
            right: 10px;
          }
        }

        /* Load Fonts */
        @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=WindSong:wght@400;500&display=swap');
      `}</style>
    </>
  )
}
