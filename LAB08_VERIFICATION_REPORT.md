# Lab Exercise 08: Debugging and System Optimization
## Comprehensive Bug Investigation, Fixes, and Verification Report

**Project**: Daily Dough – Firebase Integration System  
**Repository Directory**: `C:\Users\benzy\.gemini\antigravity-ide\scratch\daily-dough`  
**Target Firebase Database**: `https://dailydough-5480d-default-rtdb.firebaseio.com/`  
**Date**: October 23, 2026  
**Status**: **ALL 3 BUGS RESOLVED & LIVE VERIFIED**

---

### Executive Summary

| Issue | Description | Status | Evidence / Verification |
| :--- | :--- | :--- | :--- |
| **Bug 1** | **"View Cart" Button Does Not Disappear Automatically**: Floating SnackBar action or bottom cart bar persisted across sessions / logout, or did not dismiss automatically when cart is empty. | **RESOLVED** | Dismissed floating SnackBars upon logout (`ScaffoldMessenger.clearSnackBars()`); conditional `bottomNavigationBar` (`(!isAdmin && cartCount > 0)`). Verified with screenshots `mobile_lenie_cart_added.png` and `mobile_logout_cleared.png`. |
| **Bug 2** | **Customer and Admin Share Cart & Checkout Data Incorrectly**: Customer and admin accessed a shared global `/cart.json` endpoint; admin could see, manage, and checkout customer cart contents. | **RESOLVED** | Scoped cart state and Firebase endpoints to `/carts/{username}.json` (e.g. `/carts/lenie.json` and `/carts/admin.json`). Cleared in-memory cart on logout. Verified with `mobile_admin_screen.png` (cart count 0, no customer items visible to admin). |
| **Bug 3** | **Login Form Has No Show/Hide Password Option**: Password input was strictly masked with no toggle mechanism to reveal plain text. | **RESOLVED** | Added `_obscurePassword` state with eye toggle icon button in Flutter (`mobile_app/lib/screens/login_screen.dart`) and toggle button in Web Dashboard (`web_dashboard/index.html` + `app.js`). Verified with `mobile_password_shown_clear.png`. |

---

### Detailed Bug Investigation & Root Causes

#### 1. Bug 1: "View Cart" Button Persistence & Logout Cleanup
- **Observed Behavior**:
  - When a user added an item to their cart, a SnackBar with a "VIEW CART" action was displayed. If the user logged out while the SnackBar was still active, the notification remained visible on the `LoginScreen`.
  - In addition, the bottom navigation bar cart preview did not automatically clean up or hide when switching roles or logging out.
- **Root Cause**:
  - `ScaffoldMessenger.of(context)` keeps SnackBar queues alive across route transitions unless explicitly dismissed.
  - In `products_screen.dart`, logging out navigated back to `LoginScreen` without executing `ScaffoldMessenger.of(context).clearSnackBars()`.
  - The bottom bar lacked an explicit condition checking both role and item count.
