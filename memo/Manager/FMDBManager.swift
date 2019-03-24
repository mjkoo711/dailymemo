//
//  FMDBManager.swift
//  memo
//
//  Created by MinJun KOO on 08/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation
import FMDB

class FMDBManager {
  static let shared = FMDBManager()
  private var fileManager: FileManager
  private var directory: URL?
  private var databasePath: URL
  private var databasePathCompleted: URL

  private init() {
    fileManager = FileManager.default
    directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.mjkoo.memo")
    databasePath = directory!.appendingPathComponent("contacts.db")
    databasePathCompleted = directory!.appendingPathComponent("completed.db")

  }

  func createDatabase() {
    if !fileManager.fileExists(atPath: databasePath.path) {
      let contactDB = FMDatabase(url: databasePath)

      if contactDB.open() {
        let sqlStatement = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, CONTENTS TEXT, DATE TEXT, TIME TEXT, DAY TEXT, CREATED_AT TEXT, REPEATMODE INTEGER, IS_ALARM_SETTING INTEGER, ALARM_DATE TEXT)"
        if !contactDB.executeStatements(sqlStatement) {
          print("Error \(contactDB.lastErrorMessage())")
        }
        contactDB.close()
      } else {
        print("Error \(contactDB.lastErrorMessage())")
      }
    }
  }

  func createDatabaseCompleted() {
    if !fileManager.fileExists(atPath: databasePathCompleted.path) {
      let contactDB = FMDatabase(url: databasePathCompleted)

      if contactDB.open() {
        let sqlStatement = "CREATE TABLE IF NOT EXISTS COMPLETED (ID INTEGER PRIMARY KEY AUTOINCREMENT, CONTENTS TEXT, CURRENTDATE TEXT, CREATED_AT TEXT)"
        if !contactDB.executeStatements(sqlStatement) {
          print("Error Completed DB \(contactDB.lastErrorMessage())")
        }
        contactDB.close()
      } else {
        print("Error Completed DB \(contactDB.lastErrorMessage())")
      }
    }
  }

  func insertTextCompleted(text: Text, currentDate: String) {
    let contactDB = FMDatabase(url: databasePathCompleted)

    if contactDB.open() {
      let insertSQL = "INSERT INTO COMPLETED (contents, currentdate, created_at) VALUES ( '\(text.string)', '\(currentDate)', '\(text.createdAt)')"

      let result = contactDB.executeUpdate(insertSQL, withArgumentsIn: [])
      if result {
        print("insert Text in COMPLETED DB")
      } else {
        print("Error \(contactDB.lastErrorMessage())")
      }
    } else {
      print("Error \(contactDB.lastErrorMessage())")
    }
  }

  func deleteTextCompleted(text: Text, currentDate: String) {
    let contactDB = FMDatabase(url: databasePathCompleted)

    if contactDB.open() {
      let deleteSQL = "DELETE FROM COMPLETED WHERE currentdate = '\(currentDate)' and created_at = '\(text.createdAt)'"
      let result = contactDB.executeUpdate(deleteSQL, withArgumentsIn: [])
      if result {
        print("delete Text in COMPLETED DB")
      } else {
        print("Error \(contactDB.lastErrorMessage())")
      }
    } else {
      print("Error \(contactDB.lastErrorMessage())")
    }
  }

  // return is CREATED_AT ex) 2019-01-01 -> [2019-01-01 12:00:12, 2019-01-01 13:00:13, ...]
  func findTextCompleted(currentDate: String) -> [String] {
    let contactDB = FMDatabase(url: databasePathCompleted)
    var createdAtList: [String] = []

    if contactDB.open() {
      let querySQL = "SELECT created_at FROM COMPLETED WHERE currentdate = '\(currentDate)'"
      let result: FMResultSet? = contactDB.executeQuery(querySQL, withArgumentsIn: [])
      guard let resultTextList = result else { return createdAtList }

      while resultTextList.next() {
        let createdAt = resultTextList.string(forColumn: "created_at")
        createdAtList.append(createdAt!)
      }
      contactDB.close()
    } else {
      print("Error \(contactDB.lastErrorMessage())")
    }
    return createdAtList
  }


  func insertText(text: Text) {
    let contactDB = FMDatabase(url: databasePath)
    let formatter = MDateFormatter().formatter2
    let alarmDateString = text.alarmDatePicked != nil ? formatter.string(from: text.alarmDatePicked!) : ""

    if contactDB.open() {
      let insertSQL = "INSERT INTO CONTACTS (contents, date, time, day, created_at, repeatmode, is_alarm_setting, alarm_date) VALUES ( '\(text.string)', '\(text.date)', '\(text.time)', '\(text.day)', '\(text.createdAt)', '\(text.repeatMode.rawValue)', '\(text.isAlarmSetting)', '\(alarmDateString)' )"

      let result = contactDB.executeUpdate(insertSQL, withArgumentsIn: [])
      if result {
        print("insert Text in DB")
      } else {
        print("Error \(contactDB.lastErrorMessage())")
      }
    } else {
      print("Error \(contactDB.lastErrorMessage())")
    }
  }

  func updateText(text: Text) {
    let contactDB = FMDatabase(url: databasePath)
    let formatter = MDateFormatter().formatter2
    let alarmDateString = text.alarmDatePicked != nil ? formatter.string(from: text.alarmDatePicked!) : ""

    if contactDB.open() {
      let updateSQL = "UPDATE CONTACTS SET contents = '\(text.string)', repeatmode = '\(text.repeatMode.rawValue)', is_alarm_setting = '\(text.isAlarmSetting)', alarm_date = '\(alarmDateString)' WHERE created_at = '\(text.createdAt)'"
      let result = contactDB.executeUpdate(updateSQL, withArgumentsIn: [])
      if result {
        print("update Text in DB")
      } else {
        print("Error \(contactDB.lastErrorMessage())")
      }
    } else {
      print("Error \(contactDB.lastErrorMessage())")
    }
  }

  func deleteText(text: Text) {
    let contactDB = FMDatabase(url: databasePath)

    if contactDB.open() {
      let deleteSQL = "DELETE FROM CONTACTS WHERE created_at = '\(text.createdAt)'"
      let result = contactDB.executeUpdate(deleteSQL, withArgumentsIn: [])
      if result {
        print("delete Text in DB")
      } else {
        print("Error \(contactDB.lastErrorMessage())")
      }
    } else {
      print("Error \(contactDB.lastErrorMessage())")
    }

    let completedDB = FMDatabase(url: databasePathCompleted)

    if completedDB.open() {
      let deleteSQL = "DELETE FROM COMPLETED WHERE created_at = '\(text.createdAt)'"
      let result = completedDB.executeUpdate(deleteSQL, withArgumentsIn: [])
      if result {
        print("delete Text in Completed DB")
      } else {
        print("Error \(completedDB.lastErrorMessage())")
      }
    } else {
      print("Error \(completedDB.lastErrorMessage())")
    }
  }

  func findTextList(date: String) -> [Text] {
    let contactDB = FMDatabase(url: databasePath)
    var textList: [Text] = []
    let formatter = MDateFormatter().formatter2

    if contactDB.open() {
      let querySQL = "SELECT contents, date, time, day, repeatmode, is_alarm_setting, alarm_date FROM CONTACTS WHERE date = '\(date)'"
      let result: FMResultSet? = contactDB.executeQuery(querySQL, withArgumentsIn: [])
      guard let resultTextList = result else { return textList }

      while resultTextList.next() {
        let contents = resultTextList.string(forColumn: "contents")
        let date = resultTextList.string(forColumn: "date")
        let time = resultTextList.string(forColumn: "time")
        let day = resultTextList.string(forColumn: "day")
        let repeatMode = resultTextList.int(forColumn: "repeatmode")
        let isAlarmSetting = resultTextList.bool(forColumn: "is_alarm_setting")
        let alarm_date = resultTextList.string(forColumn: "alarm_date")

        let text = Text(string: contents!, date: date!, time: time!, day: day!, repeatMode: RepeatMode(rawValue: Int(repeatMode))!)

        isAlarmSetting ? text.onAlarmSetting() : text.offAlarmSetting()
        if let alarmDate = alarm_date, alarmDate.count > 0 {
          text.alarmDatePicked = formatter.date(from: alarmDate)
        }
        textList.append(text)
      }

      contactDB.close()
    } else {
      print("Error \(contactDB.lastErrorMessage())")
    }
    return textList
  }

  func selectTextList(sql: String, likeQuery: String?) -> [Text] {
    let contactDB = FMDatabase(url: databasePath)
    var textList: [Text] = []
    let formatter = MDateFormatter().formatter2

    if contactDB.open() {
      let result: FMResultSet? = try? contactDB.executeQuery(sql, values: [likeQuery ?? ""])

      guard let resultTextList = result else { return textList }

      while resultTextList.next() {
        let contents = resultTextList.string(forColumn: "contents")
        let date = resultTextList.string(forColumn: "date")
        let time = resultTextList.string(forColumn: "time")
        let day = resultTextList.string(forColumn: "day")
        let repeatMode = resultTextList.int(forColumn: "repeatmode")
        let isAlarmSetting = resultTextList.bool(forColumn: "is_alarm_setting")
        let alarm_date = resultTextList.string(forColumn: "alarm_date")

        let text = Text(string: contents!, date: date!, time: time!, day: day!, repeatMode: RepeatMode(rawValue: Int(repeatMode))!)

        isAlarmSetting ? text.onAlarmSetting() : text.offAlarmSetting()
        if let alarmDate = alarm_date, alarmDate.count > 0 {
          text.alarmDatePicked = formatter.date(from: alarmDate)
        }
        textList.append(text)
      }
      contactDB.close()
    }
    return textList
  }

  func selectDateList(sql: String) -> [String] {
    let contactDB = FMDatabase(url: databasePath)
    var dateList: [String] = []

    if contactDB.open() {
      let result: FMResultSet? = contactDB.executeQuery(sql, withArgumentsIn: [])

      guard let resultDateList = result else { return dateList }

      while resultDateList.next() {
        dateList.append(resultDateList.string(forColumn: "date")!)
      }
      contactDB.close()
    }

    return dateList
  }
}
