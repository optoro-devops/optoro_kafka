module Overcommit
  module Hook
    module PreCommit
      # Run food critic to lint commit
      class Foodcritic < Base
        def run
          load_dependencies
          foodcritic_check = run_check
          [(foodcritic_check.warnings.empty? ? :pass : :fail), foodcritic_check.to_s]
        end

        private

        def run_check
          options = {
            cookbook_paths: `git rev-parse --show-toplevel`.tr("\n", ''),
            search_gems: true
          }
          ::FoodCritic::Linter.new.check options
        end

        def load_dependencies
          {
            bundler: 'run `gem install bundler` to install the bundler gem',
            foodcritic: 'run `bundle install` to install the foodcritic gem'
          }.each do |k, v|
            begin
              require k.to_s
            rescue LoadError
              return :stop, v
            end
          end
        end
      end
    end
  end
end
