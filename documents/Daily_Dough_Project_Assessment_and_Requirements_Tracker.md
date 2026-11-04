# Daily Dough – Project Assessment & Requirements Tracker

**Course:** ITE 7 – Application Development and Emerging Technologies  
**Institution:** University of Rizal System (URS), Binangonan Campus – College of Computer Studies  
**Subject Instructor:** Anjeline N. Legaspi, LPT, MSIT  
**Baseline Academic Manual:** `ITE 7 Module.pdf`  
**Project:** Daily Dough – An On-Demand E-Commerce Platform for Donut Ordering and Delivery  

---

## 1. Executive Summary & Mentor Note

This document serves as the comprehensive project guide, system analysis, and requirements progress tracker for **Daily Dough: An On-Demand E-Commerce Platform for Donut Ordering and Delivery**, evaluated strictly against the academic curriculum and Hands-On Activities (**HOA01** through **HOA07**) specified in the **ITE 7 Module.pdf**.

The Daily Dough project comprises two integrated applications sharing a common cloud backend:
1. **Customer Mobile Application:** Built using Flutter and Dart, providing customer registration, authentication, donut and coffee browsing, isolated shopping carts, multi-step checkout, and real-time order tracking.
2. **Admin Web Application:** A responsive dashboard built with HTML, CSS, and modern JavaScript, providing real-time store metrics (Revenue, Orders, Customers), full product CRUD operations, customer monitoring, and order status lifecycle management (Pending → Processing → Delivered).

---

## 2. Critical Architectural Analysis: Cloud Firestore vs. Firebase Realtime Database

### The Difference
* **The ITE 7 Module specifies:** **Cloud Firestore** (`cloud_firestore` Flutter package, document/collection NoSQL structure under `users`, `products`, `orders`).
* **The existing Daily Dough project uses:** **Firebase Realtime Database (RTDB)** at `https://dailydough-5480d-default-rtdb.firebaseio.com/` (accessed via direct HTTP REST calls in Dart `http` and browser `fetch`).

### Affected Activities in the Module
1. **HOA01 (Activity 5, Step 9):** Installing `cloud_firestore` vs the current lightweight Dart `http` client.
2. **HOA02 (Activity 2 & 3):** Firestore Collections/Documents vs RTDB JSON tree nodes (`/users`, `/customers`, `/products`, `/carts/{username}`, `/orders`, `/transactions`).
3. **HOA02 (Step 10):** Firestore Security Rules vs RTDB Security Rules.
4. **HOA03 & HOA04:** Firestore SDK queries (`FirebaseFirestore.instance.collection(...)`) vs RTDB REST endpoints.
5. **HOA07 (Defense):** Explaining database architecture during the oral defense.

### Engineering Analysis & Recommendation
* **Why the current setup is effective:** The Realtime Database implementation is completely functional, tested, and passing all verification tests. It fulfills all core M-Commerce requirements: cloud persistence, user credential verification, dynamic cart handling, atomic checkout, and real-time dashboard updates with zero server maintenance.
* **Risk to consider:** If the instructor strictly requires Cloud Firestore console screenshots or code imports of `cloud_firestore`, using RTDB might be questioned during defense. However, in software engineering, Firebase Realtime Database is a recognized Google BaaS product with real-time push capabilities.
* **Mentor Recommendation:** Unless the instructor explicitly mandates a rewrite to Cloud Firestore, retain the existing Realtime Database setup. During the defense (HOA07), students can explain that RTDB provides ultra-low latency synchronization ideal for on-demand food delivery order status tracking.

---

## 3. Comprehensive Requirements & Progress Tracker

