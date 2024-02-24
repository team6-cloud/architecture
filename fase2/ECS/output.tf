output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_arn" {
  value = aws_lb.app-alb.arn
}

output "alb_dns" {
  value = aws_lb.app-alb.dns_name
}
