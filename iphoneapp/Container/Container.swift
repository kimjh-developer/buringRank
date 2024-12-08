//
//  Container.swift
//  iphoneapp
//
//  Created by mac on 10/19/24.
//

import SwiftUI
enum navis:CaseIterable{
   case burning,record,my
   
   var name : String{
       switch self {
       case .burning:
           return "버닝"
       case .record:
           return "기록"
       case .my:
           return "마이"
       }
   }
   var icon : String{
       switch self {
       case .burning:
           return "navFire"
       case .record:
           return "navMine"
       case .my:
           return "navRecord"
       }
   }
}
struct Container: View {
    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var workoutManager: WorkoutManager
    @StateObject var locationManager  = LocationManager()
    @State private var selectNavi : navis = .record
    @State var backToSplash : Bool = false
    var body: some View {
        ZStack {
            Color.black
            GeometryReader { proxy in
                VStack (spacing:0){
                    TabView(selection: $selectNavi) {
                        Burning().tag(navis.burning)
                        Record().tag(navis.record)
                        My(backToSplash: $backToSplash).tag(navis.my)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    HStack {
                        ForEach(navis.allCases, id: \.self) { item in
                            bottomNav(item: item)
                        }
                    }
                    .frame(height: proxy.size.width*0.3)
                    .padding(.horizontal)
                    .background {
                        Color.white
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
        .onChange(of: backToSplash) { oldValue, newValue in
            if newValue{
                dismiss()
            }
        }
        .onAppear(perform: {
            locationManager.requestAuthorization()
        })
//        .onChange(of: locationManager.authorization) { oldValue, newValue in
//            if let result = newValue{
//                if result == .authorizedAlways || result == .authorizedWhenInUse{
//                        workoutManager.requestAuthorization()
//                    }
//            }
//        }
    }
    // MARK: - buttonItem
    @ViewBuilder
    private func bottomNav(item:navis) -> some View{
        Button {
            selectNavi = item
        } label: {
            VStack {
                Image(item.icon)
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(selectNavi == item ? Color.themeRed : .black)
                Text(item.name)
                    .style(fontName: .kmedium, fontSize: 15, fontColor: selectNavi == item ? Color.themeRed : .black)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    Container()
}
