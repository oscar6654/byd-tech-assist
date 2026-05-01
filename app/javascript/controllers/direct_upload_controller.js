import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "progress"]

  connect() {
    this.element.addEventListener("direct-upload:initialize", this.initializeUpload.bind(this))
    this.element.addEventListener("direct-upload:progress", this.updateProgress.bind(this))
    this.element.addEventListener("direct-upload:end", this.endUpload.bind(this))
  }

  initializeUpload(event) {
    const { id, file } = event.detail
    const container = this.progressContainer

    const bar = document.createElement("div")
    bar.id = `direct-upload-${id}`
    bar.className = "mt-2"
    bar.innerHTML = `
      <div class="flex items-center justify-between gap-2">
        <span class="text-xs text-gray-600 truncate max-w-[200px]">${file.name}</span>
        <span class="direct-upload-percent text-xs font-medium text-gray-500">0%</span>
      </div>
      <div class="mt-1 w-full bg-gray-200 rounded-full h-2">
        <div class="direct-upload-progress bg-blue-600 h-2 rounded-full transition-all" style="width: 0%"></div>
      </div>
    `
    container.appendChild(bar)
  }

  updateProgress(event) {
    const { id, progress } = event.detail
    const bar = document.getElementById(`direct-upload-${id}`)
    if (bar) {
      bar.querySelector(".direct-upload-progress").style.width = `${progress}%`
      bar.querySelector(".direct-upload-percent").textContent = `${Math.round(progress)}%`
    }
  }

  endUpload(event) {
    const { id } = event.detail
    const bar = document.getElementById(`direct-upload-${id}`)
    if (bar) {
      bar.querySelector(".direct-upload-progress").classList.replace("bg-blue-600", "bg-green-500")
      bar.querySelector(".direct-upload-percent").innerHTML = `
        <svg class="w-4 h-4 text-green-500 inline" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/></svg>
      `
    }
  }

  get progressContainer() {
    if (this.hasProgressTarget) return this.progressTarget

    let container = this.element.querySelector("[data-direct-upload-target='progress']")
    if (!container) {
      container = document.createElement("div")
      container.setAttribute("data-direct-upload-target", "progress")
      this.element.appendChild(container)
    }
    return container
  }
}
