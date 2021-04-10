require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'slim'
require 'octokit'

TOKEN = ENV['GITHUB_TOKEN']
ORG_NAME = ENV['ORGANIZATION_NAME']
TEAM_NAME = ENV['TEAM_NAME']
BACKGROUND_CHOICE = ENV['BACKGROUND_COLOR']

if BACKGROUND_CHOICE == 'green'
    background_css = "/css/background_colors/green.css"
elsif BACKGROUND_CHOICE == 'blue'
    background_css = "/css/background_colors/blue.css"
elsif BACKGROUND_CHOICE == 'pink'
    background_css = "/css/background_colors/pink.css"
elsif BACKGROUND_CHOICE == 'red'
    background_css = "/css/background_colors/red.css"
elsif BACKGROUND_CHOICE == 'grey'
    background_css = "/css/background_colors/grey.css"
else
    background_css = "/css/background_colors/white.css"
end

html_template_path = File.join(__dir__, 'views', 'index.slim')
@layout = File.read(html_template_path)

client = Octokit::Client.new(access_token: TOKEN)

def user_exists?(client, user)
  begin
    profile = client.user(user)
  rescue Octokit::NotFound
    return false
  end
  return true
end

def get_org_avatar_url(client)
  begin
    org = client.user(ORG_NAME)
  rescue Octokit::NotFound
    return nil
  end
  org[:avatar_url]
end

def get_org_id(client)
  begin
    org = client.user(ORG_NAME)
    return org.id
  rescue Octokit::NotFound
    return nil
  end
end

# TODO(Jonathon): Remove unused function
def get_org_teams(client)
  begin
    teams = client.org_teams(ORG_NAME)
    return teams
  rescue Octokit::NotFound
    return nil
  end
end

def check_org_exists(client)
  unless get_org_avatar_url(client).nil?
    return true
  end
  return false
end

def get_team(client)
  teams = client.org_teams(ORG_NAME)
  team = teams.find {|t| t.slug.downcase == TEAM_NAME.downcase }
  return team
end

def add_user_to_org(client, username)
  begin
    client.update_organization_membership(ORG_NAME, :user => params["github-user"])
    "Sent invite to join '#{ORG_NAME}', Check your EMAIL"
  rescue Octokit::ClientError => e
    "Error: #{e.class}. #{e.message}"
  end
end

def add_user_to_team_in_org(client, username, team_id)
  begin
    client.add_team_membership(team.id, username)
    "Sent invite to join '#{ORG_NAME}' and team '#{TEAM_NAME}', Check your EMAIL"
  rescue Octokit::ClientError => e
    "Error: #{e.class}. #{e.message}"
  end
end

# The URL for the Organisation's picture/avatar
avatar = get_org_avatar_url(client)
org_id = get_org_id(client)

l = Slim::Template.new { @layout }

# ROUTES #

get "/" do
  slim l.render(Object.new, :avatar => avatar, :org_name => ORG_NAME, :background_css => background_css)
end

post "/add" do
  username = params["github-user"]
  unless user_exists?(client, username)
    return "User not found. Please check your spelling"
  end

  team = get_team(client)
  if team.nil?
    # team was blank or could not be found, just add user to org
    add_user_to_org(client, username)
  else
    add_user_to_team_in_org(client, username, team.id)
  end
end
