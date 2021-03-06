class ProjectDecorator < Draper::Decorator
  decorates :project
  include Draper::LazyHelpers

  def remaining_text
    pluralize_without_number(time_to_go[:time], I18n.t('words.remaining_singular'), I18n.t('words.remaining_plural'))
  end

  def time_to_go
    time_and_unit = nil
    %w(day hour minute second).detect do |unit|
      time_and_unit = time_to_go_for unit
    end
    time_and_unit || time_and_unit_attributes(0, 'second')
  end

  def remaining_days
    source.time_to_go[:time]
  end

  def display_status
    if source.online?
      (source.reached_goal? ? 'reached_goal' : 'not_reached_goal')
    else
      source.state
    end
  end

  # Method for width of progress bars only
  def display_progress
    if source.total_contributions.zero?
      0
    else
      [
        [source.progress, 8].max,
        100
      ].min
    end
  end

  def display_image(version = 'project_thumb' )
    use_uploaded_image(version) || use_video_tumbnail(version)
  end

  def display_address_formated
    text = ""
    if source.address_city || source.address_state
      text += "#{source.address_neighborhood} // " unless source.address_neighborhood.blank?
      text += source.address_city unless source.address_city.blank?
      text += "#{source.address_city.present? ? ', ' : ''}#{source.address_state}" unless source.address_state.blank?
    end
    text
  end

  def display_video_embed_url
    if source.video_embed_url
      "//#{source.video_embed_url}?title=0&byline=0&portrait=0&autoplay=0&color=ffffff&badge=0&modestbranding=1&showinfo=0&border=0&controls=2".gsub('http://', '')
    end
  end

  def display_expires_at
    source.expires_at ? I18n.l(source.expires_at.to_date) : ''
  end

  def display_pledged
    number_to_currency source.pledged, precision: 0
  end

  def display_goal
    number_to_currency source.goal, precision: 0
  end

  def progress_bar
    classes = if display_progress == 100
      %i(green-bar progress round)
    else
      %i(progress round)
    end
    content_tag :div, class: classes do
      content_tag :span, nil, class: :meter, style: "width: #{display_progress}%"
    end
  end


  def successful_flag
    return unless source.successful?

    content_tag(:div, class: [:successful_flag]) do
      image_tag("successful.#{I18n.locale}.png")
    end

  end

  def display_organization_type
    I18n.t("project.organization_type.#{source.organization_type}")
  end

  private

  def use_uploaded_image(version)
    source.uploaded_image.send(version).url
  end

  def use_video_tumbnail(version)
    source.video_thumbnail.send(version).url ||
      'image-placeholder-upload-in-progress.jpg'
  end

  def time_to_go_for(unit)
    time = 1.send(unit)

    if source.expires_at.to_i >= time.from_now.to_i
      time = ((source.expires_at - Time.zone.now).abs / time).round
      time_and_unit_attributes time, unit
    end
  end

  def time_and_unit_attributes(time, unit)
    { time: time, unit: pluralize_without_number(time, I18n.t("datetime.prompts.#{unit}").downcase) }
  end
end

