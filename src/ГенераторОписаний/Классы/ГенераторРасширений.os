///////////////////////////////////////////////////////////////////
//
// Класс для генерации расширений
//
// (с) BIA Technologies, LLC    
//
///////////////////////////////////////////////////////////////////

#Использовать fs

///////////////////////////////////////////////////////////////////

Перем ЗаписьConfiguration;
Перем ОписаниеКонфигурации;
Перем Лог;
Перем СтруктураКаталогов;
Перем ГенераторОписаний Экспорт;
Перем ТипКорневогоЭлемента;

Перем Парсер;

///////////////////////////////////////////////////////////////////
// Программный интерфейс
///////////////////////////////////////////////////////////////////

// Инициализирует новое расширение в указанном каталоге
//
// Параметры:
//   КаталогНазначения - Строка - Путь к каталогу нового расширения
//   Формат - Строка - Формат выгрузки, см ФорматыВыгрузки 
//
Процедура СоздатьНовоеРасширение(Знач КаталогНазначения, Формат) Экспорт

	КаталогНазначения = (Новый Файл(КаталогНазначения)).ПолноеИмя;

    Лог.Информация("Начало генерации расширения");

	Если НЕ ФС.КаталогСуществует(КаталогНазначения) Тогда

		ФС.ОбеспечитьКаталог(КаталогНазначения);

	ИначеЕсли НЕ ФС.КаталогПустой(КаталогНазначения) Тогда
		
		Лог.Предупреждение("Каталог расширения ""%1"" не пустой. Каталог будет очищен", КаталогНазначения);
		ФС.ОбеспечитьПустойКаталог(КаталогНазначения);
		
	КонецЕсли;
	
	ИнициализироватьПеременные(КаталогНазначения, Формат);
	
	СтрокаКонфигурация = ОписаниеКонфигурации.ОбъектыКонфигурации.Добавить();
	СтрокаКонфигурация.Тип = ТипыОбъектовКонфигурации.ИмяТипаКонфигурации();
	СтрокаКонфигурация.Наименование = СтрокаКонфигурация.Тип;
	СтрокаКонфигурация.ПутьКФайлу = СтруктураКаталогов.ИмяФайлаОписанияКонфигурации();
	СтрокаКонфигурация.Описание = ОписаниеКонфигурации.СвойстваКонфигурации;

КонецПроцедуры

// Читает расширение из каталога и подготавливает к модификации
//
// Параметры:
//   КаталогНазначения - Строка - Путь к каталогу нового расширения
//
Процедура Загрузить(Знач КаталогНазначения) Экспорт
	
	Если НЕ ФС.КаталогСуществует(КаталогНазначения) Тогда

		ВызватьИсключение "Каталог не найден " + КаталогНазначения;

	КонецЕсли;
	
	КаталогНазначения = (Новый Файл(КаталогНазначения)).ПолноеИмя;

	Парсер = ПарсерBSL.ПарсерРасширения(КаталогНазначения);
	Парсер.ПрочитатьСтруктуруКонфигурации();
	ОписаниеКонфигурации = Парсер.ОписаниеКонфигурации();

	ИнициализироватьПеременные(КаталогНазначения, Парсер.ФорматВыгрузки());

КонецПроцедуры

// Устанавливает свойства расширения
//
// Параметры:
//   ИмяРасширения - Строка - Наименование расширения
//   ПредставлениеРасширения - Строка - Синоним расширения
//   ПрефиксРасширения - Строка - Префикс расширения
//
Процедура УстановитьОписание(ИмяРасширения, ПредставлениеРасширения, ПрефиксРасширения) Экспорт
	
	ОписаниеКонфигурации.СвойстваКонфигурации.Наименование = ИмяРасширения;
	ОписаниеКонфигурации.СвойстваКонфигурации.Синоним = ПредставлениеРасширения;
	ОписаниеКонфигурации.СвойстваКонфигурации.ПрефиксИмен = ПрефиксРасширения;
	
