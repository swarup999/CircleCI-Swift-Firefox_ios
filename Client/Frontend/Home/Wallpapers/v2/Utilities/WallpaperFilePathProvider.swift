// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

/// Responsible for providing the required file paths on the disk.
struct WallpaperFilePathProvider: Loggable {

    /// Given a key, creates a URL pointing to the
    /// `.../wallpaper/key-as-folder/key-as-filePath` of the application's document directory.
    ///
    /// - Parameter key: The key to be used as the final path for the file.
    /// - Returns: A URL containing the correct path for the key.
    func metadataPath(forKey key: String) -> URL? {
        guard let keyDirectoryPath = folderPath(forKey: key) else {
            browserLog.debug("WallpaperFilePathProtocol - error fetching keyed directory path for application")
            return nil
        }

        return keyDirectoryPath.appendingPathComponent(key)
    }

    /// Given a key, creates a URL pointing to the
    /// `.../wallpaper/key-as-folder/name-as-filePath` of the application's document directory.
    ///
    /// - Parameters:
    ///   - key: The key to be used as the folder path for the file.
    ///   - name: The name to be used as the final path for the file.
    /// - Returns: A URL containing the correct path for the key.
    func imagePathWith(name: String, andKey key: String) -> URL? {
        guard let keyDirectoryPath = folderPath(forKey: key) else {
            browserLog.debug("WallpaperFilePathProvider - error fetching keyed directory path for application")
            return nil
        }

        return keyDirectoryPath.appendingPathComponent(name)
    }

    /// Given a key, creates a URL pointing to the `wallpaper/key-as-folder` folder
    /// of the application's document directory.
    ///
    /// - Parameter key: The key to be used as the file's containing folder
    /// - Parameter fileManager: The file manager to use to persist and retrieve the wallpaper.
    /// - Returns: A URL containing the correct path for the key.
    func folderPath(forKey key: String,
                    with fileManager: FileManager = FileManager.default
    ) -> URL? {
        guard let basePath = fileManager.urls(
            for: .applicationSupportDirectory,
            in: FileManager.SearchPathDomainMask.userDomainMask).first
        else {
            browserLog.debug("WallpaperFilePathProvider - error fetching basePath for application")
            return nil
        }

        let wallpaperDirectoryPath = basePath.appendingPathComponent("wallpapers")
        createFolderAt(path: wallpaperDirectoryPath)

        let keyDirectoryPath = wallpaperDirectoryPath.appendingPathComponent(key)
        createFolderAt(path: keyDirectoryPath)

        return keyDirectoryPath
    }

    private func createFolderAt(path directoryPath: URL,
                                with fileManager: FileManager = FileManager.default
    ) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryPath.path) {
            do {
                try fileManager.createDirectory(atPath: directoryPath.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                browserLog.debug("Could not create directory at \(directoryPath.absoluteString)")
            }
        }
    }
}
