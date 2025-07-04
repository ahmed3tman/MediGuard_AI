# ملخص الفايلات الغير مستخدمة في مشروع Spider Doctor

## الفايلات المعلمة كغير مستخدمة

### 1. Theme Files (ملفات التصميم)

- `/lib/core/share/theme/my_images.dart` - غير مستخدم
- `/lib/core/share/theme/my_colors.dart` - غير مستخدم

### 2. Auth View Files (ملفات واجهة تسجيل الدخول القديمة)

- `/lib/features/auth/view/screen/login_screen.dart` - غير مستخدم (يوجد نسخة أخرى مستخدمة)
- `/lib/features/auth/view/screen/signup_screen.dart` - غير مستخدم
- `/lib/features/auth/view/widget/custom_text_field.dart` - غير مستخدم
- `/lib/features/auth/view/widget/custom_auth_button.dart` - غير مستخدم
- `/lib/features/auth/view/widget/custom_social_button.dart` - غير مستخدم
- `/lib/features/auth/data/auth.dart` - غير مستخدم

### 3. Home View Files (ملفات واجهة الرئيسية القديمة)

- `/lib/features/home/view/screen/home.dart` - غير مستخدم (يوجد نسخة أخرى مستخدمة)

### 4. Widget Files (ملفات الويدجت الفارغة)

- `/lib/features/home/widgets/device_card_clean.dart` - ملف فارغ
- `/lib/features/home/widgets/vital_sign_tile.dart` - ملف فارغ
- `/lib/features/home/widgets/device_status_indicator.dart` - ملف فارغ
- `/lib/features/home/widgets/delete_device_button.dart` - ملف فارغ

### 5. Core Files (ملفات الأساسية)

- `/lib/core/firebase_initializer.dart` - ملف فارغ

### 6. Test Files (ملفات الاختبار)

- `/test/widget_test.dart` - غير مستخدم في الإنتاج

## الفايلات المستخدمة بالفعل

- `/lib/main.dart` - نقطة بداية التطبيق
- `/lib/my_app.dart` - التطبيق الرئيسي
- `/lib/firebase_options.dart` - إعدادات Firebase
- `/lib/features/auth/services/auth_service.dart` - خدمة المصادقة
- `/lib/features/auth/screens/login_screen.dart` - شاشة تسجيل الدخول المستخدمة
- `/lib/features/home/screens/home_screen.dart` - الشاشة الرئيسية المستخدمة
- `/lib/features/home/screens/add_device_screen.dart` - شاشة إضافة جهاز
- `/lib/features/home/widgets/device_card.dart` - كارت الجهاز
- `/lib/features/home/bloc/*` - جميع ملفات BLoC
- `/lib/features/home/model/data_model.dart` - نموذج البيانات
- `/lib/features/home/services/device_service.dart` - خدمة الأجهزة

## ملاحظات

- جميع الفايلات الغير مستخدمة تم تعليمها بتعليق واضح في بداية الملف
- يمكن حذف هذه الفايلات بأمان لتنظيف المشروع
- بعض الفايلات كانت فارغة أو تحتوي على كود قديم غير مستخدم
