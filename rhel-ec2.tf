resource "aws_instance" "sinatra" {
    ami = "ami-0a443decce6d88dc2"
    instance_type = "t2.micro"
    security_groups = [ aws_security_group.sinatra-sg.name ]
    associate_public_ip_address = true
    key_name = aws_key_pair.sinatra-kp.key_name
    tags = {
        Name = "sinatra"
    }
}

resource "aws_security_group" "sinatra-sg" {
    name = "sinatra-sg"
    description = "custom security group to allow inbound ssh and http connections"
    ingress = [ 
        {
            description = "ssh connection"
            cidr_blocks = [ "0.0.0.0/0" ]
            ipv6_cidr_blocks = [ "::/0" ]
            protocol = "tcp"
            from_port = 22
            to_port = 22
            prefix_list_ids = []
            security_groups = []
            self = false
        },
        {
            description = "http connection"
            cidr_blocks = [ "0.0.0.0/0" ]
            ipv6_cidr_blocks = [ "::/0" ]
            protocol = "tcp"
            from_port = 80
            to_port = 80
            prefix_list_ids = []
            security_groups = []
            self = false
        }
    ]

    egress = [ 
        {
            description = "Allow all outbound connections"
            cidr_blocks = [ "0.0.0.0/0" ]
            ipv6_cidr_blocks = [ "::/0" ]
            protocol = "-1"
            from_port = 0
            to_port = 0
            security_groups = []
            prefix_list_ids = []
            self = false
        } 
    ]
    tags = {
        Name = "sinatra"
    }
}

resource "aws_key_pair" "sinatra-kp" {
    key_name = "sinatra-key-pair"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/iuVgsYBczifjL4yfBPuncHjaLe60E1um+NoFHYZR8AYMmkEbmDRo1ukdBEuk9kzyFTlBTBzRCPm5YbKTexKZwvf3h6jN1dvNZfYZPTayA+Aw++5DtDsACeSacozewOMamETciCu/74j7HIANTsLzb6L352TfRtpzY+TJcTo1XYI4jxk0AyNJtRgwlxXuWweQYKa0TfzGgCjlbH2KdJRHBlaSPG7Wo5IGNNvAIhjW0bDuR0om2kDaw1lvURa5V5uoAr7jDBfdjof6wl2XTDnuiJArsLKtoMckUtNIiqWsK0zG2EsFA4KS80EiYXemIq6OPh76U2Jvs7ro9FWgnjhAWYiQCd2kl5sFn7wJy8z6nSpPRbFktO6koQlOkXRPvA34DHomSkdXhcdlU4+i95ZYDDf62w1UJ8HNEIjG065AT+AK6UPiMGrdIWget3dBzODW6xkBNZa4+JGIjzRpl/zNVXQsR44Mau5iIyYTIOmbGRn2yNY2jWyumYoroeS6MV8= tspai@Tejas-LAB-PC"
    tags = {
      "Name" = "sinatra"
    }
}