#############################################
# ECR Repositories for Application Images
#############################################

resource "aws_ecr_repository" "vote" {
  name         = "${var.cluster_name}/vote"
  force_delete = var.ecr_force_delete

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "result" {
  name         = "${var.cluster_name}/result"
  force_delete = var.ecr_force_delete

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "worker" {
  name         = "${var.cluster_name}/worker"
  force_delete = var.ecr_force_delete

  image_scanning_configuration {
    scan_on_push = true
  }
}
