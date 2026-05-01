import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  select(event) {
    const selectedIndex = this.tabTargets.indexOf(event.currentTarget)

    this.tabTargets.forEach((tab, index) => {
      if (index === selectedIndex) {
        tab.classList.add("border-blue-500", "text-blue-600")
        tab.classList.remove("border-transparent", "text-gray-500", "hover:text-gray-700", "hover:border-gray-300")
      } else {
        tab.classList.remove("border-blue-500", "text-blue-600")
        tab.classList.add("border-transparent", "text-gray-500", "hover:text-gray-700", "hover:border-gray-300")
      }
    })

    this.panelTargets.forEach((panel, index) => {
      panel.classList.toggle("hidden", index !== selectedIndex)
    })
  }
}
