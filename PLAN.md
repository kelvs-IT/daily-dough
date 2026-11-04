# Implementation & Debugging Plan: Cart Functionality, User Data Isolation, and Password Visibility

- **Project Location**: `C:\Users\benzy\.gemini\antigravity-ide\scratch\daily-dough`
- **Application Components**:
  - Flutter Mobile Application: `daily-dough/mobile_app`
  - Web Dashboard Application: `daily-dough/web_dashboard`
- **Target Firebase Database**:
  - `https://dailydough-5480d-default-rtdb.firebaseio.com/` (Active, Test Rules Open / 200 OK)
  - `https://integration-system-3c83a-default-rtdb.firebaseio.com/` (Project ID `integration-system-3c83a`, currently 401 Unauthorized / Locked Rules)

---

## A. Findings

### Bug 1: The "View Cart" Button Does Not Disappear Automatically
- **Files & Functions Involved**:
  1. `mobile_app/lib/screens/products_screen.dart`:
     - `_handleAddToCart(Product product)`: Launches `ScaffoldMessenger.of(context).showSnackBar(...)` with `SnackBarAction(label: 'VIEW CART')`.
     - `bottomNavigationBar`: Renders `Container(...)` with `ElevatedButton.icon(label: Text('View Cart ($cartCount)'))`.
     - `IconButton(icon: Icon(Icons.logout_rounded), onPressed: ...)`: Handles user logout navigation.
  2. `mobile_app/lib/services/firebase_service.dart`:
     - `logout()`: Handles clearing authentication state.
  3. `web_dashboard/app.js`:
     - `handleLogout()` & `updateCartBadge()`: Handles session cleanup and badge reset.
- **Observed Implementation**:
  - In `products_screen.dart`, when a user clicks "Add to Cart", a SnackBar with action label `'VIEW CART'` is shown. Because `ScaffoldMessenger` lives above the Navigator route tree, calling `pushReplacement` to `LoginScreen` on logout does **not** dismiss the SnackBar. The SnackBar remains floating over the login screen.
  - Furthermore, `bottomNavigationBar` is rendered unconditionally in `products_screen.dart` regardless of whether `cartCount > 0`.
  - In `firebase_service.dart`, `logout()` resets `_isLoggedIn = false` and `_currentUsername = ''`, but leaves `_cachedCart` populated in memory. When a new user logs in, the previous user's cached cart items and badge count persist.
- **Root Cause (Confirmed)**:
  1. `ScaffoldMessenger.of(context).clearSnackBars()` is never invoked when logging out.
  2. In-memory `_cachedCart` is not cleared on session termination in `logout()`.
  3. `bottomNavigationBar` does not check `cartCount > 0` and `isCustomer` before rendering.

---

### Bug 2: Customer and Admin Share Cart and Checkout Data Incorrectly
- **Files & Functions Involved**:
  1. `mobile_app/lib/services/firebase_service.dart`:
     - `addToCart(Product product)`: Syncs to `POST $databaseUrl/cart.json`.
     - `fetchCart()`: Reads from `GET $databaseUrl/cart.json`.
     - `clearCart()`: Deletes via `DELETE $databaseUrl/cart.json`.
     - `processCheckout(...)`: Processes `_cachedCart` and wipes `$databaseUrl/cart.json`.
  2. `mobile_app/lib/screens/cart_screen.dart` & `checkout_screen.dart`.
  3. `web_dashboard/app.js`:
     - `handleAddToCart`, `renderCart`, `handleClearCart`, `handleProcessCheckout`.
- **Observed Implementation**:
  - The database queries use a single, shared global path: `/cart.json`.
  - There is no user isolation or namespace (e.g., `/carts/{username}.json` or `/cart/{userId}.json`).
  - `_cachedCart` in `FirebaseService` is a single list shared across all sessions.
  - When customer `lenie` adds an item, it writes to `/cart.json`. When `admin` opens their interface, the app reads the same `/cart.json` and in-memory list, displaying `lenie`'s items in the admin's cart and allowing the admin to check them out.
- **Root Cause (Confirmed)**:
  - Database schema lacks user-specific path partitioning (all users share `/cart.json`).
  - Local state in `FirebaseService` and `app.js` is not scoped to `currentUsername`.

---

### Bug 3: Login Form Has No Show/Hide Password Option
- **Files & Functions Involved**:
  1. `mobile_app/lib/screens/login_screen.dart`:
     - `_passwordController` inside `TextFormField`.
  2. `web_dashboard/index.html` & `app.js`:
     - `<input type="password" id="passwordInput">`.
- **Observed Implementation**:
  - In `login_screen.dart`, `TextFormField` has `obscureText: true` hardcoded with no state variable to toggle it, and no `suffixIcon` with an `IconButton`.
  - In `web_dashboard/index.html`, `#passwordInput` is a static `<input type="password">` without a visibility toggle button or eye icon.
- **Root Cause (Confirmed)**:
  - Missing boolean visibility toggle state (`_obscurePassword`) and interactive toggle widgets in both Mobile and Web login interfaces.

---

## B. Proposed Changes

### 1. `daily-dough/mobile_app/lib/services/firebase_service.dart`
- **Changes**:
  - Partition cart paths by user: change `/cart.json` to `/carts/$_currentUsername.json` (or `/carts/$cleanUser.json`).
  - Update `fetchCart()`: Fetch `/carts/$_currentUsername.json` upon successful login.
  - Update `addToCart()`: Save items to `/carts/$_currentUsername.json`.
  - Update `clearCart()`: Delete only `/carts/$_currentUsername.json`.
  - Update `logout()`: Call `_cachedCart.clear()`, reset user state, and notify listeners so memory does not leak across sessions.
  - Update `processCheckout()`: Associate transactions with `username: _currentUsername`.
