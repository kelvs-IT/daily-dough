# Lab Exercise 07: Live System Demonstration Guide
## Step-by-Step Presentation Script for Instructor Demonstration

- **Course**: ITE 7 – Application Development and Emerging Technologies
- **Instructor**: Anjeline N. Legaspi, LPT, MSIT
- **Student Project Folder**: `daily-dough`

---

## Demonstration Sequence (PDF Step 8)

Follow this exact sequence during your live presentation or video recording:

### 1. Application Overview (30 seconds)
* **Project Name**: Daily Dough — Firebase Integrated Shopping System
* **Firebase Database**: Connected to project `integration-system-3c83a` at `https://integration-system-3c83a-default-rtdb.firebaseio.com/`.
* **Objective**: Demonstrating authentication, shopping cart, checkout workflow, transaction processing, and access control.

---

### 2. Live Demonstration Steps

#### Step 1: Security Checking (Scenarios 1 & 3)
1. **Access Control (Scenario 1)**:
   * Attempt to navigate to the **Cart** or **Checkout** while logged out.
   * **Instructor Verification**: Point out the card stating:  
     `Access Denied - Please Login First`.
2. **Invalid Credentials (Scenario 3)**:
   * On the Login screen, enter username `admin` and an incorrect password (e.g. `wrong123`).
   * Click **Login**.
   * **Instructor Verification**: Point out the error message:  
     `Invalid Username or Password`.

#### Step 2: Authentication (Part B)
1. Enter the valid test credentials:
   * **Username**: `admin`
   * **Password**: `admin123`
2. Click **Login**.
3. **Instructor Verification**: Show that upon successful login, the system immediately redirects you to the **Products Page**.

#### Step 3: Product Listing & Cart Functionality (Part C)
1. Show the products displayed:
   * Laptop (₱35,000)
   * Phone (₱15,000)
   * Headphones (₱2,500)
   * Smartwatch (₱8,500)
2. Click **Add to Cart** on at least three items:
   * Add **Laptop** (₱35,000)
   * Add **Phone** (₱15,000)
   * Add **Headphones** (₱2,500)
3. **Instructor Verification**: Show the cart badge in the top bar updating to `3`.

#### Step 4: Cart Page & Automatic Total Calculation (Part C Step 4)
1. Click the **Cart** button in the navigation bar.
2. Show all 3 added items listed.
3. **Instructor Verification**: Point out the automatic total calculation:  
   `Total: ₱52,500` (₱35,000 + ₱15,000 + ₱2,500).

#### Step 5: Checkout Form & Input Validation (Scenario 2 / Part D)
1. Click **Proceed to Checkout**.
2. **Test Scenario 2 (Validation Error)**:
   * Leave the Customer Name or Address blank.
   * Click **Confirm Checkout**.
   * **Instructor Verification**: Point out the alert message:  
     `Validation Error`.
3. Now fill in valid information:
   * **Customer Name**: `Juan Dela Cruz`
   * **Delivery Address**: `123 Rizal St, Morong, Rizal`
   * **Payment Method**: `Cash on Delivery`
4. Show the order summary.

#### Step 6: Transaction Processing (Part F)
1. Click **Confirm Checkout**.
2. **Instructor Verification**:
   * Show the confirmation alert: `Transaction Completed Successfully!`
   * Show the transaction receipt details (Customer, Address, Total: ₱52,500, Status: `Completed`).
   * Show that the **Cart is automatically cleared** (Badge returns to `0`).
3. Click **Transactions** in the navigation bar and show the new record logged with its timestamp and ID.

---

## 3. How to Launch Your Demonstration

### To Launch the Web Dashboard:
Double-click or open in Google Chrome:
`C:\Users\benzy\.gemini\antigravity-ide\scratch\daily-dough\web_dashboard\index.html`

### To Run the Flutter Mobile App:
In your terminal, run:
```powershell
cd C:\Users\benzy\.gemini\antigravity-ide\scratch\daily-dough\mobile_app
flutter run -d chrome
```
*(Or target your Android device / emulator if connected)*.
