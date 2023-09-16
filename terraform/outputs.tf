output "aws_elb_dns" {
  description = "aws elb dns address"
  value = aws_lb.dvwa.dns_name
}
