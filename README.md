<div align="right">

**English** · [Bahasa Indonesia](README.id.md)

</div>

# Tamajiwa: nursing care documentation

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Laravel](https://img.shields.io/badge/Laravel-12-FF2D20?style=flat-square&logo=laravel&logoColor=white)](https://laravel.com)

A mobile app and API for **nursing students and their lecturers** to document patient care. Students (*mahasiswa*) record patients and fill in the standard nursing forms; lecturers (*dosen*) manage the diagnosis and intervention libraries, review submitted forms, and track the students assigned to them.

## Features

- **Roles:** students and lecturers, with a lecturer assignment flow and per-role dashboards.
- **Patients:** create and manage the patients a student is working with.
- **Forms:** assessment (*pengkajian*), communication strategy (SAP), group activity therapy (TAK), outpatient and emergency resumes, and extra notes. Photos and materials can be attached.
- **Genogram builder:** build a family genogram in the app and render it as SVG.
- **Nursing libraries:** diagnoses and interventions maintained by lecturers.
- **Review and PDF:** lecturers review submitted forms; forms can be exported to PDF.
- **Password reset:** request and reset by email link.

## Screenshots

Captured from the real app against a locally seeded backend, using Faker-generated demo data.

| Sign in | Lecturer dashboard | Lecturer: students |
|---|---|---|
| ![Sign in](docs/screenshots/login.jpg) | ![Lecturer dashboard](docs/screenshots/dosen-dashboard.jpg) | ![Students](docs/screenshots/dosen-students.jpg) |

| Lecturer: forms to review | Student dashboard | Student: forms |
|---|---|---|
| ![Forms to review](docs/screenshots/dosen-forms.jpg) | ![Student dashboard](docs/screenshots/student-dashboard.jpg) | ![Student forms](docs/screenshots/student-forms.jpg) |

## Tech stack

| Area | Technology |
|---|---|
| App | Flutter, Dart, GetX, Hive |
| API | Laravel 12, Sanctum, SQLite (default) or any Laravel database |
| Tests | `flutter test`, PHPUnit |
| CI | GitHub Actions |

## Getting started

### 1. Backend

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate
php artisan serve          # http://127.0.0.1:8000
```

Set `DB_CONNECTION=sqlite` in `.env` for the quickest start. Mail uses the `log` driver by default, so password-reset links appear in `storage/logs/laravel.log`.


### Demo accounts

`php artisan migrate:fresh --seed` creates fictional data (50 patients, about 100 forms, diagnoses and interventions). All accounts use the password `password`:

| Role | Email |
|---|---|
| Lecturer | `dosen1@example.com` … `dosen5@example.com` |
| Student | `mahasiswa1@example.com` … `mahasiswa10@example.com` |

Students are assigned to lecturers in turn (Mahasiswa 1 and 6 belong to Dosen 1, and so on), so the lecturer screens have data.

### 2. App

```bash
flutter pub get
flutter run
```

The app talks to `http://127.0.0.1:8000/api` by default (`10.0.2.2` on the Android emulator). To use another server:

```bash
flutter run --dart-define=API_BASE_URL=https://your-server.example/api
```

## Testing

```bash
flutter analyze && flutter test
cd backend && php artisan test
```

End-to-end check and screenshots (backend running and seeded, simulator booted):

```bash
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/e2e_test.dart -d <simulator-id> --dart-define=ROLE=mahasiswa   # or dosen
```

## Security notes

- Never commit `.env` files, archives or local databases; they are ignored in `.gitignore`.
- The app stores no server address in the source. Provide it at build time.
- This project handles patient-care records. Use fictional data for demos and follow your institution's rules for real data.

## Author

**Rizky Eka Haryadi**  
[GitHub](https://github.com/Rizky28eka) · [LinkedIn](https://www.linkedin.com/in/rizky28eka/) · [Portfolio](https://heyeka.vercel.app)
