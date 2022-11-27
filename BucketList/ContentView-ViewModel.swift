//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Michael Knych on 11/22/22.
//

import SwiftUI
import MapKit
import LocalAuthentication

// The view model for ContenView
extension ContentView {
  @MainActor class ViewModel: ObservableObject {
    
    @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
    
    @Published private(set) var locations: [Location]
    
    @Published var selectedPlace: Location?
    
    @Published var isUnlocked = false
    
    @Published var authenticationError = "Uknown error"
    @Published var isShowingAuthenticationError = false
    
    // Create a file in the documents directory to read and save the app data.
    // Will be used by the initilizer and save() method.
    // The name only needs to be changed here instead of two place (the init and sve())
    // if we want to change the file name for our data.
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
    
    // read the saved locations form the savePath file in the docuemnts directory
    init() {
      do {
        let data = try Data(contentsOf: savePath)
        locations = try JSONDecoder().decode([Location].self, from: data)
      } catch {
        locations = []
      }
    }
    
    func addLocation() {
      let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
      locations.append(newLocation)
      save()
    }
    
    func update(location: Location) {
      // here the location passed in is the updated location info to be
      // updated for the selected location on the map annotation
      guard let selectedPlace = selectedPlace else { return }
      
      if let index = locations.firstIndex(of: selectedPlace) {
        locations[index] = location
        save()
      }
    }
    
    // Write the locations to the savePath file of the docuemnts directory
    func save() {
      do {
        let data = try JSONEncoder().encode(locations)
        try data.write(to: savePath, options: [.atomic, .completeFileProtection])
      } catch {
        print("Error: Unable to save locations data")
      }
    }
    
    // Performs all the biometric authentication for the app
    // both face-id and touch-id
    func authenticate() {
      // 1. create a LAContext property so we have something that can check and perform
      //    biometrics
      let context = LAContext()
      
      // 2. Check if biometric authentication is possible by this device
      var error: NSError?
      if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        
        // 3. If the dvice supports it go ahead and try and use it and provide a closure
        //    to run when it completes.
        // Note: the string here is used for Touch-id.  The string in the info.plist key is
        //       for face-id permissions.
        let reason = "Please authenticate yourself to unlock your places."
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
          // Authentication has now completed
          // needed to get rid of runtime warning and have this run on the
          // main actor
          Task { @MainActor in
            if success {
              // authentication sucessful
              self.isUnlocked = true
            } else {
              // authentication failed
              self.authenticationError = "There was a problem authenticatiing you, please try again."
              self.isShowingAuthenticationError = true
            }
          }
        }
      } else {
        authenticationError = "Sorry, your device does not support biometric authentication"
        isShowingAuthenticationError = true
      }
    }
    
  }
}
