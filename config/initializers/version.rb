# Reads the application version from the VERSION file at the repository root.
#
# VERSION is the single source of truth and is bumped by commit-and-tag-version
# (see .versionrc.js). It carries explanatory comments, so the version is read
# as the first bare semver line rather than as the whole file.
#
# Elphame::VERSION is the canonical Ruby constant. The value is also exposed as
# Rails.configuration.x.app_version and surfaced to agents through the skill
# document at /skill.
module Elphame
  VERSION = begin
    contents = Rails.root.join("VERSION").read
    match = contents.match(/^\d+\.\d+\.\d+$/)
    raise "VERSION file at #{Rails.root.join('VERSION')} has no bare semver line" unless match

    match[0].freeze
  end
end

Rails.application.config.x.app_version = Elphame::VERSION
