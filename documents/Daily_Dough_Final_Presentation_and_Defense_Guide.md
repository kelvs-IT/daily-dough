# Daily Dough: Final System Presentation & Defense Guide

**Course:** ITE 7 – Application Development and Emerging Technologies  
**Institution:** University of Rizal System (URS), Binangonan Campus – College of Computer Studies  
**Subject Instructor:** Anjeline N. Legaspi, LPT, MSIT  
**Activity Reference:** HOA07 – Final System Presentation and Defense (Pages 36–38)  
**Project:** Daily Dough – An On-Demand E-Commerce Platform for Donut Ordering and Delivery  

---

# Part 1: Official Presentation Slides (9 Required Sections)

```
================================================================================
SLIDE 1: TITLE & COVER
================================================================================
```
### Slide 1: Title & Overview
* **Project Title:** Daily Dough: An On-Demand E-Commerce Platform for Donut Ordering and Delivery
* **Course & Code:** ITE 7 – Application Development and Emerging Technologies
* **Academic Institution:** University of Rizal System, Binangonan Campus – College of Computer Studies
* **Subject Instructor:** Anjeline N. Legaspi, LPT, MSIT
* **Project Team:** BSIT / BSIS Development Team
* **Target Backend:** Google Firebase Realtime Database (`dailydough-5480d-default-rtdb`)

> **Speaker Notes:**
> *"Good morning, Ma'am Legaspi and members of the evaluation panel. Today, we present Daily Dough, an on-demand mobile-commerce platform designed to streamline fresh donut and coffee ordering for customers while giving bakery managers full operational oversight through a synchronized web administration dashboard."*

---

```
================================================================================
SLIDE 2: INTRODUCTION
================================================================================
```
### Slide 2: Introduction
* **The Daily Dough Concept:** A modern, mobile-first commerce solution dedicated to artisanal donuts and specialty coffee.
* **The Problem Identified:**
  * Traditional phone-in and physical walk-in bakery ordering leads to long queue times, order mix-ups, and unrecorded sales.
  * Small local bakeries lack affordable, real-time inventory and delivery tracking tools.
* **The Daily Dough Solution:**
  * **Customer Mobile App:** Provides real-time pastry and beverage browsing, isolated shopping carts, and live 5-stage order tracking.
  * **Admin Web Dashboard:** Centralizes store operations with live revenue metrics, product catalog management (CRUD), customer monitoring, and instant order dispatching.

> **Speaker Notes:**
> *"The problem Daily Dough addresses is operational friction in boutique food retail. Customers often encounter long queues and lack visibility into order preparation. On the store side, managing manual paper receipts slows down delivery fulfillment. Daily Dough resolves this by linking a customer mobile app and a management web dashboard through a unified cloud database."*

---

```
================================================================================
SLIDE 3: OBJECTIVES
================================================================================
```
### Slide 3: Objectives
* **General Objective:**
  To design, develop, and deploy an end-to-end, multi-platform M-Commerce system that automates pastry ordering, cart computation, checkout, and administrative order fulfillment using cloud synchronization.
* **Specific Objectives:**
  1. **User Authentication & Role Separation:** Implement secure login and registration with Role-Based Access Control (RBAC) separating customers from store administrators.
  2. **Mobile Ordering Experience:** Develop an intuitive Flutter mobile application featuring dynamic category browsing (Donuts & Coffee), detailed item modifiers, and user-isolated carts.
  3. **Multi-Payment Checkout:** Support Cash on Delivery (COD), GCash mobile wallet, and Credit Card options with automated subtotal calculation.
  4. **Web Administrative Control:** Build a lightweight, responsive web dashboard for real-time KPI monitoring, product CRUD, and order lifecycle management.
  5. **Cloud Synchronization:** Maintain sub-second reactive data synchronization between mobile customers and store managers via Firebase.

> **Speaker Notes:**
> *"Our primary objective was to deliver a complete commercial lifecycle: from customer browsing to cloud transaction recording and admin dispatch. All specific objectives have been verified through automated unit tests and live multi-device synchronization."*