- **Solution & Files Modified**:
  - File: [`mobile_app/lib/screens/products_screen.dart`](file:///C:/Users/benzy/.gemini/antigravity-ide/scratch/daily-dough/mobile_app/lib/screens/products_screen.dart)
  - Added `ScaffoldMessenger.of(context).clearSnackBars();` to the logout button callback.
  - Guarded `bottomNavigationBar`: set to `(!isAdmin && cartCount > 0) ? ... : null`. When cart has 0 items or when user is admin, the bottom cart control completely disappears.

#### 2. Bug 2: Data Isolation Between Customer and Admin
- **Observed Behavior**:
  - When customer `lenie` added items to her cart, logging in as `admin` displayed `lenie`'s items in the admin's cart, allowing the admin to checkout the customer's items.
- **Root Cause**:
  - Both `FirebaseService` in Flutter and `app.js` in the Web Dashboard used a single static node: `$databaseUrl/cart.json`.
  - In-memory cart lists were not properly reset upon logout, allowing cached state to bleed into the subsequent user's session.
- **Solution & Files Modified**:
  - Files:
    - [`mobile_app/lib/services/firebase_service.dart`](file:///C:/Users/benzy/.gemini/antigravity-ide/scratch/daily-dough/mobile_app/lib/services/firebase_service.dart)
    - [`web_dashboard/app.js`](file:///C:/Users/benzy/.gemini/antigravity-ide/scratch/daily-dough/web_dashboard/app.js)
  - Replaced global `/cart.json` with user-isolated `/carts/{username}.json` for `addToCart`, `fetchCart`, and `clearCart`.
  - Updated `logout()` to reset `_cachedCart.clear()` and nullify `_currentUser`.
  - Updated `login()` to eagerly fetch the logging-in user's specific cart from Firebase.

#### 3. Bug 3: Password Visibility Toggle
- **Observed Behavior**:
  - Login password field had `obscureText: true` hardcoded with no option for the user to verify their typed password before submitting.
- **Root Cause**:
  - No state variable was defined to control `obscureText`, and no `suffixIcon` was defined on `InputDecoration`.
- **Solution & Files Modified**:
  - Files:
    - [`mobile_app/lib/screens/login_screen.dart`](file:///C:/Users/benzy/.gemini/antigravity-ide/scratch/daily-dough/mobile_app/lib/screens/login_screen.dart)
    - [`web_dashboard/index.html`](file:///C:/Users/benzy/.gemini/antigravity-ide/scratch/daily-dough/web_dashboard/index.html)
    - [`web_dashboard/app.js`](file:///C:/Users/benzy/.gemini/antigravity-ide/scratch/daily-dough/web_dashboard/app.js)
  - Flutter: Added `bool _obscurePassword = true;` with an `IconButton` toggling between `Icons.visibility_off_outlined` and `Icons.visibility_outlined`.
  - Web: Added `#togglePasswordBtn` with `togglePasswordVisibility()` switching `input.type = 'password' <-> 'text'`.

---

### Step-by-Step Test Results Matrix

| Step / Test Case | Action | Expected Result | Actual Result | Verification Status |
| :--- | :--- | :--- | :--- | :--- |
| **TC-01: Password Toggle** | Tap eye icon on login screen | Password changes from `•••••••` to plain text `lenie123` | Password clearly visible as `lenie123` | **PASS** (Screenshot: `mobile_password_shown_clear.png`) |
| **TC-02: Customer Login** | Login as `lenie` | Navigate to products screen; show "Customer: lenie (Shop Only)" | Header shows `Customer: lenie`; cart count 0; no bottom cart bar | **PASS** (Screenshot: `mobile_lenie_products.png`) |
| **TC-03: Add Product to Cart** | Tap "Add to Cart" on Phone (₱15,000) | Cart count increments to 1; SnackBar appears with "VIEW CART"; Bottom bar appears | Cart count shows 1; "VIEW CART" SnackBar shown; Bottom bar displays "View Cart (1)" with ₱15,000 | **PASS** (Screenshot: `mobile_lenie_cart_added.png`) |
| **TC-04: Logout SnackBar Dismissal (Bug 1)** | Tap Logout icon button | Immediately return to Login Screen; dismiss SnackBar | SnackBar dismissed instantly; clean Login Screen with no lingering UI | **PASS** (Screenshot: `mobile_logout_cleared.png`) |
| **TC-05: User Data Isolation (Bug 2)** | Login as `admin` | Admin dashboard loads; Admin cart must be 0 items, NOT sharing Lenie's Phone | Admin screen displays "Admin: admin (Full CRUD)", cart is 0 items, no Phone in cart | **PASS** (Screenshot: `mobile_admin_screen.png`) |
| **TC-06: Customer Re-login Persistence** | Logout Admin, Login as `lenie` | Lenie's isolated cart (`/carts/lenie.json`) restored from Firebase | Lenie's cart displays 1 item (Phone ₱15,000); bottom bar reappears | **PASS** (Screenshot: `mobile_lenie_relogin_cart.png`) |
| **TC-07: Checkout & Cart Cleared** | Proceed to Checkout -> Tap Checkout | Order submitted to Firebase `/transactions`; isolated cart deleted | Order Confirmed modal appears; Cart reset to 0 items; Bottom bar disappears | **PASS** (Screenshots: `mobile_checkout_complete.png`, `mobile_order_success.png`, `mobile_store_cart_cleared.png`) |
| **TC-08: Code Quality Suite** | Run `flutter analyze` & `flutter test` | 0 errors, 0 warnings; All tests pass | `No issues found!`, `All tests passed!` | **PASS** |

---

### Captured Test Evidence Files

All screenshots were captured live directly from Android Emulator (`emulator-5554`):
- `mobile_login_with_eye.png`: Password input field equipped with eye toggle icon.
- `mobile_password_shown_clear.png`: Plain-text password reveal functionality.
- `mobile_lenie_products.png`: Customer products screen with zero initial cart items and hidden cart bar.
- `mobile_lenie_cart_added.png`: Active cart badge (1), floating SnackBar with "VIEW CART", and bottom navigation bar.
- `mobile_logout_cleared.png`: Immediate dismissal of floating notifications on logout.
- `mobile_admin_screen.png`: Proof of isolated admin session with 0 cart items (no access to customer cart).
- `mobile_lenie_relogin_cart.png`: Isolated customer cart restoration from Firebase.
- `mobile_checkout_complete.png` & `mobile_order_success.png`: Successful transaction dispatch and cart clearing.
- `mobile_store_cart_cleared.png`: Confirmation of automatic disappearance of bottom cart bar when cart is empty.
