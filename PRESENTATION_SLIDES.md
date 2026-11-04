# Presentation Slides: Lab Exercise 07
## Enhancing the Firebase Integration System with Cart and Checkout Workflow

---

### Slide 1: Title & Application Overview
* **Project Title**: Daily Dough — Firebase Integrated Shopping System
* **Course**: ITE 7 — Application Development and Emerging Technologies
* **Institution**: University of Rizal System (URS)
* **Instructor**: Anjeline N. Legaspi, LPT, MSIT
* **Technology Stack**:
  * **Frontend**: Flutter Mobile App & Modern Web Dashboard
  * **Backend & Database**: Firebase Realtime Database (`integration-system-3c83a`)
  * **Architecture**: Realtime Reactive Synchronized State

---

### Slide 2: Purpose & Firebase Realtime Database Architecture
* **Purpose**:
  * Bridge multi-platform clients (Flutter mobile & Web dashboard) with a unified, real-time database backend.
  * Implement full e-commerce lifecycle: authentication, dynamic cart, checkout validation, and atomic transaction recording.
* **Database Schema (Firebase Realtime Database)**:
  * `/products`: Catalog records with real-time pricing (`name`, `price`, `details`).
  * `/cart`: Active shopping sessions dynamically synced per client.
  * `/transactions`: Persistent historical order records with timestamp, customer details, and total.
  * `/users`: Role-based authentication credentials (`username`, `password`).

---

### Slide 3: Functional Features (Authentication, Cart & Checkout)
* **Part B: Authentication**:
  * Clean login interface validating non-empty fields against Firebase `/users` records.
  * Automatic redirection to Product Catalog upon verified authentication.
* **Part C: Cart Functionality**:
  * Real-time "Add to Cart" button on every product item.
  * Dedicated Cart Page displaying itemized list and automatically computed total.
* **Part D: Checkout Workflow**:
  * Complete checkout form capturing Customer Name, Delivery Address, and Payment Method (COD, GCash, Credit Card).
  * Robust input validation preventing incomplete submissions.

---

### Slide 4: Security Implementation & Integration Testing Results
* **Part E: Security & Access Control**:
  * **Scenario 1 (Access Control)**: Direct access to Cart/Checkout without authenticating produces *"Access Denied Please Login First"*.
  * **Scenario 2 (Form Validation)**: Incomplete checkout submissions produce *"Validation Error"*.
  * **Scenario 3 (Bad Credentials)**: Invalid login attempts produce *"Invalid Username or Password"*.
* **Part F: Transaction Processing Verification**:
  * Automatic total summation: ₱35,000 + ₱15,000 + ₱2,500 = **₱52,500**.
  * Instant transaction creation in `/transactions`, confirmation receipt modal, and automatic cart clearing.
* **Test Suite Status**: 11/11 Test Cases **PASSED** (100% compliance).

---

### Slide 5: Group Reflection & Key Learnings
* **Challenges Encountered**:
  * Synchronizing cross-platform state across both web and mobile environments.
  * Enforcing robust client-side access control guards to prevent unauthenticated URL navigation.
* **How Issues Were Resolved**:
  * Implemented centralized route guards and standardized REST/SDK payloads for Firebase Realtime Database.
  * Added fallback error handling and validation alerts for edge cases.
* **Key Learnings**:
  * Practical understanding of NoSQL JSON trees in Firebase Realtime Database.
  * Developing resilient checkout workflows and testing automated validation sequences.
