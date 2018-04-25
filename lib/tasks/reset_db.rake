# frozen_string_literal: true

# lib/tasks/reset_db.rake
namespace :db do
  desc 'Drop, create, migrate then seed the database'
  task reset_db: :environment do
    puts "Executing `bin/rails db:environment:set RAILS_ENV=#{ENV['RAILS_ENV']}` for you !"
    system("bin/rails db:environment:set RAILS_ENV=#{ENV['RAILS_ENV']}")
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    #Rake::Task['db:schema:load'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
  end

  desc 'Drop data then seed the database with db/data.sql'
  task reset_data: :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:data:load'].invoke
  end

  desc 'Create, migrate then seed the database'
  task init_db: :environment do
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
  end
end
