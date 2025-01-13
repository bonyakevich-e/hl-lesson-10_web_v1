### OTUS High Load Lesson #10 | Subject: Настройка конфигурации веб приложения под высокую нагрузку
----------------
### ЦЕЛЬ: Настройка конфигурации веб приложения под высокую нагрузку
----------------
### ОПИСАНИЕ ЗАДАЧ

- Создать несколько инстансов с помощью терраформ (2 nginx, 2 backend, 1 db).
- Развернуть Nginx и Keepalived на серверах nginx при помощи Ansible.
- Развернуть бэкенд способный работать по Uwsgi/Unicorn/PHP-FPM и базой данных при помощи Ansible. Можно взять готовую CMS или проект на Django.
- Развернуть GFS2 для бэкенд серверах, для хранения статики.
- Развернуть СУБД для работы бэкенда при помощи Ansible.
- Проверить отказоустойчивость системы при выходе из строя серверов backend или nginx.

В работе должны применяться:

- Keepalived (в случае использования vagrant и virtualbox), Load balancer от Yandex (в случае использования Яндекс.Облака);
- Nginx/Angie;
- Uwsgi/Unicorn/PHP-FPM;
- некластеризованная СУБД MySQL/MongoDB/PostgreSQL/Redis.
------------------
### ОПИСАНИЕ ВЫПОЛНЕНИЯ

Стенд собирается из виртуальных машин, развёрнутых в Яндек Облаке: 

![otus highload scheme v2 (2)](https://github.com/user-attachments/assets/0e27fccf-0ef1-49e2-b22f-bafa43643e57)

Компоненты стенда:
1. __Yandex NLB__ - сетевой балансировщик Yandex Network Load Balancer. Балансирует http-запросы между frontend-серверами
2. __nginx1, nginx2__ - frontend-сервера nginx для хранения статики и проксирования запросов к backend-серверам
3. __backend1, backend2__ - backend-сервера с облачным сервисом __Nextcloud__
4. __database__ - сервер с СУБД MariaDB для Nextcloud
5. __storage__ - сервер хранения данных. Nextcloud здесь хранит пользовательские данные

Backend-сервера используют единное хранилище, подключенное по __iscsi__ с файловой системой __GFS2__. Кластер из backend-сервером собирается при помощи __Pacemaker__.

При падении одного из frontend и одного из backend-сервером сервис Nextcloud продолжает работать. 

Стенд автоматически собирается с помощью комманд:
```
$ terraform apply
$ ansible-playbook -i hosts playbook.yml
``` 
