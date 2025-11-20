# **Masjid-Connect Mobile Application**

## **1\. Project Initiation - Aisar Nasrun, Farhan Haikal, Muhammad Daniel, Muzammel**

### **1.1 Group Details**

**Group Name:** Tung Tung Tung Sahur

| Name | Matric No | Assigned Tasks |
| :---- | :---- | :---- |
| Aisar Nasrun Bin Ramjee | 2216791 | Documentation, UI/UX Design, Frontend \- Prayer Times Screen |
| Farhan Haikal Bin Hishamuddin | 2219173 | Backend \- Authentication, Database Setup |
| Muhammad Daniel | 2218857 | Deployment, Frontend \- Events Screen, State Management |
| Muzammel | 2310939 | Testing, Frontend \- Profile Screen, API Integration |

### **1.2 Project Overview**

**Title:** Masjid-Connect

**Background of the Problem:** In the digital age, community engagement with local mosques (masjids) often relies on fragmented communication channels like WhatsApp groups, physical notice boards, or verbal announcements. This leads to missed information regarding prayer times, events, donations, and community updates. There is a lack of a centralized, digital platform that consolidates all masjid-related activities and information for the *jama'ah* (congregation).

**Purpose/Objective:** The purpose of "Masjid-Connect" is to bridge the communication gap between the masjid administration and the community. The objectives are:

* To provide accurate, real-time prayer times based on location.  
* To facilitate easy access to masjid events and announcements.  
* To streamline donation processes for mosque maintenance and community welfare.  
* To enhance community engagement through a centralized mobile platform.

**Target User:**

* **Primary:** Muslim community members (Congregants).  
* **Secondary:** Masjid Committee/Administrators (for content management).

**Preferred Platform:**

* **Mobile Application:** Developed using Flutter (Cross-platform for Android & iOS).

**Features and Functionalities:**

1. **Authentication:** User registration and login (Email/Password).  
2. **Prayer Times:** Real-time daily prayer schedule based on user location.  
3. **Qibla Finder:** Compass feature to point towards the Qibla direction.  
4. **Events & Announcements:** List of upcoming lectures, classes, and community events with details.  
5. **Donation:** Secure integration for users to donate to the masjid funds.  
6. **Masjid Locator:** Map view to find nearby masjids.  
7. **Digital Tasbih:** Simple counter for dhikr.

## **2\. Requirement Analysis & Planning - Aisar Nasrun (2216791)**

### **2.1 Technical Feasibility**

* **Framework:** Flutter (Dart) for high-performance, cross-platform development.  
* **Backend:** Firebase (BaaS) for:  
  * **Authentication:** Managing user accounts securely.  
  * **Cloud Firestore:** NoSQL database for storing user data, events, prayer times settings, and donation records.  
  * **Storage:** Storing images for event banners and user profiles.  
* **State Management:** Provider or Riverpod for efficient state handling across screens.  
* **APIs:** Integration with a Prayer Times API (e.g., Aladhan API) and Google Maps API.

### **2.2 Logical Design**

**Screen Navigation Flow:**

1. **Splash Screen** \-\> **Login/Register**  
2. **Home Screen** (Dashboard with Prayer Times)  
3. **Navigation Bar**:  
   * Home \-\> Events \-\> Donation \-\> Profile \-\> Qibla/Tasbih

**Sequence Diagram (simplified):**

* *User* opens app \-\> *App* checks Auth status.  
* If logged out \-\> Show Login Screen \-\> *User* inputs credentials \-\> *Firebase* verifies \-\> Access granted.  
* If logged in \-\> Show Home Screen \-\> *App* fetches location \-\> *App* calls Prayer Time API \-\> Display times.

## **3\. Planning (Gantt Chart) - Farhan Haikal**

**Timeline:** Nov 10, 2025 to Jan 25, 2026

| Phase | Task | Duration | Start Date | End Date |
| :---- | :---- | :---- | :---- | :---- |
| **Initiation** | Idea Proposal & Project Setup | 1 Week | Nov 10, 2025 | Nov 16, 2025 |
| **Analysis** | Requirement Gathering & Feasibility | 1 Week | Nov 17, 2025 | Nov 23, 2025 |
| **Design** | UI/UX Design (Figma/Mockups) | 2 Weeks | Nov 24, 2025 | Dec 07, 2025 |
| **Development** | Frontend Implementation (Widgets) | 3 Weeks | Dec 08, 2025 | Dec 28, 2025 |
| | Backend Integration (Firebase) | 2 Weeks | Dec 15, 2025 | Dec 28, 2025 |
| | API & Logic Implementation | 2 Weeks | Dec 29, 2025 | Jan 11, 2026 |
| **Testing** | Bug Fixes & Usability Testing | 1 Week | Jan 12, 2026 | Jan 18, 2026 |
| **Final** | Documentation & Presentation Prep | 1 Week | Jan 19, 2026 | Jan 25, 2026 |



## **4\. Project Design - Muhammad Daniel**

### **4.1 User Interface (UI)**

The app utilizes Flutter's Material Design widgets to ensure a native look and feel on Android and a smooth experience on iOS.

* **Navigation:** Bottom Navigation Bar for easy switching between core features (Home, Events, Profile).  
* **Responsiveness:** Layouts use MediaQuery and Expanded widgets to adapt to different screen sizes.

### **4.2 User Experience (UX)**

* **Intuitive Layout:** Essential information (Prayer Times) is placed prominently on the Home screen.  
* **Feedback:** Loading indicators (spinners) are used during data fetching to inform the user.  
* **Minimalism:** Clean interfaces with whitespace to avoid clutter, focusing on readability for text-heavy sections like announcements.

### **4.3 Consistency**

* **Theme:** A consistent color palette (e.g., Green/Gold/White) reflecting an Islamic aesthetic.  
* **Typography:** Uniform font styles for headings and body text throughout the app.  
* **Icons:** Consistent icon sets (Material Icons) for navigation and actions.

## **5\. Project Development - Muzammel**

### **5.1 Functionality Implementation**

* **Widgets:** Extensive use of Stateless and Stateful widgets. Custom widgets created for reusable components like "Prayer Time Card" and "Event Tile".  
* **Navigation:** Named routes defined in main.dart for clean navigation management.

### **5.2 Code Quality**

* **Modular Structure:**  
  * lib/models/: Data models (e.g., User, Event, PrayerTime).  
  * lib/screens/: UI screens (e.g., home\_screen.dart, login\_screen.dart).  
  * lib/services/: Backend logic (e.g., auth\_service.dart, database\_service.dart).  
  * lib/widgets/: Reusable UI components.

### **5.3 Packages and Plugins**

* firebase\_core, firebase\_auth, cloud\_firestore: For backend services.  
* provider: For state management.  
* http: For fetching prayer times from external APIs.  
* geolocator: To get device location for accurate prayer times.  
* intl: For date and time formatting.

### **5.4 Collaborative Tool**

* **GitHub:** Used for version control.  
* **Branching Strategy:** Created separate branches for features (e.g., feature-auth, feature-ui) and merged into main after review.

## **6\. References**

1. Flutter Team. (n.d.). *Flutter documentation*. Flutter. https://flutter.dev/docs  
2. Firebase. (n.d.). *Firebase documentation*. Google. https://firebase.google.com/docs  
3. Aladhan. (n.d.). *Prayer Times API*. https://aladhan.com/prayer-times-api

*(Add any other specific tutorials, StackOverflow threads, or AI tools used here in APA format)*
