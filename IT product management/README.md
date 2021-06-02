# Лабораторные работы №1-4 (Управление ИТ-проектами) #
Студент: Купчик Владислав

Группа: М8О-103М-20


## Подготовка к сборке ##

```bash
$ mkdir -p CMakeFiles
$ cd CMakeFiles
$ cmake --configure ..
$ cd ../
```

## Сборка основного приложения ##
```bash
$ cmake --build CMakeFiles --target hl_labs -- -j 3
```

## Сборка приложения для работы с очередью обработки запросов на добавление в БД ##
```bash
$ cmake --build CMakeFiles --target event_writer -- -j 3
```

## Запуск необходимых контейнеров ##
```bash
$ docker-compose up -d
```
## Создание таблиц базы данных везде ##

```bash
$ mysql -utest -ppzjqUkMnc7vfNHET -h 127.0.0.1 -P6033 --comments
mysql> source infrastructure/db_prepare/init.sql;
mysql> exit;
```

### Получение файла с данными ##
```bash
$ cmake --build CMakeFiles --target gen_data -- -j 3 && ./CMakeFiles/gen_data
```
В итоге получим файл infrastructure/db_prepare/sharded_gen_data100k.sql

### Загрузка сгенерированных данные по шардам ###
```bash
$ mysql -utest -ppzjqUkMnc7vfNHET -h 127.0.0.1 -P6033 --comments
mysql> source infrastructure/db_prepare/sharded_gen_data100k.sql;
mysql> exit
```
## Запуск основного приложения ##
```bash
$ sudo sh ./start.sh
```

## Запуск приложения с очередью ##
```bash
$ sudo sh ./start_writer.sh
```

## Отключение контейнеров ##
```bash
$ docker-compose stop
```

## Тестирование ##
### Запуск отдельного окружения для тестирования и инициализация шардов ###
```bash
$ docker-compose -f docker-compose-test.yaml up -d
$ mysql -utest -ppzjqUkMnc7vfNHET -h 127.0.0.1 -P6043 --comments
mysql> source infrastructure/db_prepare/init.sql;
mysql> exit;
```
### Компиляция и запуск тестов ###
```bash
$ cmake --build CMakeFiles --target gtests -- -j 3 && ./CMakeFiles/gtests
```
### Выключение тестового окружения ###
```bash
$ docker-compose -f docker-compose-test.yaml stop
```

## Нагрузочное тестирование ##
Нагрузочное тестирование осуществлялось с помощью утилиты wrk. Были проведены нагрузочные тесты на чтение (с кешем Apache Ignite - 2-4 ЛР, так и без него - 1 ЛР) и запись (с очередью - 4 ЛР, так и без нее - 1-3 ЛР).

```bash
# Тест на чтение
$ wrk -t $Threads -c100 -d30s http://localhost:8080/person\?login\=166-06-8645
# Тест на запись
$ wrk -s tests/post_wrk_req.lua -t $Threads -c100 -d30s http://localhost:8080
```

Все контейнеры, само основное приложение и приложение с очередью были запущены на одной физической машине

### Тестирование на запись ###

Результаты с использованием очередей Apache Kafka (ЛР 4):

Threads | Req/sec | Latency(ms)
--- | --- | ---
1 | 107.37 | 145.20
2 | 87.00 | 181.33
6 | 85.28 | 184.37
10 | 78.46 | 200.84

Результаты без использования очередей (ЛР 1-3):

Threads | Req/sec | Latency(ms)
--- | --- | ---
1 | 35.12 | 451.51
2 | 42.37 | 374.89
6 | 42.82 | 370.55
10 | 40.10| 396.03

### Тестирование на чтение ###

Результаты с использованием кеша Apache Ignite (ЛР 2-4):

Threads | Req/sec | Latency(ms)
--- | --- | ---
1 | 2358.97 | 11.92
2 | 3259.86 | 4.69
6 | 2968.89 | 5.34
10 | 2764.17 | 5.76

Результаты без использования кеша (ЛР 1):

Threads | Req/sec | Latency(ms)
--- | --- | ---
1 | 275.05 | 57.55
2 | 267.08 | 59.73
6 | 254.59 | 85.23
10 | 256.86 | 128.93

## Точки входа ##
Добавление пользователя
```bash
$ curl -d "login=mik-12345&last_name=Kupchik&first_name=Vladislav&age=28" -X POST http://localhost:8080/person
```
Получение всех пользователей
```bash
$ curl -X GET http://localhost:8080/person
```
Получение пользователей по маске
```bash
$ curl -X GET http://localhost:8080/person\?first_name\=I\&last_name\=Ma
```
Получение конкретного пользователя
```bash
$ curl -X GET http://localhost:8080/person\?login\=mik-12345
```
