class Repository < ApplicationRecord
  def self.refresh
    client = Octokit::Client.new(:access_token => ENV['PERSONAL_ACCESS_TOKEN'])
    all.each do |repo|
      Services::Monitoring.set_repo_latest_release(repo, client)
      repo.save
    end
  end

  def url
    "https://github.com/" + owner + "/" + name
  end
end
