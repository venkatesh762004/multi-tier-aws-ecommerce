resource "aws_launch_template" "backend" {
  name_prefix   = "${var.project_name}-backend-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.backend_sg.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y python3

    mkdir -p /opt/ecommerce

    cat > /opt/ecommerce/app.py <<'PYTHON'
    from http.server import BaseHTTPRequestHandler, HTTPServer
    import json

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == "/health":
                data = {"status": "healthy"}
            elif self.path == "/api/products":
                data = {
                    "products": [
                        {"id": 1, "name": "Laptop", "price": 55000},
                        {"id": 2, "name": "Headphones", "price": 2500}
                    ]
                }
            else:
                self.send_response(404)
                self.end_headers()
                return

            body = json.dumps(data).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

    HTTPServer(("0.0.0.0", 5000), Handler).serve_forever()
    PYTHON

    cat > /etc/systemd/system/ecommerce-api.service <<'SERVICE'
    [Unit]
    Description=Ecommerce API
    After=network.target

    [Service]
    ExecStart=/usr/bin/python3 /opt/ecommerce/app.py
    Restart=always
    User=root

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable --now ecommerce-api
  EOF
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ecommerce-backend-instance"
      Tier = "Backend"
    }
  }
}