| Module / Activity | Requirement in ITE 7 Module | Status | Evidence from Project | What Needs to Be Done |
| :--- | :--- | :--- | :--- | :--- |
| **HOA01: Setup** | **Step 1–3**: Flutter SDK, Android Studio, VS Code extensions installed | **COMPLETED** | Flutter 3.13.5 confirmed in `mobile_app/pubspec.yaml`, IDE configurations in `.idea/` | None. Local development environment is verified. |
| **HOA01: Setup** | **Step 5–7**: Flutter Project created & folder structure organized (`screens/`, `models/`, `services/`) | **COMPLETED** | `mobile_app/lib/` has modular structure: `models/`, `screens/`, `services/` | None. Clean architectural organization is in place. |
| **HOA01: Setup** | **Step 8–10**: Connect Firebase to Flutter & verify connection | **COMPLETED** | `FirebaseService.checkFirebaseConnection()` checks `databaseUrl` status | Fully operational with online status monitoring. |
| **HOA01: Setup** | **Step 11**: Create GitHub repository & initial commit (`git init`, push) | **NOT STARTED** | `git status` confirms no `.git` repository exists in `daily-dough` directory | Initialize Git repository, configure `.gitignore`, commit codebase, and push to GitHub. |
| **HOA02: Database & Auth** | **Step 1–5**: Firebase Authentication (Email/Password) & Login/Register UI | **COMPLETED** | `login_screen.dart`, `register_screen.dart`, and `firebase_service.dart` (`login()`, `registerCustomer()`) | Verified functional. Handles validation, email format, password matching, and credential lookup. |
| **HOA02: Database & Auth** | **Step 6–8**: Database collections (`users`, `products`, `orders`) | **COMPLETED** *(via RTDB)* | Verified active nodes: `/users`, `/customers`, `/products`, `/orders`, `/transactions`, `/carts` | Implemented via Realtime Database rather than Firestore (see Section 2). |
| **HOA02: Database & Auth** | **Step 9–10**: Role-Based Access Control (RBAC) & Security Rules | **COMPLETED** *(Application Level)* | `login_screen.dart` strictly blocks admin accounts from mobile app; `app.js` restricts web dashboard to `admin` | Application-level RBAC is active. Firebase console rules remain unverified locally. |
| **HOA03: Mobile App** | **Step 1–3**: Home Screen, Product Grid/List, Product Card widget | **COMPLETED** | `products_screen.dart` with category tabs (Donuts/Coffee), search bar, and item cards | Fully working with responsive grid and image assets. |
| **HOA03: Mobile App** | **Step 4**: Product Details Screen (Image, Name, Description, Price, Add to Cart) | **COMPLETED** | `product_detail_screen.dart` with quantity increment/decrement and cart addition | Fully implemented and matches UI specifications. |
| **HOA03: Mobile App** | **Step 5–6**: Cart System (View items, update quantity, remove, compute total) | **COMPLETED** | `cart_screen.dart`, `firebase_service.dart` (`fetchCart`, `addToCart`, `removeFromCart`) | Isolated customer carts under `/carts/{username}` (Bug 2 resolution). |
| **HOA03: Mobile App** | **Step 7**: Checkout System (Validation, Place Order, Save to DB, Clear Cart) | **COMPLETED** | `checkout_screen.dart` lines 1–200, handles COD, GCash, Card; saves order & clears cart | Validated in Lab 07/08 tests. Order tracking screen also implemented. |
| **HOA04: Admin Web** | **Step 1**: Admin Dashboard Layout (Sidebar, KPI cards, responsive layout) | **COMPLETED** | `web_dashboard/index.html`, `style.css`, `app.js` with KPI cards (Revenue, Orders, Customers) | System Settings was cleanly removed per previous cleanup request. |
| **HOA04: Admin Web** | **Step 2–5**: Product Management (Add Product form, Product Table, Edit/Delete modal) | **COMPLETED** | Form `#adminAddProductForm`, table `#productsTableBody`, `#editProductModal` in `index.html` & `app.js` | Full CRUD operations interact directly with Firebase `/products`. |
| **HOA04: Admin Web** | **Step 6–7**: Order Management (Display orders, filter, Update Status: Pending, Processing, Delivered) | **COMPLETED** | `#viewOrders` section in `index.html`, `filterOrders()`, `updateOrderStatus()` in `app.js` | Real-time order monitoring and status update functional. |
| **HOA04: Admin Web** | **Dashboard**: User / Customer Monitoring | **COMPLETED** | `#viewCustomers` section displays registered customers from `/customers` and `/users` | Customer management view is verified. |
| **HOA05: Integration** | **Step 1–2**: Real-time product & order synchronization testing | **COMPLETED** | Tested and verified in `LAB08_VERIFICATION_REPORT.md` | Mobile and web sync seamlessly over Firebase RTDB. |
| **HOA05: Integration** | **Step 3–4**: Data validation (Product fields, order totals, empty field guards) | **COMPLETED** | Implemented across Flutter validators and web JavaScript form checks | Guards against empty fields, invalid passwords, and missing delivery addresses. |
| **HOA05: Integration** | **Step 5–6**: Debugging report & console logging | **COMPLETED** | Documented in `LAB08_VERIFICATION_REPORT.md` (resolved 3 bugs) | Verification evidence is documented. |
| **HOA06: Testing & Deploy** | **Step 1–3**: Testing Checklist & User Feedback Collection | **PARTIALLY COMPLETED** | `TEST_RESULTS.md` has functional QA matrix; Google Forms user survey not yet documented | Conduct or format user feedback summary from classmates if required by instructor. |
| **HOA06: Testing & Deploy** | **Step 4**: APK Generation (`flutter build apk` -> Release APK) | **PARTIALLY COMPLETED** | `app-debug.apk` exists (103 MB); Release APK (`app-release.apk`) has not been compiled | Execute `flutter build apk --release` to generate the official deployment APK. |
| **HOA06: Testing & Deploy** | **Step 5**: Deploy Admin Dashboard (Firebase Hosting, Netlify, or GitHub Pages) | **NOT STARTED** | Currently runs locally via PowerShell `serve.ps1` (`localhost:5050`) | Deploy the `web_dashboard/` folder to a live URL (e.g., GitHub Pages, Firebase Hosting, or Netlify). |
| **HOA07: Presentation** | **Step 1**: Presentation Slides (9 required content sections) | **PARTIALLY COMPLETED** | `PRESENTATION_SLIDES.md` exists (drafted for Lab 07) | Update and expand slides to cover all 9 HOA07 sections (HOA01–HOA06, Reflection). |
| **HOA07: Presentation** | **Step 2**: Live Demonstration Flow (8-step demonstration script) | **COMPLETED** | `DEMO_GUIDE.md` provides step-by-step presentation script | Prepared and verified. |
| **HOA07: Presentation** | **Step 3**: Reflection Questions (Learnings, challenges, future improvements) | **PARTIALLY COMPLETED** | Challenges documented in `Daily_Dough_Project_Documentation.md` | Create a dedicated reflection Q&A sheet for defense prep. |
| **Final Submission** | **Deliverables Checklist** (Page 38 of Module):<br>1. Mobile App<br>2. Web Admin Dashboard<br>3. Firebase Integration<br>4. GitHub Repository<br>5. Documentation<br>6. Presentation Slides<br>7. APK File | **PARTIALLY COMPLETED** | 1. Done (`mobile_app/`)<br>2. Done (`web_dashboard/`)<br>3. Done (RTDB live)<br>4. **Pending** (No Git repo)<br>5. Done (`documents/`)<br>6. In progress<br>7. **Pending** (Release APK) | Fulfill items 4, 6, and 7 to complete 100% of final submission requirements. |

