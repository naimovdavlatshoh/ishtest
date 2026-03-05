"""
User tests
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_register_user():
    """Test user registration"""
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "test@example.com",
            "phone": "+998 90 123 45 67",
            "first_name": "Test",
            "last_name": "User",
            "password": "testpass123"
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "id" in data


def test_login_user():
    """Test user login"""
    # First register
    client.post(
        "/api/v1/auth/register",
        json={
            "email": "login@example.com",
            "phone": "+998 90 123 45 68",
            "first_name": "Login",
            "last_name": "Test",
            "password": "testpass123"
        }
    )
    
    # Then login
    response = client.post(
        "/api/v1/auth/login",
        json={
            "phone": "+998 90 123 45 68",
            "password": "testpass123"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"
