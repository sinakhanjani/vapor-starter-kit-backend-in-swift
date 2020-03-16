//
//  Q.swift
//  App
//
//  Created by Sina khanjani on 12/18/1398 AP.
//

// Custom message response to request
// Set timer for send sms code expired date
// Update database without rm docker db
// Delete last jwt token when new token generate *

//func authorizedUser() throws -> Future<User> {
//    let userID = try TokenHelpers.getUserID(fromPayloadOf: self.token)
//    return User.find(userID, on: self)
//        .unwrap(or: Abort(.unauthorized, reason: "Authorized user not found"))
//}

//    func getHandler(_ request: Request) throws -> Future<[Mag.Public]> {
//        let builder = SwifQLSelectBuilder()
//        builder.select(Tag.table.*)
//        let publics = builder.build()
//        .from(MagTagPivot.table)
//        .join(.inner, Tag.table, on: \MagTagPivot.tagID == \Tag.id)
//        .limit(100)
//        .offset(0)
//        .execute(on: request, as: .psql)
//        .all(decoding: Tag.self)
//            .flatMap(to: [Mag.Public].self) { (tags) in
//            return Mag.query(on: request)
//                .all()
//                .map(to: [Mag.Public].self) { (mags) in
//                let pubs = mags.map { mag in
//                    mag.convertToPublic(tags: tags)
//                }
//                return pubs
//            }
//        }
//        return publics
//    }
    
//    func getHandler(_ request: Request) throws -> Future<[Mag]> {
//     let _ = SwifQL.select(\Mag.title,\Mag.type,\Mag.id,\Mag.description)
//        let builder = SwifQLSelectBuilder()
//        builder.where(\User.id == 1)
//        builder.from(Mag.table)
//        builder.limit(1)
//        builder.select(Mag.table.*)
//        let query = builder.build()
//        return query.execute(on: request, as: .psql).all(decoding: Mag.self)
//    }
