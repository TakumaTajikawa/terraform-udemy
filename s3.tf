resource "random_string" "s3_unique_key" {
    length = 6
    upper = false
    lower = true
    number = true
    special = false
}

# ----------------------------------------
# S3 static bucket
# ----------------------------------------
resource "aws_s3_bucket" "s3_static_bucket" {
    # バケット名
    bucket = "${var.project}-${var.environment}-static-bucket-${random_string.s3_unique_key.result}"

    # バージョニング(同じバケット内でオブジェクトの複数のバリアントを保持する手段のこと)設定
    versioning {
        # 有効化するか
        enabled = false
    }
}

resource "aws_s3_bucket_public_access_block" "s3_static_bucket" {
    # バケット名
    bucket = aws_s3_bucket.s3_static_bucket.id

    # 新しいACL設定をブロック
    # （ACLとは：アクセスコントロールリスト、「被付与者」に「バケット・オブジェクト」への「アクセス」を許可するもの）
    block_public_acls = true

    # 新しいバケットポリシーをブロック
    block_public_policy = true

    # 公開ACL設定を無視するか
    ignore_public_acls = true

    # 所有者とAWSサービスのみにアクセス制限
    restrict_public_buckets = false
    depends_on = [
        aws_s3_bucket_policy.s3_static_bucket
    ]
}

resource "aws_s3_bucket_policy" "s3_static_bucket" {
    bucket = aws_s3_bucket.s3_static_bucket.id
    policy = data.aws_iam_policy_document.s3_static_bucket.json
}

data "aws_iam_policy_document" "s3_static_bucket" {
    statement {
        # ステートメントの結果を許可または明示的な拒否のどちらにするかを指定
        # (Allow：許可、Deny：拒否)
        effect = "Allow"

        # アクションリスト
        actions = [ "s3:GetObject" ]
        
        # 処理対象のリソース
        resources = [ "${aws_s3_bucket.s3_static_bucket.arn}/*" ]

        # 関連付けるエンティティ
        principals {
            # "AWS", "Service"など
            type = "*"

            # ARN, サービスURLなど
            identifiers =  [ "*" ]
        }
    }
}