module EvaluationsHelper

  def working_with_evaluation_template?(evaluation)
    return params?(controller: "template/evaluations") ||
      params?(controller: "evaluations") && evaluation && evaluation.type.template?
  end
  def working_with_generic_evaluation?(evaluation)
    return params?(controller: "generic/evaluations") ||
      params?(controller: "evaluations") && evaluation && evaluation.type.generic?
  end

  # Returns an URL to where the cancel button of an evaluation form should go,
  # which is different depending on its type and whether it's a new record or not
  def evaluation_cancel_path(evaluation)
    return nil unless evaluation && evaluation.type

    if evaluation.type.suite?
      return suite_path(evaluation.suite)
    elsif !evaluation.new_record?
      return evaluation_path(evaluation)
    elsif evaluation.type.template?
      return template_evaluations_path()
    elsif evaluation.type.generic?
      return generic_evaluations_path()
    end
  end

  # Renders a bootstrap progress bar representing the result distribution 
  # of this evaluation, if any
  def evaluation_progress_bar(evaluation)
    result_distribution = evaluation.result_distribution

    bars = []

    if !result_distribution.blank?
      bars << content_tag(:div, "", class:"bar bar-success", style: "width: #{result_distribution[:green].round(1)}%")
      bars << content_tag(:div, "", class:"bar bar-yellow",  style: "width: #{result_distribution[:yellow].round(1)}%")
      bars << content_tag(:div, "", class:"bar bar-danger",  style: "width: #{result_distribution[:red].round(1)}%")
    end

    bar_container = content_tag(:div, bars.join("").html_safe, class: "progress")
  end
end