---

```
================================================================================
SLIDE 4: SYSTEM FEATURES
================================================================================
```
### Slide 4: System Features
* **Customer Mobile Application (Flutter):**
  * **Authentication:** Customer sign-up and sign-in with email validation and show/hide password toggle.
  * **Product Catalog:** Real-time browsing of donuts and beverages with keyword search and category tabs.
  * **Item Details:** High-resolution graphics, ingredient/flavor details, and interactive quantity selectors.
  * **Shopping Cart:** Isolated user cart sessions (`/carts/{username}`) with live total computation.
  * **Checkout & Tracking:** 3-step checkout with delivery address validation and a 5-stage live order status timeline.
* **Admin Web Dashboard (HTML5 / Vanilla JavaScript):**
  * **Dashboard Analytics:** Live KPI stat cards (Gross Revenue, Total Orders, Pending Orders, Completed Orders, Customers) and visual sales trend charts.
  * **Product CRUD:** Real-time creation, reading, editing, and deletion of store offerings with image previews.
  * **Order Management:** Filterable order table with instant status transitions (*Order Placed → Preparing Food → Ready for Delivery → Order Delivered*).
  * **Customer Monitoring:** Comprehensive registry of registered customers and lifetime order counts.

> **Speaker Notes:**
> *"Notice the clear separation of concerns between our two applications: the mobile app is optimized for rapid, frictionless purchasing, while the web dashboard provides store administrators with actionable business analytics and fulfillment controls."*

---

```
================================================================================
SLIDE 5: TECHNOLOGIES USED
================================================================================
```
### Slide 5: Technologies Used
* **Mobile Client:**
  * **Flutter SDK (v3.13.5 / 3.47):** High-performance cross-platform UI framework compiling to native Android ARM code.
  * **Dart Language:** Strongly-typed object-oriented language powering application business logic and reactive state management (`ChangeNotifier`).
* **Web Admin Client:**
  * **HTML5 & CSS3:** Semantic markup, CSS Grid, and custom variables delivering a responsive desktop dashboard.
  * **Vanilla JavaScript (ES6+):** Asynchronous `fetch` calls, dynamic DOM manipulation, and SVG chart rendering without heavy external dependencies.
* **Cloud Backend & Persistence:**
  * **Google Firebase Realtime Database:** NoSQL cloud database providing low-latency JSON tree synchronization and persistent data storage.
* **Tooling & Version Control:**
  * **Git & GitHub:** Version control with automated GitHub Pages deployment via GitHub Actions.
  * **Android Studio & Gradle 9.3:** Build toolchain compiling our production-ready release APK.

> **Speaker Notes:**
> *"We specifically chose Flutter and Dart for the mobile client because they compile directly to native machine code, giving our customers smooth animations and immediate responsiveness. For the backend, Google Firebase acts as our Backend-as-a-Service, eliminating server maintenance overhead."*

---

```
================================================================================
SLIDE 6: DATABASE STRUCTURE
================================================================================
```
### Slide 6: Database Structure
* **Architecture:** Firebase Realtime Database JSON Hierarchy
```
dailydough-5480d-default-rtdb.firebaseio.com/
├── users/                <- Authentication credentials & roles
├── customers/            <- Customer profile data (name, email, phone)
├── products/             <- Catalog records (id, name, price, image, details)
├── carts/{username}/     <- Scoped active shopping sessions
└── transactions/         <- Persistent historical customer orders
```
* **Data Flow & Relationships:**
  * **Authentication:** Customer registers → created in `/customers` & `/users`.
  * **Cataloging:** Admin adds/updates `/products` → mobile app streams updates.
  * **Session Isolation:** Carts are strictly scoped to `/carts/{username}`, ensuring customers never share cart items with other users.
  * **Transaction Integrity:** On checkout, cart items are committed as a new timestamped order in `/transactions`, and the active cart is automatically emptied.

> **Speaker Notes:**
> *"Our database uses a normalized JSON tree structure. A key achievement from our Lab 08 optimization was scoping active shopping sessions under `/carts/{username}`, which guarantees complete data privacy between different customer accounts."*

