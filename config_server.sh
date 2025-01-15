#!/bin/bash

detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
  elif [ -f /etc/redhat-release ]; then
    DISTRO="rhel"
  elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
  else
    echo "Tidak dapat mendeteksi jenis distribusi Linux."
    exit 1
  fi
}

disable_selinux() {
  if command -v sestatus &>/dev/null; then
    echo "Menonaktifkan SELinux..."
    sudo setenforce 0
    sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
  else
    echo "SELinux tidak ditemukan di sistem ini."
  fi
}

install_web_server() {
  case "$DISTRO" in
  ubuntu | debian)
    echo "Melakukan instalasi web server (Apache)..."
    sudo apt update
    sudo apt install -y apache2
    sudo systemctl enable apache2
    sudo systemctl start apache2
    ;;
  centos | rhel | fedora)
    echo "Melakukan instalasi web server (Apache/httpd)..."
    sudo dnf install -y httpd
    sudo systemctl enable httpd
    sudo systemctl start httpd
    ;;
  *)
    echo "Distribusi Linux tidak didukung oleh script ini."
    exit 1
    ;;
  esac
}

install_mariadb() {
  case "$DISTRO" in
  ubuntu | debian)
    echo "Melakukan instalasi MariaDB Server..."
    sudo apt update
    sudo apt install -y mariadb-server
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
    ;;
  centos | rhel | fedora)
    echo "Melakukan instalasi MariaDB Server..."
    sudo dnf install -y mariadb-server
    sudo systemctl enable mariadb
    sudo systemctl start mariadb
    ;;
  *)
    echo "Distribusi Linux tidak didukung oleh script ini."
    exit 1
    ;;
  esac
}

install_php() {
  case "$DISTRO" in
  ubuntu | debian)
    echo "Melakukan instalasi PHP dan dependensi..."
    sudo apt install -y php libapache2-mod-php php-mysql php-cli php-curl php-zip php-mbstring php-xml php-bcmath php-intl
    sudo systemctl restart apache2
    ;;
  centos | rhel | fedora)
    echo "Melakukan instalasi PHP dan dependensi..."
    sudo dnf install -y php php-mysqlnd php-cli php-common php-fpm php-curl php-zip php-mbstring php-xml php-bcmath php-intl
    sudo systemctl restart httpd
    ;;
  *)
    echo "Distribusi Linux tidak didukung oleh script ini."
    exit 1
    ;;
  esac
}

configure_firewalld() {
  if command -v firewall-cmd &>/dev/null; then
    echo "Mengonfigurasi firewalld untuk web server dan MariaDB..."
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --permanent --add-service=mysql
    sudo firewall-cmd --reload
  else
    echo "firewalld tidak ditemukan, melewati konfigurasi firewall."
  fi
}

main() {
  detect_distro
  disable_selinux
  install_web_server
  install_php
  install_mariadb
  configure_firewalld
  echo "Instalasi web server dan MariaDB Server selesai!"
}

main
