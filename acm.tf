# ----------------------------------------
# Cerfitificate
# ----------------------------------------
# for tokyo region
resource "aws_acm_certificate" "tokyo_cert" {
    # ドメイン名
    domain_name = "*.${var.domain}"

    # "DNS", "EMAIL", "NONE"のいずれかを記入
    validation_method = "DNS"

    tags = {
        Name = "${var.project}-${var.environment}-wildcard-sslcert"
        Project = var.project
        Env = var.environment
    }

    # リソース操作の詳細制御を指定
    lifecycle {
        # 削除前に生成を行うか
        create_before_destroy = true
    }

    # Route53との依存関係を定義
    depends_on = [
        aws_route53_zone.route53_zone
    ]
}