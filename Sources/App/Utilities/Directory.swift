//
//  Serv.swift
//  App
//
//  Created by Sina khanjani on 11/27/1398 AP.
//

import Foundation
import Vapor
import SwiftGD

struct Directory {

    internal enum Folder {
        case picture([String])
        case root
    }
    
    internal enum Compress {
        case yes,no
    }

    private let file, ext: String
    private let root = Constant.Directory.base
    private let folder: Folder

    init (file: String = UUID().uuidString, ext: String, folder: Folder = .root) {
        self.file = file
        self.ext = ext
        self.folder = folder
    }
    
    private var relativePath: String {
        return extendedPath(folder) + "/" + fileWithExt
    }
    
    public var filePath: String {
        let serverConfig = NIOServerConfig.default()
        let _ = "http://" + serverConfig.hostname + ":\(serverConfig.port)" + "/"
        return  relativePath
    }
    
    static public var baseBath: String {
        let serverConfig = NIOServerConfig.default()
        let hostname = "http://" + serverConfig.hostname + ":\(serverConfig.port)" + "/"
        return hostname
    }
            
    private var fileWithExt: String { return file + "." + ext }
    
    private func extendedPath(_ folder: Folder) -> String {
        switch folder {
        case .picture(let paths):
            let path = paths.isEmpty ? "":"/" + paths.map { $0.replacingOccurrences(of: " ", with: "_", options: NSString.CompareOptions.literal, range: nil) }.joined(separator: "/")
            return Constant.Directory.Path.images + path
        case .root:
            return Constant.Directory.Path.root
        }
    }
    
    public func save(with data: Data, compress: Compress) throws {
        /// Get path to project's dir
        let workDir = DirectoryConfig.detect().workDir
        /// Build path to Public folder
        let publicDir = workDir.appending(root)
        /// Build path to file folder
        let fileFolder = publicDir + "/" + extendedPath(folder)
        /// Create file folder if needed
        var isDir : ObjCBool = true
        if !FileManager.default.fileExists(atPath: fileFolder, isDirectory: &isDir) {
            try FileManager.default.createDirectory(atPath: fileFolder, withIntermediateDirectories: true)
        }
        let filePath = publicDir + "/" + relativePath
        /// Save data into file
        let compressedImg = try Image.init(data: data)
        let compressedData = try compressedImg.resizedTo(width: 640)?.export(as: .png)
        switch compress {
        case .yes:
            try compressedData?.write(to: URL(fileURLWithPath: filePath))
        case .no:
            try data.write(to: URL(fileURLWithPath: filePath))
        }
    }
}
