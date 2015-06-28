---
layout: post
title: "成都金夫人从零部署记录"
date: 2014-12-02 09:48:59 +0800
comments: true
categories: 技术
---
成都金夫人香港服务器需要部署网站，记录整个服务器搭建的全部流程，涉及安全、用户、
系统等综合性管理。

**Task List**

+ 添加部署用户
+ 禁止root用户登录
+ 网站部署
+ 防火墙
+ FTP功能

## 用户管理

建立`deployment`用户组，负责项目部署；并且在`sudoers`文件中添加组`deployment`为管
理员组。

``` bash
useradd deployment

# In /etc/sudoers
# Allows people in group deployment to run all commands
%deployment ALL=(ALL) ALL
```

禁用`root`用户远程登录系统

``` bash
# In /etc/ssh/sshd_config
PermitRootLogin no
```

## 服务器环境搭建

+ 安装`lnmp`（Linux + Nginx + Mysql + PHP）

    > 参考 [LNMP](http://lnmp.org),
    > [PHP升级](http://www.vpser.net/manage/lnmp-upgrade-php-script.html)

+ 安装`git`

``` bash
yum install git
```

+ 配置PHP

``` ini
# php.ini 添加或者修改配置
max_post_size = 300M
file_upload_size = 300M
extension = fileinfo.so
disable_functions =
```

+ 源码迁移与数据库迁移

``` bash
# 源码迁移
zip -r project /path/to/project
unzip /path/to/source -d /path/to/destination

# 数据库迁移
mysqldump -u username -p db_name > db_name.sql
```

+ 配置Nginx

``` nginx
# default.conf
server {
  listen 80 default;
  server_name _;
  set $root_path '/bjdata/bj/golden_ladies/public';
  root $root_path;
  index index.php index.html index.htm;

  location / {
    try_files $uri $uri/ /index.php$is_args$args;
  }

# Removes trailing slashes
  if (!-d $request_filename) {
    rewrite ^/(.+)/$ /$1 permanent;
  }

# Rewrite to index.php unless the request is for an existing file
  (image, js,
# css, etc.)
    if (!-e $request_filename) {
      rewrite ^/(.*)$ /index.php?/$1 last;
      break;
    }

  error_page 404  /404.html;
  location = /404.html {
    root /bjdata/error_pages/;
  }

  error_page 500 502 503 504 /500.html;
  location = /500.html {
    root /bjdata/error_pages/;
  }

  location ~ \.php$ {
    try_files $uri /index.php =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
# fastcgi_pass unix:/var/run/php5-fpm.sock;
    fastcgi_pass unix:/tmp/php-cgi.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
  }

# deny access to .htaccess files, if Apache's document root
# concurs with nginx's one
  location ~ /\.ht {
    deny all;
  }

  access_log /var/log/nginx/www.cdjfr.com.log;
  error_log  /var/log/nginx/www.cdjfr.com.error.log;
}
```
