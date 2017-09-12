module Parsed
  extend ActiveSupport::Concern
  NAME = { 'Pied Piper' => 0, 'Hooli' => 1, 'Stark Ind.' => 2, 'Umbrella' => 3, 'Wayne Ent.' => 4 }

  def message_type(message)
    return :parse_battle unless message['text'].scan(/По итогам битвы/).empty?
    return :parse_stock unless message['text'].scan(/👍Акции всех|👎На рынке/).empty?
    return :parse_totals unless message['text'].scan(/Рейтинг компаний за день/).empty?
    :parse_undefined
  end

  def parse(message, type)
    send(type, message)
  end

  def parse_undefined(message)
    'не могу понять: ' << message['text']
  end

  def parse_totals(_message)
    'не поддерживается рейтинг компаний за день'
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
      battle = company.battles.create(score: scores[i], name: name, percent_score: percent_scores[i], result: results[i], money: monies[i], at: Time.at(message['date']))
      result_str << battle.inspect
    end
    result_str << parse_stock(message)
  end

  private

  def name(message)
    Time.at(message['date']).strftime('%Y-%m-%d-%H')
  end

  def to_int(s)
    s.delete('  ').to_i
  end
end
