require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'slim'
require 'octokit'

token = ENV['GITHUB_TOKEN']
org_name = ENV['ORGANIZATION_NAME']
team_name = ENV['TEAM_NAME']
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

html_template_path = File.join(__dir__, 'views', 'index.slim')
@layout = File.read(html_template_path)

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

def get_org_id(client, org_name)
  begin
    org = client.user(org_name)
    return org.id
  rescue Octokit::NotFound
    return nil
  end
end

def get_org_teams(client, org_name)
  begin
    teams = client.org_teams(org_name)
    return teams
  rescue Octokit::NotFound
    return nil
  end
end

def check_org_exists(client, org_name)
  unless get_org_avatar_url(client, org_name).nil?
    return true
  end
  return false
end

def get_team(client, org_name, team_name)
  teams = client.org_teams(org_name)
  team = teams.find {|t| t.slug.downcase == team_name.downcase }    
  return team
end

# The URL for the Organisation's picture/avatar
avatar = get_org_avatar_url(client, org_name)
org_id = get_org_id(client, org_name)

l = Slim::Template.new { @layout }

# ROUTES #

get "/" do
  slim l.render(Object.new, :avatar => avatar, :org_name => org_name, :background_css => background_css)
end

post "/add" do
  if user_exists?(client, params["github-user"])
    team = get_team(client, org_name, team_name)    
    if team.nil?
      # team was blank or could not be found, just add user to org
      client.update_organization_membership(org_name, :user => params["github-user"])
      "Sent invite to join '" + org_name + "', Check your EMAIL"
    else
      # team_id valid so invite member directly to org's team
      client.add_team_membership(team.id, params["github-user"])      
      "Sent invite to join '" + org_name + "' and team '" + team_name + "', Check your EMAIL"
    end
  else
    "User not found. Please check your spelling"
  end
end
