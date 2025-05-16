# Stock Profile Tracker

A cross-platform Flutter app for managing your stock portfolio with user authentication and cloud storage using [Back4App (Parse Server)](https://www.back4app.com/).

## Features

- **User Authentication:**  
  - Sign up, login, logout, and password reset using Back4App's user management.
- **Stock Management:**  
  - Add, view, edit, and delete stock entries (CRUD operations).
  - Each stock entry includes: Name, Buy Date, Price, and Quantity.
  - Query stocks by name.
- **Cloud Storage:**  
  - All data is securely stored and synced with Back4App.
- **Session Management:**  
  - Secure user sessions with automatic token handling.
- **Responsive UI:**  
  - Works on Android, iOS, and desktop (with Flutter support).

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A Back4App account and app (get your App ID and Client Key)
- Android/iOS emulator or a physical device

### Setup

1. **Clone the repository:**
    ```bash
    git clone <your-repo-url>
    cd stock_profile_tracker
    ```

2. **Install dependencies:**
    ```bash
    flutter pub get
    ```

3. **Configure Back4App:**
    - In `lib/main.dart`, set your Back4App `appId`, `clientKey`, and `parseServerUrl`.

4. **Run the app:**
    ```bash
    flutter run
    ```

### Running Tests

To run unit tests:
```bash
flutter test
```

## Usage

- **Sign Up:** Create a new account with username, email, and password.
- **Login:** Log in with your credentials.
- **Add Stock:** Tap the "+" button to add a new stock entry.
- **Edit/Delete:** Use the edit and delete icons next to each stock entry.
- **Query:** Use the search icon to filter stocks by name.
- **Refresh:** Use the refresh icon to reload all stocks.
- **Logout:** Use the logout icon to sign out.

## Notes

- Only alphabetic characters are allowed in the stock name.
- Buy date is selected using a date picker (no manual entry).
- All operations are synced with Back4App in real time.

## License

MIT

---

**Developed with Flutter & Back4App**
