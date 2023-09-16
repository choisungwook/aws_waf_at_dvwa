vpc_cidr = "192.168.0.0/16"

public-subnets = {
  public-a = {
    az   = "ap-northeast-2a",
    cidr = "192.168.1.0/24"
    tags = {
      Name = "public-subnet-a"
    }
  }
}
