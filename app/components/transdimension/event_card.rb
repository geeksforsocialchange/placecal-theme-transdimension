# frozen_string_literal: true

# One event in the homepage listing, ported from viewEvent in
# src/Theme/Page/Events.elm: a row-reverse flex with the big day number and
# uppercase month on the right and the title, times, postcode and organiser on
# the left. The whole card is one link.
#
# Core's Components::Event renders a different card (icons, neighbourhood badge,
# no date block) and the homepage is extension-owned, so this is the theme's own.
class Transdimension::Components::EventCard < Components::Base
  prop :event, _Interface(:summary, :dtstart), reader: :private

  def view_template
    li(class: 'td-events__item') do
      link_to event_path(event.id), class: 'with-no-sass td-event__link' do
        article(class: 'td-event') do
          render_description
          render_date
        end
      end
    end
  end

  private

  def render_description
    div(class: 'td-event__description') do
      h4(class: 'td-event__title') { event.summary }
      div do
        render_times
        p(class: 'td-event__paragraph') { postcode } if postcode.present?
        p(class: 'td-event__paragraph') { t('transdimension.home.event_by', name: organiser_name) } if organiser_name.present?
      end
    end
  end

  def render_times
    p(class: 'td-event__paragraph') do
      time(datetime: event.dtstart.iso8601) { fmt_time(event.dtstart) }
      if event.dtend
        # Kept verbatim from the Elm site, which separates the two times with a
        # spaced em dash.
        span { ' — ' }
        time(datetime: event.dtend.iso8601) { fmt_time(event.dtend) }
      end
    end
  end

  def render_date
    div do
      time(class: 'td-event__date', datetime: event.dtstart.to_date.iso8601) do
        span(class: 'td-event__day') { event.dtstart.strftime('%d') }
        span(class: 'td-event__month') { event.dtstart.strftime('%b') }
      end
    end
  end

  def postcode
    @postcode ||= event.address&.postcode.presence || event.place&.address&.postcode
  end

  def organiser_name
    @organiser_name ||= event.organiser&.name
  end

  # Elm's TransDate.humanTimeFromPosix: "11:00pm", "10:30am".
  def fmt_time(value)
    value.strftime('%l:%M%P').strip
  end
end
