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
  private var directoryPath: [String]
  private var documentDirectory: String
  private var databasesPath: String

  private init() {
    fileManager = FileManager.default
    directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    documentDirectory = directoryPath[0] as String
    databasesPath = documentDirectory.appending("/contact.db")
  }

  func createDatabase() {
    if !fileManager.fileExists(atPath: databasesPath) {
      let contactDB = FMDatabase(path: databasesPath)

      if contactDB.open() {
        let sqlStatement = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, CONTENTS TEXT, DATE TEXT, TIME TEXT, DAY TEXT, CREATED_AT TEXT, REPEATMODE INTEGER, IS_ALARM_SETTING BOOL, ALARM_DATE TEXT)"
        if !contactDB.executeStatements(sqlStatement) {
          print("Error \(contactDB.lastErrorMessage())")
        }
        contactDB.close()
      } else {
        print("Error \(contactDB.lastErrorMessage())")
      }
    }
  }

  func insertText(text: Text) {
    let contactDB = FMDatabase(path: databasesPath)
    let formatter = MDateFormatter().formatter
    let alarmDateString = text.alarmDatePicked != nil ? formatter.string(from: text.alarmDatePicked!) : ""

    if contactDB.open() {
      let insertSQL = "INSERT INTO CONTACTS (contents, date, time, day, created_at, repeatmode, is_alarm_setting, alarm_date) VALUES ( '\(text.string), '\(text.date)', '\(text.time)', '\(text.day)', '\(text.createdAt)', '\(text.repeatMode.rawValue)', '\(text.isAlarmSetting)', '\(alarmDateString))' )"

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
    let contactDB = FMDatabase(path: databasesPath)
    let formatter = MDateFormatter().formatter
    let alarmDateString = text.alarmDatePicked != nil ? formatter.string(from: text.alarmDatePicked!) : ""

    if contactDB.open() {
      let updateSQL = "UPDATE CONTACTS SET repeatmode = '\(text.repeatMode.rawValue), is_alarm_setting = '\(text.isAlarmSetting)', 'alarm_date = '\(alarmDateString)' WHERE created_at = '\(text.createdAt)'"
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
    let contactDB = FMDatabase(path: databasesPath)

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
  }

  // TODO: Date로 찾기, repeatMode로 찾기
  func findText(date: String) -> [Text] {
    let contactDB = FMDatabase(path: databasesPath)
    var textList: [Text] = []
    let formatter = MDateFormatter().formatter

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
}
