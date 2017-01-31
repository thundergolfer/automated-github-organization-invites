require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'slim'
require 'octokit'

token = ENV['GITHUB_TOKEN']
org_name = ENV['ORGANISATION_NAME']
background_choice = ENV['BACKGROUND_COLOR']

if background_choice == 'green'
    background_css = "/css/background_colors/green.css"
elsif background_choice == 'blue'
    background_css = "/css/background_colors/blue.css"
elsif background_choice == 'pink'
    background_css = "/css/background_colors/pink.css"
elsif background_choice == 'red'
    background_css = "/css/background_colors/red.css"
elsif background_choice == 'grey'
    background_css = "/css/background_colors/grey.css"
else
    background_css = "/css/background_colors/white.css"
end


client = Octokit::Client.new(access_token: token)

def user_exists?(client, user)
  begin
    profile = client.user(user)
  rescue Octokit::NotFound
    return false
  end
  return true
end

def get_org_avatar_url(client, org_name)
  begin
    org = client.user(org_name)
  rescue Octokit::NotFound
    return nil
  end
  org[:avatar_url]
end

def check_org_exists(client, org_name)
  unless get_org_avatar_url(client, org_name).nil?
    return true
  end
  return false
end

@layout =<<EOS

doctype html
html
  head
    title Registration
    link href="/css/bootstrap.css" rel="stylesheet" type="text/css"
    link href="/css/bootstrap-responsive.css" rel="stylesheet" type="text/css"
    link href="/css/custom.css" rel="stylesheet" type="text/css"
    link href==background_css rel="stylesheet" type="text/css"
    link rel="shortcut icon" href="/favicon.ico"
  body
    div class="container container-table"
      div class="row vertical-center-row"
        div class="text-center col-md-4 col-md-offset-4"
          img{class="avatar" src==avatar height='100px' width='100px'}
          h1 Get GitHub Invite To
          h2 =org_name
          form action="add" method="POST"
            p Please enter your GitHub username
            p
              input.input_box name="github"
            p
              input.button type="submit" value="Add me to organization"
EOS

@post_text = "post text"
avatar = get_org_avatar_url(client, org_name)

l = Slim::Template.new { @layout }

get "/" do
  slim l.render(Object.new, :avatar => avatar, :org_name => org_name, :background_css => background_css)
end

#get "/" do
  #slim :index
#end

post "/add" do
  if user_exists?(client, params["github"])
    client.add_team_membership(org_id, params["github"])
    "OK, Check your EMAIL"
  end
  "User not found. Please check your spelling"
end
