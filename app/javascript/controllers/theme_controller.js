import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lightIcon", "darkIcon"]

  toggle() {
    const html = document.documentElement
    const isDark = html.classList.contains("dark")
    const newTheme = isDark ? "light" : "dark"

    html.classList.toggle("dark")
    this.updateIcons(newTheme)
    this.saveTheme(newTheme)
  }

  updateIcons(theme) {
    if (!this.hasLightIconTarget || !this.hasDarkIconTarget) return

    if (theme === "dark") {
      this.lightIconTarget.classList.add("hidden")
      this.darkIconTarget.classList.remove("hidden")
    } else {
      this.lightIconTarget.classList.remove("hidden")
      this.darkIconTarget.classList.add("hidden")
    }
  }

  saveTheme(theme) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch("/theme", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "application/json"
      },
      body: JSON.stringify({ theme })
    })
  }
}
