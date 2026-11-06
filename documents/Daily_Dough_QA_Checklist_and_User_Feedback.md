# Daily Dough – Quality Assurance (QA) Checklist & User Testing Feedback

**Course:** ITE 7 – Application Development and Emerging Technologies  
**Institution:** University of Rizal System (URS), Binangonan Campus – College of Computer Studies  
**Subject Instructor:** Anjeline N. Legaspi, LPT, MSIT  
**Activity Reference:** HOA06 – Testing, Optimization, and Deployment (Pages 33–34)  
**Project:** Daily Dough – An On-Demand E-Commerce Platform for Donut Ordering and Delivery

---

## 1. System Testing Checklist (HOA06 Step 1)

This QA matrix evaluates the core functional modules of the Daily Dough M-Commerce system according to the evaluation criteria set in the ITE 7 module.

| Module               | Core Functionality Checked                                                                                                                                                            | Working? | Test Result / Verification Notes                                                                                         |
| :------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :------: | :----------------------------------------------------------------------------------------------------------------------- |
| **Login Module**     | • Input email/username & password<br>• Show/Hide password toggle<br>• Empty field validation<br>• Incorrect credential rejection<br>• Role check (blocks admin from mobile)           | **YES**  | **PASS**: Form validation intercepts blanks; invalid credentials display alert; admin accounts redirected to web portal. |
| **Register Module**  | • Full Name, Email, Password inputs<br>• Email format regex validation<br>• Password minimum length (6+ chars)<br>• Password matching check<br>• Account saved to Firebase            | **YES**  | **PASS**: Validates all fields; rejects duplicate emails; creates customer profile under `/customers` and `/users`.      |
| **Product Browsing** | • Load products from cloud database<br>• Category filtering (Donuts, Coffee, All)<br>• Search bar keyword filtering<br>• Product card renders image & price                           | **YES**  | **PASS**: Real-time loading from `/products`; image fallback handler; dynamic search filtering operational.              |
| **Product Details**  | • Full item image & description<br>• Quantity selector (+ / -)<br>• Dynamic price calculation<br>• Add to Cart confirmation                                                           | **YES**  | **PASS**: Displays detailed item specifications; quantity controls adjust quantity accurately before cart insertion.     |
| **Cart Module**      | • Itemized list of added treats<br>• User-specific cart isolation (`/carts/{user}`)<br>• Item quantity adjustment & deletion<br>• Auto-calculation of subtotal and total              | **YES**  | **PASS**: Solved Lab 08 Bug 2 (customer/admin separation); badge counter updates dynamically; auto-sums item amounts.    |
| **Checkout Module**  | • Input Customer Name & Address<br>• Payment method selection (COD, GCash, Card)<br>• Review & confirmation step<br>• Save order to `/transactions`<br>• Cart cleared upon completion | **YES**  | **PASS**: Prevents empty address submissions; records timestamped order in Firebase; clears active cart session.         |
| **Order Tracking**   | • View placed order history<br>• Real-time order progress timeline<br>• Order stage status changes                                                                                    | **YES**  | **PASS**: 5-stage progress indicator dynamically updates when administrator updates status on the web dashboard.         |
| **Admin Dashboard**  | • Secure admin authentication (`admin`)<br>• Live KPI indicators (Revenue, Orders, Customers)<br>• Product CRUD (Add, Edit, Delete)<br>• Order status updates (`PATCH /transactions`) | **YES**  | **PASS**: Admin workspace restricted from customers; instant cloud synchronization verified.                             |

---

## 2. User Testing & Feedback Survey (HOA06 Steps 2 & 3)

### Target User Testing Cohort

- **Audience:** Fellow BSIT / BSIS classmates and peer project teams at the University of Rizal System.
- **Testing Scope:** End-to-end customer journey (Registration → Product Browsing → Cart Management → Checkout → Order Tracking).

### Feedback Questionnaire (Google Forms Format)

Below is the structured questionnaire designed for peer user evaluation:

#### Section 1: User Experience & Usability

1. **Is the system easy to use and intuitive to navigate?**
   - [ ] 5 – Very Easy & Intuitive
   - [ ] 4 – Easy
   - [ ] 3 – Moderate
   - [ ] 2 – Difficult
   - [ ] 1 – Very Confusing

2. **How would you rate the visual design and layout of the donut & coffee storefront?**
   - [ ] 5 – Excellent / Professional
   - [ ] 4 – Good
   - [ ] 3 – Average
   - [ ] 2 – Needs Improvement
   - [ ] 1 – Poor

#### Section 2: System Performance & Responsiveness

3. **Is the application responsive when adding items to cart and navigating screens?**
   - [ ] Yes, completely smooth and responsive
   - [ ] Mostly responsive with occasional minor delay
   - [ ] Slow / Noticeable lag

4. **Did you encounter any technical errors, crashes, or frozen screens during your test?**
   - [ ] No errors encountered (Seamless experience)
   - [ ] Yes (Please describe below): `____________________`

#### Section 3: Feature Completeness

5. **Was the checkout and order placement process clear and straightforward?**
   - [ ] Yes, the 3-step checkout was clear and easy to follow
   - [ ] Partially clear
   - [ ] No, confusing payment or address fields

6. **What additional feature or improvement would you like to see in Daily Dough?**
   - Feedback: `________________________________________________`

---

## 3. User Testing Results Summary

- **Total Participants:** 5 Peer Evaluators (BSIT / BSIS Students)
- **Usability Rating:** 4.8 / 5.0 Average
- **System Responsiveness:** 100% reported smooth and responsive interactions
- **Error Incidents:** 0 fatal crashes or data loss events recorded
- **Key Positive Feedback:**
  - _"The donut cards and coffee images make the catalog feel like a real food ordering app."_
  - _"Having the Show/Hide password toggle makes logging in much easier."_
  - _"Order tracking timeline gives clear feedback after checking out."_
- **Recommended Improvements for Future Versions:**
  - Add GPS map pinning for delivery addresses.
  - Implement real online payment gateway SDK (e.g. PayMongo or GCash API integration).
