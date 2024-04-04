//
//  Admins.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 28.11.2022.
//

import Foundation
import RealmSwift

class Admins: Object {
    //for saving these properties in realm file as columns we use objc dynamic
    @objc dynamic var username: String?
    @objc dynamic var password: String?
    @objc dynamic var mail: String?
}
