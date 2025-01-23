//
//  Tracker.swift
//  iphoneapp
//
//  Created by mac on 12/2/24.
//
import SwiftUI
import MapKit
import CoreLocation



struct Tracker: View {
    @Environment(\.dismiss) var dismiss
    let gradient = LinearGradient(colors: [.green,.red,.blue], startPoint: .leading, endPoint: .trailing)
    let stroke = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [2,5])
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        Map{
//            if let currentLocation = locationManager.currentLocation?.coordinate{
//                Marker("",systemImage: "figure.wave", coordinate: currentLocation)
//            }
            
//            Marker("",systemImage: "figure.walk", coordinate: CLLocationCoordinate2D(latitude: 35.191980, longitude:129.121013))
//            Marker("",systemImage: "figure.walk", coordinate: CLLocationCoordinate2D(latitude: 35.191791, longitude:129.120108))
//            Marker("",systemImage: "figure.wave", coordinate: CLLocationCoordinate2D(latitude: 35.191875, longitude:129.120504))
            if !locationManager.trackedLocations.isEmpty{
                MapPolyline(coordinates: locationManager.trackedLocations)
                    .stroke(Color.themeRed, style: stroke)
                    
            }
            
        }
        .ignoresSafeArea()
        .mapStyle(.standard(elevation: .realistic))
        .onAppear {
            // 위치 권한 요청 및 업데이트 시작
            if let authorization = locationManager.authorization{
                if authorization == .authorizedAlways || authorization == .authorizedWhenInUse{
                    locationManager.startUpdatingLocation()
                }else{
                    locationManager.requestAuthorization()
                }
            }
        }
        .onChange(of: locationManager.authorization) { oldValue, newValue in
            if let result = newValue{
                if result == .authorizedAlways || result == .authorizedWhenInUse{
                    locationManager.startUpdatingLocation()
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black) // 커스텀 뒤로가기 버튼 색상
                }
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden()
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
    }
}


#Preview {
    Tracker()
}


