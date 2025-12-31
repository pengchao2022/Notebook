# terrafrom 中 查询现有资源

1, 使用 data source , data source 是允许 terrafrom 读取 但不管理已存在的资源信息

data "resource_type" "local_name" {
    # 查询条件
    filter_attribute = "value"
}

# 输出使用
output "existing_resouce_info" {
    value = data.resource_type.local_name.attribute
}

2, 查询 aws 资源

# 查询现有 vpc 
data "aws_vpc" "selected" {
    filter{
        name = "tag:Name"
        values = ["production-vpc"]

    }
}

# 查询现有子网
data "aws_subnet" "selected" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.selected.id]
    }
    filter {
        name = "tag:Name"
        values = ["public-subnet-1"]
    }
}

# 查询现有AMI (amazon machine image)
data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

3. 在现有 vpc 中创建资源

# 查询现有VPC 
data "aws_vpc" "main" {
    tags = {
        Environment = "production"
    }

}

# 查询现有子网
data "aws_subnets" "private" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.main.id]
    }

    tags = {
        Tier = "private"
    }
}

# 在查询到的资源中创建新的实例
resource "aws_instance" "app_server" {
    # 使用查询到的子网
    subnet_id = data.aws_subnets.private.ids[0]

    # 使用查询到的VPC 安全组
    vpc_security_group_ids = [data.aws_vpc.main.default_security_group_id]

    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t3.micro"

    tags = {
        Name = "app-server-in_existing-vpc"
    }
}

# 输出查询结构
output "vpc_id" {
    value = data.aws_vpc.main.id
}

output "available_subnets" {
    value = data.aws_subnets.private.ids
}


# 查询现有资源并引用
data "aws_db_instance" "production" {
    db_instance_identifier = "prod-database"
}

# 在新应用中引用现有数据库
resource "aws_ecs_task_definition" "app" {
    family = "app-task"

    container_definition = jsonencode([{
        name = "app"
        image = "myapp:latest"
        environment = [
            {
                name = "DATABASE_HOST"
                # 使用查询到的地址
                value = data.aws_db_instance.production.address
            },
            {
                name = "DATABASE_PORT"
                value = data.aws_db_instance.production.port
            }
        ]
    }])
}