КонецПроцедуры

// Завершает генерацию расширения и записывает описание корневого файла(configuration.xml)
//
Процедура Зафиксировать() Экспорт
	
	ОписаниеКонфигурации.ОбъектыКонфигурации.Сортировать("Тип, Наименование");
	ТипКонфигурация = ТипыОбъектовКонфигурации.ИмяТипаКонфигурации();

	Для Каждого Стр Из ОписаниеКонфигурации.ОбъектыКонфигурации Цикл
		
		Если Стр.Тип <> ТипКонфигурация И Стр.Родитель = Неопределено Тогда
			
			ГенераторОписаний.ЗарегистрироватьОбъектВКонфигурации(Стр);
			
		КонецЕсли;
		
	КонецЦикла;

	ГенераторОписаний.ЗафиксироватьОписаниеКорневогоОбъекта();

    Лог.Информация("Расширение создано");

КонецПроцедуры

// Возвращает описание конфигурации
//
//  Возвращаемое значение:
//   Структура - Описание конфигурации
//
Функция ОписаниеКонфигурации() Экспорт
	
	Возврат ОписаниеКонфигурации;

КонецФункции

// Добавляет новый объект в конфигурацию
//
// Параметры:
//   ИмяОбъекта - Строка - Имя добавляемого объекта
//   ТипОбъекта - Строка - Тип объекта конфигурации, см ТипыОбъектовКонфигурации, ОбъектыКонфигурации.md
//   ОписаниеОбъекта - <Тип.Вид> - <описание параметра>
//
//  Возвращаемое значение:
//   СтрокаТаблицыЗначений - Описание добавленного объекта. См. СтруктурыОписаний.ТаблицаОписанияОбъектовКонфигурации
//
Функция ДобавитьОбъект(ИмяОбъекта, Знач ТипОбъекта, ОписаниеОбъекта = Неопределено) Экспорт
	
	ОбъектКонфигурации = ДобавитьОбъектКонфигурации(ИмяОбъекта, ТипОбъекта);

	Если ОбъектКонфигурации = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;

	Если ОписаниеОбъекта = Неопределено И ОбъектКонфигурации.Описание = Неопределено Тогда
		
		ОбъектКонфигурации.Описание = СтруктурыОписаний.СоздатьОбъект(ТипОбъекта, ИмяОбъекта);
		ЗаписатьОписаниеОбъекта(ОбъектКонфигурации, ОбъектКонфигурации.Описание);

	ИначеЕсли ОписаниеОбъекта <> Неопределено И ОбъектКонфигурации.Описание <> ОписаниеОбъекта Тогда
		
		ОбъектКонфигурации.Описание = ОписаниеОбъекта;
		ЗаписатьОписаниеОбъекта(ОбъектКонфигурации, ОбъектКонфигурации.Описание);

	КонецЕсли;

	Возврат ОбъектКонфигурации;
	
КонецФункции

// Обновляет файл описания объекта
//
// Параметры:
//   ОбъектКонфигурации - СтрокаТаблицыЗначений - Описание объекта конфигурации. См. СтруктурыОписаний.ТаблицаОписанияОбъектовКонфигурации
//
Процедура СохранитьОписаниеОбъекта(ОбъектКонфигурации) Экспорт
	
	ЗаписатьОписаниеОбъекта(ОбъектКонфигурации, ОбъектКонфигурации.Описание);
	
КонецПроцедуры // Введите имя процедуры()

