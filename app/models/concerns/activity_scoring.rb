module ActivityScoring
  extend ActiveSupport::Concern

  # Named constants for the activity score formula.
  # Adjust these to tune thread ranking behavior.
  SCORE_PIN_WEIGHT      = 10_000   # Pinned threads always float to top
  SCORE_STAR_WEIGHT     = 2        # Points per total_stars
  SCORE_REPLY_WEIGHT    = 5        # Points per reply
  SCORE_DECAY_PER_HOUR  = 0.5      # Points lost per hour of inactivity

  included do
    # Smart sorting scope using the weighted formula.
    # Computes: PIN + label_weights + (stars * 2) + (replies * 5) + boost - (hours * 0.5) DESC
    scope :by_activity_score, -> {
      left_joins(thread_labels: :label)
        .select(
          "discussions.*",
          "COALESCE(SUM(DISTINCT labels.sort_weight), 0) as label_score",
          "((julianday('now') - julianday(discussions.last_activity_at)) * 24) as hours_since_activity"
        )
        .group("discussions.id")
        .order(Arel.sql(<<~SQL.squish))
          CASE WHEN discussions.pinned THEN #{SCORE_PIN_WEIGHT} ELSE 0 END +
          COALESCE(label_score, 0) +
          (discussions.total_stars * #{SCORE_STAR_WEIGHT}) +
          (discussions.reply_count_cache * #{SCORE_REPLY_WEIGHT}) +
          discussions.manual_boost_score -
          (hours_since_activity * #{SCORE_DECAY_PER_HOUR})
          DESC
        SQL
    }
  end

  def activity_score
    label_weight = labels.sum(:sort_weight)
    hours = last_activity_at ? ((Time.current - last_activity_at) / 1.hour) : 0

    score = 0.0
    score += SCORE_PIN_WEIGHT if pinned?
    score += label_weight
    score += total_stars.to_f * SCORE_STAR_WEIGHT
    score += reply_count_cache.to_i * SCORE_REPLY_WEIGHT
    score += manual_boost_score.to_i
    score -= hours * SCORE_DECAY_PER_HOUR
    score
  end
end
