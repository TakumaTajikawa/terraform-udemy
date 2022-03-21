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