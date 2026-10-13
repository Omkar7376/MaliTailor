# 🧵 StitchUp – Atelier & Tailor Management System

> A modern, responsive, and cross-platform Atelier & Tailoring Management Suite built with **Flutter**, **Firebase Cloud Firestore**, and **GetX Clean Architecture**. Designed to run smoothly across **Web**, **Tablet**, and **Android/iOS Mobile** devices.

---

## 🌟 Key Features

### 1. 📊 Interactive Atelier Dashboard
- **Real-Time KPIs**: Live counters for Total Orders, Pending Deliveries, Urgent Rush Orders, Total Customers, and Workshop Staff.
- **Smart Status Badges**: Real-time breakdown of order states (*Pending*, *In Progress*, *Ready for Trial*, *Delivered*).
- **Responsive Navigation**: Adaptive desktop sidebar, tablet navigation rail, and mobile bottom navigation bar with pull-to-refresh.

### 2. 👥 Customer & Digital Measurement Book
- **Customer Directory**: Fast search by customer name, book number, or phone number.
- **Precision Measurements**:
  - **Shirt**: Length, Chest, Shoulder, Sleeve, Collar, Cuff, Bicep, Back, Front divisions, notes.
  - **Pant**: Outside Length, Inside Length, Waist, Seat, Thigh, Knee, Bottom opening, Rise, and styling notes.
- **Order History per Customer**: Direct access to past orders and previous sizing references.

### 3. ✂️ Order Management & Workflow
- **Multi-Item Support**: Record Shirt and Pant quantities with automatic itemized billing.
- **Urgent Delivery Flag**: Rush order tag with visual urgency badges for deliveries due within 48 hours.
- **Worker Allocation**: Assign separate tailors/cutters for Shirts and Pants with customized piece rates.
- **Financial Calculations**: Real-time calculation of totals, customer advances, discount allowances, remaining balance, and admin profit margin.
- **WhatsApp Integration**: Single-tap sharing of order confirmation, measurements, and delivery receipts to customer WhatsApp.
- **Thermal Invoice Printing & PDF**: Built-in 80mm thermal receipt generator and standard invoice PDF creation.

### 4. 🪡 Workshop Staff & Wage Piece Rates
- **Staff Directory**: Register cutters, stitchers, and finishers with roles and contact information.
- **Dynamic Piece Rates**: Admin controls standard workshop piece rates per shirt and pant. Updated rates seamlessly apply to subsequent orders.
- **Cash Advances & Payments**: Record worker advances, track payouts, and inspect net pending salary per worker.

### 5. 📈 Accounts & Income Analytics
- **Dual-Perspective Analysis**:
  - **Admin View**: Total gross revenue, customer advances received, worker wages paid, discounts given, and net workshop profit.
  - **Staff View**: Wage breakdown per worker, advance cash tracking, and pending wage liabilities.
- **Time Filters**: Filter financial figures by Today, This Week, This Month, or Custom Date ranges.

### 6. 🔄 Real-Time Sync & Pull-to-Refresh
- Cloud Firestore real-time listener streams with offline persistence.
- Pull-to-refresh (`RefreshIndicator`) gesture on mobile screens and top-bar **Refresh Button** for web/desktop.
- Dedicated **"Reset Database"** button to purge sample records while preserving admin credentials.

---

## 🏗️ Architecture & Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart 3.x) |
| **State Management** | [GetX](https://pub.dev/packages/get) (Reactive Controllers, Dependency Injection, Navigation) |
| **Backend & Database** | Firebase Cloud Firestore with offline local persistence |
| **Typography & UI** | Google Fonts (Poppins), Adaptive Scaffold, Cupertinio Icons |
| **PDF & Printing** | `pdf` & `printing` packages |
| **Messaging** | `url_launcher` (Direct WhatsApp click-to-chat) |

---

## 📂 Project Directory Structure

```text
lib/
├── core/
│   ├── config/              # Environment config (AppEnv)
│   ├── responsive/          # AdaptiveLayout breakpoint helpers (Desktop, Tablet, Mobile)
│   ├── theme/               # Atelier color palette, Dark & Light ThemeData
│   └── utils/               # Currency & date formatters
├── controllers/             # GetX Controllers
│   ├── auth_controller.dart
│   ├── customer_controller.dart
│   ├── dashboard_controller.dart
│   ├── order_controller.dart
│   ├── theme_controller.dart
│   └── worker_controller.dart
├── data/
│   ├── models/              # Customer, Order, Measurement, Worker, and Tailor Models
│   └── services/            # FirebaseService, FirestoreService, AuthService
├── routes/                  # GetX Page Routes and Named Navigations
└── views/                   # UI Modules
    ├── analytics/           # Income & Accounts View
    ├── auth/                # Admin Login View
    ├── customers/           # Customer List, Add Dialog, Profile & Measurement Book
    ├── dashboard/           # Atelier KPI Dashboard
    ├── orders/              # Orders List, New Order Form, Edit Dialog, Receipt View
    ├── widgets/             # AdaptiveScaffold, MeasurementFormWidget, etc.
    └── workers/             # Staff Directory & Wage Rate Dialogs
```

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.19 or higher)
- [Git](https://git-scm.com/)
- Chrome browser (for web preview) or Android Studio / Xcode (for device builds)

### 2. Clone the Repository
```bash
git clone https://github.com/your-username/TailorApp.git
cd TailorApp
```

### 3. Setup Environment Variables
1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` and fill in your admin credentials and Firebase keys:
   ```env
   # Admin Credentials
   ADMIN_USERNAME=admin
   ADMIN_PASSWORD=your_secure_password
   ADMIN_EMAIL=admin@yourtailor.com
   DEFAULT_TAILOR_ID=admin_studio_01
   DEFAULT_SHOP_NAME=Mali Tailor
   DEFAULT_OWNER_NAME=Mahadev Mali
   DEFAULT_PHONE=+91 99609 45720
   DEFAULT_SHIRT_WAGE=130
   DEFAULT_PANT_WAGE=150

   # Firebase Configuration
   FIREBASE_API_KEY=your_firebase_api_key
   FIREBASE_APP_ID=your_firebase_app_id
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
   FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
   FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app
   ```
   > 🔒 **Security Notice:** `.env` is included in `.gitignore` and will never be pushed to your public Git repository.

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the Application
- **Run on Chrome (Web):**
  ```bash
  flutter run -d chrome
  ```
- **Run on Connected Mobile Device / Emulator:**
  ```bash
  flutter run
  ```

---

## 🔐 Default Admin Credentials
When launching the app with the sample `.env`, you can sign in using:
- **Username / Email:** `admin` or `admin@stitchup.com`
- **Password:** `admin@123`

*(You can customize these credentials in your local `.env` file at any time.)*

---

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
