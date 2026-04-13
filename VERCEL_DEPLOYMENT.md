# دليل رفع المشروع على Vercel

## المتطلبات الأساسية
1. حساب على [Vercel](https://vercel.com)
2. تثبيت Flutter SDK
3. تثبيت Vercel CLI (اختياري)

## خطوات الرفع

### الطريقة الأولى: عبر واجهة Vercel (الأسهل)

1. ادخل إلى [vercel.com](https://vercel.com) وسجل الدخول
2. اضغط على "Add New Project"
3. اربط حساب GitHub/GitLab/Bitbucket الخاص بك
4. اختر هذا المشروع من القائمة
5. Vercel سيكتشف الإعدادات تلقائياً من ملف `vercel.json`
6. اضغط على "Deploy"

### الطريقة الثانية: عبر Vercel CLI

1. ثبت Vercel CLI:
```bash
npm install -g vercel
```

2. سجل الدخول:
```bash
vercel login
```

3. ارفع المشروع:
```bash
vercel
```

4. اتبع التعليمات التفاعلية

## بناء المشروع محلياً (للاختبار)

```bash
flutter build web --release --web-renderer canvaskit
```

## ملاحظات مهمة

1. تأكد من إضافة متغيرات البيئة في Vercel:
   - SUPABASE_URL
   - SUPABASE_ANON_KEY
   - أي متغيرات أخرى يحتاجها المشروع

2. الملفات المهمة:
   - `vercel.json`: إعدادات Vercel
   - `web/index.html`: صفحة HTML الرئيسية
   - `web/manifest.json`: إعدادات PWA

3. بعد الرفع، يمكنك الوصول للموقع عبر الرابط الذي يوفره Vercel

## استكشاف الأخطاء

- إذا فشل البناء، تحقق من سجلات البناء في Vercel
- تأكد من أن جميع التبعيات محدثة في `pubspec.yaml`
- تحقق من أن Flutter SDK محدث