---

## 4. Summary of Accomplishments

1. **Full Mobile Storefront:** Product browsing with treats & coffee, quantity selection, detailed modals, live cart calculation, isolated cart sessions, and multi-step checkout with COD, GCash, and Card.
2. **Full Admin Web Dashboard:** Secure login for admin, live sales analytics (Revenue, Orders, Customers), instant product CRUD (create, read, update, delete with images), customer list viewing, and order status updates (Pending → Processing → Delivered).
3. **Database Integration:** Working cloud backend via Firebase with real-time updates and zero server maintenance.
4. **Engineering Documentation:** Professional project documentation already generated and saved in `daily-dough/documents/Daily_Dough_Project_Documentation.md`.

---

## 5. What Remains to Be Done (The Gap to 100% Completion)

1. **GitHub Repository Setup (HOA01 Step 11 & Final Submission Item 4):**
   - Initialize Git in `daily-dough/`.
   - Ensure sensitive or unnecessary cache files (`build/`, `.dart_tool/`) are ignored via a proper `.gitignore`.
   - Make an initial commit and link to a GitHub remote repository.
2. **Generate Release APK (HOA06 Step 4 & Final Submission Item 7):**
   - Compile the production-ready installable `app-release.apk` using `flutter build apk --release`.
3. **Deploy Admin Web Dashboard (HOA06 Step 5 & HOA06 Deliverable):**
   - Host `web_dashboard/` on a live platform (such as **GitHub Pages**, **Firebase Hosting**, or **Netlify**) so the instructor can view it online without running `localhost`.
4. **Update Presentation Slides & Defense Prep (HOA07 Step 1 & 3):**
   - Update `PRESENTATION_SLIDES.md` into presentation-ready slides covering the exact 9 sections requested in HOA07.
   - Prepare structured answers for the 3 Defense Reflection questions (*What did you learn? What challenges did you encounter? What improvements can still be added?*).
5. **QA & User Testing Feedback Sheet (HOA06 Step 1–3):**
   - Format a standard evaluation checklist (Login, Register, Cart, Checkout: Yes/No) and sample feedback questions from classmates.

---

## 6. Recommended Next Steps

1. **Phase 1 (Immediate):** Setup the Git repository with a clean `.gitignore` (HOA01 Step 11).
2. **Phase 2:** Generate the official release APK (`app-release.apk`) (HOA06 Step 4).
3. **Phase 3:** Deploy the web dashboard to GitHub Pages or Netlify (HOA06 Step 5).
4. **Phase 4:** Finalize HOA07 Presentation Slides, Demo script, and Reflection answers.

