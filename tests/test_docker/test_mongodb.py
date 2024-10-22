#!/usr/bin/env python3
# test_mongodb.py

import os
from pymongo import MongoClient
from datetime import datetime
import sys
import time

def test_mongodb():
    """Test MongoDB connection and basic operations"""
    mongodb_host = os.getenv('MONGODB_HOST')
    max_attempts = 30
    attempt = 1
    
    print(f"\n🔄 Testing MongoDB connection to {mongodb_host}")
    
    while attempt <= max_attempts:
        try:
            # Create client with short timeout for faster retry
            client = MongoClient(mongodb_host, serverSelectionTimeoutMS=2000)
            
            # Test connection by listing databases
            print(f"\nAttempt {attempt}: Trying to connect...")
            client.admin.command('ping')
            
            # If we get here, connection successful
            print("✅ Successfully connected to MongoDB")
            
            # Test basic operations
            print("\nTesting basic operations...")
            db = client.test_database
            collection = db.test_collection
            
            # Insert
            test_doc = {
                "test_id": "connection_test",
                "timestamp": datetime.utcnow(),
                "status": "testing"
            }
            result = collection.insert_one(test_doc)
            print(f"✅ Insert successful: {result.inserted_id}")
            
            # Find
            found = collection.find_one({"test_id": "connection_test"})
            if found:
                print("✅ Find operation successful")
            
            # Delete
            delete_result = collection.delete_one({"test_id": "connection_test"})
            if delete_result.deleted_count == 1:
                print("✅ Delete operation successful")
            
            print("\n✅ All MongoDB tests passed successfully!")
            return True
            
        except Exception as e:
            if attempt == max_attempts:
                print(f"\n❌ Failed to connect to MongoDB after {max_attempts} attempts")
                print(f"Error: {str(e)}")
                print("\nDebug information:")
                print(f"MongoDB Host: {mongodb_host}")
                print(f"Current attempt: {attempt}/{max_attempts}")
                return False
            
            print(f"Attempt {attempt}: Connection failed, retrying...")
            attempt += 1
            time.sleep(2)

if __name__ == "__main__":
    success = test_mongodb()
    sys.exit(0 if success else 1)