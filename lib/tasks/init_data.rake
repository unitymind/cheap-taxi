#encoding: utf-8

namespace :db do
  desc "Init database from a scratch. Parse and populate data."
  task(:init => ["db:schema:load", "db:parser:moscow:all", "db:populate:all"])
end