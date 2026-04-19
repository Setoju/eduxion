class AddLagThresholdToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :lag_threshold, :integer, null: false, default: 20
    add_check_constraint :courses, "lag_threshold BETWEEN 5 AND 50",
                         name: "courses_lag_threshold_range"
  end
end
