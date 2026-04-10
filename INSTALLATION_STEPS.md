# خطوات التثبيت والتشغيل

## التاريخ
9 أبريل 2026

---

## الخطوات المطلوبة

### 1. تثبيت المكتبات

```bash
# في terminal، في مجلد المشروع
flutter pub get
```

إذا ظهرت أخطاء، جرب:
```bash
flutter clean
flutter pub get
```

---

### 2. إضافة حقل imageUrl في Course Model

افتح `lib/data/models/course.dart` وأضف:

```dart
class Course {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;  // ← أضف هذا السطر
  // ... باقي الحقول
  
  Course({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,  // ← أضف هذا السطر
    // ... باقي الحقول
  });
  
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],  // ← أضف هذا السطر
      // ... باقي الحقول
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,  // ← أضف هذا السطر
      // ... باقي الحقول
    };
  }
}
```

---

### 3. تحديث جدول courses في قاعدة البيانات

في Supabase SQL Editor، شغّل:

```sql
-- إضافة عمود image_url إلى جدول courses
ALTER TABLE courses 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- إضافة تعليق
COMMENT ON COLUMN courses.image_url IS 'رابط الصورة التعريفية للكورس';
```

---

### 4. للأندرويد - تحديث الصلاحيات

افتح `android/app/src/main/AndroidManifest.xml` وأضف:

```xml
<manifest ...>
    <!-- أضف هذه الأسطر قبل <application> -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <application ...>
        ...
    </application>
</manifest>
```

---

### 5. لـ iOS - تحديث Info.plist

افتح `ios/Runner/Info.plist` وأضف:

```xml
<dict>
    <!-- أضف هذه الأسطر -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>نحتاج للوصول إلى معرض الصور لاختيار الفيديوهات والصور</string>
    
    <key>NSCameraUsageDescription</key>
    <string>نحتاج للوصول إلى الكاميرا لتصوير الفيديوهات</string>
    
    <key>NSMicrophoneUsageDescription</key>
    <string>نحتاج للوصول إلى الميكروفون لتسجيل الصوت</string>
    
    <!-- باقي المحتوى -->
</dict>
```

---

### 6. تشغيل التطبيق

```bash
# للويب
flutter run -d chrome

# للأندرويد
flutter run -d android

# لـ iOS
flutter run -d ios

# للويندوز
flutter run -d windows
```

---

## التحقق من التثبيت

### 1. اختبار رفع صورة الكورس:
1. افتح التطبيق
2. اذهب إلى "الكورسات"
3. اضغط "إضافة كورس جديد"
4. اضغط على منطقة رفع الصورة
5. اختر صورة
6. يجب أن تظهر معاينة الصورة ✅

### 2. اختبار رفع درس فيديو:
1. افتح كورس
2. اذهب إلى "إدارة المحتوى"
3. أضف وحدة جديدة
4. أضف درس جديد
5. اختر نوع "فيديو"
6. اختر ملف فيديو
7. يجب أن يتم ملء الحقول تلقائياً ✅
8. اضغط "حفظ"
9. يجب أن يظهر مؤشر التقدم ✅

---

## حل المشاكل

### مشكلة: "Target of URI doesn't exist: 'package:video_compress'"
**الحل**:
```bash
flutter clean
flutter pub get
```

### مشكلة: "The getter 'imageUrl' isn't defined"
**الحل**: أضف حقل `imageUrl` في Course Model (راجع الخطوة 2)

### مشكلة: "Failed to compress video"
**الحل**: 
- للأندرويد: تأكد من الصلاحيات في AndroidManifest.xml
- لـ iOS: تأكد من Info.plist محدث
- جرب:
```bash
cd android && ./gradlew clean && cd ..
# أو
cd ios && pod install && cd ..
```

### مشكلة: "Cannot extract video duration"
**الحل**: استخدم ملف فيديو بصيغة MP4 أو MOV

---

## ملاحظات مهمة

### للويب (Flutter Web):
- ضغط الفيديو لن يعمل (قيود المتصفح)
- استخراج مدة الفيديو محدود
- استخدم ملفات مضغوطة مسبقاً

### للموبايل والديسكتوب:
- جميع الميزات تعمل بشكل كامل
- ضغط الفيديو فعال
- استخراج المعلومات دقيق

---

## الخلاصة

بعد تنفيذ هذه الخطوات، ستكون جميع الميزات جاهزة:

✅ رفع صورة الكورس
✅ مؤشر التقدم
✅ ضغط الفيديو
✅ استخراج معلومات الفيديو
✅ الملء التلقائي للحقول

إذا واجهت أي مشاكل، راجع ملف `FINAL_FEATURES_GUIDE.md` للتفاصيل الكاملة.
