"""
Session Utilities
Helper functions for working with sessions and requests
"""

from typing import Optional
from fastapi import Request


def get_session_id_from_request(request: Request) -> Optional[str]:
    """
    Extract session ID from request (cookie or header)
    
    Priority:
    1. X-Session-ID header
    2. session_id cookie
    
    Args:
        request: FastAPI Request object
        
    Returns:
        Session ID string or None
    """
    # Try header first
    session_id = request.headers.get("X-Session-ID")
    if session_id:
        return session_id
    
    # Try cookie
    session_id = request.cookies.get("session_id")
    if session_id:
        return session_id
    
    return None


def get_client_ip(request: Request) -> Optional[str]:
    """
    Extract client IP address from request
    
    Checks X-Forwarded-For header first (for proxies),
    then falls back to client host
    
    Args:
        request: FastAPI Request object
        
    Returns:
        IP address string or None
    """
    # Check for proxy headers
    forwarded_for = request.headers.get("X-Forwarded-For")
    if forwarded_for:
        # X-Forwarded-For can contain multiple IPs, take the first one
        return forwarded_for.split(",")[0].strip()
    
    # Fall back to direct connection
    if request.client:
        return request.client.host
    
    return None


def get_user_agent(request: Request) -> Optional[str]:
    """
    Extract user agent from request
    
    Args:
        request: FastAPI Request object
        
    Returns:
        User agent string or None
    """
    return request.headers.get("User-Agent")
