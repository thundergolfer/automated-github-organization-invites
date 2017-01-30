require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'octokit'
require 'slim'

token = "[TEMPORARY PERSONAL ACCESS TOKEN]"
org_id = 1227580

client = Octokit::Client.new(access_token: token)

get "/" do
  slim :index
end

post "/add" do
  client.add_team_membership(org_id, params["github"])
  "OK, Check your EMAIL"
end
