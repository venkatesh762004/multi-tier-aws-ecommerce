
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main["app_1a"].id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx

    systemctl enable nginx
    systemctl start nginx

    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
      <title>Multi-Tier E-Commerce</title>
    </head>
    <body>
      <h1>Welcome to AWS E-Commerce Application</h1>
      <p>Frontend deployed successfully using Terraform!</p>
    </body>
    </html>
    HTML
  EOF

  tags = {
    Name = "ecommerce-frontend"
    Tier = "Frontend"
  }
}

resource "aws_instance" "backend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main["app_1a"].id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y python3

    mkdir -p /opt/ecommerce

    cat > /opt/ecommerce/app.py <<'PYTHON'
    from http.server import BaseHTTPRequestHandler, HTTPServer
    import json

    class APIHandler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == "/api/products":
                products = [
                    {"id": 1, "name": "Laptop", "price": 55000},
                    {"id": 2, "name": "Headphones", "price": 2000}
                ]

                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps(products).encode())
            else:
                self.send_response(404)
                self.end_headers()

    HTTPServer(("0.0.0.0", 5000), APIHandler).serve_forever()
    PYTHON

    cat > /etc/systemd/system/ecommerce-api.service <<'SERVICE'
    [Unit]
    Description=Ecommerce Python API
    After=network.target

    [Service]
    ExecStart=/usr/bin/python3 /opt/ecommerce/app.py
    Restart=always

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable --now ecommerce-api
  EOF

  tags = {
    Name = "ecommerce-backend"
    Tier = "Backend"
  }
}

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = aws_instance.frontend.id
  port             = 80
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}
