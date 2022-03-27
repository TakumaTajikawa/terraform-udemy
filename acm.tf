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

resource "aws_route53_record" "route53_acm_dns_resolve" {
    for_each = {
        for dvo in aws_acm_certificate.tokyo_cert.domain_validation_options : dvo.domain_name => {
            name = dvo.resource_record_name
            type = dvo.resource_record_type
            record = dvo.resource_record_value
        }
    }

    allow_overwrite = true
    zone_id = aws_route53_zone.route53_zone.id
    name = each.value.name
    type = each.value.type
    ttl = 600
    records = [ each.value.record ]
}

resource "aws_acm_certificate_validation" "cert_valid" {
    # ACM証明書ARN
    certificate_arn = aws_acm_certificate.tokyo_cert.arn

    # DNS検証に利用するFQDN(ドメイン名 + ホスト名)
    validation_record_fqdns = [ for record in aws_route53_record.route53_acm_dns_resolve : record.fqdn ]
}

# for virginia region
resource "aws_acm_certificate" "virginia_cert" {
    provider = aws.virginia

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


