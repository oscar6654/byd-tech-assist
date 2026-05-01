import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "fallback"]

  connect() {
    if (!this.hasVideoTarget) return

    const video = this.videoTarget
    const sources = video.querySelectorAll("source")
    let canPlay = false

    sources.forEach((source) => {
      if (video.canPlayType(source.type)) {
        canPlay = true
      }
    })

    if (!canPlay) {
      video.classList.add("hidden")
      if (this.hasFallbackTarget) {
        this.fallbackTarget.classList.remove("hidden")
      }
    }
  }
}
