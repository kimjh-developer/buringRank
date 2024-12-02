//
//  CounterVM.swift
//  iphoneapp
//
//  Created by mac on 12/2/24.
//

import Foundation
import Combine

class CounterVM:ObservableObject{
    let muscleGroupExercises: [MuscleGroupExercise] = [
        MuscleGroupExercise(muscleGroup: "가슴", exercises: ["벤치프레스", "푸쉬업", "딥스", "플라이 머신"]),
        MuscleGroupExercise(muscleGroup: "등", exercises: ["풀업", "바벨 로우", "랫풀다운", "데드리프트"]),
        MuscleGroupExercise(muscleGroup: "어깨", exercises: ["숄더프레스", "레터럴 레이즈", "페이스 풀", "프론트 레이즈"]),
        MuscleGroupExercise(muscleGroup: "팔", exercises: ["바벨 컬", "덤벨 컬", "트라이셉스 익스텐션", "케이블 푸쉬다운"]),
        MuscleGroupExercise(muscleGroup: "복부", exercises: ["크런치", "레그 레이즈", "플랭크", "러시안 트위스트"]),
        MuscleGroupExercise(muscleGroup: "하체", exercises: ["스쿼트", "레그 프레스", "런지", "레그 익스텐션"]),
        MuscleGroupExercise(muscleGroup: "전신", exercises: ["버피", "케틀벨 스윙", "스내치", "클린앤저크"])
    ]
    @Published var choosedmuscleGroupExercises : MuscleGroupExercise?
    @Published var exercises : String?
    @Published var counter : Int = 0
    @Published var timerString: String = "00:00:00"
    @Published var showSummaryActivate : Bool = false
    @Published var availToFinish : Bool = false
    @Published var warnActivate : Bool = false
    
    var savedMuscleGroupExercises : [SavedMuscleGroupExercises] = []
    private var timerSubscription: AnyCancellable?
    private var startTime: Date?
    
    func startTimer() {
        if startTime != nil {return}
        startTime = Date()
        timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let startTime = self.startTime else { return }
                let elapsedTime = Int(Date().timeIntervalSince(startTime))
                self.timerString = self.formatTime(elapsedTime)
            }
    }
    
    func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func upCounter(){
        if exercises != nil{
            counter += 1
        }else{
            warnActivate.toggle()
        }
    }
    
    func downCounter(){
        if counter == 0{return}
        counter -= 1
    }
    func otherWorkout(){
        if let choosedmuscleGroupExercises = choosedmuscleGroupExercises,
           let exercises = exercises{
            if counter>0{
                savedMuscleGroupExercises.append(SavedMuscleGroupExercises(muscleGroupExercise: choosedmuscleGroupExercises, exercises: exercises, counter: counter))
            }
        }
        
        counter = 0
        choosedmuscleGroupExercises = nil
        exercises = nil
    }
    func finishWorkout(){
        otherWorkout()
        stopTimer()
        timerString = "00:00:00"
        showSummaryActivate = true
    }
}

struct MuscleGroupExercise {
    let muscleGroup: String
    let exercises: [String]
}

struct SavedMuscleGroupExercises{
    var muscleGroupExercise : MuscleGroupExercise
    var exercises : String
    var counter : Int
}





