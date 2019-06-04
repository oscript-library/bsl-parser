///////////////////////////////////////////////////////////////////////////////
//
// Информация о типах конфигурации
//
///////////////////////////////////////////////////////////////////////////////

Перем ОбъектыКонфигурации;
Перем ХэшПоиска;

///////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС
///////////////////////////////////////////////////////////////////////////////

// Возвращает информацию о типе объекта конфигурации по имени типа
//
// Параметры:
//   ИмяТипаОбъектаКонфигурации - Строка - Имя типа объекта, например, Справочник, Document, Перечисления
//
//  Возвращаемое значение:
//   Структура - Описание типа
//		* Наименование - Русское наименование типа в единственном числе
//		* НаименованиеКоллекции - Русское наименование типа во множественном числе
//		* НаименованиеEng - Английское наименование типа в единственном числе
//		* НаименованиеКоллекцииEng - Английское наименование типа во множественном числе
//
Функция ОписаниеТипаПоИмени(ИмяТипаОбъектаКонфигурации) Экспорт
	
	Возврат ХэшПоиска[ВРег(ИмяТипаОбъектаКонфигурации)];
	
КонецФункции

// Выполняет приведение имени типа в различных вариациях к единому стилю
//	Возвращает вариант на английском в единственном числе
//
// Параметры:
//   ИмяТипаОбъектаКонфигурации - Строка - Имя типа объекта, например, Справочник, Document, Перечисления
//
//  Возвращаемое значение:
//   Строка - Имя типа на английском в единственном числе
//
Функция НормализоватьИмя(ИмяТипаОбъектаКонфигурации) Экспорт
	
	ЗагрузитьОписаниеТиповОбъектовКонфигурации();

	Описание = ХэшПоиска[ВРег(ИмяТипаОбъектаКонфигурации)];
	
	Если Описание = Неопределено Тогда		
		Возврат ИмяТипаОбъектаКонфигурации;
	Иначе
		Возврат Описание.НаименованиеEng;
	КонецЕсли;

КонецФункции

// Возвращает имя типа по-русски
//
// Параметры:
//   ИмяТипаОбъектаКонфигурации - Строка - Имя типа объекта, например, Справочник, Document, Перечисления
//
//  Возвращаемое значение:
//   Строка - Имя типа по-русски
//
Функция ПолучитьИмяТипаНаРусском(ИмяТипаОбъектаКонфигурации) Экспорт
	
	ОписаниеТипа = ОписаниеТипаПоИмени(ИмяТипаОбъектаКонфигурации);
	
	Возврат ?(ОписаниеТипа = Неопределено, ИмяТипаОбъектаКонфигурации, ОписаниеТипа.Наименование);
	
КонецФункции

#Область ИменаТиповОбъектовКонфигурации

// Возвращает имя типа подсистемы
//
//  Возвращаемое значение:
//   Строка - Имя типа
//
Функция ИмяТипаПодсистема() Экспорт
	
	Возврат НормализоватьИмя("Подсистемы");

КонецФункции

// Возвращает имя типа конфигурации
//
//  Возвращаемое значение:
//   Строка - Имя типа
//
Функция ИмяТипаКонфигурации() Экспорт
	
	Возврат "Configuration";

КонецФункции

// Возвращает имя типа расширение
//
//  Возвращаемое значение:
//   Строка - Имя типа
//
Функция ИмяТипаРасширения() Экспорт
	
	Возврат НормализоватьИмя("Расширение");

КонецФункции

// Возвращает имя типа общего модуля
//
//  Возвращаемое значение:
//   Строка - Имя типа
//
Функция ИмяТипаОбщийМодуль() Экспорт
	
	Возврат НормализоватьИмя("ОбщийМодуль");

КонецФункции

// Возвращает имя типа плана обмена
//
//  Возвращаемое значение:
//   Строка - Имя типа
//
Функция ИмяТипаПланОбмена() Экспорт
	
	Возврат НормализоватьИмя("ПланОбмена");

КонецФункции

#КонецОбласти

// Возвращает имя типа конфигурации
//
//  Возвращаемое значение:
//   Строка - Имя типа
//
Функция ЭтоТипКонфигурации(ИмяТипа) Экспорт
	
	Возврат СтрСравнить(ИмяТипа, ИмяТипаКонфигурации()) = 0;

КонецФункции

///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ
///////////////////////////////////////////////////////////////////////////////

Процедура ЗагрузитьОписаниеТиповОбъектовКонфигурации()
	
	Если ОбъектыКонфигурации <> Неопределено Тогда
		
		Возврат;
		
	КонецЕсли;

	ФайлОписаний = ОбъединитьПути(Утилиты.КаталогМакеты(), "ОбъектыКонфигурации.md");
	
	Чтение = Новый ЧтениеТекста();
	Чтение.Открыть(ФайлОписаний, КодировкаТекста.UTF8);
	
	Утилиты.НайтиСледующийЗаголовокMarkdown(Чтение, "## Имена");

	ОбъектыКонфигурации = Утилиты.ПрочитатьТаблицуMarkdown(Чтение);

	ХэшПоиска = Новый Соответствие();

	Для Каждого СтрокаОписание Из ОбъектыКонфигурации Цикл
		
		СтрокаОписание.ПорождаемыеТипы = СтрРазделить(СтрокаОписание.ПорождаемыеТипы, " ", Ложь);
		
		ХэшПоиска.Вставить(ВРег(СтрокаОписание.Наименование), СтрокаОписание);
		ХэшПоиска.Вставить(ВРег(СтрокаОписание.НаименованиеКоллекции), СтрокаОписание);
		ХэшПоиска.Вставить(ВРег(СтрокаОписание.НаименованиеEng), СтрокаОписание);
		ХэшПоиска.Вставить(ВРег(СтрокаОписание.НаименованиеКоллекцииEng), СтрокаОписание);
		
	КонецЦикла;
	
	Чтение.Закрыть();
	
КонецПроцедуры

ЗагрузитьОписаниеТиповОбъектовКонфигурации();