// Добавляет объект базовой конфигурации в расширение
//
// Параметры:
//   ОбъектРодительскойКонфигурации - СтрокаТаблицыЗначений - Описание объекта родительской конфигурации. См. СтруктурыОписаний.ТаблицаОписанияОбъектовКонфигурации
//
//  Возвращаемое значение:
//   СтрокаТаблицыЗначений - Описание объекта расширения. См. СтруктурыОписаний.ТаблицаОписанияОбъектовКонфигурации
//
Функция ПеренестиОбъектВРасширение(ОбъектРодительскойКонфигурации, НеЗакрывать = Ложь) Экспорт
	
	ОбъектКонфигурации = ДобавитьОбъектКонфигурации(ОбъектРодительскойКонфигурации.Наименование, ОбъектРодительскойКонфигурации.Тип);
	
	Если ОбъектКонфигурации = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ОбъектРасширения = СтруктурыОписаний.СоздатьОбъектДляВключенияВРасширение(ОбъектРодительскойКонфигурации.ПолноеНаименование);
	
	Если ОбъектРодительскойКонфигурации.Описание = Неопределено Тогда
		
		ОбъектРасширения.Наименование = ОбъектКонфигурации.Наименование;

	Иначе
		
		ЗаполнитьЗначенияСвойств(ОбъектРасширения, ОбъектРодительскойКонфигурации.Описание, , "Подчиненные");

	КонецЕсли;

	ОбъектРасширения.Принадлежность = "Adopted";
	
	ОбъектКонфигурации.Описание = ОбъектРасширения;

	Запись = ЗаписатьОписаниеОбъекта(ОбъектКонфигурации, ОбъектКонфигурации.Описание, НеЗакрывать);
	
	Если НеЗакрывать = Истина Тогда
		
		Возврат Запись;
		
	Иначе
		
		Возврат ОбъектКонфигурации;

	КонецЕсли;
	
КонецФункции

Процедура ПеренестиОбъектВРасширениеСПодчиненными(Объект, Атрибуты = Истина, ТабличныеЧасти = Ложь, Формы = Ложь, Команды = Ложь)
	
	Чтение = Новый ЧтениеXML();
	Чтение.ОткрытьФайл(Объект.ПутьКФайлу);
	
	Запись = ПеренестиОбъектВРасширение(Объект, Истина);
	
	Исключения = Новый Структура();
	Исключения.Вставить("standardAttributes", Истина);
	Исключения.Вставить("attributes", НЕ Атрибуты);
	Исключения.Вставить("forms", НЕ Формы);
	Исключения.Вставить("commands", НЕ Команды);
	Исключения.Вставить("tabularSections", НЕ ТабличныеЧасти);
	
	СтекИмен = Новый Соответствие();
	СтекИмен = Новый Соответствие();
	Уровень = -1;
	УровеньЗаписи = 0;
	Пропустить = Ложь;
	
	Пока Чтение.Прочитать() Цикл
		
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента И Исключения.Свойство(Чтение.ЛокальноеИмя, Пропустить) И Пропустить Тогда

			Чтение.Пропустить();
			Продолжить;
			
		КонецЕсли;
		
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			
			Уровень = Уровень + 1;
			СтекИмен.Вставить(Уровень, Чтение.Имя);
			
		ИначеЕсли Чтение.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			
			Уровень = Уровень - 1;
			
			Если Уровень < УровеньЗаписи Тогда
				
				Запись.ЗаписатьКонецЭлемента();
				УровеньЗаписи = Уровень;

			КонецЕсли;

		КонецЕсли;
		
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента И Уровень <> 1 И СтрСравнить(Чтение.ЛокальноеИмя, "name") = 0 Тогда
			
			Для Инд = УровеньЗаписи + 1 По Уровень Цикл
				
				Запись.ЗаписатьНачалоЭлемента(СтекИмен[Инд]);
				
			КонецЦикла;
			
			// Перейдем к значению
			Чтение.Прочитать();

			Запись.ЗаписатьТекст(Чтение.Значение);
			Запись.ЗаписатьКонецЭлемента();

			// Выйдем из тэга name
			Чтение.Прочитать();

			ОбработкаXML.ЗаписатьЗначениеXML(Запись, "objectBelonging", "Adopted");
			
			Если ОбработкаXML.ПерейтиКСледующемуЭлементу(Чтение, "type") Тогда
				
				ОбработкаXML.СкопироватьДанныеXML(Чтение, Запись);

			Иначе
				
				Запись.ЗаписатьКонецЭлемента();
				
			КонецЕсли;
			
			Уровень = Уровень - 1;
			УровеньЗаписи = Уровень;

		КонецЕсли;
		
	КонецЦикла;

	Чтение.Закрыть();
	Запись.Закрыть();