- **Preservation**: Existing `/products`, `/users`, and `/transactions` remain untouched.

### 2. `daily-dough/mobile_app/lib/screens/products_screen.dart`
- **Changes**:
  - In `logout` onPressed: Call `ScaffoldMessenger.of(context).clearSnackBars()` before navigating to `LoginScreen`.
  - Condition `bottomNavigationBar`: Render only if `!isAdmin && cartCount > 0`. If cart count is 0, return `null` so the bottom bar disappears automatically.
  - In `_handleAddToCart`: Ensure the SnackBar action properly handles navigation and self-dismissal.

### 3. `daily-dough/mobile_app/lib/screens/login_screen.dart`
- **Changes**:
  - Add state variable `bool _obscurePassword = true;`.
  - In password `TextFormField`:
    - Set `obscureText: _obscurePassword`.
    - Add `suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))`.
- **Preservation**: Existing login validation, styling, and test account fill buttons remain intact.

### 4. `daily-dough/web_dashboard/index.html` & `app.js`
- **Changes**:
  - Add eye icon toggle button `<button type="button" id="togglePasswordBtn">👁️</button>` inside `#passwordInput` wrapper.
  - In `app.js`: Update `state.cart` and endpoints to `${FIREBASE_BASE_URL}/carts/${state.currentUser}.json`.
  - In `handleLogout()`: Reset `state.cart = []`, update cart badge to 0, and hide any active cart controls.

---

## C. Firebase Data Plan

### Path Architecture & Data Partitioning:
```
/
├── products/
│   ├── product1 { name, price, details }
│   └── product2 { name, price, details }
├── users/
│   ├── user1 { username: "admin", password: "..." }
│   └── user2 { username: "lenie", password: "..." }
├── carts/                          <-- User-isolated cart nodes
│   ├── lenie/
│   │   └── -CartItemKey1 { productName, price }
│   └── admin/
│       └── -CartItemKey2 { productName, price }
└── transactions/
    └── -TxKey1 { customerUsername, customerName, totalAmount, items, status, timestamp }
```

### Database Endpoint Note:
- The project currently targets `https://dailydough-5480d-default-rtdb.firebaseio.com/` (where test rules are open and verified HTTP 200 OK).
- The prompt mentions `https://integration-system-3c83a-default-rtdb.firebaseio.com/`. However, inspecting `integration-system-3c83a` indicates its security rules currently respond with `401 Unauthorized` without credentials.
- **Safe Plan**: We can maintain seamless functionality using the active database endpoint or switch if you grant write authorization on `integration-system-3c83a`. No existing `/products` or `/users` records will be overwritten or deleted.

---

## D. Testing Plan

1. **Bug 1: Cart Control Dismissal & Logout Verification**:
   - Log in as `lenie`, add 1 product to cart -> Verify "View Cart (1)" bar appears at the bottom.
   - Click "Logout" -> Verify `ScaffoldMessenger.clearSnackBars()` executes, returning to `LoginScreen` with **no floating cart button or bar visible**.
   - Re-open products -> Verify cart control only appears when cart has items.

2. **Bug 2: User Data & Cart Isolation**:
   - Log in as `lenie` -> Add `Laptop` (₱35,000) to cart -> Verify `/carts/lenie.json` contains `Laptop`.
   - Log out `lenie`.
   - Log in as `admin` -> Check Admin cart -> Verify Admin cart has **0 items** and cannot see or checkout `lenie`'s items.
   - Log in as `lenie` again -> Verify `Laptop` is still present in `lenie`'s cart.
   - Complete checkout as `lenie` -> Verify transaction records `lenie` as the customer and only `lenie`'s cart is cleared.

3. **Bug 3: Password Visibility Toggle**:
   - On `LoginScreen`, enter password `admin123` -> Verify masked dots `••••••••` by default.
   - Click Eye icon -> Verify text reveals `admin123`.
   - Click Eye icon again -> Verify text re-masks `••••••••`.
   - Test login with toggled state -> Confirm authentication succeeds without errors.

4. **Security & Regression Validation**:
   - Attempt to access Cart/Checkout without authentication -> Verify "Access Denied" guard.
   - Run `flutter analyze` -> Confirm 0 issues.
   - Run `flutter test` -> Confirm all tests pass.

---

## E. Risks and Limitations

1. **Legacy Global `/cart` Node**:
   - Existing data in `/cart.json` belongs to prior un-isolated tests. We will leave `/cart.json` intact (not deleting it) and point new queries to `/carts/{username}.json`.
2. **Firebase Rules Compatibility**:
   - If using `integration-system-3c83a`, rules must allow reads/writes to `/carts` and `/transactions`.

---

## 8. APPROVAL & IMPLEMENTATION STATUS

> [!NOTE]
> **STATUS: APPROVED & FULLY IMPLEMENTED (October 23, 2026)**
> - Approved by user ("go ahead").
> - All code modifications completed across `mobile_app` and `web_dashboard`.
> - All 3 bugs verified on Android Emulator (`emulator-5554`) with zero analysis issues and passing test suites.
> - Detailed report and screenshot artifacts available in `LAB08_VERIFICATION_REPORT.md`.
