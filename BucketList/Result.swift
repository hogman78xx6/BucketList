//
//  Result.swift
//  BucketList
//
//  Created by Michael Knych on 11/20/22.
//

import Foundation

// A set of linked Codable structures to hold the results of the
// data that is fetched from Wkipedia API with location iquiery

struct Result: Codable {
  let query: Query
}

struct Query: Codable {
  let pages: [Int: Page]
}

struct Page: Codable, Comparable {
  let pageid: Int
  let title: String
  let terms: [String: [String]]?
  
  // the required < function for Comparable protocal
  static func < (lhs: Page, rhs: Page) -> Bool {
    lhs.title < rhs.title
  }
  
  // get the first description in terms if it exsits in the decoded JASON
  var description: String {
    terms?["description"]?.first ?? "No further data"
  }
}
