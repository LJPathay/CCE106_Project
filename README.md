## How to Guide

# 1. Clone The Repository
  - git clone https://github.com/LJPathay/CCE106_Project.git
  - cd CCE106_Project

# 2. Configure Your Firebase
  - Install firebase CLI and Flutterfire ( watch youtube video on how to do it )
  - Flutter login
  - Flutterfire configure (Create a Furebase Project first)

# 3. Go to Firebase Google 
  - Create new Firebase project
  - On the Left side click 'Build' -> Firebase Database
  - Build -> Authentication (Sign-in Method -> email/password)
  - Go to Firebase Collection and create these Collections:
  1.) loan_applicants
    - address (string)
    - createdAt (timestamp)
    - email (string)
    - fullName (string)
    - phone (string)
      
  2.) loans
    - just add randoms it'll just generate it self after doing a loan

  3.) payments
  4.) users
  5.) verificationRequests

# 4. Cloudinary Configuration 
  - Go to Cloudinary ( Create a account)
  - Go to Image and get the cloud_name, api_key, and api_secret from the dashboard
  - Change the configuration file in Services/cloudinary_service.dart
  - Change this line of code to your own cloudinary cloud_name and upload_Preset
      - static const String _cloudName = 'dzlqpn3yb';
      - static const String _uploadPreset = 'verification_images';

# 5. Run the Project
  - Go to main.dart and run
  - or
  - Go to Terminal and type Flutter run