---

```
================================================================================
SLIDE 7: SYSTEM WORKFLOW
================================================================================
```
### Slide 7: End-to-End System Workflow
```
[Customer Mobile App]                     [Firebase Cloud Backend]                 [Admin Web Dashboard]
        │                                             │                                      │
 1. Sign In / Register ─────────────────────────> /users & /customers                        │
        │                                             │                                      │
 2. Browse Donuts & Coffee <────────────────────  /products  <─────────────────── Manage Products (CRUD)
        │                                             │                                      │
 3. Add to Cart ────────────────────────────────> /carts/{username}                          │
        │                                             │                                      │
 4. Complete Checkout ──────────────────────────> /transactions ─────────────────────> Live New Order Alert!
        │                                             │                                      │
 5. View Order Tracking <─────────────────────── Status Change <────────────────── Update Status (Preparing/Delivered)
```

> **Speaker Notes:**
> *"This architectural diagram demonstrates the end-to-end data loop. When a customer confirms checkout on their phone, Firebase receives the transaction in milliseconds. The Admin Web Dashboard instantly detects the new order, increments the pending badge, and allows staff to progress the order through each kitchen stage."*

---

```
================================================================================
SLIDE 8: CHALLENGES ENCOUNTERED & SOLUTIONS
================================================================================
```
### Slide 8: Development Challenges & Engineering Solutions
1. **Challenge 1: Cart Data Cross-Contamination (Lab 08 Bug 2)**
   * *Problem:* Admin and customers previously shared a global `/cart` endpoint.
   * *Solution:* Implemented dynamic user scoping (`/carts/{username}.json`) and cleared local cache upon logout.
2. **Challenge 2: UI Persistence Across Route Transitions (Lab 08 Bug 1)**
   * *Problem:* Floating SnackBars and bottom navigation bars remained visible when logging out.
   * *Solution:* Explicitly cleared SnackBar queues (`ScaffoldMessenger.clearSnackBars()`) and added state-guarded navigation bars.
3. **Challenge 3: Role Separation & Access Control**
   * *Problem:* Preventing customers from loading admin management tools and vice-versa.
   * *Solution:* Built strict client-side role guards: the mobile login screen intercepts `admin` attempts, while the web dashboard blocks all non-admin accounts.

> **Speaker Notes:**
> *"Every software system encounters engineering hurdles. Through systematic debugging and unit testing, we identified and eliminated data leakage bugs, ensuring strict security boundaries and seamless user sessions."*

---

```
================================================================================
SLIDE 9: CONCLUSION & FUTURE WORK
================================================================================
```
### Slide 9: Conclusion
* **Accomplishments:**
  * Successfully developed and integrated all seven Hands-On Activities (**HOA01 to HOA07**).
  * Built a commercially viable M-Commerce platform for Daily Dough.
  * Delivered a compiled 55.7 MB Release APK and an automated web deployment pipeline.
* **Future System Enhancements:**
  1. Direct mobile payment gateway SDK integration (GCash & PayMongo APIs).
  2. Google Maps API integration for real-time delivery rider GPS tracking.
  3. Firebase Cloud Messaging (FCM) for push notifications when donuts leave the oven.

> **Speaker Notes:**
> *"In conclusion, Daily Dough demonstrates how modern mobile-commerce technologies empower traditional food storefronts. The system is robust, thoroughly tested, and ready for deployment. Thank you very much, and we are now ready for your questions."*

---

# Part 2: Step-by-Step Live Demonstration Script (HOA07 Step 2)

Follow this exact 8-step script during your demonstration to Instructor Legaspi:

