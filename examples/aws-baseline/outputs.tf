output "cloudtrail_arn" {
  value = module.cloudtrail.trail_arn
}

output "cloudtrail_bucket" {
  value = module.cloudtrail.bucket_name
}

output "guardduty_detector_id" {
  value = module.guardduty.detector_id
}

output "logs_kms_key_arn" {
  value = module.logs_key.key_arn
}
