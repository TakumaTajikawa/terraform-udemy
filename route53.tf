# ----------------------------------------
# Route53
# ----------------------------------------
resource "aws_route53_zone" "route53_zone" {
    name = var.domain

    # ゾーンを削除する際にレコードも削除するか
    force_destroy = false

    tags = {
        Name = "${var.project}-${var.environment}-domain"
        Project = var.project
        Env = var.environment
    }
}

resource "aws_route53_record" "route53_record" {
    zone_id = aws_route53_zone.route53_zone.id
    name = "dev-elb.${var.domain}"

    # レコードタイプ("A", "CNAME"など)
    type = "A"

    # トラフィックルーティング先
    alias {
        # DNSドメイン名
        name = aws_lb.alb.dns_name

        # ホストゾーンID
        zone_id = aws_lb.alb.zone_id

        # ヘルスチェックするか
        evaluate_target_health = true
    }
}
