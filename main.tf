# получаем id образа ubuntu 24.04
data "yandex_compute_image" "ubuntu2404" {
  family = "ubuntu-2404-lts-oslogin"
}

# получаем id дефолтной network
data "yandex_vpc_network" "default" {
  name = "default"
}

# создаем дополнительный диск, который используется как iscsi share
resource "yandex_compute_disk" "shared_disk" {
  name = "shared-disk"
  type = "network-hdd"
  size = "5"
}

# создаем подсеть
resource "yandex_vpc_subnet" "subnet01" {
  name           = "subnet01"
  network_id     = data.yandex_vpc_network.default.network_id
  v4_cidr_blocks = ["10.16.0.0/24"]
}

# создаем сервер под iscsi storage
resource "yandex_compute_instance" "storage" {
  name     = "storage"
  hostname = "storage"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      name     = "boot-disk-storage"
      image_id = data.yandex_compute_image.ubuntu2404.id
    }
  }

  secondary_disk {
    disk_id     = yandex_compute_disk.shared_disk.id
    device_name = "shared_disk"
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

# создаем сервер под базу данных
resource "yandex_compute_instance" "database" {
  name     = "database"
  hostname = "database"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      name     = "boot-disk-database"
      image_id = data.yandex_compute_image.ubuntu2404.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

# создаем инстансы под backend
resource "yandex_compute_instance" "backend" {
  count    = var.backend_size
  name     = "${var.backend_name}${count.index + 1}"
  hostname = "${var.backend_name}${count.index + 1}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      name     = "boot-disk-${var.backend_name}${count.index + 1}"
      image_id = data.yandex_compute_image.ubuntu2404.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

# создаем инстансы под frontend
resource "yandex_compute_instance" "frontend" {
  count    = var.frontend_size
  name     = "${var.frontend_name}${count.index + 1}"
  hostname = "${var.frontend_name}${count.index + 1}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      name     = "boot-disk-${var.frontend_name}${count.index + 1}"
      image_id = data.yandex_compute_image.ubuntu2404.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

# создаем inventory файл для Ansible
resource "local_file" "inventory" {
  filename        = "./hosts"
  file_permission = "0644"
  content         = <<EOT
[database]
%{for vm in yandex_compute_instance.database.*~}
${vm.hostname} ansible_host=${vm.network_interface.0.nat_ip_address} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{endfor}

[backend]
%{for vm in yandex_compute_instance.backend.*~}
${vm.hostname} ansible_host=${vm.network_interface.0.nat_ip_address} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{endfor~}

[frontend]
%{for vm in yandex_compute_instance.frontend.*~}
${vm.hostname} ansible_host=${vm.network_interface.0.nat_ip_address} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{endfor~}

[storage]
%{for vm in yandex_compute_instance.storage.*~}
${vm.hostname} ansible_host=${vm.network_interface.0.nat_ip_address} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{endfor}
EOT
}

# создаем Ansible playbook
resource "local_file" "playbook_yml" {
  filename        = "./playbook.yml"
  file_permission = "0644"
  content = templatefile("playbook.tmpl.yml", {
    remote_user  = var.system_user,
    backend_name = var.backend_name,
    backend_size = var.backend_size,
    database     = yandex_compute_instance.database,
    storage      = yandex_compute_instance.storage,
    backend      = yandex_compute_instance.backend[*],
    frontend     = yandex_compute_instance.frontend[*]
    iqn_base     = var.iqn_base,
    vg_name      = var.vg_name,
    lv_name      = var.lv_name,
    fs_name      = var.fs_name
  })
}

# создаем скрипт, который выполняет настройку iscsi сервера
resource "local_file" "setup_iscsi_target" {
  filename        = "./iscsi_target.bash"
  file_permission = "0644"
  content = templatefile("iscsi_target.bash.tmpl", {
    iqn_base     = var.iqn_base,
    backend      = yandex_compute_instance.backend[*],
    backend_name = var.backend_name
  })

}

/* resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ${local_file.inventory.filename} ${local_file.playbook_yml.filename}"
  }
} */

/* output "internal_ip_address_nginx0" {
  value = yandex_compute_instance.iscsi.network_interface.0.ip_address
}

output "external_ip_address_nginx" {
  value = yandex_compute_instance.iscsi.network_interface.0.nat_ip_address
} */