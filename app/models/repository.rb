class Repository < ApplicationRecord
  def self.refresh
    client = Octokit::Client.new(:access_token => ENV['PERSONAL_ACCESS_TOKEN'])
    all.each do |repo|
      Services::Monitoring.set_repo_latest_release(repo, client)
      repo.save
    end
  end

  # utility method
  def self.clear_all
    all.each do |repo|
      repo.latest_tag = Repository.column_defaults["latest_tag"]
      repo.latest_release_notes = Repository.column_defaults["latest_release_notes"]
      repo.latest_release_date = Repository.column_defaults["latest_release_date"]
      repo.read = true
      repo.save
    end
  end

  def url
    "https://github.com/" + owner + "/" + name
  end
end
