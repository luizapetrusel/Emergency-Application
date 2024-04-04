//
//  UsersInDanger.swift
//  EmergencyApplication
//
//  Created by Luiza Petrusel on 24.11.2022.
//

import Foundation
import RealmSwift

class UsersInDanger: Object {
    //for saving these properties in realm file as columns we use objc dynamic
    @objc dynamic var username: String?
    @objc dynamic var mail: String?
    @objc dynamic var longitude: String?
    @objc dynamic var latitude: String?
}
