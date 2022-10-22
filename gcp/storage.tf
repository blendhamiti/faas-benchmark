resource "google_storage_bucket" "profile_image_bucket" {
  name     = "blend-thesis-profile-image-bucket"
  location = "US"

  labels = {
    "name" = "functions-bucket"
  }
}

resource "google_storage_bucket" "thumbnail_bucket" {
  name     = "blend-thesis-thumbnail-bucket"
  location = "US"

  labels = {
    "name" = "thumbnail-bucket"
  }
}