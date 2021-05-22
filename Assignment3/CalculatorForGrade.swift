//
//  CalculatorForGrade.swift
//  Assignment3
//
//  Created by mobiledev on 21/5/21.
//

import Foundation

class CalculatorForGrade{
    
    func getStudentAvgGrade(grades:Array<String>, schemes:Array<Scheme>) -> String{
             
        var sum : Double = 0
        for index in 0...(schemes.count-1)
        {
            let i = Int(schemes[index].week) - 1
            switch schemes[index].type {
            case "level_HD":
                sum = sum + transferGradeHD(type: grades[i])
            case "level_A":
                sum = sum + transferGradeA(type: grades[i])
            case "checkbox":
                sum = sum + transferCheckBox(value: grades[i])
            case "score":
                sum = sum + transferScoreToNewBase(score: grades[i], originBase: schemes[index].extra, afterBase: "100")
            case "attendance":
                sum = sum + transferAttendance(type: grades[i])
            default:
                sum = 0
            }
            //print("sum: \(sum)")
        }
        let avg = sum / Double(grades.count)
        //print("avg: \(avg)")
        return String(format: "%.1f", avg)
    }
    
    func getClassAvgGrade(students:Array<StudentSummary>, scheme:Scheme) -> String{
        
        switch scheme.type {
            case "level_HD":
                var sum = 0.0
                for i in 0...(students.count-1)
                {
                    sum += transferGradeHD(type: students[i].grades[scheme.week-1])
                }
                let cAvg = String(format: "%.1f", sum/(Double(students.count)))
                return "\(cAvg) /100.0"
            case "level_A":
                var sum = 0.0
                for i in 0...(students.count-1)
                {
                    sum += transferGradeA(type: students[i].grades[scheme.week-1])
                }
                let cAvg = String(format: "%.1f", sum/Double(students.count))
                return "\(cAvg) /100.0"
            case "attendance":
                var sum = 0.0
                for i in 0...(students.count-1)
                {
                    sum += transferAttendance(type: students[i].grades[scheme.week-1])
                }
                let cAvg = String(format: "%.1f", sum/Double(students.count))
                return "\(cAvg) /100.0"
            case "score":
                var sum = 0.0
                for i in 0...(students.count-1)
                {
                    sum += getScore(s: students[i].grades[scheme.week-1])
                }
                let cAvg = String(format: "%.1f", sum/Double(students.count))
                return "\(cAvg) /\(scheme.extra).0"
            case "checkbox":
                var sum = 0.0
                for i in 0...(students.count-1)
                {
                    sum += countCheckBoxesTrue(s: students[i].grades[scheme.week-1])
                }
                let cAvg = String(format: "%.1f", sum/Double(students.count))
                return "\(cAvg) /\(scheme.extra).0"
            default:
                return "0.0/0.0"
        }

    }
    
    private func getScore(s:String) -> Double{
        if s == ""
        {
            return 0.0
        }else{
            return Double(s)!
        }
    }
    
    private func transferScoreToNewBase(score:String, originBase:String, afterBase:String) -> Double{
        var final_score : Double = 0
        if score == ""
        {
            final_score = 0
        }else
        {
            final_score = Double(score)!
        }
        return  final_score / Double(originBase)! * Double(afterBase)!
    }
    
    private func transferCheckBox(value:String) -> Double{
        if value == ""
        {
            return 0
        }
        let checks = value.components(separatedBy: ",")
        var sum:Double = 0
        for c in checks{
            if Int(c) == 1 {
                sum = sum + 1
            }
        }
        return sum / Double(checks.count) * 100.0
    }
    
    private func countCheckBoxesTrue(s:String) ->Double{
        let checks = s.components(separatedBy: ",")
        if s == ""
        {
            return 0.0
        }
        var sum:Double = 0
        for c in checks{
            if Int(c) == 1 {
                sum = sum + 1
            }
        }
        return sum
    }
    
    func transferCheckBoxSlash(s:String) -> String{
        let checks = s.components(separatedBy: ",")
        if s == ""
        {
            return "0/\(String(checks.count))"
        }
        var sum:Int = 0
        for c in checks{
            if Int(c) == 1 {
                sum = sum + 1
            }
        }
        return "\(String(sum))/\(String(checks.count))"
        
    }
    
    private func transferAttendance(type:String) -> Double{
        switch type {
            case "Attend":
                return 100
            case "Absent":
                return 0
        default:
            return 0
        }
    }
    
    private func transferGradeHD(type:String) -> Double{
        switch type {
            case "HD+":
                return 100
            case "HD":
                return 80
            case "DN":
                return 70
            case "CR":
                return 60
            case "PP":
                return 50
            case "NN":
                return 0
            default:
                return 0
        }
    }
    
    private func transferGradeA(type:String) -> Double{
        switch type {
            case "A":
                return 100
            case "B":
                return 80
            case "C":
                return 70
            case "D":
                return 60
            case "F":
                return 0
            default:
                return 0
        }
    }}
