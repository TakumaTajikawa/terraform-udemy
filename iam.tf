# ----------------------------------------
# IAM Role
# ----------------------------------------
resource "aws_iam_role" "app_iam_role" {
    # IAMロール名
    name ="${var.project}-${var.environment}-app-iam-role"

    # 信頼ポリシーJSON
    assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
    statement {
        # アクションリスト
        actions = ["sts:AssumeRole"]

        # 関連づけるエンティティ（実態）
        principals {
            # AWS、Serviceなど
            type = "Service"

            # ARN、サービスURLなど
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}