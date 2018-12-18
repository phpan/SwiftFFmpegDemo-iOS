//
//  SwsContext.swift
//  SwiftFFmpeg
//
//  Created by sunlubo on 2018/7/11.
//

import CFFmpeg

// MARK: - SwsContext

public final class SwsContext {
    public struct Flag: OptionSet {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let fastBilinear = Flag(rawValue: SWS_FAST_BILINEAR)
        public static let bilinear = Flag(rawValue: SWS_BILINEAR)
        public static let bicubic = Flag(rawValue: SWS_BICUBIC)
        public static let x = Flag(rawValue: SWS_X)
        public static let point = Flag(rawValue: SWS_POINT)
        public static let area = Flag(rawValue: SWS_AREA)
        public static let bicublin = Flag(rawValue: SWS_BICUBLIN)
        public static let gauss = Flag(rawValue: SWS_GAUSS)
        public static let sinc = Flag(rawValue: SWS_SINC)
        public static let lanczos = Flag(rawValue: SWS_LANCZOS)
        public static let spLine = Flag(rawValue: SWS_SPLINE)
    }

    internal let ctx: OpaquePointer

    /// Allocate an empty `SwsContext`.
    public init() {
        ctx = sws_alloc_context()
    }

    /// Allocate and return an `SwsContext`.
    ///
    /// - Parameters:
    ///   - srcW: the width of the source image
    ///   - srcH: the height of the source image
    ///   - srcFormat: the source image format
    ///   - dstW: the width of the destination image
    ///   - dstH: the height of the destination image
    ///   - dstFormat: the destination image format
    ///   - flags: specify which algorithm and options to use for rescaling
    public init?(
        srcW: Int, srcH: Int, srcFormat: AVPixelFormat,
        dstW: Int, dstH: Int, dstFormat: AVPixelFormat,
        flags: SwsContext.Flag
    ) {
        guard let ptr = sws_getContext(
            Int32(srcW), Int32(srcH), srcFormat,
            Int32(dstW), Int32(dstH), dstFormat,
            flags.rawValue,
            nil, nil,
            nil
        ) else {
            return nil
        }
        ctx = ptr
    }

    /// Scale the image slice in srcSlice and put the resulting scaled slice in the image in dst.
    ///
    /// A slice is a sequence of consecutive rows in an image.
    ///
    /// Slices have to be provided in sequential order, either in top-bottom or bottom-top order.
    /// If slices are provided in non-sequential order the behavior of the function is undefined.
    ///
    /// - Parameters:
    ///   - src: the array containing the pointers to the planes of the source slice
    ///   - srcStride: the array containing the strides for each plane of the source image
    ///   - srcSliceY: the position in the source image of the slice to process, that is the number
    ///     (counted starting from zero) in the image of the first row of the slice
    ///   - srcSliceH: the height of the source slice, that is the number of rows in the slice
    ///   - dst: the array containing the pointers to the planes of the destination image
    ///   - dstStride: the array containing the strides for each plane of the destination image
    /// - Returns: the height of the output slice
    @discardableResult
    public func scale(
        src: UnsafePointer<UnsafePointer<UInt8>?>,
        srcStride: UnsafePointer<Int32>,
        srcSliceY: Int,
        srcSliceH: Int,
        dst: UnsafePointer<UnsafeMutablePointer<UInt8>?>,
        dstStride: UnsafePointer<Int32>
    ) -> Int {
        return Int(sws_scale(ctx, src, srcStride, Int32(srcSliceY), Int32(srcSliceH), dst, dstStride))
    }

    /// Returns a Boolean value indicating whether the pixel format is a supported input format.
    ///
    /// - Parameter pixFmt: pixel format
    /// - Returns: true if it is supported; otherwise false.
    public static func isSupportedInput(_ pixFmt: AVPixelFormat) -> Bool {
        return sws_isSupportedInput(pixFmt) > 0
    }

    /// Returns a Boolean value indicating whether the pixel format is a supported output format.
    ///
    /// - Parameter pixFmt: pixel format
    /// - Returns: true if it is supported; otherwise false.
    public static func isSupportedOutput(_ pixFmt: AVPixelFormat) -> Bool {
        return sws_isSupportedOutput(pixFmt) > 0
    }

    /// Returns a Boolean value indicating whether an endianness conversion is supported.
    ///
    /// - Parameter pixFmt: pixel format
    /// - Returns: true if it is supported; otherwise false.
    public static func isSupportedEndiannessConversion(_ pixFmt: AVPixelFormat) -> Bool {
        return sws_isSupportedEndiannessConversion(pixFmt) > 0
    }

    deinit {
        sws_freeContext(ctx)
    }
}
