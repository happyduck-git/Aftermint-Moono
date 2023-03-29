//
//  TemplateService.swift
//  mojitok-nft
//
//  Created by GAMZA on 2022/03/25.
//

import Foundation

import RxSwift

final class TemplateService {
    
    enum TemplateServiceEvent {
        case refresh([Template])
    }
    
    static let templateFolderURL = FilesManager.cacheFolderURL.appendingPathComponent("templateS", isDirectory: true)
    static let templateFileURL = templateFolderURL.appendingPathComponent("Template.txt")
    static let shared: TemplateService = .init()
    
    private(set) var templates: [Template] = []
    private let queue = DispatchQueue(label: "TemplateService", qos: .background ,attributes: .concurrent)
    private let templateQueue = DispatchQueue(label: "TemplateService-Template")
    private let group = DispatchGroup()
    
    var event = PublishSubject<TemplateServiceEvent>()
    
    private init() {
        FilesManager.checkDirectory(url: TemplateService.templateFolderURL)
        templates = fetchTemplates()
        syncRemoteConfig()
    }
    
    private func fetchTemplates() -> [Template] {
        templateQueue.sync {
            if let data = try? Data(contentsOf: TemplateService.templateFileURL),
               let templates = try? JSONDecoder().decode([Template].self, from: data) {
                print("templateFileURL: \(TemplateService.templateFileURL)")
                return templates
            }
            return []
        }
    }
    
    private func saveTemplates() {
        templateQueue.sync {
            if let data = try? JSONEncoder().encode(templates) {
                try? data.write(to: TemplateService.templateFileURL)
            }
        }
    }
    
    private func syncRemoteConfig() {
        RemoteConfigService.shared.getResource(key: .templates) { [weak self] data in
            if let data = data,
               let templates = try? JSONDecoder().decode([Template].self, from: data) {
                LLog.i("templates: \(templates)")
                
                // XXX code for Aftermint.
                let orderedTemplates = [
                    templates.filter { $0.name == "basic" }.first!,
                    templates.filter { $0.name == "welcome"}.first!,
                    templates.filter { $0.name == "gallery"}.first!,
                    templates.filter { $0.name == "just_bought"}.first!
                ]
                
                self?.syncTemplate(remoteTemplates: orderedTemplates)
            }
        }
    }
    
    private func syncTemplate(remoteTemplates: [Template]) {
        var isChanged = false
        for template in self.templates {
            if !remoteTemplates.contains(template) {
                isChanged = true
                queue.sync {
                    removeTemplate(template: template)
                }
            }
        }
        
        for (index, remoteTemplate) in remoteTemplates.enumerated() {
            if !templates.contains(where: { $0.name == remoteTemplate.name && $0.version == remoteTemplate.version }) {
                isChanged = true
                queue.async(group: group) { [weak self] in
                    let fileSemaphore = DispatchSemaphore(value: 0)
                    var fileData: Data?
                    let thumbnailSemaphore = DispatchSemaphore(value: 0)
                    var thumbnailData: Data?
                    self?.removeTemplate(template: remoteTemplate)

                    FirebaseStorageService.shared.getFile(urlString: "/template/lottie_resources/\(remoteTemplate.lottieFileName)") { data in
                        fileData = data
                        fileSemaphore.signal()
                    }
                    fileSemaphore.wait()
                    
                    FirebaseStorageService.shared.getFile(urlString: "/template/lottie_thumbnails/\(remoteTemplate.thumbnailImageName)") { data in
                        thumbnailData = data
                        thumbnailSemaphore.signal()
                    }
                    thumbnailSemaphore.wait()
                    if let thumbnailData = thumbnailData {
                        self?.addTemplate(template: remoteTemplate, index: index, fileData: fileData, thumbnailData: thumbnailData)
                    }
                }
            }
        }
        
        group.notify(queue: queue) { [weak self] in
            if isChanged {
                self?.saveTemplates()
                self?.templateQueue.sync { [weak self] in
                    if let self = self {
                        self.event.onNext(.refresh(self.templates))
                    }
                }
            }
        }
    }
    
    private var _templates: [Template?] = Array(repeating: nil, count: 4)
    private func addTemplate(template: Template, index: Int, fileData: Data?, thumbnailData: Data) {
        if let fileData = fileData {
            try? fileData.write(to: template.fileURL)
        }
        try? thumbnailData.write(to: template.thumbnailURL)
        templateQueue.sync {
            _templates[index] = template
            templates = _templates
                .filter { $0 != nil }
                .map { $0! }
        }
    }
    
    private func removeTemplate(template: Template) {
        let templateFileURL = TemplateService.templateFolderURL.appendingPathComponent(template.lottieFileName)
        let templateThumbnailURL = TemplateService.templateFolderURL.appendingPathComponent(template.thumbnailImageName)
        FilesManager.removeFile(url: templateFileURL)
        FilesManager.removeFile(url: templateThumbnailURL)
        if let index = templates.firstIndex(of: template) {
            templates.remove(at: index)
        }
    }
}
