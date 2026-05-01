import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobile", "overlay"]

  toggle() {
    this.mobileTarget.classList.toggle("-translate-x-full")
    this.mobileTarget.classList.toggle("translate-x-0")
    this.overlayTarget.classList.toggle("hidden")
  }

  close() {
    this.mobileTarget.classList.add("-translate-x-full")
    this.mobileTarget.classList.remove("translate-x-0")
    this.overlayTarget.classList.add("hidden")
  }
}