КонецПроцедуры

// Копирует описание объект из другой конфигурации.
//
// Параметры:
//   ОбъектКонфигурации - СтрокаТаблицыЗначений - Описание объекта конфигурации. См. СтруктурыОписаний.ТаблицаОписанияОбъектовКонфигурации
//
//  Возвращаемое значение:
//   СтрокаТаблицыЗначений - Описание добавленного объекта. См. СтруктурыОписаний.ТаблицаОписанияОбъектовКонфигурации
//
Функция СкопироватьОбъект(ОбъектКонфигурации) Экспорт

	НовыйОбъект = ДобавитьОбъект(ОбъектКонфигурации.Наименование, ОбъектКонфигурации.Тип);
	КопироватьФайл(ОбъектКонфигурации.ПутьКФайлу, НовыйОбъект.ПутьКФайлу);
	Возврат НовыйОбъект;

КонецФункции

// Добавляет внешную обработку в конфигурацию
// TODO: необходима переработка
//
// Параметры:
//   КаталогВнешнейОбработки - Строка - Путь до каталога выгрузки внешней обработки
//
//  Возвращаемое значение:
//   СтрокаТаблицыЗначений - Описание добавленного объекта. См. СтруктурыОписаний.ТаблицаОписанияОбъектовКонфигурации
//
Функция ДобавитьВнешнуюОбработку(КаталогВнешнейОбработки) Экспорт
	
	ИмяОбработки = (Новый Файл(КаталогВнешнейОбработки)).Имя;

	Обработка = ДобавитьОбъект(ИмяОбработки, ТипыОбъектовКонфигурации.НормализоватьИмя("Обработка"));
	
	Для Каждого Файл Из НайтиФайлы(КаталогВнешнейОбработки, "*", Истина) Цикл
		
		Если НЕ Файл.ЭтоФайл() Тогда
			
			Продолжить;
			
		КонецЕсли;

		ОтносительныйПуть = СтрЗаменить(Файл.ПолноеИмя, КаталогВнешнейОбработки, "");
		
		ПутьНовогоФайла = ДобавитьФайлОбъекта(Обработка, ОтносительныйПуть, Файл.ПолноеИмя);
		
		Если Файл.Расширение = ".mdo" ИЛИ Файл.Расширение = ".form" Тогда
			
			Текст = Утилиты.ПрочитатьФайл(ПутьНовогоФайла);
			Текст = СтрЗаменить(Текст, "ExternalDataProcessor", "DataProcessor");
			
			Утилиты.ЗаписатьФайл(ПутьНовогоФайла, Текст);
			
		ИначеЕсли СтрСравнить(Файл.Расширение, ".bsl") Тогда
			
			Текст = Утилиты.ПрочитатьФайл(ПутьНовогоФайла);
			Текст = СтрЗаменить(Текст, "ВнешнаяОбработка", "Обработка");
			
			Утилиты.ЗаписатьФайл(ПутьНовогоФайла, Текст);

		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Обработка;
	
КонецФункции

// Добавляет в расширение существующий файл, как общий модуль
//
// Параметры:
//   ИмяМодуля - Строка - <описание параметра>
//   ПараметрыМодуля - Структура - Свойства модуля: Клиент, Сервер, ВызовСервера, ВнешнееСоединение, Привилегированный
//   ИмяФайла - Строка - Путь к добавляемому файлу
//
Процедура ДобавитьМодульОбъекта(ОбъектКонфигурации, ИмяМодуля, ИмяФайла) Экспорт
	
	ИмяФайлаНазначения = СтруктураКаталогов.ИмяФайлаМодуля(ОбъектКонфигурации.Наименование, ОбъектКонфигурации.Тип, ИмяМодуля);
	
	КопироватьФайл(ИмяФайла, ИмяФайлаНазначения);

    Лог.Отладка("Добавлен модуль %3.%1.%2", ОбъектКонфигурации.Наименование, ИмяМодуля, ОбъектКонфигурации.Тип);

