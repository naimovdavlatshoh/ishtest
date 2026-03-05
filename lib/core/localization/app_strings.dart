// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

/// Supported languages
enum AppLanguage { uz, ru, en }

extension AppLanguageExt on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.uz: return 'uz';
      case AppLanguage.ru: return 'ru';
      case AppLanguage.en: return 'en';
    }
  }
  String get label {
    switch (this) {
      case AppLanguage.uz: return "O'zbek";
      case AppLanguage.ru: return 'Русский';
      case AppLanguage.en: return 'English';
    }
  }
  String get flag {
    switch (this) {
      case AppLanguage.uz: return '🇺🇿';
      case AppLanguage.ru: return '🇷🇺';
      case AppLanguage.en: return '🇬🇧';
    }
  }
  Locale get locale {
    switch (this) {
      case AppLanguage.uz: return const Locale('uz', 'UZ');
      case AppLanguage.ru: return const Locale('ru', 'RU');
      case AppLanguage.en: return const Locale('en', 'US');
    }
  }
  static AppLanguage fromCode(String code) {
    switch (code) {
      case 'ru': return AppLanguage.ru;
      case 'en': return AppLanguage.en;
      default:   return AppLanguage.uz;
    }
  }
}

/// All static UI strings in 3 languages
class AppStrings {
  static const Map<String, Map<String, String>> _strings = {

    // ── Auth ────────────────────────────────────────────────────────────────
    'welcome': {
      'uz': 'Xush kelibsiz',
      'ru': 'Добро пожаловать',
      'en': 'Welcome',
    },
    'login': {
      'uz': 'Kirish',
      'ru': 'Войти',
      'en': 'Login',
    },
    'register': {
      'uz': "Ro'yxatdan o'tish",
      'ru': 'Регистрация',
      'en': 'Register',
    },
    'email': {
      'uz': 'Elektron pochta',
      'ru': 'Эл. почта',
      'en': 'Email',
    },
    'password': {
      'uz': 'Parol',
      'ru': 'Пароль',
      'en': 'Password',
    },
    'full_name': {
      'uz': "To'liq ism",
      'ru': 'Полное имя',
      'en': 'Full Name',
    },
    'forgot_password': {
      'uz': 'Parolni unutdingizmi?',
      'ru': 'Забыли пароль?',
      'en': 'Forgot Password?',
    },
    'dont_have_account': {
      'uz': "Akkauntingiz yo'qmi?",
      'ru': 'Нет аккаунта?',
      'en': "Don't have an account?",
    },
    'already_have_account': {
      'uz': 'Akkauntingiz bormi?',
      'ru': 'Уже есть аккаунт?',
      'en': 'Already have an account?',
    },
    'sign_up': {
      'uz': "Ro'yxatdan o'tish",
      'ru': 'Зарегистрироваться',
      'en': 'Sign Up',
    },
    'sign_in': {
      'uz': 'Tizimga kirish',
      'ru': 'Войти',
      'en': 'Sign In',
    },
    'logout': {
      'uz': 'Chiqish',
      'ru': 'Выйти',
      'en': 'Logout',
    },
    'enter_email': {
      'uz': 'Emailingizni kiriting',
      'ru': 'Введите Email',
      'en': 'Enter your email',
    },
    'enter_password': {
      'uz': 'Parolni kiriting',
      'ru': 'Введите пароль',
      'en': 'Enter your password',
    },
    'enter_full_name': {
      'uz': "To'liq ismingizni kiriting",
      'ru': 'Введите полное имя',
      'en': 'Enter your full name',
    },

    // ── Navigation / Sidebar ─────────────────────────────────────────────────
    'feed': {
      'uz': 'Yangiliklar',
      'ru': 'Лента',
      'en': 'Feed',
    },
    'chat': {
      'uz': 'Xabarlar',
      'ru': 'Сообщения',
      'en': 'Messages',
    },
    'jobs': {
      'uz': 'Vakansiyalar',
      'ru': 'Вакансии',
      'en': 'Jobs',
    },
    'employees': {
      'uz': 'Xodimlar',
      'ru': 'Сотрудники',
      'en': 'Employees',
    },
    'companies': {
      'uz': 'Kompaniyalar',
      'ru': 'Компании',
      'en': 'Companies',
    },
    'my_profile': {
      'uz': 'Mening profilim',
      'ru': 'Мой профиль',
      'en': 'My Profile',
    },
    'invitations': {
      'uz': 'Takliflar',
      'ru': 'Приглашения',
      'en': 'Invitations',
    },
    'my_applications': {
      'uz': 'Mening arizalarim',
      'ru': 'Мои заявки',
      'en': 'My Applications',
    },
    'saved_jobs': {
      'uz': "Saqlangan ish e'lonlari",
      'ru': 'Сохранённые вакансии',
      'en': 'Saved Jobs',
    },
    'my_jobs': {
      'uz': "Mening e'lonlarim",
      'ru': 'Мои вакансии',
      'en': 'My Jobs',
    },
    'my_companies': {
      'uz': 'Mening kompaniyalarim',
      'ru': 'Мои компании',
      'en': 'My Companies',
    },
    'settings': {
      'uz': 'Sozlamalar',
      'ru': 'Настройки',
      'en': 'Settings',
    },
    'profile_settings': {
      'uz': 'Profil sozlamalari',
      'ru': 'Настройки профиля',
      'en': 'Profile Settings',
    },
    'visibility': {
      'uz': "Ko'rinish",
      'ru': 'Видимость',
      'en': 'Visibility',
    },
    'my_resume': {
      'uz': 'Mening rezyumem',
      'ru': 'Мое резюме',
      'en': 'My Resume',
    },

    // ── Common ───────────────────────────────────────────────────────────────
    'save': {
      'uz': 'Saqlash',
      'ru': 'Сохранить',
      'en': 'Save',
    },
    'cancel': {
      'uz': 'Bekor qilish',
      'ru': 'Отмена',
      'en': 'Cancel',
    },
    'confirm': {
      'uz': 'Tasdiqlash',
      'ru': 'Подтвердить',
      'en': 'Confirm',
    },
    'delete': {
      'uz': "O'chirish",
      'ru': 'Удалить',
      'en': 'Delete',
    },
    'edit': {
      'uz': 'Tahrirlash',
      'ru': 'Редактировать',
      'en': 'Edit',
    },
    'search': {
      'uz': 'Qidirish',
      'ru': 'Поиск',
      'en': 'Search',
    },
    'send': {
      'uz': 'Yuborish',
      'ru': 'Отправить',
      'en': 'Send',
    },
    'loading': {
      'uz': 'Yuklanmoqda...',
      'ru': 'Загрузка...',
      'en': 'Loading...',
    },
    'error': {
      'uz': 'Xatolik yuz berdi',
      'ru': 'Произошла ошибка',
      'en': 'An error occurred',
    },
    'retry': {
      'uz': 'Qayta urinish',
      'ru': 'Повторить',
      'en': 'Retry',
    },
    'today': {
      'uz': 'Bugun',
      'ru': 'Сегодня',
      'en': 'Today',
    },
    'yesterday': {
      'uz': 'Kecha',
      'ru': 'Вчера',
      'en': 'Yesterday',
    },
    'type_message': {
      'uz': 'Xabar yozing...',
      'ru': 'Написать сообщение...',
      'en': 'Type a message...',
    },
    'no_results': {
      'uz': 'Natija topilmadi',
      'ru': 'Результаты не найдены',
      'en': 'No results found',
    },
    'back': {
      'uz': 'Orqaga',
      'ru': 'Назад',
      'en': 'Back',
    },
    'yes': {
      'uz': 'Ha',
      'ru': 'Да',
      'en': 'Yes',
    },
    'no': {
      'uz': "Yo'q",
      'ru': 'Нет',
      'en': 'No',
    },
    'all': {
      'uz': 'Barchasi',
      'ru': 'Все',
      'en': 'All',
    },
    'filter': {
      'uz': 'Filter',
      'ru': 'Фильтр',
      'en': 'Filter',
    },
    'apply_filter': {
      'uz': 'Filterni qo\'llash',
      'ru': 'Применить фильтр',
      'en': 'Apply Filter',
    },
    'clear_filter': {
      'uz': 'Filterni tozalash',
      'ru': 'Очистить фильтр',
      'en': 'Clear Filter',
    },
    'language': {
      'uz': 'Til',
      'ru': 'Язык',
      'en': 'Language',
    },
    'select_language': {
      'uz': 'Tilni tanlang',
      'ru': 'Выберите язык',
      'en': 'Select Language',
    },

    // ── Feed ─────────────────────────────────────────────────────────────────
    'write_post': {
      'uz': 'Post yozing...',
      'ru': 'Написать пост...',
      'en': 'Write a post...',
    },
    'share_thoughts': {
      'uz': 'Fikrlaringizni ulashing',
      'ru': 'Поделитесь мыслями',
      'en': 'Share your thoughts',
    },
    'like': {
      'uz': 'Yoqdi',
      'ru': 'Нравится',
      'en': 'Like',
    },
    'comment': {
      'uz': 'Izoh',
      'ru': 'Комментарий',
      'en': 'Comment',
    },
    'share': {
      'uz': 'Ulashish',
      'ru': 'Поделиться',
      'en': 'Share',
    },
    'publish': {
      'uz': 'Chop etish',
      'ru': 'Опубликовать',
      'en': 'Publish',
    },
    'post_hint': {
      'uz': 'Nima haqida yozmoqchisiz?',
      'ru': 'О чём хотите написать?',
      'en': 'What do you want to write about?',
    },
    'no_posts': {
      'uz': 'Hozircha post yo\'q',
      'ru': 'Пока нет постов',
      'en': 'No posts yet',
    },

    // ── Jobs ─────────────────────────────────────────────────────────────────
    'apply': {
      'uz': 'Ariza berish',
      'ru': 'Откликнуться',
      'en': 'Apply',
    },
    'applied': {
      'uz': 'Ariza berilgan',
      'ru': 'Заявка отправлена',
      'en': 'Applied',
    },
    'saved': {
      'uz': 'Saqlangan',
      'ru': 'Сохранено',
      'en': 'Saved',
    },
    'salary': {
      'uz': 'Maosh',
      'ru': 'Зарплата',
      'en': 'Salary',
    },
    'salary_negotiable': {
      'uz': 'Maosh kelishiladi',
      'ru': 'Зарплата по договорённости',
      'en': 'Salary Negotiable',
    },
    'job_type': {
      'uz': 'Ish turi',
      'ru': 'Тип занятости',
      'en': 'Job Type',
    },
    'location': {
      'uz': 'Joylashuv',
      'ru': 'Местоположение',
      'en': 'Location',
    },
    'full_time': {
      'uz': "To'liq stavka",
      'ru': 'Полная занятость',
      'en': 'Full Time',
    },
    'part_time': {
      'uz': 'Yarim stavka',
      'ru': 'Частичная занятость',
      'en': 'Part Time',
    },
    'remote': {
      'uz': 'Masofaviy',
      'ru': 'Удалённо',
      'en': 'Remote',
    },
    'internship': {
      'uz': 'Stajirovka',
      'ru': 'Стажировка',
      'en': 'Internship',
    },
    'contract': {
      'uz': 'Shartnoma',
      'ru': 'Контракт',
      'en': 'Contract',
    },
    'cover_letter': {
      'uz': "Qo'shma xat",
      'ru': 'Сопроводительное письмо',
      'en': 'Cover Letter',
    },
    'write_cover_letter': {
      'uz': "Qo'shma xat yozing...",
      'ru': 'Напишите сопроводительное письмо...',
      'en': 'Write a cover letter...',
    },
    'job_description': {
      'uz': "Vakansiya haqida",
      'ru': 'Описание вакансии',
      'en': 'Job Description',
    },
    'requirements': {
      'uz': 'Talablar',
      'ru': 'Требования',
      'en': 'Requirements',
    },
    'no_jobs': {
      'uz': 'Vakansiya topilmadi',
      'ru': 'Вакансии не найдены',
      'en': 'No jobs found',
    },
    'add_job': {
      'uz': "Vakansiya qo'shish",
      'ru': 'Добавить вакансию',
      'en': 'Add Job',
    },
    'view_count': {
      'uz': "Ko'rishlar soni",
      'ru': 'Количество просмотров',
      'en': 'View Count',
    },
    'withdraw': {
      'uz': 'Qaytarib olish',
      'ru': 'Отозвать',
      'en': 'Withdraw',
    },
    'withdraw_confirm': {
      'uz': 'Arizani qaytarib olish',
      'ru': 'Отозвать заявку',
      'en': 'Withdraw Application',
    },
    'withdraw_confirm_msg': {
      'uz': "Haqiqatan ham bu arizani qaytarib olmoqchimisiz? Bu amalni ortga qaytarib bo'lmaydi.",
      'ru': 'Вы действительно хотите отозвать эту заявку? Это действие нельзя отменить.',
      'en': 'Are you sure you want to withdraw this application? This action cannot be undone.',
    },
    'yes_withdraw': {
      'uz': 'Ha, qaytarib olish',
      'ru': 'Да, отозвать',
      'en': 'Yes, Withdraw',
    },

    // ── Applications Status ───────────────────────────────────────────────────
    'status_pending': {
      'uz': "Ko'rib chiqilmoqda",
      'ru': 'На рассмотрении',
      'en': 'Under Review',
    },
    'status_accepted': {
      'uz': 'Qabul qilindi',
      'ru': 'Принято',
      'en': 'Accepted',
    },
    'status_rejected': {
      'uz': 'Rad etildi',
      'ru': 'Отклонено',
      'en': 'Rejected',
    },
    'total': {
      'uz': 'Jami',
      'ru': 'Всего',
      'en': 'Total',
    },
    'pending': {
      'uz': 'Kutilmoqda',
      'ru': 'Ожидание',
      'en': 'Pending',
    },
    'accepted': {
      'uz': 'Qabul',
      'ru': 'Принято',
      'en': 'Accepted',
    },
    'rejected': {
      'uz': 'Rad',
      'ru': 'Отклонено',
      'en': 'Rejected',
    },
    'track_applications': {
      'uz': 'Ish arizalaring kuzatish',
      'ru': 'Отслеживание заявок на работу',
      'en': 'Track your job applications',
    },
    'no_applications': {
      'uz': "Hali ariza yo'q",
      'ru': 'Пока нет заявок',
      'en': 'No applications yet',
    },
    'go_to_jobs': {
      'uz': "Vakansiyalarga o't",
      'ru': 'Перейти к вакансиям',
      'en': 'Go to Jobs',
    },
    'applied_on': {
      'uz': 'Ariza yuborilgan',
      'ru': 'Заявка отправлена',
      'en': 'Applied on',
    },

    // ── Chat ─────────────────────────────────────────────────────────────────
    'no_chats': {
      'uz': "Hali xabarlar yo'q",
      'ru': 'Пока нет сообщений',
      'en': 'No messages yet',
    },
    'new_message': {
      'uz': 'Yangi xabar',
      'ru': 'Новое сообщение',
      'en': 'New Message',
    },
    'unread': {
      'uz': "O'qilmagan",
      'ru': 'Непрочитанное',
      'en': 'Unread',
    },

    // ── Invitations ──────────────────────────────────────────────────────────
    'received_invitations': {
      'uz': 'Qabul qilingan',
      'ru': 'Полученные',
      'en': 'Received',
    },
    'sent_invitations': {
      'uz': 'Yuborilgan',
      'ru': 'Отправленные',
      'en': 'Sent',
    },
    'accept': {
      'uz': 'Qabul qilish',
      'ru': 'Принять',
      'en': 'Accept',
    },
    'reject': {
      'uz': 'Rad etish',
      'ru': 'Отклонить',
      'en': 'Reject',
    },
    'open_chat': {
      'uz': 'Chatni ochish',
      'ru': 'Открыть чат',
      'en': 'Open Chat',
    },
    'invitation_message': {
      'uz': 'Xabar',
      'ru': 'Сообщение',
      'en': 'Message',
    },
    'no_invitations': {
      'uz': "Hali takliflar yo'q",
      'ru': 'Пока нет приглашений',
      'en': 'No invitations yet',
    },
    'sent_on': {
      'uz': 'Yuborilgan',
      'ru': 'Отправлено',
      'en': 'Sent on',
    },

    // ── Profile ──────────────────────────────────────────────────────────────
    'profile_edit': {
      'uz': 'Profilni tahrirlash',
      'ru': 'Редактировать профиль',
      'en': 'Edit Profile',
    },
    'bio': {
      'uz': "O'zingiz haqida",
      'ru': 'О себе',
      'en': 'About Me',
    },
    'city': {
      'uz': 'Shahar',
      'ru': 'Город',
      'en': 'City',
    },
    'position': {
      'uz': 'Lavozim',
      'ru': 'Должность',
      'en': 'Position',
    },
    'skills': {
      'uz': "Ko'nikmalar",
      'ru': 'Навыки',
      'en': 'Skills',
    },
    'experience': {
      'uz': 'Tajriba',
      'ru': 'Опыт',
      'en': 'Experience',
    },
    'education': {
      'uz': "Ta'lim",
      'ru': 'Образование',
      'en': 'Education',
    },
    'resume': {
      'uz': 'Rezyume',
      'ru': 'Резюме',
      'en': 'Resume',
    },
    'upload_resume': {
      'uz': 'Rezyume yuklash',
      'ru': 'Загрузить резюме',
      'en': 'Upload Resume',
    },
    'account': {
      'uz': 'Akkaunt',
      'ru': 'Аккаунт',
      'en': 'Account',
    },
    'open_to_work': {
      'uz': 'Ishga ochiq (Xodim)',
      'ru': 'Открыт для работы (Сотрудник)',
      'en': 'Open to Work (Employee)',
    },
    'select_file': {
      'uz': 'Fayl tanlash',
      'ru': 'Выбрать файл',
      'en': 'Select File',
    },

    // ── Employees ────────────────────────────────────────────────────────────
    'invite_to_chat': {
      'uz': 'Chatga taklif qilish',
      'ru': 'Пригласить в чат',
      'en': 'Invite to Chat',
    },
    'send_invitation': {
      'uz': 'Taklif yuborish',
      'ru': 'Отправить приглашение',
      'en': 'Send Invitation',
    },
    'no_employees': {
      'uz': "Xodimlar topilmadi",
      'ru': 'Сотрудники не найдены',
      'en': 'No employees found',
    },

    // ── Company ─────────────────────────────────────────────────────────────
    'company_name': {
      'uz': 'Kompaniya nomi',
      'ru': 'Название компании',
      'en': 'Company Name',
    },
    'no_companies': {
      'uz': "Kompaniyalar topilmadi",
      'ru': 'Компании не найдены',
      'en': 'No companies found',
    },
    'add_company': {
      'uz': "Kompaniya qo'shish",
      'ru': 'Добавить компанию',
      'en': 'Add Company',
    },

    // ── Language modal ────────────────────────────────────────────────────────
    'choose_language_subtitle': {
      'uz': 'Interfeys tilini tanlang',
      'ru': 'Выберите язык интерфейса',
      'en': 'Choose interface language',
    },

    // ── Auth extras ───────────────────────────────────────────────────────────
    'phone_number': {
      'uz': 'Telefon raqam',
      'ru': 'Номер телефона',
      'en': 'Phone Number',
    },
    'first_name': {
      'uz': 'Ism',
      'ru': 'Имя',
      'en': 'First Name',
    },
    'last_name': {
      'uz': 'Familiya',
      'ru': 'Фамилия',
      'en': 'Last Name',
    },
    'enter_first_name': {
      'uz': 'Ismingizni kiriting',
      'ru': 'Введите имя',
      'en': 'Enter your first name',
    },
    'enter_last_name': {
      'uz': 'Familiyangizni kiriting',
      'ru': 'Введите фамилию',
      'en': 'Enter your last name',
    },
    'confirm_password': {
      'uz': 'Parolni tasdiqlash',
      'ru': 'Подтвердите пароль',
      'en': 'Confirm Password',
    },
    're_enter_password': {
      'uz': 'Parolni qayta kiriting',
      'ru': 'Повторите пароль',
      'en': 'Re-enter your password',
    },
    'sign_in_continue': {
      'uz': 'Davom etish uchun kiring',
      'ru': 'Войдите, чтобы продолжить',
      'en': 'Sign in to continue',
    },
    'sign_up_started': {
      'uz': 'Boshlash uchun ro\'yxatdan o\'ting',
      'ru': 'Зарегистрируйтесь, чтобы начать',
      'en': 'Sign up to get started',
    },

    // ── Feed extras ────────────────────────────────────────────────────────────
    'welcome_user': {
      'uz': 'Xush kelibsiz',
      'ru': 'Добро пожаловать',
      'en': 'Welcome',
    },
    'dashboard_subtitle': {
      'uz': 'Profilingiz bilan bugun nimalar bo\'layotganini ko\'ring.',
      'ru': 'Посмотрите, что происходит с вашим профилем сегодня.',
      'en': 'See what\'s happening with your profile today.',
    },
    'profile_views': {
      'uz': 'Profil ko\'rilishi',
      'ru': 'Просмотры профиля',
      'en': 'Profile Views',
    },
    'applications_count': {
      'uz': 'Arizalar',
      'ru': 'Заявки',
      'en': 'Applications',
    },
    'connections': {
      'uz': 'Aloqalar',
      'ru': 'Связи',
      'en': 'Connections',
    },
    'notifications_count': {
      'uz': 'Bildirishnomalar',
      'ru': 'Уведомления',
      'en': 'Notifications',
    },
    'recent_activity': {
      'uz': 'So\'nggi faoliyat',
      'ru': 'Последняя активность',
      'en': 'Recent Activity',
    },
    'quick_actions': {
      'uz': 'Tezkor harakatlar',
      'ru': 'Быстрые действия',
      'en': 'Quick Actions',
    },
    'complete_profile': {
      'uz': 'Profilni to\'ldiring',
      'ru': 'Заполните профиль',
      'en': 'Complete Your Profile',
    },
    'complete_profile_subtitle': {
      'uz': 'To\'liq profil ish beruvchilardan 3 marta ko\'proq ko\'rinadi',
      'ru': 'Полный профиль виден работодателям в 3 раза чаще',
      'en': 'A complete profile is seen 3x more by employers',
    },
    'progress': {
      'uz': 'Jarayon',
      'ru': 'Прогресс',
      'en': 'Progress',
    },
    'complete_now': {
      'uz': 'Hozir to\'ldirish',
      'ru': 'Заполнить сейчас',
      'en': 'Complete Now',
    },
    'open_to_work_label': {
      'uz': 'Ishga ochiq',
      'ru': 'Открыт для работы',
      'en': 'Open to Work',
    },
    'open_to_work_subtitle': {
      'uz': 'Ish beruvchilarga ko\'rinish uchun yoqing',
      'ru': 'Включите, чтобы вас видели работодатели',
      'en': 'Turn on to be visible to employers',
    },
    'manage_visibility': {
      'uz': 'Ko\'rinishni boshqarish →',
      'ru': 'Управление видимостью →',
      'en': 'Manage Visibility →',
    },
    'inactive': {
      'uz': 'Nofaol',
      'ru': 'Неактивно',
      'en': 'Inactive',
    },
    'browse_jobs': {
      'uz': 'Ishlarni ko\'rish',
      'ru': 'Просмотр вакансий',
      'en': 'Browse Jobs',
    },
    'find_specialist': {
      'uz': 'Mutaxassis topish',
      'ru': 'Найти специалиста',
      'en': 'Find Specialist',
    },
    'update_profile': {
      'uz': 'Profilni yangilash',
      'ru': 'Обновить профиль',
      'en': 'Update Profile',
    },

    // ── Jobs extras ────────────────────────────────────────────────────────────
    'job_title': {
      'uz': 'Lavozim nomi',
      'ru': 'Название должности',
      'en': 'Job Title',
    },
    'company': {
      'uz': 'Kompaniya',
      'ru': 'Компания',
      'en': 'Company',
    },
    'description': {
      'uz': 'Tavsif',
      'ru': 'Описание',
      'en': 'Description',
    },
    'enter_job_title': {
      'uz': 'Lavozim nomini kiriting',
      'ru': 'Введите название должности',
      'en': 'Enter job title',
    },
    'enter_company': {
      'uz': 'Kompaniya nomini kiriting',
      'ru': 'Введите название компании',
      'en': 'Enter company name',
    },
    'enter_location': {
      'uz': 'Joylashuvni kiriting',
      'ru': 'Введите местоположение',
      'en': 'Enter location',
    },
    'enter_salary': {
      'uz': 'Maoshni kiriting',
      'ru': 'Введите зарплату',
      'en': 'Enter salary',
    },
    'enter_description': {
      'uz': 'Tavsifni kiriting',
      'ru': 'Введите описание',
      'en': 'Enter description',
    },
    'job_posted': {
      'uz': 'E\'lon joylashtirildi',
      'ru': 'Вакансия опубликована',
      'en': 'Job Posted',
    },
    'post_job': {
      'uz': 'E\'lon joylashtirish',
      'ru': 'Опубликовать вакансию',
      'en': 'Post Job',
    },
    'update_job': {
      'uz': 'Yangilash',
      'ru': 'Обновить',
      'en': 'Update',
    },
    'delete_job': {
      'uz': 'E\'lonni o\'chirish',
      'ru': 'Удалить вакансию',
      'en': 'Delete Job',
    },
    'delete_confirm': {
      'uz': 'O\'chirishni tasdiqlang',
      'ru': 'Подтвердите удаление',
      'en': 'Confirm Delete',
    },
    'delete_confirm_msg': {
      'uz': 'Bu e\'lonni o\'chirmoqchimisiz?',
      'ru': 'Вы хотите удалить эту вакансию?',
      'en': 'Do you want to delete this job?',
    },
    'applications': {
      'uz': 'Arizalar',
      'ru': 'Заявки',
      'en': 'Applications',
    },
    'no_saved_jobs': {
      'uz': 'Saqlangan ish e\'lonlari yo\'q',
      'ru': 'Нет сохранённых вакансий',
      'en': 'No saved jobs',
    },
    'no_my_jobs': {
      'uz': 'Siz hali ish e\'lon qilmagansiz',
      'ru': 'Вы ещё не опубликовали вакансий',
      'en': 'You haven\'t posted any jobs yet',
    },
    'views': {
      'uz': 'ko\'rishlar',
      'ru': 'просмотров',
      'en': 'views',
    },
    'applicants': {
      'uz': 'ariza',
      'ru': 'заявок',
      'en': 'applicants',
    },
    'active': {
      'uz': 'Faol',
      'ru': 'Активно',
      'en': 'Active',
    },
    'closed': {
      'uz': 'Yopilgan',
      'ru': 'Закрыто',
      'en': 'Closed',
    },
    'see_applications': {
      'uz': 'Arizalarni ko\'rish',
      'ru': 'Посмотреть заявки',
      'en': 'See Applications',
    },
    'no_application_detail': {
      'uz': 'Ariza topilmadi',
      'ru': 'Заявка не найдена',
      'en': 'Application not found',
    },

    // ── Chat extras ────────────────────────────────────────────────────────────
    'messages': {
      'uz': 'Xabarlar',
      'ru': 'Сообщения',
      'en': 'Messages',
    },
    'start_chat': {
      'uz': 'Suhbat boshlash',
      'ru': 'Начать чат',
      'en': 'Start Chat',
    },
    'no_messages': {
      'uz': 'Hozircha xabar yo\'q',
      'ru': 'Пока нет сообщений',
      'en': 'No messages yet',
    },
    'chat_invitation': {
      'uz': 'Chat taklifi',
      'ru': 'Приглашение в чат',
      'en': 'Chat Invitation',
    },
    'invitation_sent': {
      'uz': 'Taklif yuborildi',
      'ru': 'Приглашение отправлено',
      'en': 'Invitation Sent',
    },
    'invitation_hint': {
      'uz': 'Xabar yozing (ixtiyoriy)',
      'ru': 'Напишите сообщение (необязательно)',
      'en': 'Write a message (optional)',
    },
    'write_message': {
      'uz': 'Xabar yozing...',
      'ru': 'Написать сообщение...',
      'en': 'Write a message...',
    },

    // ── Employees extras ───────────────────────────────────────────────────────
    'all_employees': {
      'uz': 'Barcha mutaxassislar',
      'ru': 'Все специалисты',
      'en': 'All Specialists',
    },
    'search_employees': {
      'uz': 'Mutaxassis qidirish...',
      'ru': 'Поиск специалистов...',
      'en': 'Search specialists...',
    },
    'send_message': {
      'uz': 'Xabar yuborish',
      'ru': 'Написать сообщение',
      'en': 'Send Message',
    },
    'view_profile': {
      'uz': 'Profilni ko\'rish',
      'ru': 'Посмотреть профиль',
      'en': 'View Profile',
    },

    // ── Profile extras ─────────────────────────────────────────────────────────
    'profile_info_subtitle': {
      'uz': 'Profil ma\'lumotlari va ko\'rinishini boshqarish',
      'ru': 'Управление данными и видимостью профиля',
      'en': 'Manage profile data and visibility',
    },
    'complete_badge': {
      'uz': 'To\'liq',
      'ru': 'Завершено',
      'en': 'Complete',
    },
    'basic_info': {
      'uz': 'Asosiy',
      'ru': 'Основное',
      'en': 'Basic Info',
    },
    'add_skill': {
      'uz': 'Ko\'nikma qo\'shish',
      'ru': 'Добавить навык',
      'en': 'Add Skill',
    },
    'save_skills': {
      'uz': 'Ko\'nikmalarni saqlash',
      'ru': 'Сохранить навыки',
      'en': 'Save Skills',
    },
    'my_skills': {
      'uz': 'Ko\'nikmalarim',
      'ru': 'Мои навыки',
      'en': 'My Skills',
    },
    'add_experience': {
      'uz': 'Tajriba qo\'shish',
      'ru': 'Добавить опыт',
      'en': 'Add Experience',
    },
    'add_education': {
      'uz': 'Ta\'lim qo\'shish',
      'ru': 'Добавить образование',
      'en': 'Add Education',
    },
    'upload_resume_hint': {
      'uz': 'Rezyumeni yuklang (PDF, DOC, DOCX)',
      'ru': 'Загрузите резюме (PDF, DOC, DOCX)',
      'en': 'Upload resume (PDF, DOC, DOCX)',
    },
    'max_size': {
      'uz': 'Maks. hajmi: 5MB',
      'ru': 'Макс. размер: 5МБ',
      'en': 'Max size: 5MB',
    },
    'data_saved': {
      'uz': 'Ma\'lumotlar saqlandi',
      'ru': 'Данные сохранены',
      'en': 'Data saved',
    },
    'error_occurred': {
      'uz': 'Xatolik yuz berdi',
      'ru': 'Произошла ошибка',
      'en': 'An error occurred',
    },
    'profile_visibility': {
      'uz': 'Profil ko\'rinishi',
      'ru': 'Видимость профиля',
      'en': 'Profile Visibility',
    },
    'show_on_page': {
      'uz': 'Ushbu sahifada ko\'rsatish',
      'ru': 'Показать на этой странице',
      'en': 'Show on this page',
    },
    'open_to_seeker': {
      'uz': 'Ishga ochiq (Xodim)',
      'ru': 'Открыт для работы (Сотрудник)',
      'en': 'Open to Work (Employee)',
    },
    'open_to_seeker_desc': {
      'uz': 'Profilingizni Xodimlar sahifasida ko\'rsating — ish beruvchilar sizni topishi uchun.',
      'ru': 'Показывайте профиль на странице Сотрудников — чтобы работодатели могли вас найти.',
      'en': 'Show your profile on the Employees page — so employers can find you.',
    },
    'connect_telegram': {
      'uz': 'Telegramni ulash',
      'ru': 'Подключить Telegram',
      'en': 'Connect Telegram',
    },
    'telegram_code': {
      'uz': 'Telegram kodi',
      'ru': 'Код Telegram',
      'en': 'Telegram Code',
    },
    'verify': {
      'uz': 'Tasdiqlash',
      'ru': 'Подтвердить',
      'en': 'Verify',
    },

    // ── Companies extras ────────────────────────────────────────────────────────
    'search_companies': {
      'uz': 'Kompaniya qidirish...',
      'ru': 'Поиск компаний...',
      'en': 'Search companies...',
    },
    'my_companies_title': {
      'uz': 'Mening kompaniyalarim',
      'ru': 'Мои компании',
      'en': 'My Companies',
    },
    'create_company': {
      'uz': 'Kompaniya yaratish',
      'ru': 'Создать компанию',
      'en': 'Create Company',
    },
    'company_description': {
      'uz': 'Kompaniya haqida',
      'ru': 'О компании',
      'en': 'About Company',
    },
    'website': {
      'uz': 'Veb-sayt',
      'ru': 'Веб-сайт',
      'en': 'Website',
    },
    'industry': {
      'uz': 'Soha',
      'ru': 'Отрасль',
      'en': 'Industry',
    },
    'employees_count': {
      'uz': 'Xodimlar soni',
      'ru': 'Количество сотрудников',
      'en': 'Employees Count',
    },
  };

  static String tr(String key, String langCode) {
    return _strings[key]?[langCode] ?? _strings[key]?['uz'] ?? key;
  }

  static const String defaultLang = 'uz';
}
