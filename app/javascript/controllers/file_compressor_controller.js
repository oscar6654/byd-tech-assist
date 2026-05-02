import { Controller } from "@hotwired/stimulus"

// Client-side image compression before S3 upload using Canvas API.
// Resizes large images and re-encodes as JPEG at configurable quality.
// A typical 5MB phone photo compresses to 200-400KB (90%+ savings).
export default class extends Controller {
  static targets = ["input", "status"]
  static values = {
    maxWidth: { type: Number, default: 1920 },
    maxHeight: { type: Number, default: 1080 },
    quality: { type: Number, default: 0.80 },
  }

  connect() {
    if (this.hasInputTarget) {
      this.inputTarget.addEventListener("change", this.handleFiles.bind(this))
    }
  }

  async handleFiles(event) {
    const input = event.target
    const files = Array.from(input.files)
    if (files.length === 0) return

    const hasImages = files.some(f => f.type.startsWith("image/"))
    if (!hasImages) {
      this.showStatus(`${files.length} file(s) ready — ${this.formatSize(files.reduce((s, f) => s + f.size, 0))}`, "text-gray-500")
      return
    }

    this.showStatus("Compressing images...")
    const compressed = []
    let totalOriginal = 0
    let totalCompressed = 0

    for (const file of files) {
      totalOriginal += file.size
      if (file.type.startsWith("image/")) {
        try {
          const result = await this.compressImage(file)
          compressed.push(result)
          totalCompressed += result.size
        } catch (e) {
          console.warn(`Compression failed for ${file.name}, using original:`, e)
          compressed.push(file)
          totalCompressed += file.size
        }
      } else {
        compressed.push(file)
        totalCompressed += file.size
      }
    }

    const dt = new DataTransfer()
    compressed.forEach(f => dt.items.add(f))
    input.files = dt.files

    const savedPct = totalOriginal > 0 ? Math.round((1 - totalCompressed / totalOriginal) * 100) : 0
    if (savedPct > 5) {
      this.showStatus(`Compressed: ${this.formatSize(totalOriginal)} → ${this.formatSize(totalCompressed)} (${savedPct}% smaller)`, "text-green-600")
    } else {
      this.showStatus(`Ready: ${this.formatSize(totalCompressed)}`, "text-gray-500")
    }
  }

  compressImage(file) {
    return new Promise((resolve, reject) => {
      const img = new Image()
      img.onload = () => {
        try {
          let { width, height } = img
          const maxW = this.maxWidthValue
          const maxH = this.maxHeightValue

          if (width > maxW || height > maxH) {
            const ratio = Math.min(maxW / width, maxH / height)
            width = Math.round(width * ratio)
            height = Math.round(height * ratio)
          }

          const canvas = document.createElement("canvas")
          canvas.width = width
          canvas.height = height
          const ctx = canvas.getContext("2d")
          ctx.drawImage(img, 0, 0, width, height)

          const isPng = file.type === "image/png"
          const outputType = isPng ? "image/png" : "image/jpeg"
          const quality = isPng ? undefined : this.qualityValue

          canvas.toBlob((blob) => {
            URL.revokeObjectURL(img.src)
            if (!blob) return reject(new Error("Canvas toBlob failed"))
            if (blob.size < file.size) {
              const ext = isPng ? ".png" : ".jpg"
              const name = file.name.replace(/\.[^.]+$/, ext)
              resolve(new File([blob], name, { type: outputType, lastModified: file.lastModified }))
            } else {
              resolve(file)
            }
          }, outputType, quality)
        } catch (e) { reject(e) }
      }
      img.onerror = () => { URL.revokeObjectURL(img.src); reject(new Error("Failed to load image")) }
      img.src = URL.createObjectURL(file)
    })
  }

  formatSize(bytes) {
    if (bytes < 1024) return `${bytes}B`
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(0)}KB`
    return `${(bytes / 1024 / 1024).toFixed(1)}MB`
  }

  showStatus(message, colorClass = "text-gray-500") {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.className = `text-xs mt-1 ${colorClass}`
    }
  }
}
