//
//  MapRecord.swift
//  iphoneapp
//
//  Created by mac on 11/19/24.
//
import SwiftUI
import MapKit
import CoreLocation

struct MapRecord: View {
    @Environment(\.dismiss) var dismiss
    let chooseDay:Date?
    @StateObject private var locationManager = LocationManager()
    @StateObject private var vm = MapRecordVM()
    
    
    @State var cumulativeDistance: String?
    @State var cumulativeTime:String?
    @State var EveragePace:String? = ""
    @State var userLocation:CLLocationCoordinate2D?
    
    
    var body: some View {
        ZStack {
            mapSection()
            decoration()
            cameraBtn()
            
        }
        .onAppear(perform: {
            vm.requestAuthorization { success, error in
                print(success)
                if let date = chooseDay{
                    vm.fetchWorkoutRoute(for: date)
                }
            }
        })
        .navigationTitle("")
        .navigationBarBackButtonHidden()
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
    }
    
    // MARK: - 지도영역
    @ViewBuilder
    private func mapSection() -> some View{
        MapView(segments: vm.segments,
                userCoordinate: userLocation,
                CumulativeDistance: $cumulativeDistance,
                CumulativeTime: $cumulativeTime,
                EveragePace: $EveragePace)
                .onReceive(locationManager.$currentLocation) { location in
                    if let location = location {
                        userLocation = location.coordinate
                    }
                }
                .ignoresSafeArea()
    }
    
    // MARK: - 꾸밈 영역
    @ViewBuilder
    private func decoration() -> some View{
        ZStack(alignment: .bottomTrailing) {
            Color.clear
            VStack(alignment: .trailing) {
                if cumulativeDistance != nil || cumulativeTime != nil || EveragePace != nil{
                    VStack(alignment: .trailing) {
                        if let value = cumulativeDistance{
                            Text("이동거리")
                                .style(fontName: .player,fontSize: 15,fontColor: .black)
                            Text("\(value)km")
                                .style(fontName: .player,fontSize: 15,fontColor: .black)
                        }
                        if let value = cumulativeTime{
                            Text("이동시간")
                                .style(fontName: .player,fontSize: 15,fontColor: .black)
                            Text(value)
                                .style(fontName: .player,fontSize: 15,fontColor: .black)
                        }
                        if let value = EveragePace{
                            Text("평균페이스")
                                .style(fontName: .player,fontSize: 15,fontColor: .black)
                            Text(value)
                                .style(fontName: .player,fontSize: 15,fontColor: .black)
                        }
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.white)
                    }
                }
                
                Image("logoColor")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
            }
            
        }
        .padding(.trailing)
    }
    
    // MARK: - 카메라 버튼
    @ViewBuilder
    private func cameraBtn() -> some View{
        ZStack(alignment: .bottom) {
            Color.clear
            Button {
                print("CAPTURE")
            } label: {
                Image(systemName: "camera.aperture")
                    .renderingMode(.template)
                    .tint(.black)
                    .font(.system(size: 20))
            }
            .padding(.bottom,5)
        }
    }
}



#Preview(body: {
    MapRecord(chooseDay: Date())
})


