resource "aws_lb" "main" {
  name            = var.name
  subnets         = var.subnet_ids
  security_groups = var.security_group_ids
  internal        = var.internal

  load_balancer_type = "application"

  
}

resource "aws_lb_target_group" "site" {
  name     = "${var.name}-site"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "api" {
  name     = "${var.name}-api"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}


resource "aws_lb_target_group_attachment" "site" {
  for_each = {
  for index, id in var.instance_ids : index => id
}

  target_group_arn = aws_lb_target_group.site.arn
  target_id        = each.value
  port             = 80

  
  

}

resource "aws_lb_target_group_attachment" "api" {
  for_each = {
  for index, id in var.instance_ids : index => id
}

  target_group_arn = aws_lb_target_group.api.arn
  target_id        = each.value
  port             = 3000

}


resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.site.arn
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100


  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

}