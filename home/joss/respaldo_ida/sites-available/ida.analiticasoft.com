server {
    server_name ida.analiticasoft.com;

    # Frontend (Angular)
    location / {
        proxy_pass http://localhost:4200; 
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Backend (Spring Boot API)
    location /api/ {
        proxy_pass http://localhost:8080/api/; 
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # WebSockets (Mensajería en tiempo real)
    location /ws/ {
        proxy_pass http://localhost:8080/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/ida.analiticasoft.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/ida.analiticasoft.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = ida.analiticasoft.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name ida.analiticasoft.com;
    return 404; # managed by Certbot


}