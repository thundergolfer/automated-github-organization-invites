module Credentials
  @access_token="somegithuborgtoken" # A GITHUB ACCESS TOKEN
  @organisation_name="org name goes here" # YOUR ORGANISATION NAME, FOUND BY GOING TO DASHBOARD` https://github.com/orgs/{ORGANISATION_NAME}/dashboard

  def self.access_token
    return @access_token
  end

  def self.org_name
    return @organisation_name
  end

  def self.access_token=(val)
    @test_val=val;
  end
end
