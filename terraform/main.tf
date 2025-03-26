terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.34.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "product_data_bucket" {
  name                        = "${var.project_id}-products-data"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "function_source_bucket" {
  name                        = "${var.project_id}-function-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "function_source" {
  type        = "zip"
  output_path = "/tmp/function-source.zip"
  source_dir  = "${path.module}/../function"
}

resource "google_storage_bucket_object" "function_source_object" {
  name   = "function-source-${data.archive_file.function_source.output_md5}.zip"
  bucket = google_storage_bucket.function_source_bucket.name
  source = data.archive_file.function_source.output_path
}

resource "google_cloudfunctions2_function" "data_ingestion_function" {
  name        = "data-ingestion"
  location    = var.region
  description = "Fetches data from Fake Store API and stores it in GCS"

  build_config {
    runtime     = "python311"
    entry_point = "fetch_store_data"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source_bucket.name
        object = google_storage_bucket_object.function_source_object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      BUCKET_NAME = google_storage_bucket.product_data_bucket.name
    }
  }
}


resource "google_cloud_run_service_iam_member" "public_invoker" {
  location = google_cloudfunctions2_function.data_ingestion_function.location
  service  = google_cloudfunctions2_function.data_ingestion_function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}


output "function_url" {
  value = google_cloudfunctions2_function.data_ingestion_function.service_config[0].uri
}