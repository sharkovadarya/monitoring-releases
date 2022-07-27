require 'octokit'
require 'open-uri'

module Services
  class Monitoring
    ONLY_BUG_FIXES = ['bug fixes only', 'only bug fixes']
    NEW_FEATURES = ['new features', 'features', 'added', 'enhancements', 'feature changes']
    BUG_FIXES = ['bug fixes', 'fixed', 'fixes']
    def self.set_repo_latest_release(repo, client)
      repo_path = repo.owner + '/' + repo.name

      begin
        releases = client.releases(repo_path)
      rescue Octokit::Error => e
        log_error e
        return
      end

      begin
        tags = client.tags(repo_path)
      rescue Octokit::Error => e
        log_error e
        return
      end

      if tags.nil? || tags.empty?
        return
      end

      latest_tag_index = tags.find_index { |tag| important_tag? tag.name }
      latest_tag = tags[latest_tag_index]
      begin
        commit = client.commit(repo_path, latest_tag.commit.sha)
      rescue Octokit::Error => e
        log_error e
        return
      end
      latest_tag_date = commit.commit.author.date
      latest_tag = latest_tag.name

      if releases.nil? || releases.empty? || release_over_tag?(latest_tag, latest_tag_date, releases.first)
        latest_release_date = latest_tag_date
        prev_tag = latest_tag_index < tags.size - 1 ? tags[latest_tag_index + 1].name : nil
        latest_release_notes = read_changelog(repo_path, client, latest_tag, prev_tag)
      else
        latest_release = find_latest_release releases

        latest_tag = latest_release.tag_name
        latest_release_notes = latest_release.body
        latest_release_date = latest_release.published_at
      end
      unless latest_tag.eql? repo.latest_tag
        repo.read = false
        repo.latest_tag = latest_tag
        repo.latest_release_date = latest_release_date
        repo.latest_release_notes = latest_release_notes
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

      important_release_notes? release.body.downcase
    end

    def self.important_release_notes?(release_notes)
      if ONLY_BUG_FIXES.any? { |phrase| release_notes.include? phrase }
        return false
      end

      sep = $/.nil? ? "\n" : $/
      if BUG_FIXES.any? { |p| release_notes.match?(/#+ *#{p}\s*#{sep}/) || release_notes.match?(/#{p}:\s*#{sep}/) } &&
        !NEW_FEATURES.any? { |p| release_notes.include? p }
        return false
      end

      true
    end

    def self.important_tag?(tag)
      tag = tag.downcase
      !(tag.include?("preview") || tag.include?("rc") || tag.include?("beta"))
    end

    def self.read_changelog(repo_path, client, latest_tag, prev_tag)
      begin
        changelog_file = client.contents(repo_path)
                               .filter { |file| file.name.match(Regexp.new("changelog.md", Regexp::IGNORECASE)) }
                               .first
      rescue Octokit::Error => e
        log_error e
        return nil
      end

      if changelog_file.nil?
        return nil
      end

      changelog_download_url = changelog_file.download_url
      download = URI.open(changelog_download_url)
      if download.nil?
        return nil
      end

      changelog = download.read
      unless changelog.nil?
        changelog_tag_index = changelog.index(/[\s#]+(#{latest_tag}|#{latest_tag.delete_prefix("v")})/)
        changelod_end_index = prev_tag.nil? ?
                                changelog.length :
                                changelog.index(/[\s#]+(#{prev_tag}|#{prev_tag.delete_prefix("v")})/)
        return changelog[changelog_tag_index..changelod_end_index]
      end

      nil
    end

    def self.find_latest_release(releases)
      first_release = releases.first
      releases.each do |release|
        latest_release = release
        latest_tag = release.tag_name
        if latest_release.nil? ? important_tag?(latest_tag) : important_release?(latest_release)
          return latest_release
        end
      end

      first_release
    end

    def self.release_over_tag?(latest_tag_name, latest_tag_date, latest_release)
      # 1. the release is less than approximately 4 months older than the tag      #
      # 2. the tag and the release are of the same versioning level, e.g. rails 7.0.3 vs 7.0.3.1
      latest_tag_date - latest_release.published_at > 30 * 4 &&
        latest_tag_name.count('.') <= latest_release.tag_name.count('.')
    end
  end
end
