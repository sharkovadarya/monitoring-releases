require 'octokit'

module Services
  class Monitoring
    def self.set_repo_latest_release(repo, client)
      repo_path = repo.owner + '/' + repo.name
      begin
        releases = client.releases(repo_path)
      rescue Octokit::Error => e
        log_error e
        return
      end

      if releases.nil? || releases.empty?
        begin
          tags = client.tags(repo_path)
        rescue Octokit::Error => e
          log_error e
          return
        end

        if tags.nil? || tags.empty?
          return
        end
        latest_tag = tags.first.name
        begin
          commit = client.commit(repo_path, tags.first.commit.sha)
        rescue Octokit::Error => e
          log_error e
          return
        end
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
      unless latest_tag.eql? repo.latest_tag || latest_tag.include?("preview") || latest_tag.include?("rc")
        repo.read = false
        repo.latest_tag = latest_tag
        repo.latest_release_date = latest_release_date
      end
    end

    private
    def self.log_error(e)
      Rails.logger.error e.message
      backtrace = e.backtrace
      unless backtrace.nil?
        backtrace.each { |line| Rails.logger.error line }
      end
    end
  end
end
