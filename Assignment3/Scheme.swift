//
//  Scheme.swift
//  Assignment3
//
//  Created by mobiledev on 17/5/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

public struct Scheme:Codable
{
    @DocumentID var docId:String?
    var pk:String
    var week:Int
    var type:String
    var extra:String
}
