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

  def release_notes_new_features
    if latest_release_notes.nil?
      return ""
    end
    release_notes = latest_release_notes.downcase
    release_notes_from_header = release_notes_features_header release_notes
    unless release_notes_from_header.nil?
      return release_notes_from_header
    end

    # if no markdown header was found, attempt to find a line with a colon
    # and take everything until an empty line is found

    release_notes_from_new_line = release_notes_new_line release_notes
    unless release_notes_from_new_line.nil?
      return release_notes_from_new_line
    end

    latest_release_notes
  end

  private
  def release_notes_features_header(release_notes)
    features_indices = Services::Monitoring::NEW_FEATURES.map { |p| release_notes.index p }.filter{ |p| !p.nil? }.sort
    if features_indices.empty?
      return nil
    end

    # attempt to find a 'features' header in the markdown content
    # and take everything until the next header of the same level
    features_indices.each do |i|
      prefix = release_notes[0...i]
      suffix = release_notes[i..]
      if prefix.nil? || suffix.nil?
        next
      end
      if prefix.rstrip.ends_with? '#'
        header_level = prefix.match('#+\s*$')[0]
        unless header_level.nil?
          next_header_index = suffix.index header_level.rstrip
          return latest_release_notes[(i - header_level.length)..(i - header_level.length + next_header_index)]
        end
      end
    end

    nil
  end

  def release_notes_new_line(release_notes)
    features_indices = Services::Monitoring::NEW_FEATURES
                         .filter { |p| release_notes.include? p }
                         .map { |p| [release_notes.index(p), p.length] }
                         .sort
    if features_indices.empty?
      return nil
    end

    # attempt to find a 'features' header in the markdown content
    # and take everything until the next header of the same level
    features_indices.each do |p|
      i = p[0]
      len = p[1]
      prefix = release_notes[0...(i + len)]
      suffix = release_notes[(i + len)..]
      if prefix.nil? || suffix.nil?
        next
      end
      if prefix.lstrip.ends_with? ':'
        next_empty_line_index = release_notes.index($\ + $\)
        return next_empty_line_index.nil? ? latest_release_notes[i..] : latest_release_notes[i..next_empty_line_index]
      end
    end

    nil
  end
end
