# config/initializers/dartsass.rb
Rails.application.config.dartsass.builds = {
  "active_admin.scss" => "active_admin.css",
  "application.scss" => "application.css"
}

Rails.application.config.dartsass.load_paths = [
  ActiveAdmin::Engine.root.join("app/assets/stylesheets")
]
