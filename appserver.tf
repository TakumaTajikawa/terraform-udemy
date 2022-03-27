# ----------------------------------------
# key pair
# ----------------------------------------

resource "aws_key_pair" "keypair" {
    key_name = "${var.project}-${var.environment}-keypair"
    public_key = file("./src/tastylog-dev-keypair.pub")

    tags = {
        Name = "${var.project}-${var.environment}-keypair"
        Project = var.project
        Env = var.environment
    }
}

# ----------------------------------------
# SSM Parameter Store
# ----------------------------------------
resource "aws_ssm_parameter" "host" {
    name = "/${var.project}/${var.environment}/app/MYSQL_HOST"
    type = "String"
    value = aws_db_instance.mysql_standalone.address
}

resource "aws_ssm_parameter" "port" {
    name = "/${var.project}/${var.environment}/app/MYSQL_PORT"
    type = "String"
    value = aws_db_instance.mysql_standalone.port
}

resource "aws_ssm_parameter" "database" {
    name = "/${var.project}/${var.environment}/app/MYSQL_DATABASE"
    type = "String"
    value = aws_db_instance.mysql_standalone.name
}

resource "aws_ssm_parameter" "username" {
    name = "/${var.project}/${var.environment}/app/MYSQL_USERNAME"
    type = "SecureString"
    value = aws_db_instance.mysql_standalone.username
}

resource "aws_ssm_parameter" "password" {
    name = "/${var.project}/${var.environment}/app/MYSQL_PASSWORD"
    type = "SecureString"
    value = aws_db_instance.mysql_standalone.password
}

# ----------------------------------------
# EC2 Instance
# # ----------------------------------------
# resource "aws_instance" "app_server" {
#     ami = data.aws_ami.app.id
#     instance_type = "t2.micro"
#     subnet_id = aws_subnet.public_subnet_1a.id
#     associate_public_ip_address = true
#     iam_instance_profile = aws_iam_instance_profile.app_ec2_profile.name
#     vpc_security_group_ids = [
#         aws_security_group.app_sg.id,
#         aws_security_group.opmng_sg.id
#     ]
#     key_name = aws_key_pair.keypair.key_name

#     tags = {
#         Name = "${var.project}-${var.environment}-app-ec2"
#         Project = var.project
#         Env = var.environment
#         Type = "app"
#     }
# }


# ----------------------------------------
# launch template
# ----------------------------------------
resource "aws_launch_template" "app_lt" {
    # デフォルトバージョンを自動更新するか
    update_default_version = true

    # 起動テンプレート名
    name = "${var.project}-${var.environment}-app-lt"

    # マシンイメージ名
    image_id = data.aws_ami.app.id

    # キーペア名
    key_name = aws_key_pair.keypair.key_name

    # 起動されるインスタンスに付与するタグ
    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "${var.project}-${var.environment}-app-ec2"
            Project = var.project
            Env = var.environment
            Type = "app"
        }
    }

    # ネットワーク設定
    network_interfaces {
        # パブリックIPを使えるようにする
        associate_public_ip_address = true
        security_groups = [
            aws_security_group.app_sg.id,
            aws_security_group.opmng_sg.id
        ]

        # EC2が落ちた時にネットワークのリソースも合わせて削除するか
        delete_on_termination = true
    }

    # IAMロール
    iam_instance_profile {
        name = aws_iam_instance_profile.app_ec2_profile.name
    }

    user_data = filebase64("./src/initialize.sh")
}

# ----------------------------------------
# auto scaling group
# ----------------------------------------
resource "aws_autoscaling_group" "app_asg" {
    # オートスケーリンググループ名
    name = "${var.project}-${var.environment}-app-asg"

    # 最大インスタンス数
    max_size = 1

    # 最小インスタンス数
    min_size = 1

    # 希望するインスタンス数
    desired_capacity = 1

    # 指定した時間以降にヘルスチェックを開始(秒)
    health_check_grace_period = 300
    # "EC2", "ELB"のいずれかを記述
    health_check_type = "ELB"

    # サブネット
    vpc_zone_identifier = [
        aws_subnet.public_subnet_1a.id,
        aws_subnet.public_subnet_1c.id,
    ]

    # ELBのターゲットグループARN
    target_group_arns = [aws_lb_target_group.alb_target_group.arn]

    # ユーザーデータ
    mixed_instances_policy {
        launch_template {
            launch_template_specification {
                launch_template_id = aws_launch_template.app_lt.id
                version = "$Latest"
            }
            override {
                instance_type = "t2.micro"
            }
        }
    }
}