class TelegramViewController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Grapher
  context_to_action!

  DURATION = { 'День' => :day, 'Неделя' => :week, 'Все' => :all }.freeze
  TYPE = {
    'Акции' => :generate_stoks_line,
    'Деньги' => :generate_moneys_area,
    'Рейтинг' => :generate_points_line,
    'Очки%' => :generate_percent_points_bar,
    'Очки' => :generate_points_bar
  }.freeze

  def start(*)
    respond_with :message, text: 'View'
    save_context :type
    type_keyboard
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def type_keyboard
    respond_with :message, text: 'Выберите тип', reply_markup: {
      keyboard: [TYPE.keys],
      resize_keyboard: true,
      selective: true
    }
  end

  def duration_keyboard
    respond_with :message, text: 'Выберите период', reply_markup: {
      keyboard: [DURATION.keys],
      resize_keyboard: true,
      selective: true
    }
  end

  def type(value = nil, *)
    if TYPE.keys.include?(value)
      session[:memo] = value
      save_context :duration
      duration_keyboard
    else
      save_context :type
      type_keyboard
    end
  end

  def duration(value = nil, *)
    if DURATION.keys.include?(value)
      generate_graph(TYPE[session[:memo]], DURATION[value])
      save_context :type
      respond_with :photo, photo: File.open('public/line_xy.png'), reply_markup: {
        keyboard: [TYPE.keys],
        resize_keyboard: true,
        selective: true
      }
    else
      save_context :duration
      duration_keyboard
    end
  end

  def message(_message)
    save_context :type
    type_keyboard
  end
end
