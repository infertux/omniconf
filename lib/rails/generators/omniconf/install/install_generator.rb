module Omniconf
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Installs Omniconf and generates the necessary migration"

      include Rails::Generators::Migration

      def self.source_root
        File.expand_path("../templates", __FILE__)
      end

      def self.next_migration_number(dirname)
        Time.now.strftime("%Y%m%d%H%M%S")
      end

      def copy_initializer
        template 'omniconf.rb.erb', 'config/initializers/omniconf.rb'
      end

      def create_migrations
        Dir["#{self.class.source_root}/migrations/*.rb"].sort.each do |filepath|
          name = File.basename(filepath)
          migration_template "migrations/#{name}", "db/migrate/#{name.gsub(/^\d+_/,'')}"
          sleep 1 # ensure next migration gets a new number
        end
      end
    end
  end
end
