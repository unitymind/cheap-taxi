# Прототип системы вертикального поиска по услугам такси города Москвы

## Постановка задачи

Функциональные и иные требования в формате PDF доступны [здесь](https://github.com/unitymind/cheap-taxi/blob/master/doc/aviasales.pdf?raw=true)

## Сбор данных

Тестовые данные должны более-менее реалистичными.

В качестве источника данных о Москве использован сайт [http://mosopen.ru](http://mosopen.ru). Получены:

* административные округа
* районы, входящие в административные округа
* станции метро и к каким районам они относятся
* площадь районов и численность жителей
* для каждого района собрана информация о граничащих с ним районах (необходимо для построения кратчайших маршрутов)

В качестве источника данных о таксомотороных службах использован сайт [http://taxodrom.ru](http://taxodrom.ru). Получены:

* Названия компаний
* Веб-сайт
* Телефоны
* Типы используемых автомобилей и их класс (эконом, бизнес, VIP)

## Структура данных

Структура данных должна максимально соответствовать реальному миру