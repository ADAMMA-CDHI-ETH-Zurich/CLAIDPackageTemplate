The files in this folder are used to build the android AAR and flutter pub packages.
You can open these packages in Android Studio, but please keep in mind the following:

- Do not make changes to the flutter/android directory, as those will be overriden when running make flutter_package
- Assets added to the android package are not automatically packaged into the flutter package. Add your assets in the ../assets folder.
- Source files added to the android package will not be packaged into the flutter package. Add your android files in the ../src/android/java folder instead.