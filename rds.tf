# ----------------------------------------
# RDS parameter group
# ----------------------------------------
resource "aws_db_parameter_group" "mysql_standalone_parametergroup" {
    name = "${var.project}-${var.environment}-mysql-standalone-parametergroup"
    family = "mysql8.0"

    parameter {
        name = "character_set_database"
        value = "utf8mb4"
    }

    parameter {
        name = "character_set_server"
        value = "utf8mb4"
    }
}


# ----------------------------------------
# RDS option group
# ----------------------------------------
resource "aws_db_option_group" "mysql_standalone_optiongroup" {
    name = "${var.project}-${var.environment}-mysql-standalone-optiongroup"
    engine_name = "mysql"
    major_engine_version = "8.0"
}


# ----------------------------------------
# RDS subnet group
# ----------------------------------------
resource "aws_db_subnet_group" "mysql_standalone_subnetgroup" {
    name = "${var.project}-${var.environment}-mysql-standalone-subnetgroup"
    subnet_ids = [
        aws_subnet.private_subnet_1a.id,
        aws_subnet.private_subnet_1c.id
    ]

    tags = {
        Name = "${var.project}-${var.environment}-mysql-standalone-subnetgroup"
        Project = var.project
        Env = var.environment
    }
}


# ----------------------------------------
# RDS instance
# ----------------------------------------
resource "random_string" "db_password" {
    length = 16
    special = false
}

resource "aws_db_instance" "mysql_standalone" {
    engine = "mysql"
    engine_version = "8.0.20"

    # RDSを識別する名前
    identifier = "${var.project}-${var.environment}-mysql-standalone"

    username = "admin"
    password = random_string.db_password.result

    instance_class = "db.t2.micro"

    # ストレージ（単位：GB)
    allocated_storage = 20

    # 最大拡張ストレージ（単位：GB)
    max_allocated_storage = 50

    storage_type = "gp2"

    # 暗号化を行うか
    storage_encrypted = false

    multi_az = false
    availability_zone = "ap-northeast-1a"
    db_subnet_group_name = aws_db_subnet_group.mysql_standalone_subnetgroup.name

    vpc_security_group_ids = [ aws_security_group.db_sg.id ]

    # インスタンスがパブリックにアクセス可能かどうかを制御する真偽値
    publicly_accessible = false
    port = 3306

    name = "tastylog"
    parameter_group_name = aws_db_parameter_group.mysql_standalone_parametergroup.name
    option_group_name = aws_db_option_group.mysql_standalone_optiongroup.name

    # バックアップを行う時間帯
    backup_window = "04:00-05:00"

    # 過去何日分をバックアップするか
    backup_retention_period = 7

    # メンテナンス（アップグレード含む）を行う時間
    maintenance_window = "Mon:05:00-Mon:08:00"
    # 自動的にマイナーバージョンをアップグレードするか
    auto_minor_version_upgrade = false

    # 自動で削除させないか
    deletion_protection = false

    # 削除時のスナップショットをスキップするか
    skip_final_snapshot = true

    # 即時反映するか
    apply_immediately = true
    
    tags = {
        Name = "${var.project}-${var.environment}-mysql-standalone"
        Project = var.project
        Env = var.environment
    }
}
