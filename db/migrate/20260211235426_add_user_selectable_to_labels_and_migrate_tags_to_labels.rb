class AddUserSelectableToLabelsAndMigrateTagsToLabels < ActiveRecord::Migration[8.1]
  def up
    # Add user_selectable flag to labels
    add_column :labels, :user_selectable, :boolean, default: false, null: false

    # Mark existing "category" labels as user-selectable
    execute <<~SQL
      UPDATE labels SET user_selectable = 1 WHERE category = 'type' OR category = 'category'
    SQL

    # Create new labels from Discussion::TAGS that don't already exist as labels.
    # These map old tag values to new user-selectable labels with category "type".
    tag_labels = {
      "general" => { emoji: "💬", position: 0 },
      "research" => { emoji: "🔬", position: 1 },
      "decision" => { emoji: "⚖️", position: 2 },
      "archive" => { emoji: "📦", position: 3 },
      "meta" => { emoji: "🔧", position: 4 },
      "technical" => { emoji: "⚙️", position: 5 },
      "philosophical" => { emoji: "🤔", position: 6 },
      "feedback" => { emoji: "📣", position: 7 },
      "showcase" => { emoji: "🎨", position: 8 },
      "help" => { emoji: "🆘", position: 9 },
      "discussion" => { emoji: "💭", position: 10 },
      "project" => { emoji: "📋", position: 11 }
      # "question", "idea", "announcement" already exist as labels in "category" group
    }

    tag_labels.each do |name, config|
      execute <<~SQL
        INSERT OR IGNORE INTO labels (name, category, emoji, sort_weight, position, active, user_selectable, created_at, updated_at)
        VALUES ('#{name}', 'type', '#{config[:emoji]}', 0, #{config[:position]}, 1, 1, datetime('now'), datetime('now'))
      SQL
    end

    # Update existing category labels to have category "type" and user_selectable = true
    execute <<~SQL
      UPDATE labels SET category = 'type', user_selectable = 1 WHERE category = 'category'
    SQL

    # Migrate existing discussion tags to thread_labels.
    # For each discussion with a tag, create a thread_label linking it to the corresponding label.
    execute <<~SQL
      INSERT OR IGNORE INTO thread_labels (discussion_id, label_id, applied_at, created_at, updated_at)
      SELECT d.id, l.id, d.created_at, datetime('now'), datetime('now')
      FROM discussions d
      JOIN labels l ON l.name = d.tag AND l.category = 'type'
      WHERE d.tag IS NOT NULL AND d.tag != ''
    SQL

    # Remove the tag column from discussions
    remove_column :discussions, :tag
  end

  def down
    add_column :discussions, :tag, :string, default: "general"

    # Restore tag values from thread_labels
    execute <<~SQL
      UPDATE discussions SET tag = (
        SELECT l.name FROM thread_labels tl
        JOIN labels l ON l.id = tl.label_id
        WHERE tl.discussion_id = discussions.id AND l.category = 'type'
        LIMIT 1
      )
    SQL

    # Remove migrated type labels (only the ones we created, not pre-existing "category" ones)
    execute <<~SQL
      DELETE FROM labels WHERE category = 'type' AND name IN ('general', 'research', 'decision', 'archive', 'meta', 'technical', 'philosophical', 'feedback', 'showcase', 'help', 'discussion', 'project')
    SQL

    # Restore "category" group for existing labels
    execute <<~SQL
      UPDATE labels SET category = 'category' WHERE name IN ('bug', 'idea', 'question', 'docs', 'announcement')
    SQL

    remove_column :labels, :user_selectable
  end
end
