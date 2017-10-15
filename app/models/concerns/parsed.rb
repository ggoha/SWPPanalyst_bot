module Parsed
  extend ActiveSupport::Concern
  include SwParsed

  NAME = { 'Pied Piper' => 0, 'Hooli' => 1, 'Stark Ind.' => 2, 'Umbrella' => 3, 'Wayne Ent.' => 4 }.freeze

  def message_type(message)
    return :parse_invite if message['new_chat_member'].present?
    return :parse_undefined unless message['text']
    return :parse_battle unless message['text'].scan(/По итогам битвы/).empty?
    return :parse_stock unless message['text'].scan(/👍Акции всех|👎На рынке/).empty?
    return :parse_totals unless message['text'].scan(/Рейтинг компаний за день/).empty?
    if from_startup_wars?(message)
      return :parse_report if message['text'].include?('Твои результаты в битве')
      return :parse_full_profile if message['text'].include?('До следующей Битвы')
      return :parse_compact_profile if message['text'].include?('Полный профиль')
      return :parse_endurance if message['text'].include?('🔋Выносливость:')
    end
    return :parse_bag if message['text'].include?('#SWОтделыБаг')
    return :parse_feature if message['text'].include?('#SWОтделыИдея')
    :parse_undefined
  end

  def parse(message, type)
    send(type, message)
  end

  def parse_undefined(message)
    message['text']
  end

  def parse_totals(message)
    text = message['text']
    result_str = ''
    scores = {}
    text.scan(/(🎩|🤖|⚡️|☂️|📯)(.+)🏆/).each do |substr|
      name, score = substr[1].split('-')
      scores[NAME[name.strip]] = to_int(score)
    end
    Company.all.each_with_index do |company, i|
      result_str << "#{company.title}: #{scores[i]} - #{company.score}\n"
    end
    result_str
  end

  def parse_feature(message)
    me = Rails.application.secrets['telegram']['me']
    bot.forward_message message_id: message['message_id'], from_chat_id: message['chat']['id'], chat_id: me
    respond_with :message, text: t('.parse_feature.content')
  end

  def parse_bag(message)
    me = Rails.application.secrets['telegram']['me']
    bot.forward_message message_id: message['message_id'], from_chat_id: message['chat']['id'], chat_id: me
    respond_with :message, text: t('.parse_bag.content')
  end

  def parse_invite(message)
    return unless message['new_chat_member']['id'] == Rails.application.secrets['telegram']['bots']['division']['id']
    user = User.find_by_telegram_id(message['from']['id'])
    unless user
      respond_with :message, text: 'Отдел не созданн, для создания отдела вам предварительно надо отправить профиль боту в личку'
      return
    end
    result_str = ''
    division = Division.find_or_create(message, user)
    result_str << division.inspect
    result_str
  end

  def parse_battle(message)
    text = message['text']
    result_str = ''
    monies, scores, results = [], [], []
    # Деньги
    text.scan(/(отобрали|утащили|собой)(.+)/).each do |substr|
      if substr[0] == 'собой'
        results << false
        monies << 0
        next
      end
      results << (substr[0] == 'отобрали')
      monies << ((substr[0] == 'утащили') ? -to_int(substr[1]) : to_int(substr[1]))
    end
    # Очки
    text.scan(/(🎩|🤖|⚡️|☂️|📯)(.+)🏆/).each do |substr|
      name, score = substr[1].split('+')
      scores[NAME[name.strip]] = to_int(score)
    end
    # Проценты
    full_scores = scores.inject(0, :+)
    percent_scores = scores.map { |score| score.to_f / full_scores * 100 }
    # Условное название
    name = name(message)
    Company.all.each_with_index do |company, i|
      battle = company.battles.create(raw: message['text'], score: scores[i], name: name, percent_score: percent_scores[i], result: results[i], money: monies[i], at: Time.at(message['date']))
      result_str << battle.inspect
    end
    result_str << parse_stock(message)
  end

  def parse_stock(message)
    text = message['text']
    result_str = ''
    prices = text.scan(/(\d+) 💵(\n\n|.)/).map { |price| price[0].split(' ')[0] }
    name = name(message)
    Company.all.each_with_index do |company, i|
      stock = company.stocks.create(price: prices[i], name: name, at: Time.at(message['date']))
      result_str << stock.inspect
    end
    result_str
  end

  private

  def name(message)
    # TODO: FIX ПЕРЕВЕСТИ В МСК
    (Time.at(message['date']) + 3.hours).strftime('%Y-%m-%d-%H')
  end

  def from_startup_wars?(message)
    message['forward_from'] &&
      (message['forward_from']['id'] == Rails.application.secrets['telegram']['SW'] ||
      message['forward_from']['id'] == Rails.application.secrets['telegram']['SW1'])
  end
end
