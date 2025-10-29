require 'rswag/ui/middleware'
require 'rswag/ui/basic_auth'

module Rswag
  module Ui
    class Engine < ::Rails::Engine
      isolate_namespace Rswag::Ui

      initializer 'rswag-ui.initialize' do |app|
        middleware.use Rswag::Ui::Middleware, Rswag::Ui.config

        if Rswag::Ui.config.basic_auth_enabled
          c = Rswag::Ui.config
          app.middleware.use Rswag::Ui::BasicAuth do |username, password|
            c.config_object[:basic_auth].values == [username, password]
          end
        end
      end

      initializer 'rswag-ui.check_dependencies', before: 'rswag-ui.initialize' do
        unless File.exist?(Rswag::Ui.config.assets_root)
          gem_root = File.expand_path('../../../..', __FILE__)

          Rails.logger.info "Rswag::UI: JavaScript dependencies not found. Installing..."

          Dir.chdir(gem_root) do
            if system('which yarn > /dev/null 2>&1')
              success = system('yarn install --production --frozen-lockfile 2>/dev/null') ||
                        system('yarn install --production 2>/dev/null') ||
                        system('yarn install')

              if success
                Rails.logger.info "Rswag::UI: Successfully installed JavaScript dependencies with yarn"
              else
                Rails.logger.error "Rswag::UI: yarn install failed. Run 'rake rswag:ui:install' manually."
              end
            elsif system('which npm > /dev/null 2>&1')
              if system('npm install --production')
                Rails.logger.info "Rswag::UI: Successfully installed JavaScript dependencies with npm"
              else
                Rails.logger.error "Rswag::UI: npm install failed. Run 'rake rswag:ui:install' manually."
              end
            else
              Rails.logger.error "Rswag::UI: Neither yarn nor npm found. Install Node.js and run 'rake rswag:ui:install'."
            end
          end
        end
      end

      rake_tasks do
        load File.expand_path('../../../tasks/rswag-ui_tasks.rake', __FILE__)
      end
    end
  end
end
