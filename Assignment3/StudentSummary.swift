//
//  StudentSummary.swift
//  Assignment3
//
//  Created by mobiledev on 14/5/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

public struct StudentSummary:Codable
{
    @DocumentID var docId:String?
    var name:String
    var pk:String
    var id:String
    var grades:Array<String>
    var img:String
}
