"""
Formatting utilities
"""
import re


def format_phone_number(phone: str) -> str:
    """
    Format phone number to +998 XX XXX XX XX
    """
    # Remove all non-digit characters
    cleaned = re.sub(r'\D', '', phone)
    
    # If starts with 998, format it
    if cleaned.startswith('998') and len(cleaned) == 12:
        return f"+998 {cleaned[3:5]} {cleaned[5:8]} {cleaned[8:10]} {cleaned[10:12]}"
    
    # If starts with 9 and has 9 digits, add 998
    if cleaned.startswith('9') and len(cleaned) == 9:
        return f"+998 {cleaned[0:2]} {cleaned[2:5]} {cleaned[5:7]} {cleaned[7:9]}"
    
    return phone


def validate_phone_number(phone: str) -> bool:
    """
    Validate Uzbek phone number
    """
    cleaned = re.sub(r'\D', '', phone)
    return len(cleaned) == 12 and cleaned.startswith('998') or len(cleaned) == 9 and cleaned.startswith('9')
