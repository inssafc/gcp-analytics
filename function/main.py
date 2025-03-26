import functions_framework
import requests
import csv
import io
from google.cloud import storage
import tempfile

@functions_framework.http
def fetch_store_data(request):
    """HTTP Cloud Function :  retrieves product data from 
    the Fake Store API and stores it in a structured format in Google 
    Cloud Storage.  
    """

        
    response = requests.get('https://fakestoreapi.com/products')
    json_data = response.json()
    keys_list = list(json_data[0].keys())
    

    with tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix='.csv') as temp_file:
        writer = csv.writer(temp_file)
        writer.writerow(keys_list)
        
        for item in json_data:
            writer.writerow([item.get(key, '') for key in keys_list])
            
        temp_file_name = temp_file.name
    

    bucket_name = "products-data"
    destination_blob_name = "products.csv"
    
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    
  
    blob.upload_from_filename(temp_file_name)
    
    return f'Successfully uploaded gs://{bucket_name}/{destination_blob_name}', 200
    
