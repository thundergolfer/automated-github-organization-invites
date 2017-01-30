require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'octokit'
require 'slim'

require './creds.rb'

token = Credentials.access_token
org_id = 1227580
client = Octokit::Client.new(access_token: token)

def check_user_exists(client, user)
  begin
  profile = client.user(user)
  rescue Octokit::NotFound
    return false
  end
  return true
end

@layout =<<EOS

doctype html
html
  head
    title Registration
    link href="/css/bootstrap.css" rel="stylesheet" type="text/css"
    link href="/css/bootstrap-responsive.css" rel="stylesheet" type="text/css"
  body
    img{src==avatar height='100px' width='100px'}
    h1 GitHub
    form action="add" method="POST"
      p Please enter your GitHub username
      p
        input name="github"
      p
        input type="submit" value="Add me to organization"
EOS

@post_text = "post text"
avatar = "https://assets-cdn.github.com/images/modules/logos_page/Octocat.png"

l = Slim::Template.new { @layout }

get "/" do
  slim l.render(Object.new, :avatar => avatar)
end

#get "/" do
  #slim :index
#end

post "/add" do
  client.add_team_membership(org_id, params["github"])
  "OK, Check your EMAIL"
end
