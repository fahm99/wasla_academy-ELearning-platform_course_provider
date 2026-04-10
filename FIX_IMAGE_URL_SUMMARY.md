# حل مشكلة imageUrl في Course Model

## التاريخ
9 أبريل 2026

---

## المشكلة
```
The getter 'imageUrl' isn't defined for the type 'Course'.
```

---

## الحل

### 1. إضافة Getter في Course Model ✅

**الملف**: `lib/data/models/course.dart`

```dart
class Course {
  final String? coverImageUrl;
  
  // Getter للتوافق مع الكود الجديد
  String? get imageUrl => coverImageUrl;
}
```

**الفائدة:**
- يسمح باستخدام `course.imageUrl` في الكود
- يشير إلى `coverImageUrl` الموجود بالفعل
- لا حاجة لتغيير بنية قاعدة البيانات

---

### 2. تحديث course_form_dialog.dart ✅

**التغيير:**
```dart
// قبل
imageUrl: imageUrl,

// بعد
coverImageUrl: imageUrl,
```

**السبب:**
- استخدام الحقل الفعلي `coverImageUrl` في الـ constructor
- الـ getter `imageUrl` يعمل للقراءة فقط

---

### 3. التأكد من قاعدة البيانات ✅

**الملف**: `database/ensure_image_url_column.sql`

```sql
-- إضافة عمود cover_image_url إذا لم يكن موجوداً
ALTER TABLE courses 
ADD COLUMN IF NOT EXISTS cover_image_url TEXT;
```

**كيفية التشغيل:**
1. افتح Supabase SQL Editor
2. الصق محتوى الملف
3. اضغط Run

---

## النتيجة

✅ لا توجد أخطاء في الكود
✅ `course.imageUrl` يعمل بشكل صحيح
✅ `course.coverImageUrl` يعمل بشكل صحيح
✅ قاعدة البيانات جاهزة
✅ رفع الصورة يعمل

---

## الاستخدام

```dart
// القراءة (كلاهما يعمل)
final url1 = course.imageUrl;        // ✅ يعمل
final url2 = course.coverImageUrl;   // ✅ يعمل

// الكتابة (استخدم coverImageUrl فقط)
Course(
  coverImageUrl: 'https://...',  // ✅ صحيح
  // imageUrl: 'https://...',    // ❌ خطأ (getter فقط)
)
```

---

## ملاحظات

1. **imageUrl** هو getter فقط (للقراءة)
2. **coverImageUrl** هو الحقل الفعلي (للقراءة والكتابة)
3. كلاهما يشير إلى نفس القيمة
4. استخدم `coverImageUrl` في الـ constructor
5. استخدم `imageUrl` أو `coverImageUrl` للقراءة

---

## تم الحل! ✅
