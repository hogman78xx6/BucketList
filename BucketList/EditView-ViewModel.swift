//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Michael Knych on 11/26/22.
//

import SwiftUI

extension EditView {
  @MainActor class ViewModel: ObservableObject {
    
    @Published var name: String
    @Published var description: String
    
    // the loading state
    @Published var loadingState = LoadingState.loading
    
    // an array of loaded Wikipedia pages
    @Published var pages = [Page]()
    
    var location: Location
    
    enum LoadingState {
      case loading, loaded, failed
    }
    
    // The initilizer for properties of the class that need initilizers
    // takes a location passed in to it.
    // We need to get the initial values for name and description this way because
    // we can't use @State with some initial values since the user needs to see
    // what is being passed in with the location.
    // (needed this to make code compile)
    init(location: Location) {
      self.name = location.name
      self.description = location.description
      self.location = location      
    }
    
    func fetchNearbyPlsaces() async {
      let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
      
      guard let url = URL(string: urlString) else {
        print("Invlaid URL: \(urlString) ")
        return
      }
      
      do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // we got some data back from url session
        let items = try JSONDecoder().decode(Result.self, from: data)
        
        // success - convert the array values to our pages array
        // Sort the array elements loaded to our pages array by the title
        // property.  Do it this way before we have Page conform to Comparable.
        //      pages = items.query.pages.values.sorted {
        //        $0.title < $1.title
        //      }
        
        // Do it this way after we make Page conform to Comparable
        pages = items.query.pages.values.sorted()
        
        loadingState = .loaded
      } catch {
        // if we're still here in means the request failed sonehow
        loadingState = .failed
      }
    }  // end of func
    
    func createNewLocation() -> Location {
      var newLocation = location
      newLocation.id = UUID()   // need to add this so map will be updated
      newLocation.name = name
      newLocation.description = description
      return newLocation
    }
  }
}
    
