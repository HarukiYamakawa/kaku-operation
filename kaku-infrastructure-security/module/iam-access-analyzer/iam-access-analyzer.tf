resource "aws_accessanalyzer_analyzer" "default" {
  analyzer_name = "${var.name_prefix}-iam-access-analyzer"
}