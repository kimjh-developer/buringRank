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
    @Published var setCount : Int = 1
    @Published var timerString: String = "00:00:00"
    @Published var showSummaryActivate : Bool = false
    
    @Published var warnActivate : Bool = false
    @Published var warnMSG : String = ""
    var savedMuscleGroupExercises : [SavedMuscleGroupExercises] = []
    private var timerSubscription: AnyCancellable?
    private var startTime: Date?
    
    private let storageKey = "weightlifting_records"

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
            if startTime == nil {
                startTimer()
            }
        }else{
            warnMSG = "운동형태를 먼저 선택하세요"
            warnActivate = true
        }
    }
    
    func downCounter(){
        if counter == 0{return}
        counter -= 1
    }

    func completeSet() {
        if exercises == nil {
            warnMSG = "운동형태를 먼저 선택하세요"
            warnActivate = true
            return
        }
        
        saveworkout()
        counter = 0
        setCount += 1
    }

    func resetWorkout() {
        counter = 0
        setCount = 1
    }
    
    private func saveworkout(){
        if let choosedmuscleGroupExercises = choosedmuscleGroupExercises,
           let exercises = exercises{
            if counter > 0 {
                savedMuscleGroupExercises.append(SavedMuscleGroupExercises(muscleGroupExercise: choosedmuscleGroupExercises, exercises: exercises, counter: counter))
            }
        }
    }

    func otherWorkout(){
        saveworkout()
        
        counter = 0
        setCount = 1
        choosedmuscleGroupExercises = nil
        exercises = nil
    }

    func finishWorkout(){
        saveworkout()
        if savedMuscleGroupExercises.isEmpty{
            warnMSG = "저장한 운동이 없어요."
            warnActivate = true
            return
        }
        pauseTimer()
        stopTimer()
        persistData()
        showSummaryActivate = true
    }

    private func persistData() {
        let encoder = JSONEncoder()
        let records = savedMuscleGroupExercises.map { record in
            WeightRecord(muscleGroup: record.muscleGroupExercise.muscleGroup, exercise: record.exercises, sets: record.counter, date: Date())
        }
        
        if let encoded = try? encoder.encode(records) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func pauseTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
        if let startTime = startTime {
            let elapsedTime = Int(Date().timeIntervalSince(startTime))
            self.timerString = self.formatTime(elapsedTime)
        }
    }
}

struct MuscleGroupExercise: Codable {
    let muscleGroup: String
    let exercises: [String]
}

struct SavedMuscleGroupExercises {
    var muscleGroupExercise : MuscleGroupExercise
    var exercises : String
    var counter : Int
}

struct WeightRecord: Codable {
    let muscleGroup: String
    let exercise: String
    let sets: Int
    let date: Date
}





