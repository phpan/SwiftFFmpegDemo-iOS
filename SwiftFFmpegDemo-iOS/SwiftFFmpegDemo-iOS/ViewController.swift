//
//  ViewController.swift
//  SwiftFFmpegDemo-iOS
//
//  Created by sunlubo on 2018/12/18.
//  Copyright © 2018 sunlubo. All rights reserved.
//

import UIKit
import SwiftFFmpeg

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .background).async {
            try? self.test()
        }
    }
    
    func test() throws {
        let input = Bundle.main.path(forResource: "avf_test", ofType: "mp4")!
        
        let fmtCtx = AVFormatContext()
        try fmtCtx.openInput(input)
        try fmtCtx.findStreamInfo()
        
        fmtCtx.dumpFormat(isOutput: false)
        
        guard let stream = fmtCtx.videoStream else {
            fatalError("No video stream")
        }
        guard let codec = AVCodec.findDecoderById(stream.codecpar.codecId) else {
            fatalError("Codec not found")
        }
        guard let codecCtx = AVCodecContext(codec: codec) else {
            fatalError("Could not allocate video codec context.")
        }
        try codecCtx.setParameters(stream.codecpar)
        try codecCtx.openCodec()
        
        let pkt = AVPacket()
        let frame = AVFrame()
        
        while let _ = try? fmtCtx.readFrame(into: pkt) {
            defer { pkt.unref() }
            
            if pkt.streamIndex != stream.index {
                continue
            }
            
            try codecCtx.sendPacket(pkt)
            
            while true {
                do {
                    try codecCtx.receiveFrame(frame)
                } catch let err as AVError where err == .EAGAIN || err == .EOF {
                    break
                }
                
                let str = String(
                    format: "Frame %3d (type=%@, size=%5d bytes) pts %4lld key_frame %d [DTS %3lld]",
                    codecCtx.frameNumber,
                    frame.pictType.description,
                    frame.pktSize,
                    frame.pts,
                    frame.isKeyFrame,
                    frame.codedPictureNumber
                )
                print(str)
                
                frame.unref()
            }
        }
        
        print("Done.")
    }
}
