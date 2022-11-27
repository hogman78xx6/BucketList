//
//  EditView.swift
//  BucketList
//
//  Created by Michael Knych on 11/18/22.
//

import SwiftUI

struct EditView: View {
  
  // create a property for the view model for this view
  @StateObject private var viewModel: ViewModel
  
  @Environment(\.dismiss) var dismiss
 
  // This will ask for a function (a colsure) to be passed in that accepts a single
  // location property and returns nothing.
  // Needed to get the updated name and description returned from EditView
  var onSave: (Location) -> Void
 
    var body: some View {
      NavigationView {
        Form {
          Section {
            TextField("Place name", text: $viewModel.name)
            TextField("Description", text: $viewModel.description)
          }
          // Section to display the optional pages returend from the
          // Wikipedia query of the location
          Section("Nearby...") {
            switch viewModel.loadingState {
            case .loaded:
              ForEach(viewModel.pages, id: \.pageid) { page in
                Text(page.title)
                  .font(.headline)
                + Text(": ") +
                //Text("Page description here")
                Text(page.description)
                  .italic()
              }
            case .loading:
              Text("Loading...")
            case .failed:
              Text("Problem loading data,  try again later")
            }
          }
        }
        .navigationTitle("Place details")
        .toolbar {
          Button("Save") {
            // Create a new location with the modified details and send it back
            // with onSave to the caller
            let newLocation = viewModel.createNewLocation()
            
            onSave(newLocation)
            
            dismiss()
          }
        }
        .task {
          await viewModel.fetchNearbyPlsaces()
        }
      }
    }
  
  //----------------------------------------------------------------------
  // This will create an instance of the property wrappers.
  //-----------------------------------------------------------------------
  // Add an initilizer for the onSave func with a Location property that
  // will be used later on when called in this struct.
  // This will require the call to this struct view to pass in an
  // onSave function (closure).
  // @escaping means the function is being stached away for use later on.
  //------------------------------------------------------------------------
  init(location: Location, onSave: @escaping (Location) -> Void) {
    self.onSave = onSave
    // will pass on the location into the view model initilizer
    _viewModel = StateObject(wrappedValue: ViewModel(location: location))
  }

}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
      // Needed to add parameter to meke code compile.
      // Added onSave plsceholder closure that does nothing -
      // needed to make code compile.
      EditView(location: Location.example, onSave: { _ in })
    }
}