| Step # | Action to Perform | Where to Click / Type | Expected On-Screen Reaction to Point Out |
| :---: | :--- | :--- | :--- |
| **Step 1** | **User Registration** | Open Mobile App → Tap **"Sign up"** | Enter Full Name, Email, and Password. Show password match validation. Click **Sign Up** → Point out the green "Registration Successful" dialog. |
| **Step 2** | **User Login** | Login Screen | Enter customer credentials. Demonstrate the **Show/Hide password eye toggle**. Tap **Login** → Immediate redirect to Product Catalog. |
| **Step 3** | **Product Browsing** | Products Screen | Scroll through Donut and Coffee items. Switch between **"All"**, **"Donuts"**, and **"Coffee"** tabs. Type in the search bar (e.g. *"Pistachio"* or *"Latte"*). |
| **Step 4** | **Add to Cart** | Tap a product card (e.g., *Matcha Donut*) | Show detailed modal. Adjust quantity to `2`. Tap **"Add to Cart"** → Point out the cart badge updating dynamically. |
| **Step 5** | **Cart & Checkout** | Tap **Cart** → Proceed to Checkout | Review cart items and total. Enter Delivery Address (e.g. *Binangonan, Rizal*). Select **GCash** or **COD**. Tap **Confirm Order** → Success confirmation appears. |
| **Step 6** | **Admin Receives Order** | Switch to Web Dashboard (`http://localhost:5050`) | Show that the new order appears **immediately** at the top of the Orders table with customer name and total. Point out the Header Pending badge count. |
| **Step 7** | **Admin Updates Status** | Web Dashboard → Orders View | In the Status dropdown for that order, change from **"Order Placed"** to **"Preparing Food"** or **"Order Delivered"**. |
| **Step 8** | **User Receives Update** | Switch back to Mobile App → Orders Tab | Point out that the 5-stage timeline indicator has dynamically updated to match the admin's changes without restarting the app! |

---

# Part 3: Oral Defense Reflection Q&A (HOA07 Step 3)

Be prepared to answer these three specific questions during your defense:

### Question 1: What did you learn during the development of this project?
> **Answer:**  
> *"Through Daily Dough, we mastered full-stack mobile-commerce engineering. We learned how to build a reactive user interface in Flutter using Dart, how to structure asynchronous state management, and how to utilize Firebase as a Backend-as-a-Service for instantaneous cloud synchronization. Most importantly, we learned the software engineering discipline of Role-Based Access Control (RBAC), data validation, and automated unit testing to guarantee system stability."*

### Question 2: What technical challenges did you encounter and how did you resolve them?
> **Answer:**  
> *"Our primary challenge was data isolation in a shared NoSQL database. In our earlier prototype, different users shared a generic cart node. We resolved this by re-architecting the database schema to scope active sessions under `/carts/{username}`, ensuring each customer's cart remains completely private. We also resolved state persistence issues across route transitions by managing SnackBar lifecycles with `ScaffoldMessenger` and adding proper password visibility toggles."*

### Question 3: What improvements can still be added to the Daily Dough platform?
> **Answer:**  
> *"If given more development time, our top three enhancements would be:  
> 1. Integrating real payment gateway APIs (such as PayMongo or GCash merchant SDKs) for automated cashless payment verification.  
> 2. Incorporating Google Maps GPS tracking so customers can see their delivery rider moving in real time.  
> 3. Implementing Firebase Cloud Messaging (FCM) to trigger instant push notifications on the customer's phone whenever their donut order status changes."*

---

# Part 4: Final Project Submission Checklist (Page 38)

All 7 required items are verified and ready for final submission to Instructor Anjeline N. Legaspi:

- [x] **1. Mobile Application:** Fully functional Flutter project in `mobile_app/`.
- [x] **2. Web Admin Dashboard:** Operational dashboard in `web_dashboard/`.
- [x] **3. Firebase Integration:** Live cloud synchronization at `dailydough-5480d-default-rtdb`.
- [x] **4. GitHub Repository:** Git initialized with initial commits, `.gitignore`, and GitHub Pages workflow.
- [x] **5. Project Documentation:** Complete technical documentation in `documents/Daily_Dough_Project_Documentation.md`.
- [x] **6. Presentation Slides & Defense Guide:** Formatted and saved in `documents/Daily_Dough_Final_Presentation_and_Defense_Guide.md`.
- [x] **7. APK File:** Compiled release build available at `mobile_app/build/app/outputs/flutter-apk/app-release.apk`.

