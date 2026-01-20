# TestApp - News Aggregator

iOS приложение-агрегатор новостей с поддержкой RSS, локальным кешированием и современным UI.

- Загрузка новостей из RSS-источников
- Локальное кеширование с использованием Realm
- Кеширование изображений
- Автоматическое обновление новостей по таймеру
- Управление источниками новостей
- Два режима отображения: компактный и расширенный
- Асинхронный рендеринг UI с Texture (AsyncDisplayKit)

## Технологии

- **Swift 5**
- **iOS 15.0+**
- **Архитектура**: MVVM + Coordinator Pattern
- **UI Framework**: Texture (AsyncDisplayKit)
- **База данных**: RealmSwift 10.0
- **Менеджер зависимостей**: CocoaPods

## Установка

1. Клонируйте репозиторий:
```bash
git clone <repository-url>
cd NewsAggregator
```

2. Установите зависимости через CocoaPods:
```bash
pod install
```

3. Откройте workspace:
```bash
open TestApp.xcworkspace
```

4. Соберите и запустите проект (⌘R)

## Источники новостей по умолчанию

- **Ведомости**: https://www.vedomosti.ru/rss/news.xml
- **РБК**: https://rssexport.rbc.ru/rbcnews/news/30/full.rss

Можно добавлять собственные RSS-источники через настройки приложения.

## Тестирование

Запуск unit-тестов:
```bash
⌘U в Xcode
```

Покрытие:
- `NewsItemTests` - тесты модели
- `RSSParserTests` - парсинг RSS
- `NewsListViewModelTests` - бизнес-логика

