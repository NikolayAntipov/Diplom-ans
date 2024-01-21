
#  Дипломная работа по профессии «Системный администратор» Антипова Н.С.

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).


### Сайт
Созданы виртуальные машины под инфраструктру. На скриншоте видно, что машины nginx1 и nginx2 предназначенные для web-серверов находятся в разных зонах

![vm](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/vm.jpg)

На машинах подняты веб сервера на nginx и размещён статический файл [index.html](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/Ansible/index.html). Проверим работоспособность двух веб-серверов командами curl -v  10.1.0.10 и curl -v  10.2.0.10

![nginx1](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/nginx1.jpg)
![nginx1](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/nginx2.jpg)

Вся инфраструктура создаётся с помощью терраформ. Файлы располождены в папке [Terraform](https://github.com/NikolayAntipov/Diplom-ans/tree/diplom-zabbix/Terraform)

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

![tg](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/target_group.jpg)

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

![bg](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/backand_group.jpg)

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

![router](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/http_router.jpg)

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

![balancer](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/balancer.jpg)

Протестируем работу балансировщика с помощью команды  curl -v 158.160.138.22

![balancer](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/test_load_balancer.jpg)

При доступе через веб должно отображаться содержимое
![web](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/web.jpg)

### Мониторинг
Создана машина с zabbix и развернуты агенты на целевые хосты. Установка и настройка сервера zabbix и агентов происходит с помощью щаспуска ansuible скриптов из папки [Ansible](https://github.com/NikolayAntipov/Diplom-ans/tree/diplom-zabbix/Ansible).
Конфигурирование серера и агентов происходит с помощью копирования файлов конфигураций из папки [Files](https://github.com/NikolayAntipov/Diplom-ans/tree/diplom-zabbix/Ansible/files)

Доступ в zabbix по ссылке http://51.250.33.207:8080/  
логин: Admin  
пароль: zabbix  

Настроены дашборды. Протестрована работоспособность путём отключения nginx1, что видно на графике
![zab](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/zabbix.JPG)

### Логи
Установка и настройка Elasticsearch, Kibana и filebeat осуществляется ангалагично zabbix (с помощью скриптов ansible и копирования конфигураций).  
Доступ в Kibana можно получить по адресу http://51.250.36.238:5601/

![kibana](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/kibana.JPG)  
![kibana2](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/kibana2.JPG)

### Сеть
Настроены подсети  
![subnets](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/subnets.jpg)

и группы безопасности  
![bezop](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/groups_bezop.jpg)  

Доступ к хостам осуществляется по ssh через бастионный хост.  
Например для подлючения к Elasticsearch через бастионный хост используем следующую команду:  
ssh -i ~/.ssh/id_ed25519 -J ans@51.250.37.117 ans@10.3.0.10 
  
Файл [hosts](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/Ansible/hosts) сконифигрурирорван для подключения и выполнения скриптов ansible через бастион

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

![snapshots](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/snapshots.jpg)

