# frozen_string_literal: true

# This script runs after gem installation to install JavaScript dependencies
require 'fileutils'

gem_root = File.expand_path('..', __dir__)

Dir.chdir(gem_root) do
  puts "Installing JavaScript dependencies for rswag-ui..."

  # Try yarn first, fall back to npm if yarn is not available
  if system('which yarn > /dev/null 2>&1')
    success = system('yarn install --production --frozen-lockfile 2>/dev/null') ||
              system('yarn install --production 2>/dev/null') ||
              system('yarn install')

    if success
      puts "Successfully installed JavaScript dependencies with yarn"
    else
      puts "Warning: yarn install failed, but continuing installation"
    end
  elsif system('which npm > /dev/null 2>&1')
    success = system('npm install --production')

    if success
      puts "Successfully installed JavaScript dependencies with npm"
    else
      puts "Warning: npm install failed, but continuing installation"
    end
  else
    puts "Warning: Neither yarn nor npm found. Please install Node.js and yarn/npm, then run 'yarn install' or 'npm install' in the rswag-ui directory."
  end
end

# Create a dummy Makefile to satisfy RubyGems
File.write('Makefile', "all:\n\ninstall:\n\nclean:\n\n")
