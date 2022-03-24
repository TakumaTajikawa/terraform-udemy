data "aws_prefix_list" "s3_pl" {
    name = "com.amazonaws.*.s3"
}

data "aws_ami" "app" {
    # 最も最新のものを取得するか
    most_recent = true

    owners = ["self", "amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-2.0.*-x86_64-gp2"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}
