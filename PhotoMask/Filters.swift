//
//  Filters.swift
//  PhotoMask
//
//  Created by Jia Jing on 3/7/16.
//  Copyright © 2016 Jia Jing. All rights reserved.
//

import Foundation
import CoreImage



protocol FilterType {
  var title: String { get }
  var poster: String { get }
  var key: String { get }
  func filter(input: CIImage) -> CIImage
}



struct WrappedFilter: FilterType {
  let title: String
  let poster: String
  let key: String
  let cifilters: [CIFilter]
  
  init(title: String, poster: String, key: String, cifilterName: String...) {
    self.title = title
    self.poster = poster
    self.key = key
    self.cifilters = cifilterName.map(CIFilter.init).compact()
  }
  
  
  func filter(input: CIImage) -> CIImage {
    return cifilters.reduce(input) { image, filter in
      filter.setValue(image, forKey: kCIInputImageKey)
      return filter.outputImage!.imageByCroppingToRect(input.extent)
    }
  }
}






var allFilters: [FilterType] {
  var filters: [FilterType] = []
  let f_meiyan = WrappedFilter(title: "Gloom", poster: "meiyan", key: "CIBloom", cifilterName: "CIBloom")
  f_meiyan.cifilters.first?.setValue(NSNumber(float: 0.5), forKey: "inputIntensity")
  f_meiyan.cifilters.first?.setValue(NSNumber(float: 8), forKey: "inputRadius")
  filters.append(f_meiyan)
  //  filters.append(WrappedFilter(title: "点画", poster: UIImage.invisible, key: "CIPointillize", cifilterName: "CIPointillize"))
  //
  //
  //  let f_sketch = WrappedFilter(title: "素描", poster: UIImage.invisible, key: "CILineOverlay", cifilterName: "CILineOverlay")
  //  f_sketch.cifilter.setValue(NSNumber(float: 0.07), forKey: "inputNRNoiseLevel")
  //  f_sketch.cifilter.setValue(NSNumber(float: 0.71), forKey: "inputNRSharpness")
  //  f_sketch.cifilter.setValue(NSNumber(float: 0.2), forKey: "inputEdgeIntensity")
  //  f_sketch.cifilter.setValue(NSNumber(float: 0.5), forKey: "inputThreshold")
  //  f_sketch.cifilter.setValue(NSNumber(float: 10), forKey: "inputContrast")
  //  filters.append(f_sketch)
  let f_hdr = WrappedFilter(title: "HDR", poster: "mingli", key: "CIHighlightShadowAdjust", cifilterName: "CIHighlightShadowAdjust")
  f_hdr.cifilters.first?.setValue(NSNumber(float: 0.3), forKey: "inputShadowAmount")
  filters.append(f_hdr)
  filters.append(WrappedFilter(title: "Chrome", poster: "mingli", key: "CIPhotoEffectChrome", cifilterName: "CIPhotoEffectChrome"))
  
  
  
  
  let f_fade = WrappedFilter(title: "Fade", poster: "danya", key: "CIPhotoEffectFade", cifilterName: "CIVignette", "CIPhotoEffectFade")
  f_fade.cifilters.first?.setValue(NSNumber(float: 3), forKey: "inputIntensity")
  filters.append(f_fade)
  
  let f_instant = WrappedFilter(title: "Instant", poster: "fenhong", key: "CIPhotoEffectInstant", cifilterName: "CIVignette", "CIPhotoEffectInstant")
  f_instant.cifilters.first?.setValue(NSNumber(float: 5), forKey: "inputIntensity")
  filters.append(f_instant)
  
  let f_noir = WrappedFilter(title: "Noir", poster: "heibai", key: "CIPhotoEffectNoir", cifilterName: "CIVignette", "CIPhotoEffectNoir")
  f_noir.cifilters.first?.setValue(NSNumber(float: 3), forKey: "inputIntensity")
  filters.append(f_noir)
  //  filters.append(WrappedFilter(title: |"CI_Process", poster: UIImage(named: "fugu")!, key: "CIPhotoEffectProcess", cifilterName: "CIPhotoEffectProcess"))
  let f_transfer = WrappedFilter(title: "Transfer", poster: "huaijiu", key: "CIPhotoEffectTransfer", cifilterName: "CIVignette", "CIPhotoEffectTransfer")
  f_transfer.cifilters.first?.setValue(NSNumber(float: 3), forKey: "inputIntensity")
  filters.append(f_transfer)
  
  let f_sepia = WrappedFilter(title: "Sepia", poster: "kafei", key: "CISepiaTone", cifilterName: "CIVignette", "CISepiaTone")
  f_sepia.cifilters.first?.setValue(NSNumber(float: 3), forKey: "inputIntensity")
  filters.append(f_sepia)
  //  let f_vignette = WrappedFilter(title: |"CI_Vignette", poster: UIImage(named: "jiaopian")!, key: "CIVignette", cifilterName: "CIVignette")
  //  f_vignette.cifilters.first?.setValue(NSNumber(float: 3), forKey: "inputIntensity")
  //  filters.append(f_vignette)
  
  
  return filters
}