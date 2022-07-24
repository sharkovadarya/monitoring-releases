require 'octokit'

module Services
  class Monitoring
    def self.silly_little_fun(repo)
      repo.latest_tag = rand(8).to_s
    end

    def self.set_repo_latest_release(repo, client)
      repo_path = repo.owner + '/' + repo.name
      releases = client.releases(repo_path)
      if releases.nil? || releases.empty?
        tags = client.tags(repo_path)
        # TODO ensure correctness
        latest_tag = tags.first.name
        commit = client.commit(repo_path, tags.first.commit.sha)
        latest_release_date = commit.commit.author.date
      else
        latest_release = releases.first
        releases.each do |release|
          latest_release = release
          latest_tag = release.tag_name
          unless latest_tag.include?("preview") || latest_tag.include?("rc") || latest_tag.include?("beta")
            break
          end
        end
        latest_tag = latest_release.tag_name
        repo.latest_release_notes = latest_release.body
        latest_release_date = latest_release.published_at
      end
      puts(repo.owner + " " + repo.name + " " + latest_tag)
      unless latest_tag.eql? repo.latest_tag || latest_tag.include?("preview") || latest_tag.include?("rc")
        repo.read = false
        repo.latest_tag = latest_tag
        repo.latest_release_date = latest_release_date
      end
    end
  end
end
