module ApplicationHelper
  include Pagy::Frontend

  def page_title(title)
    content_for(:title) { title }
    content_tag(:h1, title, class: "text-2xl font-bold text-gray-900")
  end

  def status_badge(status)
    colors = {
      "open" => "bg-yellow-100 text-yellow-800",
      "in_progress" => "bg-blue-100 text-blue-800",
      "resolved" => "bg-green-100 text-green-800",
      "closed" => "bg-gray-100 text-gray-800"
    }
    css = colors[status.to_s] || "bg-gray-100 text-gray-800"
    content_tag(:span, status.to_s.humanize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{css}")
  end

  def category_badge(category)
    colors = {
      "warranty" => "bg-purple-100 text-purple-800",
      "general" => "bg-indigo-100 text-indigo-800",
      "recall" => "bg-red-100 text-red-800",
      "tsb" => "bg-orange-100 text-orange-800"
    }
    css = colors[category.to_s] || "bg-gray-100 text-gray-800"
    label = category.to_s == "tsb" ? "TSB" : category.to_s.humanize
    content_tag(:span, label, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{css}")
  end

  def active_link_class(path)
    current_page?(path) ? "bg-gray-900 text-white" : "text-gray-300 hover:bg-gray-700 hover:text-white"
  end
end
