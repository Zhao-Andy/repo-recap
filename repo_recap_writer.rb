require "pry"
require "octokit"
require "./environment"
require "./special_usernames"

year = 2019
start_month = 4
start_day = 27
end_month = 5
end_day = 3

# start_of_week = Time.new(2019, 01, 20, 0, 0, 0, 0).utc
# end_of_week = Time.new(2019, end_month, end_day, 11, 59, 59, 0).utc

class RepoRecap
  include SpecialUsernames
  attr_accessor :client, :year, :start_month, :end_month, :start_day, :end_day, :start_of_week, :end_of_week

  def initialize(options)
    @client = Octokit::Client.new(access_token: ENV["GITHUB_ACCESS_TOKEN"])
    @client.auto_paginate = true
    year = 2019
    start_month = options[:start_month]
    end_month = options[:end_month]
    start_day = options[:start_day]
    end_day = options[:end_day]
    @start_of_week = Time.new(year, start_month, start_day, 0, 0, 0, 0).utc
    @end_of_week = Time.new(year, end_month, end_day, 23, 59, 59, 0).utc
    @pull_requests = get_past_weeks_merged_pull_requests
    @ios_prs = get_past_weeks_ios_prs
    @android_prs = get_past_weeks_android_prs
    @issues = get_past_weeks_open_issues
    @issues = get_past_weeks_open_issues
    @ios_issues = get_ios_open_issues
    @android_issues = get_android_open_issues
    @repository_link = ENV["REPOSITORY_LINK"]
  end

  def get_past_weeks_merged_pull_requests
    dependency_label_id = 1034632663
    # this takes a while because it loads all closed PRs
    @client.pull_requests(@repository_link, state: "closed").select do |pr|
      pr.merged_at&.between?(@start_of_week, @end_of_week) && !pr.labels.map(&:id).include?(dependency_label_id)
    end.sort_by { |pr| pr.merged_at }
  end

  def get_past_weeks_ios_prs
    dependency_label_id = 1034632663
    # this takes a while because it loads all closed PRs
    @client.pull_requests("thepracticaldev/dev-ios", state: "closed").select do |pr|
      pr.merged_at&.between?(@start_of_week, @end_of_week) && !pr.labels.map(&:id).include?(dependency_label_id)
    end.sort_by { |pr| pr.merged_at }
  end
 
  def get_past_weeks_android_prs
    dependency_label_id = 1034632663
    # this takes a while because it loads all closed PRs
    @client.pull_requests("thepracticaldev/dev-android", state: "closed").select do |pr|
      pr.merged_at&.between?(@start_of_week, @end_of_week) && !pr.labels.map(&:id).include?(dependency_label_id)
    end.sort_by { |pr| pr.merged_at }
  end

  def get_past_weeks_open_issues
    @client.issues(@repository_link, state: "open").select do |issue|
      issue[:pull_request].nil? && issue.created_at.between?(@start_of_week, @end_of_week)
    end.sort_by {|issue| issue.created_at }
  end

  def get_ios_open_issues
    @client.issues("thepracticaldev/dev-ios", state: "open").select do |issue|
      issue[:pull_request].nil? && issue.created_at.between?(@start_of_week, @end_of_week)
    end.sort_by {|issue| issue.created_at }
  end

  def get_android_open_issues
    @client.issues("thepracticaldev/dev-android", state: "open").select do |issue|
      issue[:pull_request].nil? && issue.created_at.between?(@start_of_week, @end_of_week)
    end.sort_by {|issue| issue.created_at }
  end

  def front_matter_markdown
    <<~HEREDOC
      ---
      title: #{ENV["COMPANY_NAME"]} Repo Recap from the Past Week
      published: false
      description: "A weekly post recapping what's happened in the #{ENV["COMPANY_NAME"]} repo."
      cover_image: #{ENV["COVER_IMAGE_URL"]}
      tags: #{ENV["TAGS"]}
      ---

    HEREDOC
  end

  def final_markdown
    formatted_start_day = start_of_week.strftime("%B %e")
    formatted_end_day = end_of_week.strftime("%B %e")

    <<~HEREDOC
      #{front_matter_markdown}

      Welcome back to another Repo Recap, where we cover last week's contributions to [#{ENV["COMPANY_NAME"]}'s repository](#{ENV["REPO_LINK"]}) [the iOS repo](https://github.com/thepracticaldev/dev-ios), and [the Android repo](https://github.com/thepracticaldev/dev-android). This edition is covering #{formatted_start_day} to #{formatted_end_day}.

      # Main Repo
      ## Features

      #{feature_markdown}
      ## Bug Fixes / Other Contributions

      #{other_contributions_markdown}
      ## New Issues and Discussions

      #{issue_markdown}

      # DEV-iOS
      ## Features

      #{ios_feature_markdown}
      ## Bug Fixes / Other Contributions
      
      #{ios_other_contributions_markdown}

      ## New Issues and Discussions

      #{ios_issue_markdown}

      # DEV-Android
      ## Features

      #{android_feature_markdown}

      ## Bug Fixes / Other Contributions

      #{android_other_contributions_markdown}

      ## New Issues and Discussions

      #{android_issue_markdown}
    HEREDOC
  end

  def feature_markdown
    prs = @pull_requests.map do |pr|
      if pr.body.include?("[x] Feature")
        <<~HEREDOC
          - [@#{pr.user.login.downcase}](https://dev.to/#{pr.user.login.downcase}) #{pr.title}

            {% github #{pr.html_url} %}

        HEREDOC
      else
        next
      end
    end.compact.join
    replace_special_usernames!(prs)
  end

  def ios_feature_markdown
    prs = @ios_prs.map do |pr|
      if pr.body.include?("[x] Feature")
        <<~HEREDOC
          - [@#{pr.user.login.downcase}](https://dev.to/#{pr.user.login.downcase}) #{pr.title}

            {% github #{pr.html_url} %}

        HEREDOC
      else
        next
      end
    end.compact.join
    replace_special_usernames!(prs)
  end

  def android_feature_markdown
    prs = @android_prs.map do |pr|
      if pr.body.include?("[x] Feature")
        <<~HEREDOC
          - [@#{pr.user.login.downcase}](https://dev.to/#{pr.user.login.downcase}) #{pr.title}

            {% github #{pr.html_url} %}

        HEREDOC
      else
        next
      end
    end.compact.join
    replace_special_usernames!(prs)
  end

  def ios_other_contributions_markdown
    prs = @ios_prs.map do |pr|
      unless pr.body.include?("[x] Feature")
        <<~HEREDOC
          - [@#{pr.user.login.downcase}](https://dev.to/#{pr.user.login.downcase}) #{pr.title}

            {% github #{pr.html_url} %}

        HEREDOC
      else
        next
      end
    end.compact.join
    replace_special_usernames!(prs)
  end

  def android_other_contributions_markdown
    prs = @android_prs.map do |pr|
      unless pr.body.include?("[x] Feature")
        <<~HEREDOC
          - [@#{pr.user.login.downcase}](https://dev.to/#{pr.user.login.downcase}) #{pr.title}

            {% github #{pr.html_url} %}

        HEREDOC
      else
        next
      end
    end.compact.join
    replace_special_usernames!(prs)
  end

  def other_contributions_markdown
    prs = @pull_requests.map do |pr|
      unless pr.body.include?("[x] Feature")
        <<~HEREDOC
          - [@#{pr.user.login.downcase}](https://dev.to/#{pr.user.login.downcase}) #{pr.title}

            {% github #{pr.html_url} %}

        HEREDOC
      else
        next
      end
    end.compact.join
    replace_special_usernames!(prs)
  end

  def issue_markdown
    issues = @issues.map do |issue|
      <<~HEREDOC
        - [@#{issue.user.login.downcase}](https://dev.to/#{issue.user.login.downcase}) #{issue.title}

          {% github #{issue.html_url} %}

      HEREDOC
    end.compact.join
    replace_special_usernames!(issues)
  end

  def ios_issue_markdown
    issues = @ios_issues.map do |issue|
      <<~HEREDOC
        - [@#{issue.user.login.downcase}](https://dev.to/#{issue.user.login.downcase}) #{issue.title}

          {% github #{issue.html_url} %}

      HEREDOC
    end.compact.join
    replace_special_usernames!(issues)
  end

  def android_issue_markdown
    issues = @android_issues.map do |issue|
      <<~HEREDOC
        - [@#{issue.user.login.downcase}](https://dev.to/#{issue.user.login.downcase}) #{issue.title}

          {% github #{issue.html_url} %}

      HEREDOC
    end.compact.join
    replace_special_usernames!(issues)
  end

  def replace_special_usernames!(markdown)
    special_usernames = SpecialUsernames.get
    special_usernames.each do |username_hash|
      markdown.gsub!("#{username_hash[:github_username]}", username_hash[:devto_username])
    end
    markdown
  end

  def thank_you_comment
    "Thank you for your contributions #{final_markdown.scan(/\@.*\]\(/i).map { |username| username.gsub(/\]\(/,'') }.uniq.join(", ")}!"
  end
end

g = RepoRecap.new(year: year, start_month: start_month, start_day: start_day, end_month: end_month, end_day: end_day)

fm = g.final_markdown
tyc = g.thank_you_comment
puts fm
puts "----------------"
puts tyc
