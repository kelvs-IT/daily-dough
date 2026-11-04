# Lab Exercise 07: Enhancing the Firebase Integration System with Cart and Checkout Workflow
## Official Testing Results & Verification Sheet

- **Student / Group Folder**: `daily-dough`
- **Institution**: University of Rizal System (URS)
- **Course**: ITE 7 – Application Development and Emerging Technologies
- **Subject Instructor**: Anjeline N. Legaspi, LPT, MSIT
- **Target Firebase Database**: `https://dailydough-5480d-default-rtdb.firebaseio.com/`

---

## 1. Functional & Security Test Matrix

| Test Case | Description & Input | Expected Result (from PDF) | Actual Result | Status | Evidence / Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-01: Valid Login** | Enter `admin` / `admin123` | Successful login redirects to Product Page | Authenticated session created; redirected to `products` | **PASS** | Validated in both Flutter app & Web Dashboard. |
| **TC-02: Empty Username** | Empty username with password | Reject submission; prompt error | Submission prevented; displays "Username cannot be empty" | **PASS** | Form validation blocks request before submission. |
| **TC-03: Empty Password** | Username with empty password | Reject submission; prompt error | Submission prevented; displays "Password cannot be empty" | **PASS** | Form validation blocks request before submission. |
| **TC-04: Invalid Credentials (Scenario 3)** | Enter `admin` / `wrongpassword999` | Reject login; display "Invalid Username or Password" | Red alert box displays: "Invalid Username or Password" | **PASS** | Matches PDF Page 8 Scenario 3 requirement. |
| **TC-05: Access Control (Scenario 1)** | Access Cart or Checkout while logged out | Deny access; display "Access Denied Please Login First" | Route guard intercepts; displays "Access Denied Please Login First" with Return to Login button | **PASS** | Matches PDF Page 7 Scenario 1 requirement. |
| **TC-06: Product Listing** | View store products | Display products with prices and Add to Cart buttons | Products (Laptop ₱35,000, Phone ₱15,000, Headphones ₱2,500, Smartwatch ₱8,500) rendered with ₱ symbols | **PASS** | Matches PDF Page 5 product display format. |
| **TC-07: Add to Cart (Part C Step 3)** | Click "Add to Cart" on at least 3 items | Store items in Firebase `/cart`; update cart badge | 3 items added; cart count badge shows `3`; pushed to `/cart.json` | **PASS** | Verified addition of Laptop, Phone, and Headphones. |
| **TC-08: Cart Automatic Calculation** | View Cart page | Display all items and compute total automatically | All items listed with prices; Total displays `₱52,500` automatically | **PASS** | Matches PDF Page 6: sum of item prices matches total. |
| **TC-09: Checkout Validation (Scenario 2)** | Submit checkout form with blank Name, Address, or Payment | Prevent submission; display "Validation Error" | Red alert box displays: "Validation Error" | **PASS** | Matches PDF Page 6 & Page 8 Scenario 2. |
| **TC-10: Process Transaction (Part D & F)** | Fill Customer Name, Address, Payment Method; click Checkout | 1. Compute total<br>2. Save to `/transactions`<br>3. Display success message<br>4. Clear cart contents | Transaction saved with status "Completed"; Success confirmation modal displayed; Cart emptied | **PASS** | Complete workflow verified matching PDF Step 6 & Step 8. |
| **TC-11: Firebase Data Sync** | Inspect Firebase Realtime Database nodes | Data reflected in `/products`, `/cart`, `/transactions`, `/users` | JSON payloads formatted and dispatched to Firebase Realtime Database endpoints | **PASS** | Synchronized with project `integration-system-3c83a`. |

---

## 2. Summary of Implementation & Fixes
* **Flutter Mobile App**: Fully implemented in `daily-dough/mobile_app` with clean architecture (models, services, screens), passing all Flutter analysis and test suites.
* **Web Dashboard**: Fully implemented in `daily-dough/web_dashboard` (HTML, CSS, JS) with interactive demonstration panel.
* **Database Alignment**: Supports nodes `/products`, `/cart`, `/transactions`, and `/users` matching the assignment specifications.
