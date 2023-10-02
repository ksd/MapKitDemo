//
//  ContentView.swift
//  MapKitDemo
//
//  Created by ksd on 02/10/2023.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .eaaa
    @State private var mapSelection: Int?
    @State private var showDetails = false
    @State private var route: MKRoute?
    @State private var travelTime: String?
    
    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection){
            Marker("Erhvervsakademi Aarhus", coordinate: MapCameraPosition.eaaa.camera!.centerCoordinate).tag(1)
            Marker("McDonald", coordinate: MapCameraPosition.sebastiansPlace.camera!.centerCoordinate).tag(2)
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 8)
            }
        }
        
        .mapStyle(.imagery(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapUserLocationButton()
            MapPitchToggle()
        }
        .onChange(of: mapSelection) {oldValue, newValue in
            if mapSelection != nil {
                showDetails = true
            }
        }
        
        .sheet(isPresented: $showDetails) {
            MapDetails()
                .presentationDetents([.height(300)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
                .presentationCornerRadius(25)
                .interactiveDismissDisabled(true)
        }
    }
    
    @ViewBuilder
    func MapDetails() -> some View {
        
        VStack(spacing: 15) {
            ZStack{
                // her kommer al info om den valgte marker
                if let travelTime {
                    Text(travelTime)
                        .font(.title)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: 15))
            // luk knap
            .overlay(alignment: .topTrailing) {
                Button {
                    mapSelection = nil
                    //route = nil
                    showDetails = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.black)
                        .background(.white, in: .circle)
                }

            }
            Button("Vis rute") {
                fetchRouteFrom(MapCameraPosition.eaaa.camera!.centerCoordinate,
                               to: MapCameraPosition.sebastiansPlace.camera!.centerCoordinate)
                
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.blue.gradient, in: .rect(cornerRadius: 15))
        }
        .padding(15)
    }
    
    private func fetchRouteFrom(_ source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        Task {
            let result = try? await MKDirections(request: request).calculate()
            route = result?.routes.first
            getTravelTime()
        }
    }
    
    private func getTravelTime(){
        guard let route else {return}
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        travelTime = formatter.string(from: route.expectedTravelTime)
    }
}

#Preview {
    ContentView()
}

extension MapCameraPosition {
    static var eaaa = MapCameraPosition.camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 56.119657, longitude: 10.158651),
            distance: 650,
            heading: 160,
            pitch: 60
        ))
    
    static var sebastiansPlace = MapCameraPosition.camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 56.12909, longitude: 10.16062),
            distance: 400,
            heading: 160,
            pitch: 60
        ))
}


