data "aws_iam_policy_document" "ec2_assume_role" {
    statement {
        actions = ["sts:AssumeRole"]

        principals {
            type = "service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }

}