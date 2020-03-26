//
//  WordKey.swift
//  App
//
//  Created by Sina khanjani on 1/7/1399 AP.
//

import Vapor
import Foundation

func wordKey(with request: Request,_ key: String = "test") -> Future<String> {
  return Future.map(on: request) { key }
}
