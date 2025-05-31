#!/usr/bin/env python3
"""
Simple test script for the Flask application
"""

import requests
import sys
import time

def test_flask_app(url="http://localhost:5000"):
    """Test the Flask application endpoint"""
    try:
        print(f"🧪 Testing Flask app at {url}")
        
        # Make request to the app
        response = requests.get(url, timeout=10)
        
        # Check status code
        if response.status_code == 200:
            print(f"✅ Status Code: {response.status_code}")
        else:
            print(f"❌ Status Code: {response.status_code}")
            return False
        
        # Check response content
        expected_text = "Hello from your containerized Flask app!"
        if expected_text in response.text:
            print(f"✅ Response Content: {response.text.strip()}")
            return True
        else:
            print(f"❌ Unexpected response: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print(f"❌ Connection failed to {url}")
        return False
    except requests.exceptions.Timeout:
        print(f"❌ Request timeout to {url}")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    """Main test function"""
    print("🚀 Starting Flask App Tests")
    print("=" * 50)
    
    # Test local Flask app
    success = test_flask_app()
    
    if success:
        print("\n🎉 All tests passed!")
        sys.exit(0)
    else:
        print("\n💥 Tests failed!")
        sys.exit(1)

if __name__ == "__main__":
    main() 