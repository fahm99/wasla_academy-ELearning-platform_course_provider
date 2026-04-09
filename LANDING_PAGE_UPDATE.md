# تحديث صفحة الهبوط (Landing Page)

## التاريخ
9 أبريل 2026

## الملخص
تم إصلاح جميع الأخطاء في صفحة الهبوط وجعلها الشاشة الأولى عند تشغيل التطبيق، مع ربط جميع أزرار "ابدأ الآن كمقدم خدمة" بشاشة تسجيل الدخول واستبدال الصور الخارجية بصور محلية.

---

## التغييرات المنفذة

### 1. إصلاح الأخطاء في landing.dart ✅

#### خطأ inverseOnSurface
- **المشكلة**: استخدام `inverseOnSurface` غير المدعوم في ColorScheme
- **الحل**: تم استبداله بـ `onInverseSurface`

#### خطأ نوع البيانات في _buildStepCard
- **المشكلة**: تعريف الدالة بـ `Map<String, String>` بينما البيانات تحتوي على `IconData`
- **الحل**: تم تغيير نوع البيانات إلى `Map<String, dynamic>`
- **التحديثات**:
  - تحديث تعريف الدالة
  - تحديث قائمة steps لاستخدام IconData مباشرة بدلاً من String
  - حذف دالة `_getIconData()` التي لم تعد مطلوبة

### 2. استبدال الصور في _buildPhoneMockup ✅

#### قبل التحديث
```dart
_buildPhoneMockup(context, 'https://lh3.googleusercontent.com/...')
```

#### بعد التحديث
```dart
_buildPhoneMockup(context, 'assets/mobile/waslasplash.jpg')
_buildPhoneMockup(context, 'assets/mobile/home.jpg')
_buildPhoneMockup(context, 'assets/mobile/course.jpg')
```

#### التغييرات في الدالة
- تم تغيير اسم المعامل من `imageUrl` إلى `imagePath`
- تم استبدال `Image.network()` بـ `Image.asset()`
- استخدام الصور المحلية من مجلد `assets/mobile/`

### 3. ربط أزرار "ابدأ الآن كمقدم خدمة" بشاشة تسجيل الدخول ✅

#### إضافة دالة التنقل
```dart
void _navigateToAuth(BuildContext context) {
  Navigator.pushReplacementNamed(context, '/auth');
}
```

#### الأزرار المحدثة (5 أزرار)
1. **زر في شريط التنقل العلوي (NavBar)**
   - النص: "ابدأ الآن كمقدم خدمة"
   - الموقع: أعلى الصفحة

2. **زر في قسم Hero**
   - النص: "ابدأ الآن كمقدم خدمة"
   - الموقع: القسم الرئيسي الأول

3. **زر في قسم "للخبراء والمدربين"**
   - النص: "ابدأ الآن كمقدم خدمة"
   - الموقع: قسم مقدمي الخدمات

4. **زر في قسم Call-to-Action**
   - النص: "ابدأ الآن كمقدم خدمة"
   - الموقع: قبل Footer

جميع الأزرار الآن تستدعي `_navigateToAuth(context)` عند الضغط عليها.

### 4. جعل Landing Page الشاشة الأولى ✅

#### التحديثات في app_router.dart

**قبل التحديث:**
```dart
initialLocation: '/splash',
```

**بعد التحديث:**
```dart
initialLocation: '/',
routes: [
  // صفحة الهبوط (Landing Page) - الشاشة الأولى
  GoRoute(
    path: '/',
    name: 'landing',
    builder: (context, state) => const WaslaHomePage(),
  ),
  // ... باقي المسارات
]
```

#### الإضافات
- تم إضافة import لـ `landing.dart`
- تم إنشاء مسار جديد للـ landing page على المسار `/`
- تم تغيير `initialLocation` ليشير إلى `/`

---

## الملفات المعدلة

### 1. lib/presentation/screens/landing.dart
- إصلاح خطأ `inverseOnSurface` → `onInverseSurface`
- إضافة دالة `_navigateToAuth()`
- تحديث جميع أزرار "ابدأ الآن كمقدم خدمة" (5 أزرار)
- تحديث `_buildPhoneMockup()` لاستخدام الصور المحلية
- تحديث `_buildStepCard()` لقبول `Map<String, dynamic>`
- تحديث قائمة `steps` لاستخدام IconData مباشرة
- حذف دالة `_getIconData()`

### 2. lib/core/routing/app_router.dart
- إضافة import: `import '../../presentation/screens/landing.dart';`
- تغيير `initialLocation` من `/splash` إلى `/`
- إضافة مسار جديد للـ landing page

---

## النتائج

### الأخطاء المصلحة ✅
- ✅ خطأ `inverseOnSurface` غير معرف
- ✅ خطأ نوع البيانات في `_buildStepCard`
- ✅ جميع الأخطاء تم إصلاحها

### التحذيرات المتبقية ⚠️
- 4 تحذيرات فقط عن متغيرات `colorScheme` غير مستخدمة (تحذيرات بسيطة وليست أخطاء)

### الوظائف الجديدة ✅
- ✅ Landing page هي الشاشة الأولى عند تشغيل التطبيق
- ✅ جميع أزرار "ابدأ الآن كمقدم خدمة" تنقل إلى شاشة تسجيل الدخول
- ✅ استخدام الصور المحلية من assets/mobile بدلاً من الصور الخارجية
- ✅ تجربة مستخدم محسنة مع صور التطبيق الفعلية

---

## الصور المستخدمة

### من مجلد assets/mobile/
1. **waslasplash.jpg** - شاشة البداية
2. **home.jpg** - الشاشة الرئيسية
3. **course.jpg** - شاشة الكورس

---

## تدفق التنقل الجديد

```
تشغيل التطبيق
    ↓
Landing Page (/)
    ↓
[الضغط على "ابدأ الآن كمقدم خدمة"]
    ↓
Auth Screen (/auth)
    ↓
[تسجيل الدخول بنجاح]
    ↓
Main Screen (/main)
```

---

## الاختبار

### للتحقق من التحديثات:
1. قم بتشغيل التطبيق
2. يجب أن تظهر Landing Page أولاً
3. اضغط على أي زر "ابدأ الآن كمقدم خدمة"
4. يجب أن تنتقل إلى شاشة تسجيل الدخول
5. تحقق من ظهور الصور المحلية في قسم معاينة التطبيق

---

## ملاحظات

- جميع الأخطاء تم إصلاحها بنجاح
- التطبيق جاهز للتشغيل بدون أخطاء
- تم الحفاظ على جميع الوظائف الموجودة
- تم تحسين تجربة المستخدم باستخدام الصور المحلية
