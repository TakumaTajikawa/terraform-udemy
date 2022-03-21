# ----------------------------------------
# IAM Role
# ----------------------------------------

# EC2インスタンスとIAMロールを結びつける箱
resource "aws_iam_instance_profile" "app_ec2_profile" {
    # インスタンスプロフィール名（IAMロール名と一致させるのがオススメ。異なるとわかりずらい。）
    name = aws_iam_role.app_iam_role.name

    # IAMロール
    role = aws_iam_role.app_iam_role.name
}

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

resource "aws_iam_role_policy_attachment" "app_iam_role_ec2_readonly" {
    role = aws_iam_role.app_iam_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# Session Managerの許可
resource "aws_iam_role_policy_attachment" "app_iam_role_ssm_managed" {
    role = aws_iam_role.app_iam_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_iam_role_ssm_readonly" {
    role = aws_iam_role.app_iam_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "app_iam_role_s3_readonly" {
    role = aws_iam_role.app_iam_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