КонецПроцедуры

// Добавляет в расширение существующий файл, как общий модуль
//
// Параметры:
//   ИмяМодуля - Строка - <описание параметра>
//   ПараметрыМодуля - Структура - Свойства модуля: Клиент, Сервер, ВызовСервера, ВнешнееСоединение, Привилегированный
//   ИмяФайла - Строка - Путь к добавляемому файлу
//
Процедура ДобавитьОбщийМодуль(ПараметрыМодуля, ИмяФайла) Экспорт
	
	ТипОбщийМодуль = ТипыОбъектовКонфигурации.ИмяТипаОбщийМодуль();

	ОбъектКонфигурации = ДобавитьОбъект(ПараметрыМодуля.Наименование, ТипОбщийМодуль, ПараметрыМодуля);

	ДобавитьМодульОбъекта(ОбъектКонфигурации, "Module", ИмяФайла);

КонецПроцедуры

// Добавляет модуль конфигурации (модуль сеанса, приложения и т.д.)
//
// Параметры:
//   ИмяМодуля - Строка - Тип модуля
//   ИмяФайла - Строка - Имя файла содержащего текст модуля
//
Процедура ДобавитьМодульКонфигурации(ИмяМодуля, ИмяФайла) Экспорт
	
	ИмяФайлаНазначения = СтруктураКаталогов.ИмяФайлаМодуля("Configuration", "Configuration", ИмяМодуля);
	
	КопироватьФайл(ИмяФайла, ИмяФайлаНазначения);

    Лог.Отладка("Добавлен модуль конфигурации %1", ИмяМодуля);

КонецПроцедуры

// Добавляет произвольный файл в расширение, без регистрации и смс
//
// Параметры:
//   ОтносительныйПуть - Строка - Путь в рамках исходников расширения
//   ИсходныйФайл - Строка - Полный путь к добавляемому файлу
//
Процедура ДобавитьФайл(ОтносительныйПуть, ИсходныйФайл) Экспорт
    
    ПолныйПуть = ОбъединитьПути(СтруктураКаталогов.КорневойКаталог(), ОтносительныйПуть);
    Утилиты.СоздатьРекурсивноКаталоги((Новый Файл(ПолныйПуть)).Путь);
    
    КопироватьФайл(ИсходныйФайл, ПолныйПуть);
    
КонецПроцедуры

// Добавляет произвольный файл в расширение, без регистрации и смс
//
// Параметры:
//   ОтносительныйПуть - Строка - Путь в рамках исходников расширения
//   ИсходныйФайл - Строка - Полный путь к добавляемому файлу
//
Функция ДобавитьФайлОбъекта(Объект, ОтносительныйПуть, ИсходныйФайл) Экспорт
    
    ПолныйПуть = ОбъединитьПути(Объект.ПутьККаталогу, ОтносительныйПуть);
	Утилиты.СоздатьРекурсивноКаталоги((Новый Файл(ПолныйПуть)).Путь);
	
	КопироватьФайл(ИсходныйФайл, ПолныйПуть);
	
	Возврат ПолныйПуть;
    
КонецФункции

///////////////////////////////////////////////////////////////////
// Служебный функционал
///////////////////////////////////////////////////////////////////

