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

### **1.1 Title**

Masjid-Connect

**1.2 Background of the Problem**

Despite the Masjid historically serving as the social and spiritual nucleus of the Muslim community, contemporary engagement is heavily hindered by a reliance on fragmented communication channels such as physical notice boards and informal messaging apps like WhatsApp. This lack of a centralized digital infrastructure leads to "information overload" and significant inefficiencies, where critical updates regarding prayer times, community events, and fundraising are frequently missed by the congregation due to the noise of unmanaged chat groups [1](https://www.joynedapp.com/blog/why-churches-outgrow-whatsapp---7-risks-and-fixes). Research highlights that while religious institutions are attempting to digitize, the absence of a structured management system results in "undirected" outreach that fails to bridge the gap between administration and the modern, digital-native *jama'ah*, effectively excluding members who are not physically present or part of specific social circles [2](https://www.researchgate.net/publication/357537528_The_Mapping_of_Mosque_Community_to_Improve_Mosque_Engagement_in_Community) [3](https://www.researchgate.net/publication/394145052_A_Review_of_The_Opportunities_and_Challenges_in_Digital-Based_Masjid_Management).

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
