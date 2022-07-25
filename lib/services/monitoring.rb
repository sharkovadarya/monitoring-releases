require 'octokit'

module Services
  class Monitoring
    ONLY_BUG_FIXES_PHRASES = ['bug fixes only', 'only bug fixes']
    NEW_FEATURES_PHRASES = ['new features', 'features', 'added', 'enhancements']
    BUG_FIXES = ['bug fixes', 'fixed']
    def self.set_repo_latest_release(repo, client)
      repo_path = repo.owner + '/' + repo.name
      latest_release = nil
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
          if important_tag? latest_tag
            break
          end
        end
        latest_tag = latest_release.tag_name
        repo.latest_release_notes = latest_release.body
        latest_release_date = latest_release.published_at
      end
      if latest_release.nil? ? important_tag?(latest_tag) : important_release?(latest_release)
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

    def self.important_release?(release)
      unless important_tag? release.tag_name
        return false
      end

      release_notes = release.body.downcase
      if ONLY_BUG_FIXES_PHRASES.any? { |phrase| release_notes.include? phrase }
        return false
      end

      sep = $/.nil? ? "\n" : $/
      if BUG_FIXES.any? { |p| release_notes.include?('##' + p + sep) || release_notes.include?(p + ':' + sep) } &&
        !NEW_FEATURES_PHRASES.any? { |p| release_notes.include? p }
        return false
      end

      true
    end

    def self.important_tag?(tag)
      tag = tag.downcase
      !(tag.include?("preview") || tag.include?("rc") || tag.include?("beta"))
    end
  end
end