Процедура ИнициализироватьПеременные(Каталог, Формат)

	СтруктураКаталогов = Новый СтруктураКаталоговКонфигурации(Каталог, Формат, Истина);
	ГенераторОписаний = Новый ГенераторОписаний(Формат, Истина);
	
	Если ОписаниеКонфигурации = Неопределено Тогда
		
		ОписаниеКонфигурации = Новый ОписаниеКонфигурации;

		ОписаниеКонфигурации.СвойстваКонфигурации = СтруктурыОписаний.СоздатьОбъект(ТипыОбъектовКонфигурации.ИмяТипаРасширения(), "Расширение");

	КонецЕсли;
	
	ОписаниеКонфигурации.СвойстваКонфигурации.Принадлежность = "Adopted";
	ОписаниеКонфигурации.СвойстваКонфигурации.Назначение = "Customization";
	
	ИмяФайлаОписания = СтруктураКаталогов.ИмяФайлаОписанияКонфигурации();
	
	ГенераторОписаний.СоздатьОписаниеКорневогоОбъекта(ОписаниеКонфигурации.СвойстваКонфигурации, ТипКорневогоЭлемента, ИмяФайлаОписания);
	
КонецПроцедуры

Функция ЗаписатьОписаниеОбъекта(ОбъектКонфигурации, ДанныеОбъекта, НеЗакрывать = Ложь)
	
	ИмяФайла = СтруктураКаталогов.ИмяФайлаОписанияОбъекта(ОбъектКонфигурации.Наименование, ОбъектКонфигурации.Тип);

	Запись = ГенераторОписаний.СоздатьЗапись(ОбъектКонфигурации.Тип, ИмяФайла);
	
	ОписаниеСвойств = СтруктурыОписаний.ОписаниеСвойствОбъекта(ОбъектКонфигурации.Тип);

	ГенераторОписаний.Генератор.ЗаписатьПорождаемыеТипы(Запись, ДанныеОбъекта.Наименование, ОбъектКонфигурации.Тип);
	ГенераторОписаний.Генератор.ЗаписатьСвойства(Запись, ОбъектКонфигурации.Тип, ДанныеОбъекта);
	
	Если ОписаниеСвойств.ЕстьПодчиненные Тогда
		
		ГенераторОписаний.Генератор.Подчиненные(Запись, ?(ДанныеОбъекта.Свойство("Подчиненные"), ДанныеОбъекта.Подчиненные, Неопределено));
		
	КонецЕсли;
	
	Если НеЗакрывать = Истина Тогда
		
		Возврат Запись;
		
	Иначе
		
		ОбработкаXML.ЗакрытьЗапись(Запись);
		
	КонецЕсли;
	
КонецФункции

Функция ДобавитьОбъектКонфигурации(ИмяОбъекта, Знач ТипОбъекта)
	
	ТипОбъекта = ТипыОбъектовКонфигурации.НормализоватьИмя(ТипОбъекта);
	
	Если ТипОбъекта = ТипыОбъектовКонфигурации.ИмяТипаКонфигурации() Тогда
		Возврат Неопределено;
	КонецЕсли;

	НайденныеОбъекты = ОписаниеКонфигурации.ОбъектыКонфигурации.НайтиСтроки(Новый Структура("Наименование, Тип", ИмяОбъекта, ТипОбъекта));
	
	Если НайденныеОбъекты.Количество() Тогда
		
		ОбъектКонфигурации = НайденныеОбъекты[0];
		
	Иначе
		
		ОбъектКонфигурации = ОписаниеКонфигурации.ОбъектыКонфигурации.Добавить();
		
		ОбъектКонфигурации.Наименование = ИмяОбъекта;
		ОбъектКонфигурации.Тип = ТипОбъекта;
		ОбъектКонфигурации.ПутьКФайлу = СтруктураКаталогов.ИмяФайлаОписанияОбъекта(ИмяОбъекта, ТипОбъекта);
		ОбъектКонфигурации.ПутьККаталогу = СтруктураКаталогов.КаталогФайловОбъекта(ИмяОбъекта, ТипОбъекта);
		
	КонецЕсли;

	Возврат ОбъектКонфигурации;

КонецФункции

Процедура ПриСозданииОбъекта(пТипКорневогоЭлемента)

	Лог = ПараметрыПродукта.ПолучитьЛог();
	
	ТипКорневогоЭлемента = пТипКорневогоЭлемента;

КонецПроцедуры
