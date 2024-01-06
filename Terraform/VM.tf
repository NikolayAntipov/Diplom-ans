# Токен
variable yc_token {}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

# Провайдер
provider "yandex" {
  token        = var.yc_token
  cloud_id     = "b1gjiiqd9klnn1bjrlr2"
  folder_id    = "b1gp9d1vraetieliua7c"
}


# Создание nginx1 nginx2
resource "yandex_compute_instance" "nginx1" {
  name     = "nginx1"
  hostname = "nginx1"
  zone     = "ru-central1-a"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 2

  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-nginx1.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
    ip_address         = "10.1.0.10"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"

  }


}


resource "yandex_compute_instance" "nginx2" {
  name     = "nginx2"
  hostname = "nginx2"
  zone     = "ru-central1-b"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 2

  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = 10
    }

  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-nginx2.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
    ip_address         = "10.2.0.10"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }



}

resource "yandex_compute_instance" "zabbix" {
  name     = "zabbix"
  hostname = "zabbix"
  zone     = "ru-central1-c"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 6
  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      type     = "network-ssd"
      size     = "15"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.zabbix-sg.id]
    ip_address         = "10.4.0.20"
    nat                = true

  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }


}


resource "yandex_compute_instance" "elasticsearch" {
  name     = "elasticsearch"
  hostname = "elasticsearch"
  zone     = "ru-central1-c"

  resources {
    cores  = 4
    core_fraction = 20
    memory = 8

  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-services.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.elasticsearch-sg.id]
    ip_address         = "10.3.0.100"
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }


}



resource "yandex_compute_instance" "kibana" {
  name     = "kibana"
  hostname = "kibana"
  zone     = "ru-central1-c"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 2

  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.kibana-sg.id]
    ip_address         = "10.4.0.100"
    nat                = true

  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }


}


resource "yandex_compute_instance" "bastion" {
  name     = "bastion"
  hostname = "bastion"
  zone     = "ru-central1-c"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80bm0rh4rkepi5ksdi"
      type     = "network-ssd"
      size     = "15"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-subnet.id
    security_group_ids = [yandex_vpc_security_group.bastion-sg.id]
    ip_address         = "10.4.0.10"
    nat                = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }


}
