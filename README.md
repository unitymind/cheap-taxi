# Прототип системы вертикального поиска по услугам такси города Москвы

[http://cheap-taxi.unitymind.org/](http://cheap-taxi.unitymind.org/) - запущенное приложение, соответствующее текущей версии.

## Постановка задачи

Функциональные и иные требования в формате PDF доступны [здесь](https://github.com/unitymind/cheap-taxi/blob/master/doc/aviasales.pdf?raw=true).

## Сбор данных и их структура

Тестовые данные должны быть более-менее реалистичными, а их структура - максимально соответствовать реальному миру.

### Реальные данные
В качестве источника данных о Москве использован сайт [http://mosopen.ru](http://mosopen.ru).
Получены:

* административные округа
* районы, входящие в административные округа
* станции метро и к каким районам они относятся
* площадь районов и численность жителей
* для каждого района собрана информация о граничащих с ним районах (необходимо для построения кратчайших маршрутов)

Зеленоградский округ исключен, так как его районы не имеют границ с другими районами, кроме входящих в это же округ.
Расчет маршрутов и тарифов невозможен для этих районов.

В качестве источника данных о таксомоторных службах использован сайт [http://taxodrom.ru](http://taxodrom.ru).
Получены:

* Названия компаний
* Веб-сайт
* Телефоны
* Типы используемых автомобилей и их класс (эконом, бизнес, VIP)

На основе данных о граничащих районах был построен двунаправленный граф, где в качестве веса ребра задается среднее
значение площади (в гектарах) двух районов, которые это ребро соединяет.

Этот граф используется для вычисления кратчайшего пути из одного района в другой по алгоритму Дейкстра (таким образом, для 120 районов Москвы
получили 120*120 - 120 = 14280 кратчайших маршрутов).

Операция выполняется один раз и сохраняется в базе как своеобразный кеш маршрутов, при этом расчитанное для маршрута величина из гектаров
переводится в километры квадратные, затем делится на 2 - получаем длину маршрута в километрах.

Проверка длины маршрута в Google Maps подтвердила полученные расстояния - погрешность 2-7км., приближенность к реальным данным соблюдена.

### Сгенерированные данные

Каждая компания помечается как обслуживающая 30-35 райнов Москвы (имеющая там свои автомобили постоянно), выбранных случайно.

При поиске компаний для обслуживания заказа, выбираются те, которые присутствуют в районе начала маршрута.

Сделано допущение, что такие компании способны подать автомобиль наиболее быстро, предложив меньшую стоимость поездки
 (нет накладных расходов на проезд автомобиля до точки начала маршрута).

Затем для каждой компании генерируются тарифы - по одному для каждого класса обслуживания.

Тарифы различаются:

* Временем подачи автомобиля
* Стоимостью одного километра поездки (днем и ночью)
* Минимальной стоимостью поездки (и сколько километров включено в эту стоимость) - разные величины днем и ночью.

Для каждого из классов обслуживания существуют разные "вилки" случайно сгенерированных величин.

## Подход к тестированию

Для данного приложения очень важны данные - взаимоотношения моделей и их сбор. Полно охвачены RSpec-тестами модели и lib/utils/parser.

Для тестирования ассоциаций и связей использовался gem 'rspec-rails-matchers', который был немного доработан.

Для тестирования валидаций в нем использовалось сопоставления поведения модели, тогда как для ассоциаций просто сопоставлялись
 данные, вытянутые посредством рефлексии. Мной было убрано тестирование поведение модели для валидаций (это сделано уже итак в
 тестах Rails), но добавлена схожая проверка на основе рефлексии - просто проверяем, что такая-то валидации определена в модели
 с требуемые опциями. Gem был форкнут, в Gemfile используется форкнутая версия.

Контроллер (а он всего один и простейший) не покрывался тестами, равно как и views.

Также не покрыт тестами вспомогательный lib/utils/cached_url - простая реализация кэша для парсера (или тянем содержимое запрашиваемого URL
 по сети, или берем из файловой системы). Как раз помогает при отладке парсера и перегенерации данных на чистую базу.

## Алгоритм поиска

При поиске нам важны всего несколько параметров:

* Начальный район
* Конечный район
* Класс обслуживания
* Время начала поездки

По начальному и конечному району мы получаем конкретный маршрут, предварительно рассчитанный ранее. Далее выбираем компании, которые обслуживают
 район, являющийся начальном точкой маршрута и имеющий авто в требуемом классе обслуживания. Затем расчитываем стоимость поездки на основе протяженности
 маршрута (и времени начала поездки - с 8 до 22 - дневной, с 22 до 8 - ночной тариф). Полученный набор строк отдаем в UI.

## Реализация пользовательского интерфейса

Подход утилитарный в рамках прототипа - необходимые поля, назначение которых очевидно. В качестве небольшой пользовательской "плюшки" используется [jQuery Autocomplete](http://jqueryui.com/demos/autocomplete/) с соответствующим gem 'rails3-jquery-autocomplete', который, опять же, был немного доработан, чтобы обеспечить контекстную фильтрацию зависимых полей:

* Если выбран административный округ, то можем выбрать только станции метро или район, находящиеся в этом округе
* Если выбрано метро, то можем выбрать только район(ы), к которым это метро привязано.

Поскольку результирующие наборы у нас небольшие (не более 200 строк), то вывод, сортировку, фильтрацию выполняем с помощью [jQuery DataTables](http://www.datatables.net).

Сортировка по нескольким значениям: зажимаем shift.

Поисковая форма "постится" аяксом, результирующий массив перезаписывается напрямую в Datatables.

Перезагрузка страницы отсутствует.

## Недочеты

* Не все покрыто тестами
* Нет обработки ошибок соединения при autocomplete
* Нет сообщений об ошибочных данных при отправке поисковой формы - попросту не получаем результат поисках.
 Очевидно, что нужно бы указать районы точно.
* Явно не фильтруется по наличию автомобилей отечественного производства. У тех компаний, которые используют
 в эконом-классе "ВАЗ" и "ГАЗ", есть и иномарки. Тарифы не отличаются, потом наличие такого чек-бокса важно при обработке заявки...
 А она у нас не формируется, не отправляется и не обратывается. Потому что некому! ;)
* Ожидание ответа при аяксах-запросах никак не сигнализируется в интерфейсе (крутилка, временное сообщение)


## Немного технических деталей

Парсер и генерация данных сгруппированы в rake-задачах:

	rake db:parser:moscow:all
		Parse Moscow's districts, area, metro's stations and areas relations. Parse Moscow's taxi companies

	rake db:parser:moscow:city
		Parse Moscow's districts, area, metro's stations and areas relations.

	rake db:parser:moscow:companies
		Parse Moscow's taxi companies

	rake db:populate:all
		Populate and generate (randomly) needed data

	rake db:populate:companies_to_regions
		Random bind companies to regions. Can be re-run many times

	rake db:populate:rates
		Generate random rates for companies. For different car_group - different rates

	rake db:populate:routes
		Create graph from RegionLinks and Regions. Find shortest path from one region to another and save them to database

Чтобы наполнить базу с чистого листа (парсим внешние ресурсы, генерируем данные):

	rake db:init
		Init database from a scratch. Parse and populate data.

Можно также наполнить данными, воспользовавшись дампом:

	rake db:schema:load
		Load a schema.rb file into the database

	rake db:data:load
		Load contents of db/data.extension (defaults to yaml) into database

На Heroku приложение задеплоилось, но не заработало корректно. Разбираться не стал, воспользовался [locum.ru](http://locum.ru) - [все в порядке](http://cheap-taxi.unitymind.org/)! ;)

## Что дальше?

Несмотря на то, что это всего лишь прототип, демонстрационное приложение, оно не создано по принципу "написал, показал, забыл", а вполне подходит в качестве учебной задачи 
для оттачивания различных RoR-техник. В этом ключе оно и будет обновляться - как эксперимент. Упомянутые недочеты - текущий roadmap.

Может быть, кому-нибудь и пригодится для его гениального стартапа - совершенно не против, но участвовать в нем не буду! ;)

Можно использовать как есть без гарантий.
