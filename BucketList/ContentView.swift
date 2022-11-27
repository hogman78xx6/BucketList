//
//  ContentView.swift
//  BucketList
//
//  Created by Michael Knych on 11/17/22.
//

import SwiftUI
import MapKit
import LocalAuthentication

struct ContentView: View {
  
  @StateObject private var viewModel = ViewModel()
  
    var body: some View {
      
      ZStack {
        if viewModel.isUnlocked {
          Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
              VStack {
                Image(systemName: "star.circle")
                  .resizable()
                  .foregroundColor(.red)
                  .frame(width: 44, height: 44)
                  .background(.white)
                  .clipShape(Circle())
                
                Text(location.name)
                  .fixedSize()
              }
              .onTapGesture {
                viewModel.selectedPlace = location
              }
            } // end of MapAnnotation
          }  // end of Map view
          //
          .ignoresSafeArea()
          
          Circle()
            .fill(.blue)
            .opacity(0.3)
            .frame(width: 32, height: 32)
          
          VStack {
            Spacer()
            
            HStack {
              Spacer()
              
              Button {
                viewModel.addLocation()
              } label: {
                Image(systemName: "plus")
                  .padding()
                  .background(.black.opacity(0.75))
                  .foregroundColor(.white)
                  .font(.title)
                  .clipShape(Circle())
                  .padding(.trailing)
              }
              
            }
          }
        } else {
          Button("Unlocck Places") {
            viewModel.authenticate()
          }
          .padding()
          .background(.blue)
          .foregroundColor(.white)
          .clipShape(Capsule())
          .alert("Authentication error", isPresented: $viewModel.isShowingAuthenticationError) {
            Button("OK", role: .cancel) { }
          } message: {
            Text(viewModel.authenticationError)
          }
          
        }
        
      }  // end of ZStack
      
      .sheet(item: $viewModel.selectedPlace) { place in
        //Text(place.name)
        // passes the selected location into EditView along with a closure
        // that runs in EditView that returns the new updated location, then looks
        // up where the current location (place) is and replaces with the new
        // location info in the locations array.
        EditView(location: place) { newLocation in
          viewModel.update(location: newLocation)
        }
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
