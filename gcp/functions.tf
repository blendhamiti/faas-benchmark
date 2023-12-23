resource "google_storage_bucket" "functions_bucket" {
  name     = "blend-thesis-functions-bucket"
  location = "US"

  labels = {
    "name" = "functions-bucket"
  }
}

data "archive_file" "function_create_user" {
  type = "zip"

  source_dir  = "${path.module}/functions/createUser"
  output_path = "${path.module}/functions/createUser.zip"
}

data "archive_file" "function_process_image" {
  type = "zip"

  source_dir  = "${path.module}/functions/processImage"
  output_path = "${path.module}/functions/processImage.zip"
}

resource "google_storage_bucket_object" "function_create_user" {
  name   = "createUser-${data.archive_file.function_create_user.output_md5}.zip"
  bucket = google_storage_bucket.functions_bucket.name
  source = data.archive_file.function_create_user.output_path


}

resource "google_storage_bucket_object" "function_process_image" {
  name   = "processImage-${data.archive_file.function_process_image.output_md5}.zip"
  bucket = google_storage_bucket.functions_bucket.name
  source = data.archive_file.function_process_image.output_path
}

resource "google_cloudfunctions_function" "create_user" {
  name        = "createUser"
  description = "Create user"
  runtime     = "nodejs16"

  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.functions_bucket.name
  source_archive_object = google_storage_bucket_object.function_create_user.name
  trigger_http          = true
  timeout               = 60
  entry_point           = "createUser"

  environment_variables = {
    "PROFILE_IMAGE_BUCKET" = google_storage_bucket.profile_image_bucket.name
    "DB_HOST"              = google_sql_database_instance.instance.public_ip_address
    "DB_NAME"              = "seeu_db"
    "DB_USER"              = google_sql_user.db_user.name
    "DB_PASSWORD"          = google_sql_user.db_user.password
  }
}

resource "google_cloudfunctions_function" "process_image" {
  name        = "processImage"
  description = "Process image"
  runtime     = "nodejs16"

  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.functions_bucket.name
  source_archive_object = google_storage_bucket_object.function_process_image.name
  timeout               = 60
  entry_point           = "processImage"

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.profile_image_bucket.name
  }

  environment_variables = {
    "THUMBNAIL_BUCKET" = google_storage_bucket.thumbnail_bucket.name
  }
}

resource "google_cloudfunctions_function_iam_member" "function_create_user_invoker" {
  project        = google_cloudfunctions_function.create_user.project
  region         = google_cloudfunctions_function.create_user.region
  cloud_function = google_cloudfunctions_function.create_user.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "function_process_image_invoker" {
  project        = google_cloudfunctions_function.process_image.project
  region         = google_cloudfunctions_function.process_image.region
  cloud_function = google_cloudfunctions_function.process_image.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}