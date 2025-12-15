# **Masjid-Connect Mobile Application**

### **Group Details**

### **Group Name:** Tung Tung Tung Sahur

| Name | Matric No | Assigned Tasks | Documentation Tasks |
| :---- | :---- | :---- | :---- |
| Aisar Nasrun Bin Ramjee | 2216791 | Smart Announcement (Geofencing) | Project Ideation & Initiation |
| Farhan Haikal Bin Hishamuddin | 2219173 | Backend \- Authentication, Dynamic Prayer Dashboard | Requirement Analysis & Planning |
| Muhammad Daniel | 2218857 | Events & Community Hub | Project Design |
| Muzammel | 2310939 | Utilities | Project Development |

## **1\. Project Ideation & Initiation**

*(Responsible: Aisar)*

### **1.1 Title**

Masjid-Connect

**1.2 Background of the Problem**

Despite the Masjid historically serving as the social and spiritual nucleus of the Muslim community, contemporary engagement is heavily hindered by a reliance on fragmented communication channels such as physical notice boards and informal messaging apps like WhatsApp. This lack of a centralized digital infrastructure leads to "information overload" and significant inefficiencies, where critical updates regarding prayer times, community events, and fundraising are frequently missed by the congregation due to the noise of unmanaged chat groups [1](https://www.joynedapp.com/blog/why-churches-outgrow-whatsapp---7-risks-and-fixes). Research highlights that while religious institutions are attempting to digitize, the absence of a structured management system results in "undirected" outreach that fails to bridge the gap between administration and  the modern, digital-native *jama'ah*, effectively excluding members who are not physically present or part of specific social circles [2](https://www.researchgate.net/publication/357537528_The_Mapping_of_Mosque_Community_to_Improve_Mosque_Engagement_in_Community) [3](https://www.researchgate.net/publication/394145052_A_Review_of_The_Opportunities_and_Challenges_in_Digital-Based_Masjid_Management).

**1.3 Purpose & Objective**

The purpose of "Masjid-Connect" is to centralize and modernize mosque management by replacing fragmented communication channels with a unified digital ecosystem. The application aims to bridge the information gap between the *Masjid* administration and the *Jama'ah*, ensuring that spiritual activities and community welfare are accessible, transparent, and engaging.

**The objectives are:**

* **To deliver precision:** Provide accurate, location-based prayer times and Qibla direction to facilitate daily worship.  
* **To enhance engagement:** Implement context-aware technology (Geofencing) to trigger relevant updates when congregants enter the mosque vicinity.  
* **To centralize information:** Consolidate event scheduling, lectures, and announcements into a single, easily accessible dashboard.  
* **To digitize philanthropy:** Streamline the donation process for mosque maintenance and welfare projects, ensuring security and ease of use.

**1.4 Target User**

* **Primary:** The Local Muslim Community (Congregants/Jama'ah), including youth and residents.  
* **Secondary:** Travelers looking for nearby prayer facilities.  
* **Administrative:** Mosque Committee Members responsible for content and event management.

**1.5 Preferred Platform**

* **Framework:** Flutter (Dart) – Selected for high-performance, single-codebase development across both Android and iOS.  
* **Backend:** Firebase – Utilized for real-time database management (Firestore), secure authentication, and cloud functions.

### **1.6 Features and Functionalities**

1. **Secure Authentication:** User registration/login via Email/Password and Google Sign-in.  
2. **Dynamic Prayer Dashboard:** Real-time daily schedules based on geolocation with Azan notifications.  
3. **Smart Announcements (Geofencing):** Automated notifications for events triggered when users physically enter the masjid premises.  
4. **Events & Community Hub:** Centralized feed for lectures and classes with detailed views.  
5. **Utilities:** Integrated Qibla Finder (Compass) and Digital Tasbih (Counter).

## **2\. Requirement Analysis & Planning**

## *(Responsible: Farhan)*

### **2.1 Technical Feasibility & Backend Assessment**

* **Data Storage (CRUD):** The app utilizes **Cloud Firestore** (NoSQL) to handle Create, Read, Update, and Delete operations for Users, Events, and Prayer Time settings.  
* **Platform Compatibility:** Flutter ensures the app is compatible with smartphones (Android/iOS) and scalable to wearables if needed.  
* **Packages & Plugins:**  
  * firebase\_auth: For secure user management.  
  * geolocator: For fetching device coordinates.  
  * http: For consuming external Prayer Time APIs (e.g., JAKIM eSolat API).

### **2.2 Logical Design**

A. Screen Navigation Flow:

Splash Screen → Login/Register → Home Screen (Dashboard)

From Home, the Bottom Navigation Bar leads to:

Events ↔ Donation ↔ Profile ↔ Spiritual Tools (Qibla/Tasbih) 

**B. Sequence Diagram (Authentication & Data Fetch):**

1. **User** opens app.  
2. **System** checks Auth State.  
3. Alt Frame (Not Logged In): System shows Login Screen → User enters credentials → Firebase verifies → Access Granted.  
4. Alt Frame (Logged In): System shows Home → App requests Location → **API** returns Prayer Times → App displays Dashboard .

### **2.3 Planning (Gantt Chart)**

**Timeline:** 10 November 2025 \- 25 January 2026
<img width="1024" height="768" alt="image" src="https://github.com/user-attachments/assets/3ab5e278-4412-4ed1-ad2a-f1d269ee40cc" />

![][image1]

### **2.4 Project Initiation**
 **Duration:** November Week 1 – Week 2
 **Responsible Member:** Aisar Nasrun Bin Ramjee
 **Key Activities:**
    * **Problem Identification:** Identified the main issue of "information overload" in mosque communities due to fragmented nature of communication channels like WhatsApp and physical boards.
    * **Objective Definition:** Established the primary goal to centralize mosque management and digitize individual that donates.
    * **Milestone:** Completion of the Ideal Proposal and Project Setup.

### **2.5Requirement Analysis**
* **Duration:** November Week 2 – Week 3
* **Responsible Member:** Farhan Haikal Bin Hishamuddin
* **Key Activities:**
    * **Feasibility Study:** Evaluated the technical requirements, confirming **Flutter** (Dart) for the frontend and **Firebase** (Cloud Firestore) for the backend to ensure platform compatibility.
    * **Data Modeling:** Designed the Logical Schema for CRUD operations, specifically for Users, Events, and Prayer Time settings.
    * **Plugin Assessment:** Selected essential packages such as `firebase_auth` for security, `geolocator` for location services, and `http` for the JAKIM eSolat API integration.
    * **Milestone:** Finalized Requirement Specification and Logical Design.

### **2.6 Design**
* **Duration:** November Week 4 – December Week 1
* **Responsible Member:** Muhammad Daniel
* **Key Activities:**
    * **UI/UX Design:** Developed the application interface using Flutter's Material Design principles, utilizing a Green/Gold/White color palette to reflect an Islamic aesthetic.
    * **Screen Navigation:** Mapped the user flow from the Splash Screen to Authentication, followed by the Dashboard and specific feature tabs (Events, Donation, Profile).
    * **Prototyping:** Structured the layout to prioritize high-frequency information, such as Prayer Times, at the top of the home screen to reduce cognitive load.
    * **Milestone:** Completion of UI Wireframes and Screen Navigation Flow.

### **2.7 Development**
* **Duration:** December Week 1 – December Week 4
* **Responsible Member:** Muzammel
* **Key Activities:**
    * **Frontend Implementation:** Implemented the UI code using modular widgets (e.g., `Prayer Time Card`, `Event Tile`) to ensure code reusability.
    * **Backend Integration:** Connected the Flutter app to Firebase services for real-time database management and user authentication.
    * **Logic Implementation:** Coded the core functionalities, including the API fetch for prayer times and logic for the Qibla finder.
    * **Milestone:** Delivery of a functional Alpha version of the Masjid-Connect application.


## **3\. Project Design**

*(Responsible: Daniel)*

### **3.1 User Interface (UI)**

* **Mobile Design Principles:** The app utilizes Flutter's Material Design to ensure a native look. Layouts are built using `MediaQuery` and `Expanded` widgets to ensure responsiveness across different screen sizes.  
* **Gestures:** Swipe gestures are implemented for list items (e.g., deleting a notification) and tab switching.

### **3.2 User Experience (UX)**

* **Intuition:** Essential information, specifically Prayer Times, is placed prominently at the top of the Home screen to reduce cognitive load.  
* **Feedback:** Loading indicators (spinners) and "Snackbars" are used to inform the user of success/failure states during data fetching.  
* **Minimalism:** The design utilizes whitespace effectively to avoid clutter, focusing on readability for text-heavy sections like announcements.

### **3.3 Consistency**

* **Theme:** A consistent color palette (Green/Gold/White) is used to reflect an Islamic aesthetic.  
* **Typography:** Uniform font styles (Google Fonts) are applied to headings and body text throughout the app.  
* **Iconography:** Standardized Material Icons are used for the bottom navigation bar and action buttons.

## **4\. Project Development**

*(Responsible: Muzammel)*

### **4.1 Functionality Implementation**

* **Widgets:** Extensive use of Stateless and Stateful widgets. Custom widgets created for reusable components like "Prayer Time Card" and "Event Tile".  
* **Navigation:** Named routes defined in main.dart for clean navigation management.

### **4.2 Code Quality**

* **Modular Structure:**  
  * lib/models/: Data models (e.g., User, Event, PrayerTime).  
  * lib/screens/: UI screens (e.g., home\_screen.dart, login\_screen.dart).  
  * lib/services/: Backend logic (e.g., auth\_service.dart, database\_service.dart).  
  * lib/widgets/: Reusable UI components.

### **4.3 Packages and Plugins**

* firebase\_core, firebase\_auth, cloud\_firestore: For backend services.  
* provider: For state management.  
* http: For fetching prayer times from external APIs.  
* geolocator: To get device location for accurate prayer times.  
* intl: For date and time formatting.

### **4.4 Collaborative Tool**

* **GitHub:** Used for version control.  
* **Branching Strategy:** Created separate branches for features (e.g., feature-auth, feature-ui) and merged into main after review.

## **5\. References**

1. **Joyned. (2024).** *Why Churches Outgrow WhatsApp – 7 Risks and Fixes*. Joyned Blog. [https://www.joynedapp.com/blog/why-churches-outgrow-whatsapp---7-risks-and-fixes](https://www.joynedapp.com/blog/why-churches-outgrow-whatsapp---7-risks-and-fixes)  
2. **Rosadi, K.I. et al. (2022).** *The Mapping of Mosque Community to Improve Mosque Engagement in Community*. [https://www.researchgate.net/publication/357537528\_The\_Mapping\_of\_Mosque\_Community\_to\_Improve\_Mosque\_Engagement\_in\_Community](https://www.researchgate.net/publication/357537528_The_Mapping_of_Mosque_Community_to_Improve_Mosque_Engagement_in_Community)  
3. **Madina Apps. (2025).** *Top 5 Tech Tips for Mosque Community Engagement 2025*. Madina Apps Blog. [https://www.researchgate.net/publication/394145052\_A\_Review\_of\_The\_Opportunities\_and\_Challenges\_in\_Digital-Based\_Masjid\_Management](https://www.researchgate.net/publication/394145052_A_Review_of_The_Opportunities_and_Challenges_in_Digital-Based_Masjid_Management)


