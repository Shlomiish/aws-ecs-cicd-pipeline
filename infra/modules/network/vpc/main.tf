# resource "aws_vpc" "this" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_support   = var.enable_dns_support #resolve external hostname to their ip
#   enable_dns_hostnames = var.enable_dns_hostnames #resolve internal hostname (inside the vpc) to their ip

#   tags = {
#     Name = "${var.name}-vpc"
#   }
# }

# resource "aws_internet_gateway" "this" { 
#   vpc_id = aws_vpc.this.id

#   tags = {
#     Name = "${var.name}-igw"
#   }
# }

# resource "aws_subnet" "public" {
#   count                   = length(var.azs)
#   vpc_id                  = aws_vpc.this.id
#   availability_zone       = var.azs[count.index]
#   cidr_block              = var.public_subnet_cidrs[count.index]
#   map_public_ip_on_launch = var.map_public_ip_on_launch

#   tags = {
#     Name = "${var.name}-public-${var.azs[count.index]}"
#   }
# }

# resource "aws_subnet" "private" {
#   count             = length(var.azs)
#   vpc_id            = aws_vpc.this.id
#   availability_zone = var.azs[count.index]
#   cidr_block        = var.private_subnet_cidrs[count.index]

#   tags = {
#     Name = "${var.name}-private-${var.azs[count.index]}"
#   }
# }

# # Route table for public subnets with direct internet access via IGW
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.this.id

#   tags = {
#     Name = "${var.name}-public-rt"
#   }
# }

# resource "aws_route" "public_internet" {
#   route_table_id         = aws_route_table.public.id
#   destination_cidr_block = var.internet_cidr
#   gateway_id             = aws_internet_gateway.this.id
# }

# resource "aws_route_table_association" "public" {
#   count          = length(var.azs)
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }


# resource "aws_eip" "nat" {
#   domain = "vpc"

#   tags = {
#     Name = "${var.name}-nat-eip"
#   }
# }

# resource "aws_nat_gateway" "this" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public[0].id

#   tags = {
#     Name = "${var.name}-nat"
#   }

#   depends_on = [aws_internet_gateway.this]
# }

# # Private route table -> NAT
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.this.id

#   tags = {
#     Name = "${var.name}-private-rt"
#   }
# }

# resource "aws_route" "private_internet" {
#   route_table_id         = aws_route_table.private.id
#   destination_cidr_block = var.internet_cidr
#   nat_gateway_id         = aws_nat_gateway.this.id
# }

# resource "aws_route_table_association" "private" {
#   count          = length(var.azs)
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private.id
# }


# ------ VPC CORE CONFIGURATION ------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support #resolve external hostname to their ip
  enable_dns_hostnames = var.enable_dns_hostnames #resolve internal hostname (inside the vpc) to their ip

  tags = {
    Name = "${var.name}-vpc"
  }
}

# ------ INTERNET CONNECTIVITY (IGW) ------

resource "aws_internet_gateway" "this" { 
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

# ------ PUBLIC SUBNETS (PER AZ) ------

resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.azs[count.index]
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.name}-public-${var.azs[count.index]}"
  }
}

# ------ PRIVATE SUBNETS (PER AZ) ------

resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.this.id
  availability_zone = var.azs[count.index]
  cidr_block        = var.private_subnet_cidrs[count.index]

  tags = {
    Name = "${var.name}-private-${var.azs[count.index]}"
  }
}

# ------ PUBLIC ROUTING (IGW) ------

# Route table for public subnets with direct internet access via IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.internet_cidr
  gateway_id             = aws_internet_gateway.this.id
}


# ------ NAT GATEWAY (OUTBOUND ACCESS FOR PRIVATE SUBNETS) ------

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

# ------ PRIVATE ROUTING (VIA NAT) ------

# Route table for private subnets with access to the internet via NAT gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-private-rt"
  }
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.internet_cidr
  nat_gateway_id         = aws_nat_gateway.this.id
  
}


# ------ ROUTE TABLE - SUBNET ASSOCIATIONS ------


resource "aws_route_table_association" "private" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}