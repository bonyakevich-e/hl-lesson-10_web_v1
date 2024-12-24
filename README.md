### OTUS High Load Lesson #10 | Subject: Настройка конфигурации веб приложения под высокую нагрузку
----------------
### ЦЕЛЬ: Настройка конфигурации веб приложения под высокую нагрузку
----------------
### ОПИСАНИЕ

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
