# Reads the application version from the VERSION file at the repository root.
#
# VERSION is the single source of truth and is bumped by commit-and-tag-version
# (see .versionrc.js). Elphame::VERSION is the canonical Ruby constant; the
# value is also exposed as Rails.configuration.x.app_version and surfaced to
# agents through the skill document at /skill.
module Elphame
  VERSION = Rails.root.join("VERSION").read.strip.freeze
end

Rails.application.config.x.app_version = Elphame::VERSION
