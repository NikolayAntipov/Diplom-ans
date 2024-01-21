
#  Дипломная работа по профессии «Системный администратор» Антипова Н.С.

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).


### Сайт
Созданные виртуальные машины. На скриншоте видно, что машины nginx1 и nginx2 предназначенные для web-серверов находятся в разных зонах

![vm](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/vm.jpg)

На машаинах подняты веб сервера на nginx и размещён статический файл [index.html](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/Ansible/index.html). Проверим работоспособность двух веб-серверов командами curl -v  10.1.0.10 и curl -v  10.2.0.10

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

Протестируем сайт с помощью команды  curl -v 158.160.138.22

![balancer](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/test_load_balancer.jpg)

При доступе через веб должно отображаться сождержимое
![web](https://github.com/NikolayAntipov/Diplom-ans/blob/diplom-zabbix/IMG/web.jpg)

### Мониторинг
Создана машина с zabbix и развернуты агенты на целевые хосты. Настройка инфрастуктуры происходит с помощью скриптов из папки [Ansible](https://github.com/NikolayAntipov/Diplom-ans/tree/diplom-zabbix/Ansible).
Конфигурирование происходит с помощью копирования фалов конфигураций из папки [Files](https://github.com/NikolayAntipov/Diplom-ans/tree/diplom-zabbix/Ansible/files)
### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

