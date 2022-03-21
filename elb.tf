# ----------------------------------------
# ALB
# ----------------------------------------
resource "aws_lb" "alb" {
    name = "${var.project}-${var.environment}-app-alb"

    # 内部向けLBかどうか
    internal = false

    # "application", "network", "gateway"のいずれかを記述
    load_balancer_type = "application"
    security_groups = [
        aws_security_group.web_sg.id
    ]
    subnets = [
        aws_subnet.public_subnet_1a.id,
        aws_subnet.public_subnet_1c.id,
    ]
}