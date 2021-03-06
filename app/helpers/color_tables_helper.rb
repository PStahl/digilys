module ColorTablesHelper
  def group_hierarchy_options(color_table)
    Rails.cache.fetch(controller.fragment_cache_key([color_table, "group-hierarchy"])) do
      color_table.group_hierarchy.collect { |g| [[g.name, g.parent.try(:name)].compact.join(", "), g.id]}
    end
  end

  def color_table_columns(student_data, evaluations)
    columns = [
      {
        id:       "student-name",
        name:     Student.human_attribute_name(:name),
        field:    "name",
        type:     "student-name",
        cssClass: "student-name"
      }.to_json
    ]
    columns += student_data_columns(student_data) || []
    columns += evaluation_columns(evaluations) || []
    columns.join(",")
  end

  def student_data_columns(student_data)
    return nil if student_data.blank?

    student_data.collect do |key|
      {
        id:    "student-data-#{key.parameterize}",
        name:  key,
        field: "student_data_#{key.parameterize("_")}",
        type:  "student-data"
      }.to_json
    end
  end

  def evaluation_columns(evaluations)
    return nil if evaluations.blank?

    evaluations.collect do |evaluation|
      {
        id:        "evaluation-#{evaluation.id}",
        name:      evaluation.name,
        field:     "evaluation_#{evaluation.id}",
        type:      "evaluation",
        date:      evaluation.date.to_s,
        title:     evaluation_info(evaluation),
        maxResult: evaluation.max_result.to_f,
        stanines:  evaluation.stanines?
      }.to_json
    end
  end

  def result_rows(students, student_data, evaluations)
    return [] if students.blank?

    values = {}

    rows = students.collect do |student|
      s = {
        id:     student.id,
        name:   student.name,
        groups: student.group_ids
      }

      student_data.each do |key|
        s["student_data_#{key.parameterize("_")}"] = student.data_humanized[key]
      end

      evaluations.each do |evaluation|
        result = if evaluation.series_id
                   evaluation.series.result_for(student)
                 else
                   evaluation.result_for(student)
                 end

        next unless result

        if result.value
          values[evaluation.id] ||= []
          values[evaluation.id] << result.value
        end

        s["evaluation_#{evaluation.id}"] = {
          display:  result.display_value,
          value:    result.value,
          stanine:  result.stanine,
          cssClass: result.color
        }
      end

      s.to_json
    end

    averages = {
      id: 0,
      name: t(:"color_tables.show.averages"),
    }

    values.each do |evaluation_id, values|
      averages["evaluation_#{evaluation_id}"] = values.instance_eval { reduce(:+).to_f / size }.round(2)
    end

    rows << averages.to_json

    return rows
  end
end
