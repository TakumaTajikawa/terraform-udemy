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