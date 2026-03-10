import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz')
  ];

  /// No description provided for @mainNavHome.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy'**
  String get mainNavHome;

  /// No description provided for @mainNavMessages.
  ///
  /// In uz, this message translates to:
  /// **'Xabarlar'**
  String get mainNavMessages;

  /// No description provided for @mainNavVacancies.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiyalar'**
  String get mainNavVacancies;

  /// No description provided for @mainNavProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get mainNavProfile;

  /// No description provided for @defaultUser.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi'**
  String get defaultUser;

  /// No description provided for @defaultExpert.
  ///
  /// In uz, this message translates to:
  /// **'Mutaxassis'**
  String get defaultExpert;

  /// No description provided for @drawerNews.
  ///
  /// In uz, this message translates to:
  /// **'YANGILIKLAR'**
  String get drawerNews;

  /// No description provided for @drawerDashboard.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruv paneli'**
  String get drawerDashboard;

  /// No description provided for @drawerMyProfile.
  ///
  /// In uz, this message translates to:
  /// **'Mening profilim'**
  String get drawerMyProfile;

  /// No description provided for @drawerInvitations.
  ///
  /// In uz, this message translates to:
  /// **'Taklifnomalar'**
  String get drawerInvitations;

  /// No description provided for @drawerEmployees.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get drawerEmployees;

  /// No description provided for @drawerVacanciesGroup.
  ///
  /// In uz, this message translates to:
  /// **'VAKANSIYALAR'**
  String get drawerVacanciesGroup;

  /// No description provided for @drawerSaved.
  ///
  /// In uz, this message translates to:
  /// **'Saqlanganlar'**
  String get drawerSaved;

  /// No description provided for @drawerAddVacancy.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiya qo\'shish'**
  String get drawerAddVacancy;

  /// No description provided for @drawerMyVacancies.
  ///
  /// In uz, this message translates to:
  /// **'Mening vakansiyalarim'**
  String get drawerMyVacancies;

  /// No description provided for @drawerMyApplicationsGroup.
  ///
  /// In uz, this message translates to:
  /// **'MENING ARIZALARIM'**
  String get drawerMyApplicationsGroup;

  /// No description provided for @drawerMyApplications.
  ///
  /// In uz, this message translates to:
  /// **'Mening arizalarim'**
  String get drawerMyApplications;

  /// No description provided for @drawerCompaniesGroup.
  ///
  /// In uz, this message translates to:
  /// **'KOMPANIYALAR'**
  String get drawerCompaniesGroup;

  /// No description provided for @drawerMyCompanies.
  ///
  /// In uz, this message translates to:
  /// **'Mening kompaniyalarim'**
  String get drawerMyCompanies;

  /// No description provided for @drawerSettingsGroup.
  ///
  /// In uz, this message translates to:
  /// **'SOZLAMALAR'**
  String get drawerSettingsGroup;

  /// No description provided for @drawerProfileSettings.
  ///
  /// In uz, this message translates to:
  /// **'Profil sozlamalari'**
  String get drawerProfileSettings;

  /// No description provided for @drawerAppearance.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinish'**
  String get drawerAppearance;

  /// No description provided for @drawerMyResume.
  ///
  /// In uz, this message translates to:
  /// **'Mening rezyumem'**
  String get drawerMyResume;

  /// No description provided for @drawerLogout.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get drawerLogout;

  /// No description provided for @feedWelcome.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz, {name}! 👋'**
  String feedWelcome(Object name);

  /// No description provided for @feedSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilingiz statistikasi va yangiliklarni kuzatib boring'**
  String get feedSubtitle;

  /// No description provided for @feedCompleteProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profilingizni yakunlang'**
  String get feedCompleteProfile;

  /// No description provided for @feedCompleteProfileDesc.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq profil ish beruvchilar e\'tiborini 2 barobar ko\'proq tortadi.'**
  String get feedCompleteProfileDesc;

  /// No description provided for @feedProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayon'**
  String get feedProgress;

  /// No description provided for @feedCompleteNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir yakunlash'**
  String get feedCompleteNow;

  /// No description provided for @feedProfileViews.
  ///
  /// In uz, this message translates to:
  /// **'Profilni ko\'rishlar'**
  String get feedProfileViews;

  /// No description provided for @feedApplications.
  ///
  /// In uz, this message translates to:
  /// **'Arizalar'**
  String get feedApplications;

  /// No description provided for @feedConnections.
  ///
  /// In uz, this message translates to:
  /// **'Aloqalar'**
  String get feedConnections;

  /// No description provided for @feedNotifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get feedNotifications;

  /// No description provided for @feedRecentActivity.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi faoliyat'**
  String get feedRecentActivity;

  /// No description provided for @feedHoursAgo.
  ///
  /// In uz, this message translates to:
  /// **'soat oldin'**
  String get feedHoursAgo;

  /// No description provided for @feedApplicationReviewed.
  ///
  /// In uz, this message translates to:
  /// **'arizangiz ko\'rib chiqildi'**
  String get feedApplicationReviewed;

  /// No description provided for @feedDaysAgo.
  ///
  /// In uz, this message translates to:
  /// **'kun oldin'**
  String get feedDaysAgo;

  /// No description provided for @feedProfileLevelUp.
  ///
  /// In uz, this message translates to:
  /// **'Profil darajasi oshdi'**
  String get feedProfileLevelUp;

  /// No description provided for @feedQuickActions.
  ///
  /// In uz, this message translates to:
  /// **'Tezkor amallar'**
  String get feedQuickActions;

  /// No description provided for @feedViewVacancies.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiyalarni ko\'rish'**
  String get feedViewVacancies;

  /// No description provided for @feedSearchExperts.
  ///
  /// In uz, this message translates to:
  /// **'Mutaxassis qidirish'**
  String get feedSearchExperts;

  /// No description provided for @feedUpdateProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profilni yangilash'**
  String get feedUpdateProfile;

  /// No description provided for @feedOpenToWork.
  ///
  /// In uz, this message translates to:
  /// **'Ishga tayyorlik'**
  String get feedOpenToWork;

  /// No description provided for @feedShowInExperts.
  ///
  /// In uz, this message translates to:
  /// **'Mutaxassislar sahifasida ko\'rsatish'**
  String get feedShowInExperts;

  /// No description provided for @feedInactive.
  ///
  /// In uz, this message translates to:
  /// **'Faol emas'**
  String get feedInactive;

  /// No description provided for @feedManageVisibility.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinishni boshqarish'**
  String get feedManageVisibility;

  /// No description provided for @profileTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mening profilim'**
  String get profileTitle;

  /// No description provided for @profileEditBtn.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get profileEditBtn;

  /// No description provided for @profileSkills.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'nikmalar'**
  String get profileSkills;

  /// No description provided for @profileExperience.
  ///
  /// In uz, this message translates to:
  /// **'Tajriba'**
  String get profileExperience;

  /// No description provided for @profileEducation.
  ///
  /// In uz, this message translates to:
  /// **'Ta\'lim'**
  String get profileEducation;

  /// No description provided for @profileResume.
  ///
  /// In uz, this message translates to:
  /// **'Rezyume'**
  String get profileResume;

  /// No description provided for @profileUploadedCv.
  ///
  /// In uz, this message translates to:
  /// **'Yuklangan fayl'**
  String get profileUploadedCv;

  /// No description provided for @profileViewBtn.
  ///
  /// In uz, this message translates to:
  /// **'Profilni ko\'rish'**
  String get profileViewBtn;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profil sozlamalari'**
  String get profileSettingsTitle;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilingiz ma\'lumotlarini tahrirlash'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileCompleteBadge.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq'**
  String get profileCompleteBadge;

  /// No description provided for @profileMainSection.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy ma\'lumotlar'**
  String get profileMainSection;

  /// No description provided for @profileLocationNotSet.
  ///
  /// In uz, this message translates to:
  /// **'Manzil ko\'rsatilmagan'**
  String get profileLocationNotSet;

  /// No description provided for @profileAddSkill.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'nikma qo\'shing...'**
  String get profileAddSkill;

  /// No description provided for @profileYourSkills.
  ///
  /// In uz, this message translates to:
  /// **'Sizning ko\'nikmalaringiz'**
  String get profileYourSkills;

  /// No description provided for @profileSaveSkills.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'nikmalarni saqlash'**
  String get profileSaveSkills;

  /// No description provided for @profileWorkExperience.
  ///
  /// In uz, this message translates to:
  /// **'Ish tajribasi'**
  String get profileWorkExperience;

  /// No description provided for @profileAddExperience.
  ///
  /// In uz, this message translates to:
  /// **'Tajriba qo\'shish'**
  String get profileAddExperience;

  /// No description provided for @profileSaveExperience.
  ///
  /// In uz, this message translates to:
  /// **'Tajribani saqlash'**
  String get profileSaveExperience;

  /// No description provided for @profileCurrentlyWorkingHere.
  ///
  /// In uz, this message translates to:
  /// **'Hozirda shu yerda ishlayman'**
  String get profileCurrentlyWorkingHere;

  /// No description provided for @profileDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get profileDelete;

  /// No description provided for @profileSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get profileSave;

  /// No description provided for @profileFullNameReq.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq ism (Majburiy)'**
  String get profileFullNameReq;

  /// No description provided for @profileCityReq.
  ///
  /// In uz, this message translates to:
  /// **'Shahar (Majburiy)'**
  String get profileCityReq;

  /// No description provided for @profilePosition.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimi'**
  String get profilePosition;

  /// No description provided for @profileAboutMe.
  ///
  /// In uz, this message translates to:
  /// **'O\'zim haqimda'**
  String get profileAboutMe;

  /// No description provided for @profileCharacters.
  ///
  /// In uz, this message translates to:
  /// **'belgilar'**
  String get profileCharacters;

  /// No description provided for @profileSchoolReq.
  ///
  /// In uz, this message translates to:
  /// **'O\'quv muassasasi (Majburiy)'**
  String get profileSchoolReq;

  /// No description provided for @profileDegreeReq.
  ///
  /// In uz, this message translates to:
  /// **'Daraja (Majburiy)'**
  String get profileDegreeReq;

  /// No description provided for @profileSpecialization.
  ///
  /// In uz, this message translates to:
  /// **'Mutaxassislik'**
  String get profileSpecialization;

  /// No description provided for @profileAddEducation.
  ///
  /// In uz, this message translates to:
  /// **'Ta\'lim qo\'shish'**
  String get profileAddEducation;

  /// No description provided for @profileSaveEducation.
  ///
  /// In uz, this message translates to:
  /// **'Ta\'limni saqlash'**
  String get profileSaveEducation;

  /// No description provided for @profilePresent.
  ///
  /// In uz, this message translates to:
  /// **'hozirgacha'**
  String get profilePresent;

  /// No description provided for @profilePositionReq.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim (Majburiy)'**
  String get profilePositionReq;

  /// No description provided for @profileCompanyReq.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya (Majburiy)'**
  String get profileCompanyReq;

  /// No description provided for @profileAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzil'**
  String get profileAddress;

  /// No description provided for @profileStartDateReq.
  ///
  /// In uz, this message translates to:
  /// **'Boshlanish sanasi (Majburiy)'**
  String get profileStartDateReq;

  /// No description provided for @profileEndDate.
  ///
  /// In uz, this message translates to:
  /// **'Tugash sanasi'**
  String get profileEndDate;

  /// No description provided for @profileDescription.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif'**
  String get profileDescription;

  /// No description provided for @profileResumeUploadTitle.
  ///
  /// In uz, this message translates to:
  /// **'Rezyumeni yuklash'**
  String get profileResumeUploadTitle;

  /// No description provided for @profileResumeUploadDesc.
  ///
  /// In uz, this message translates to:
  /// **'Rezyumeni yuklang (PDF, DOC, DOCX)'**
  String get profileResumeUploadDesc;

  /// No description provided for @profileMaxFileSize.
  ///
  /// In uz, this message translates to:
  /// **'Maks. hajmi: 5MB'**
  String get profileMaxFileSize;

  /// No description provided for @profileChooseFile.
  ///
  /// In uz, this message translates to:
  /// **'Fayl tanlash'**
  String get profileChooseFile;

  /// No description provided for @profileFileUploadSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Fayl muvaffaqiyatli yuklandi'**
  String get profileFileUploadSuccess;

  /// No description provided for @profileFileUploadError.
  ///
  /// In uz, this message translates to:
  /// **'Yuklashda xatolik'**
  String get profileFileUploadError;

  /// No description provided for @profileResumeUploadedBadge.
  ///
  /// In uz, this message translates to:
  /// **'Rezyume yuklandi'**
  String get profileResumeUploadedBadge;

  /// No description provided for @profileAppearance.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinish'**
  String get profileAppearance;

  /// No description provided for @profileVisibility.
  ///
  /// In uz, this message translates to:
  /// **'Profilning ko\'rinishi'**
  String get profileVisibility;

  /// No description provided for @profileVisibilityUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinish yangilandi'**
  String get profileVisibilityUpdated;

  /// No description provided for @profileVisibilityError.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi'**
  String get profileVisibilityError;

  /// No description provided for @profileAccount.
  ///
  /// In uz, this message translates to:
  /// **'Akkaunt'**
  String get profileAccount;

  /// No description provided for @profileOpenToWorkDesc.
  ///
  /// In uz, this message translates to:
  /// **'Ish beruvchilar sizni topishi uchun soha va mutaxassislikni sozlang'**
  String get profileOpenToWorkDesc;

  /// No description provided for @profileShowOnThisPage.
  ///
  /// In uz, this message translates to:
  /// **'Bu sahifada ko\'rsatilsin'**
  String get profileShowOnThisPage;

  /// No description provided for @profileTelegramConnectDesc.
  ///
  /// In uz, this message translates to:
  /// **'Telegram orqali kirish imkoniyati'**
  String get profileTelegramConnectDesc;

  /// No description provided for @profileTelegramConnected.
  ///
  /// In uz, this message translates to:
  /// **'Ulangan'**
  String get profileTelegramConnected;

  /// No description provided for @profileTelegramNotConnected.
  ///
  /// In uz, this message translates to:
  /// **'Ulanmagan'**
  String get profileTelegramNotConnected;

  /// No description provided for @messagesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xabarlar'**
  String get messagesTitle;

  /// No description provided for @messagesNoMessagesYet.
  ///
  /// In uz, this message translates to:
  /// **'Hali xabarlar yo\'q'**
  String get messagesNoMessagesYet;

  /// No description provided for @messagesStartChat.
  ///
  /// In uz, this message translates to:
  /// **'Mutaxassislar sahifasidan chat boshlang'**
  String get messagesStartChat;

  /// No description provided for @messagesConversationStarted.
  ///
  /// In uz, this message translates to:
  /// **'Suhbat boshlandi'**
  String get messagesConversationStarted;

  /// No description provided for @messagesToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get messagesToday;

  /// No description provided for @messagesYesterday.
  ///
  /// In uz, this message translates to:
  /// **'Kecha'**
  String get messagesYesterday;

  /// No description provided for @messagesOnline.
  ///
  /// In uz, this message translates to:
  /// **'online'**
  String get messagesOnline;

  /// No description provided for @messagesLoading.
  ///
  /// In uz, this message translates to:
  /// **'loading...'**
  String get messagesLoading;

  /// No description provided for @messagesNoMessagesYetRoom.
  ///
  /// In uz, this message translates to:
  /// **'Hali xabar yo\'q'**
  String get messagesNoMessagesYetRoom;

  /// No description provided for @messagesSendFirstMessage.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu suhbatga birinchi xabarni yuboring'**
  String get messagesSendFirstMessage;

  /// No description provided for @messagesTypeMessage.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yozing...'**
  String get messagesTypeMessage;

  /// No description provided for @vacanciesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiyalar'**
  String get vacanciesTitle;

  /// No description provided for @vacanciesFilterType.
  ///
  /// In uz, this message translates to:
  /// **'Ish turi'**
  String get vacanciesFilterType;

  /// No description provided for @vacanciesFilterLocation.
  ///
  /// In uz, this message translates to:
  /// **'Viloyat'**
  String get vacanciesFilterLocation;

  /// No description provided for @vacanciesFilterRemote.
  ///
  /// In uz, this message translates to:
  /// **'Masofaviy'**
  String get vacanciesFilterRemote;

  /// No description provided for @vacanciesFilterOffice.
  ///
  /// In uz, this message translates to:
  /// **'Ofisda'**
  String get vacanciesFilterOffice;

  /// No description provided for @vacanciesFilterSalary.
  ///
  /// In uz, this message translates to:
  /// **'Maosh'**
  String get vacanciesFilterSalary;

  /// No description provided for @vacanciesFilterDate.
  ///
  /// In uz, this message translates to:
  /// **'Sana'**
  String get vacanciesFilterDate;

  /// No description provided for @vacanciesResultsFound.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta natija topildi'**
  String vacanciesResultsFound(Object count);

  /// No description provided for @vacanciesClear.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get vacanciesClear;

  /// No description provided for @vacanciesNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiyalar topilmadi'**
  String get vacanciesNotFound;

  /// No description provided for @vacanciesChangeFilters.
  ///
  /// In uz, this message translates to:
  /// **'Filtrlarni o\'zgartiring'**
  String get vacanciesChangeFilters;

  /// No description provided for @vacanciesRefresh.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get vacanciesRefresh;

  /// No description provided for @vacanciesFullTime.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq kun'**
  String get vacanciesFullTime;

  /// No description provided for @vacanciesPartTime.
  ///
  /// In uz, this message translates to:
  /// **'Yarim kun'**
  String get vacanciesPartTime;

  /// No description provided for @vacanciesInternship.
  ///
  /// In uz, this message translates to:
  /// **'Amaliyot'**
  String get vacanciesInternship;

  /// No description provided for @vacanciesContract.
  ///
  /// In uz, this message translates to:
  /// **'Kontrakt'**
  String get vacanciesContract;

  /// No description provided for @vacanciesSearchLocation.
  ///
  /// In uz, this message translates to:
  /// **'Manzil qidirish'**
  String get vacanciesSearchLocation;

  /// No description provided for @vacanciesSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Masalan: Toshkent'**
  String get vacanciesSearchHint;

  /// No description provided for @vacanciesSearchBtn.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get vacanciesSearchBtn;

  /// No description provided for @vacanciesCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get vacanciesCancel;

  /// No description provided for @vacanciesWorkPlace.
  ///
  /// In uz, this message translates to:
  /// **'Ish joyi'**
  String get vacanciesWorkPlace;

  /// No description provided for @vacanciesSalaryRange.
  ///
  /// In uz, this message translates to:
  /// **'Maosh diapazoni'**
  String get vacanciesSalaryRange;

  /// No description provided for @vacanciesMinSalary.
  ///
  /// In uz, this message translates to:
  /// **'Minimum (so\'m)'**
  String get vacanciesMinSalary;

  /// No description provided for @vacanciesMaxSalary.
  ///
  /// In uz, this message translates to:
  /// **'Maksimum (so\'m)'**
  String get vacanciesMaxSalary;

  /// No description provided for @vacanciesSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get vacanciesSave;

  /// No description provided for @vacanciesSalaryNegotiable.
  ///
  /// In uz, this message translates to:
  /// **'Maosh kelishiladi'**
  String get vacanciesSalaryNegotiable;

  /// No description provided for @vacanciesSalaryFrom.
  ///
  /// In uz, this message translates to:
  /// **'dan'**
  String get vacanciesSalaryFrom;

  /// No description provided for @vacanciesSalaryTo.
  ///
  /// In uz, this message translates to:
  /// **'gacha'**
  String get vacanciesSalaryTo;

  /// No description provided for @vacanciesApplyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu ishga ariza yuborish'**
  String get vacanciesApplyTitle;

  /// No description provided for @vacanciesApplyInvite.
  ///
  /// In uz, this message translates to:
  /// **'{company} JAMOASIGA ISHGA TAKLIF QILAMIZ!'**
  String vacanciesApplyInvite(Object company);

  /// No description provided for @vacanciesCoverLetter.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shimcha xat (ixtiyoriy)'**
  String get vacanciesCoverLetter;

  /// No description provided for @vacanciesWriteHereHint.
  ///
  /// In uz, this message translates to:
  /// **'Shu yerga yozing...'**
  String get vacanciesWriteHereHint;

  /// No description provided for @vacanciesApplyBtn.
  ///
  /// In uz, this message translates to:
  /// **'Ariza yuborish'**
  String get vacanciesApplyBtn;

  /// No description provided for @vacanciesApplySuccess.
  ///
  /// In uz, this message translates to:
  /// **'Ariza muvaffaqiyatli yuborildi'**
  String get vacanciesApplySuccess;

  /// No description provided for @vacanciesApplyError.
  ///
  /// In uz, this message translates to:
  /// **'Siz bu ishga ariza topshirgansiz'**
  String get vacanciesApplyError;

  /// No description provided for @vacanciesApplicationsList.
  ///
  /// In uz, this message translates to:
  /// **'Arizalar ro\'yxati'**
  String get vacanciesApplicationsList;

  /// No description provided for @vacanciesNoApplications.
  ///
  /// In uz, this message translates to:
  /// **'Arizalar mavjud emas'**
  String get vacanciesNoApplications;

  /// No description provided for @vacanciesCoverLetterLabel.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shimcha xat:'**
  String get vacanciesCoverLetterLabel;

  /// No description provided for @vacanciesSalaryLabel.
  ///
  /// In uz, this message translates to:
  /// **'Maosh'**
  String get vacanciesSalaryLabel;

  /// No description provided for @vacanciesDescriptionLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ish tavsifi'**
  String get vacanciesDescriptionLabel;

  /// No description provided for @vacanciesRequirementsLabel.
  ///
  /// In uz, this message translates to:
  /// **'Talablar'**
  String get vacanciesRequirementsLabel;

  /// No description provided for @vacanciesSeeApplications.
  ///
  /// In uz, this message translates to:
  /// **'Arizalarni ko\'rish'**
  String get vacanciesSeeApplications;

  /// No description provided for @vacanciesNoJobs.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiya topilmadi'**
  String get vacanciesNoJobs;

  /// No description provided for @vacanciesIndustryNotSpecified.
  ///
  /// In uz, this message translates to:
  /// **'Soha ko\'rsatilmagan'**
  String get vacanciesIndustryNotSpecified;

  /// No description provided for @vacanciesCompany.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya'**
  String get vacanciesCompany;

  /// No description provided for @feedToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get feedToday;

  /// No description provided for @invitationsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Taklifnomalar'**
  String get invitationsTitle;

  /// No description provided for @invitationsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Chat orqali mutaxassislar bilan bog\'laning'**
  String get invitationsSubtitle;

  /// No description provided for @invitationsTabReceived.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilingan'**
  String get invitationsTabReceived;

  /// No description provided for @invitationsTabSent.
  ///
  /// In uz, this message translates to:
  /// **'Yuborilgan'**
  String get invitationsTabSent;

  /// No description provided for @invitationsEmptyReceived.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilingan taklifnomalar yo\'q'**
  String get invitationsEmptyReceived;

  /// No description provided for @invitationsEmptySent.
  ///
  /// In uz, this message translates to:
  /// **'Yuborilgan taklifnomalar yo\'q'**
  String get invitationsEmptySent;

  /// No description provided for @invitationsWantsToChat.
  ///
  /// In uz, this message translates to:
  /// **'{name} siz bilan chat ochmoqchi'**
  String invitationsWantsToChat(Object name);

  /// No description provided for @invitationsPrefix.
  ///
  /// In uz, this message translates to:
  /// **'Taklifnoma: {name}'**
  String invitationsPrefix(Object name);

  /// No description provided for @invitationsSentAt.
  ///
  /// In uz, this message translates to:
  /// **'Yuborildi: {date}'**
  String invitationsSentAt(Object date);

  /// No description provided for @invitationsAccept.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish'**
  String get invitationsAccept;

  /// No description provided for @invitationsReject.
  ///
  /// In uz, this message translates to:
  /// **'Rad etish'**
  String get invitationsReject;

  /// No description provided for @invitationsAccepted.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilindi'**
  String get invitationsAccepted;

  /// No description provided for @invitationsRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etildi'**
  String get invitationsRejected;

  /// No description provided for @invitationsPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get invitationsPending;

  /// No description provided for @invitationsOpenChat.
  ///
  /// In uz, this message translates to:
  /// **'Chatni ochish'**
  String get invitationsOpenChat;

  /// No description provided for @invitationsUnknownUser.
  ///
  /// In uz, this message translates to:
  /// **'Noma\'lum'**
  String get invitationsUnknownUser;

  /// No description provided for @employeesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get employeesTitle;

  /// No description provided for @employeesSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Mutaxassislarni qidiring'**
  String get employeesSubtitle;

  /// No description provided for @employeesCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} mutaxassis'**
  String employeesCount(Object count);

  /// No description provided for @employeesSkillsHeader.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'nikmalar'**
  String get employeesSkillsHeader;

  /// No description provided for @employeesAddSkillHint.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'nikma qo\'shing...'**
  String get employeesAddSkillHint;

  /// No description provided for @employeesAddBtn.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shish'**
  String get employeesAddBtn;

  /// No description provided for @employeesNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Mutaxassislar topilmadi'**
  String get employeesNotFound;

  /// No description provided for @employeesReadyToWork.
  ///
  /// In uz, this message translates to:
  /// **'Ishga tayyor'**
  String get employeesReadyToWork;

  /// No description provided for @employeesActionChat.
  ///
  /// In uz, this message translates to:
  /// **'Xabar'**
  String get employeesActionChat;

  /// No description provided for @employeesActionProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get employeesActionProfile;

  /// No description provided for @employeesInvitationTitle.
  ///
  /// In uz, this message translates to:
  /// **'{name} ga xabar'**
  String employeesInvitationTitle(Object name);

  /// No description provided for @employeesInvitationSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yuboring, agar qabul qilinsa chat ochiladi'**
  String get employeesInvitationSubtitle;

  /// No description provided for @employeesInvitationHint.
  ///
  /// In uz, this message translates to:
  /// **'Xabar (ixtiyoriy)...'**
  String get employeesInvitationHint;

  /// No description provided for @employeesInvitationBtn.
  ///
  /// In uz, this message translates to:
  /// **'Taklif yuborish'**
  String get employeesInvitationBtn;

  /// No description provided for @employeesInvitationChecking.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirilmoqda...'**
  String get employeesInvitationChecking;

  /// No description provided for @employeesAlreadyInChat.
  ///
  /// In uz, this message translates to:
  /// **'Siz allaqachon muloqot boshlagan edingiz'**
  String get employeesAlreadyInChat;

  /// No description provided for @employeesInvitationPending.
  ///
  /// In uz, this message translates to:
  /// **'Taklif kutilmoqda'**
  String get employeesInvitationPending;

  /// No description provided for @employeesInvitationPendingDesc.
  ///
  /// In uz, this message translates to:
  /// **'Sizning taklifingiz ko\'rib chiqilmoqda'**
  String get employeesInvitationPendingDesc;

  /// No description provided for @employeesClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get employeesClose;

  /// No description provided for @employeesProfileNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Profil topilmadi'**
  String get employeesProfileNotFound;

  /// No description provided for @employeesRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get employeesRetry;

  /// No description provided for @employeesOpenToJob.
  ///
  /// In uz, this message translates to:
  /// **'Ishga ochiq'**
  String get employeesOpenToJob;

  /// No description provided for @employeesLookingForWorker.
  ///
  /// In uz, this message translates to:
  /// **'Ishchi qidirmoqda'**
  String get employeesLookingForWorker;

  /// No description provided for @employeesSendMessage.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yuborish'**
  String get employeesSendMessage;

  /// No description provided for @employeesAbout.
  ///
  /// In uz, this message translates to:
  /// **'Haqida'**
  String get employeesAbout;

  /// No description provided for @employeesExperience.
  ///
  /// In uz, this message translates to:
  /// **'Ish tajribasi'**
  String get employeesExperience;

  /// No description provided for @employeesEducation.
  ///
  /// In uz, this message translates to:
  /// **'Ta\'lim'**
  String get employeesEducation;

  /// No description provided for @employeesProfileNotFilled.
  ///
  /// In uz, this message translates to:
  /// **'Profil hali to\'ldirilmagan'**
  String get employeesProfileNotFilled;

  /// No description provided for @employeesInvitationSent.
  ///
  /// In uz, this message translates to:
  /// **'Taklif yuborildi'**
  String get employeesInvitationSent;

  /// No description provided for @employeesInvitationError.
  ///
  /// In uz, this message translates to:
  /// **'Taklif yuborishda xatolik'**
  String get employeesInvitationError;

  /// No description provided for @savedJobsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Saqlanganlar'**
  String get savedJobsTitle;

  /// No description provided for @savedJobsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Saqlangan vakansiyalar yo\'q'**
  String get savedJobsEmpty;

  /// No description provided for @myJobsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mening vakansiyalarim'**
  String get myJobsTitle;

  /// No description provided for @myJobsAddSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiya qo\'shish'**
  String get myJobsAddSubtitle;

  /// No description provided for @myJobsAddBtn.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiya qo\'shish'**
  String get myJobsAddBtn;

  /// No description provided for @jobStatusDraft.
  ///
  /// In uz, this message translates to:
  /// **'Qoralama'**
  String get jobStatusDraft;

  /// No description provided for @jobStatusActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get jobStatusActive;

  /// No description provided for @jobStatusClosed.
  ///
  /// In uz, this message translates to:
  /// **'Yopildi'**
  String get jobStatusClosed;

  /// No description provided for @jobApplications.
  ///
  /// In uz, this message translates to:
  /// **'arizalar'**
  String get jobApplications;

  /// No description provided for @jobActionPublish.
  ///
  /// In uz, this message translates to:
  /// **'E\'lon qilish'**
  String get jobActionPublish;

  /// No description provided for @jobActionClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get jobActionClose;

  /// No description provided for @jobActionView.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rish'**
  String get jobActionView;

  /// No description provided for @jobActionEdit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get jobActionEdit;

  /// No description provided for @jobActionDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get jobActionDelete;

  /// No description provided for @jobStatusUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Holat yangilandi'**
  String get jobStatusUpdated;

  /// No description provided for @jobDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu vakansiyani o\'chirmoqchimisiz?'**
  String get jobDeleteConfirm;

  /// No description provided for @jobDeleted.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiya o\'chirildi'**
  String get jobDeleted;

  /// No description provided for @jobDeleteError.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirishda xatolik'**
  String get jobDeleteError;

  /// No description provided for @statsTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get statsTotal;

  /// No description provided for @statsActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get statsActive;

  /// No description provided for @statsDraft.
  ///
  /// In uz, this message translates to:
  /// **'Qoralama'**
  String get statsDraft;

  /// No description provided for @statsViews.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rishlar'**
  String get statsViews;

  /// No description provided for @jobFormTitleNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi vakansiya'**
  String get jobFormTitleNew;

  /// No description provided for @jobFormTitleEdit.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiyani tahrirlash'**
  String get jobFormTitleEdit;

  /// No description provided for @jobFormSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Barcha ma\'lumotlarni to\'ldiring'**
  String get jobFormSubtitle;

  /// No description provided for @jobFormSectionBasic.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy ma\'lumotlar'**
  String get jobFormSectionBasic;

  /// No description provided for @jobFormLabelCompany.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya'**
  String get jobFormLabelCompany;

  /// No description provided for @jobFormCompanyPersonal.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy (kompaniyasiz)'**
  String get jobFormCompanyPersonal;

  /// No description provided for @jobFormHintCompany.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniyani tanlang'**
  String get jobFormHintCompany;

  /// No description provided for @jobFormErrorLoadingCompanies.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniyalarni yuklashda xatolik'**
  String get jobFormErrorLoadingCompanies;

  /// No description provided for @jobFormLabelTitle.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim nomi'**
  String get jobFormLabelTitle;

  /// No description provided for @jobFormHintTitle.
  ///
  /// In uz, this message translates to:
  /// **'Masalan: Flutter Developer'**
  String get jobFormHintTitle;

  /// No description provided for @jobFormErrorRequired.
  ///
  /// In uz, this message translates to:
  /// **'Majburiy maydon'**
  String get jobFormErrorRequired;

  /// No description provided for @jobFormLabelType.
  ///
  /// In uz, this message translates to:
  /// **'Ish turi'**
  String get jobFormLabelType;

  /// No description provided for @jobFormLabelLocation.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv'**
  String get jobFormLabelLocation;

  /// No description provided for @jobFormHintLocation.
  ///
  /// In uz, this message translates to:
  /// **'Masalan: Toshkent'**
  String get jobFormHintLocation;

  /// No description provided for @jobFormLabelRemote.
  ///
  /// In uz, this message translates to:
  /// **'Masofaviy ish'**
  String get jobFormLabelRemote;

  /// No description provided for @jobFormSubtitleRemote.
  ///
  /// In uz, this message translates to:
  /// **'Xodim uydan ishlashi mumkin'**
  String get jobFormSubtitleRemote;

  /// No description provided for @jobFormSectionSalary.
  ///
  /// In uz, this message translates to:
  /// **'Maosh va valyuta'**
  String get jobFormSectionSalary;

  /// No description provided for @jobFormLabelMinSalary.
  ///
  /// In uz, this message translates to:
  /// **'Minimum maosh'**
  String get jobFormLabelMinSalary;

  /// No description provided for @jobFormLabelMaxSalary.
  ///
  /// In uz, this message translates to:
  /// **'Maksimum maosh'**
  String get jobFormLabelMaxSalary;

  /// No description provided for @jobFormLabelCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Valyuta'**
  String get jobFormLabelCurrency;

  /// No description provided for @jobFormSectionDetails.
  ///
  /// In uz, this message translates to:
  /// **'Tafsilotlar'**
  String get jobFormSectionDetails;

  /// No description provided for @jobFormLabelDescription.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif'**
  String get jobFormLabelDescription;

  /// No description provided for @jobFormHintDescription.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiya haqida batafsil...'**
  String get jobFormHintDescription;

  /// No description provided for @jobFormLabelRequirements.
  ///
  /// In uz, this message translates to:
  /// **'Talablar'**
  String get jobFormLabelRequirements;

  /// No description provided for @jobFormHintRequirements.
  ///
  /// In uz, this message translates to:
  /// **'Har qatorga bitta talab...'**
  String get jobFormHintRequirements;

  /// No description provided for @jobFormBtnCreate.
  ///
  /// In uz, this message translates to:
  /// **'E\'lon yaratish'**
  String get jobFormBtnCreate;

  /// No description provided for @jobFormModified.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiya tahrirlandi'**
  String get jobFormModified;

  /// No description provided for @jobFormCreated.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiya yaratildi'**
  String get jobFormCreated;

  /// No description provided for @errorOccurred.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi'**
  String get errorOccurred;

  /// No description provided for @save.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get cancel;

  /// No description provided for @jobAppBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get jobAppBack;

  /// No description provided for @jobAppTitle.
  ///
  /// In uz, this message translates to:
  /// **'{jobTitle} uchun arizalar'**
  String jobAppTitle(Object jobTitle);

  /// No description provided for @jobAppSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu vakansiyaga kelib tushgan barcha arizalar'**
  String get jobAppSubtitle;

  /// No description provided for @jobAppStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get jobAppStatusPending;

  /// No description provided for @jobAppStatusReviewed.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rib chiqildi'**
  String get jobAppStatusReviewed;

  /// No description provided for @jobAppStatusAccepted.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilindi'**
  String get jobAppStatusAccepted;

  /// No description provided for @jobAppStatusRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etildi'**
  String get jobAppStatusRejected;

  /// No description provided for @jobAppActionAccept.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish'**
  String get jobAppActionAccept;

  /// No description provided for @jobAppActionReject.
  ///
  /// In uz, this message translates to:
  /// **'Rad etish'**
  String get jobAppActionReject;

  /// No description provided for @jobAppActionReview.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rib chiqish'**
  String get jobAppActionReview;

  /// No description provided for @jobAppCoverLetter.
  ///
  /// In uz, this message translates to:
  /// **'Muqova xati'**
  String get jobAppCoverLetter;

  /// No description provided for @jobAppNotAvailable.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud emas'**
  String get jobAppNotAvailable;

  /// No description provided for @jobAppFullProfile.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq profil'**
  String get jobAppFullProfile;

  /// No description provided for @jobAppTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get jobAppTotal;

  /// No description provided for @jobAppDataSaved.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlar saqlandi'**
  String get jobAppDataSaved;

  /// No description provided for @myAppsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mening arizalarim'**
  String get myAppsTitle;

  /// No description provided for @myAppsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Arizalaringizni kuzating'**
  String get myAppsSubtitle;

  /// No description provided for @myAppsTotal.
  ///
  /// In uz, this message translates to:
  /// **'jami'**
  String get myAppsTotal;

  /// No description provided for @myAppsPending.
  ///
  /// In uz, this message translates to:
  /// **'kutilmoqda'**
  String get myAppsPending;

  /// No description provided for @myAppsAccepted.
  ///
  /// In uz, this message translates to:
  /// **'qabul qilindi'**
  String get myAppsAccepted;

  /// No description provided for @myAppsRejected.
  ///
  /// In uz, this message translates to:
  /// **'rad etildi'**
  String get myAppsRejected;

  /// No description provided for @myAppsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali arizalar yo\'q'**
  String get myAppsEmpty;

  /// No description provided for @myAppsEmptySubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiyalar bo\'limidan ariza topshiring'**
  String get myAppsEmptySubtitle;

  /// No description provided for @myAppsGoToJobs.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiyalarga o\'tish'**
  String get myAppsGoToJobs;

  /// No description provided for @myAppsSentAt.
  ///
  /// In uz, this message translates to:
  /// **'Ariza yuborildi: {date}'**
  String myAppsSentAt(Object date);

  /// No description provided for @myAppsWithdraw.
  ///
  /// In uz, this message translates to:
  /// **'qaytarib olish'**
  String get myAppsWithdraw;

  /// No description provided for @myAppsCoverLetterLabel.
  ///
  /// In uz, this message translates to:
  /// **'Arizadagi maktub:'**
  String get myAppsCoverLetterLabel;

  /// No description provided for @myAppsWithdrawTitle.
  ///
  /// In uz, this message translates to:
  /// **'Arizani qaytarib olish'**
  String get myAppsWithdrawTitle;

  /// No description provided for @myAppsWithdrawConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Arizani qaytarib olmoqchimisiz?'**
  String get myAppsWithdrawConfirm;

  /// No description provided for @myAppsWithdrawConfirmBtn.
  ///
  /// In uz, this message translates to:
  /// **'Ha, qaytarib olish'**
  String get myAppsWithdrawConfirmBtn;

  /// No description provided for @myCompaniesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mening kompaniyalarim'**
  String get myCompaniesTitle;

  /// No description provided for @myCompaniesAddBtn.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya qo\'shish'**
  String get myCompaniesAddBtn;

  /// No description provided for @myCompaniesEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha kompaniyalar yo\'q'**
  String get myCompaniesEmpty;

  /// No description provided for @myCompaniesDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniyani o\'chirish'**
  String get myCompaniesDeleteTitle;

  /// No description provided for @myCompaniesDeleteConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Ushbu kompaniyani o\'chirishga ishonchingiz komilmi?'**
  String get myCompaniesDeleteConfirm;

  /// No description provided for @myCompaniesDeleted.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya o\'chirildi'**
  String get myCompaniesDeleted;

  /// No description provided for @myCompaniesEmployeesCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} xodim'**
  String myCompaniesEmployeesCount(Object count);

  /// No description provided for @myCompaniesAddJob.
  ///
  /// In uz, this message translates to:
  /// **'Vakansiya qo\'sh'**
  String get myCompaniesAddJob;

  /// No description provided for @companyFormTitleNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi kompaniya'**
  String get companyFormTitleNew;

  /// No description provided for @companyFormTitleEdit.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniyani tahrirlash'**
  String get companyFormTitleEdit;

  /// No description provided for @companyFormSectionAbout.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya haqida'**
  String get companyFormSectionAbout;

  /// No description provided for @companyFormLabelName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi *'**
  String get companyFormLabelName;

  /// No description provided for @companyFormLabelDescription.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif *'**
  String get companyFormLabelDescription;

  /// No description provided for @companyFormSectionDetails.
  ///
  /// In uz, this message translates to:
  /// **'Tafsilotlar'**
  String get companyFormSectionDetails;

  /// No description provided for @companyFormLabelWebsite.
  ///
  /// In uz, this message translates to:
  /// **'Veb-sayt *'**
  String get companyFormLabelWebsite;

  /// No description provided for @companyFormLabelLocation.
  ///
  /// In uz, this message translates to:
  /// **'Manzil *'**
  String get companyFormLabelLocation;

  /// No description provided for @companyFormLabelIndustry.
  ///
  /// In uz, this message translates to:
  /// **'Soha *'**
  String get companyFormLabelIndustry;

  /// No description provided for @companyFormHintIndustry.
  ///
  /// In uz, this message translates to:
  /// **'masalan: IT, Moliya, Tibbiyot'**
  String get companyFormHintIndustry;

  /// No description provided for @companyFormLabelSize.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya hajmi *'**
  String get companyFormLabelSize;

  /// No description provided for @companyFormUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya ma\'lumotlari yangilandi'**
  String get companyFormUpdated;

  /// No description provided for @companyFormCreated.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya muvaffaqiyatli yaratildi'**
  String get companyFormCreated;

  /// No description provided for @fieldRequired.
  ///
  /// In uz, this message translates to:
  /// **'Maydonni to\'ldirish shart'**
  String get fieldRequired;

  /// No description provided for @pleaseSelect.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos tanlang'**
  String get pleaseSelect;

  /// No description provided for @selectLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Tilni tanlang'**
  String get selectLanguage;

  /// No description provided for @profileUploadingImage.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuklanmoqda...'**
  String get profileUploadingImage;

  /// No description provided for @profileImageUploaded.
  ///
  /// In uz, this message translates to:
  /// **'Rasm muvaffaqiyatli yuklandi'**
  String get profileImageUploaded;

  /// No description provided for @profileImageUploadError.
  ///
  /// In uz, this message translates to:
  /// **'Rasmni yuklashda xatolik yuz berdi'**
  String get profileImageUploadError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
