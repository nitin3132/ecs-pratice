import pytest
from app import app


@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_home(client):
    """Test the home endpoint"""
    response = client.get('/')
    assert response.status_code == 200
    assert response.data == b"Hello from ECS behind ALB!\n"


def test_api(client):
    """Test the API endpoint"""
    response = client.get('/api')
    assert response.status_code == 200
    data = response.get_json()
    assert data['service'] == 'demo'
    assert 'env' in data


def test_api_with_env(client):
    """Test API endpoint with custom ENV"""
    response = client.get('/api')
    assert response.status_code == 200
    data = response.get_json()
    assert data['service'] == 'demo'
    # Default should be 'dev' if ENV is not set
    assert data['env'] == 'dev'


def test_health(client):
    """Test the health check endpoint"""
    response = client.get('/health')
    assert response.status_code == 200
    assert response.data == b"ok\n"


def test_invalid_route(client):
    """Test accessing non-existent route"""
    response = client.get('/nonexistent')
    assert response.status_code == 404
