//
//  Location.swift
//  BucketList
//
//  Created by Michael Knych on 11/17/22.
//

import Foundation
import MapKit

struct Location: Identifiable, Codable, Equatable {
  // id needs to be mutable so that SwiftUI will understand that this is a new
  // location that needs to be upodated on the map
  var id: UUID
  var name: String
  var description: String
  let latitude: Double
  let longitude: Double
  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
  // an example for documentation
  static var example = Location(id: UUID(), name: "Buckinham Palace", description: "Where King Charles lives", latitude: 50.501, longitude: -0.141)
  
  // a custom == function for the struct to only equate the unigue id property
  static func ==(lhs: Location, rhs: Location) -> Bool {
    lhs.id == rhs.id
  }
  
}
