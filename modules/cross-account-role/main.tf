
data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "cdp-cross-account-policy" {
  name = "${var.PREFIX}cdp-cross-account-policy"
  path = "/"
  description = "Policy required for CDP provisioning"

  policy = file("${path.module}/json_for_policies/cross_account_policy.json")
}


resource "aws_iam_role" "cdp-cross-account-role" {
  name = "${var.PREFIX}cdp-cross-account-role"
  description = "CDP management role"
  assume_role_policy = file("${path.module}/json_for_policies/cross_account_role.json")
}

resource "aws_iam_role_policy_attachment" "cdp" {
  role = aws_iam_role.cdp-cross-account-role.name
  policy_arn = aws_iam_policy.cdp-cross-account-policy.arn
}

output "arn" {
  value = aws_iam_role.cdp-cross-account-role.arn
}
