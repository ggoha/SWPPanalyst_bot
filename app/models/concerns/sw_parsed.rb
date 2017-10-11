module SwParsed
  extend ActiveSupport::Concern
  COUNT = { 'никого' => 0, 'одного' => 1, 'двух' => 2, 'трёх' => 3, 'четырёх' => 4 }.freeze
  NAME = { 'Pied Piper' => 0, 'Hooli' => 1, 'Stark Ind.' => 2, 'Umbrella' => 3, 'Wayne Ent.' => 4 }.freeze
  NAME_SMILE = { '📯Pied Piper' => 1, '🤖Hooli' => 2, '⚡️Stark Ind.' => 3, '☂️Umbrella' => 4, '🎩Wayne Ent.' => 5 }.freeze

  def endurances(message)
    message['text'].scan(/🔋Осталось выносливости: (\d+)%/)[0] ? (message['text'].scan(/🔋Осталось выносливости: (\d+)%/)[0][0]).to_i : 0
  end

  def kill(message)
    COUNT[message['text'].scan(/(Тебе не удалось|Ты вынес|Ты выпилил сразу|Тебе удалось выбить сразу|Ты уронил аж) ([а-яё]+)/)[0][1]]
  end

  def star(message)
    (message['text'].scan(/(.+)\/cool/)[0][0].length - 1) / 2
  end

  def star1(message)
    (message['text'].scan(/Крутизна: (.+)\/cool/)[0][0].length - 1) / 2
  end

  def money(message)
    message['text'].scan(/Деньги: (.+)\n/)[0] ? message['text'].scan(/Деньги: (.+)\n/)[0][0].delete('$').to_i : 0
  end

  def score(message)
    message['text'].scan(/Твой вклад: (.+)\n/)[0] ? message['text'].scan(/Твой вклад: (.+)\n/)[0][0].to_i : 0
  end

  def levels(message)
    return (message['text'].scan(/🎚(\d+) \(/)[0][0]).to_i if message['text'].scan(/🎚(\d+) \(/)[0]
    return (message['text'].scan(/Уровень: (\d+)/)[0][0]).to_i if message['text'].scan(/Уровень: (\d+)/)[0]
  end

  def enemies(message)
    message['text'].scan(/(.+)🔨/)
  end

  def parse_report(message)
    text = message['text']
    result_str = ''

    user = User.find_or_create(message)
    username = text.scan(/(🎩|🤖|⚡️|☂️|📯)(.+) \(/)[0][1]
    if !user || (user && username != user.game_name)
      return ['Репорт не обработан, пользователь не совпадает', 'Репорт не обработан, пользователь не совпадает']
    end
    user.division.update_attributes(company_id: user.company_id) if user.division.company_id.blank?
    battle_name = battle_date(message)
    battle_name2 = yesterdays_battle_date(message)
    battle_id = (user.company.battles.find_by_name(battle_name) || user.company.battles.find_by_name(battle_name2)).id
    if text.scan(/(Ты защищал|Ты взламывал) (.+)/).empty?
      return ['Репорт не обработан, необходимо добавить компанию, которую ты вламывал', 'Репорт не обработан, необходимо добавить компанию, которую ты вламывал']
    end
    broked_company_id = NAME_SMILE[text.scan(/(Ты защищал|Ты взламывал) (.+)/)[0][1]]
    kill = kill(message)
    money = money(message)
    score = score(message)
    endurance = endurances(message)
    buff = buff(message, user)
    report =  user.reports.create(battle_id: battle_id, broked_company_id: broked_company_id, kill: kill, money: money, score: score, buff: buff)
    user.update_endurance(endurance)
    result_str << report.inspect
    [result_str, 'Репорт обработан']
  end

  def parse_full_profile(message)
    text = message['text']
    result_str = ''
    
    user = User.find_or_create(message)
    params = {}
    params[:game_name] = message['text'].scan(/\n\n💰?(.*) \(/)[0][0]
    params[:practice] = message['text'].scan(/Практика:.+\((\d+)\)/)[0][0]
    params[:theory] = message['text'].scan(/Теория:.+\((\d+)\)/)[0][0]
    params[:cunning] = message['text'].scan(/Хитрость:.+\((\d+)\)/)[0][0]
    params[:wisdom] = message['text'].scan(/Мудрость:.+\((\d+)\)/)[0][0]
    params[:stars] = star1(message)
    params[:level] = message['text'].scan(/Уровень: (\d+)/)[0][0]
    params[:experience] = to_int(message['text'].scan(/Опыт: (.+) из/)[0][0])
    endurance = endurances(message)
    user.update_profile(params)
    user.update_endurance(endurance)
    result_str << user.inspect
    [result_str, 'Профиль обработан']
  end

  def parse_compact_profile(message)
    text = message['text']
    result_str = ''
    
    user = User.find_or_create(message)
    params = {}
    params[:game_name] = message['text'].scan(/\n\n💰?(.*) \(/)[0][0]
    params[:practice] = to_int(message['text'].scan(/🔨(.+)🎓/)[0][0])
    params[:theory] = to_int(message['text'].scan(/🎓(.+)/)[0][0])
    params[:cunning] = to_int(message['text'].scan(/🐿(.+)🐢/)[0][0])
    params[:wisdom] = to_int(message['text'].scan(/🐢(.+)/)[0][0])
    params[:stars] = star(message)
    params[:level] = message['text'].scan(/🎚(\d+) \(/)[0][0]
    params[:experience] = to_int(message['text'].scan(/\((.+) из/)[0][0])
    endurance = message['text'].scan(/🔋(\d+)%/)[0] ? message['text'].scan(/🔋(\d+)%/)[0][0] : 0
    user.update_profile(params)
    user.update_endurance(endurance)
    result_str << user.inspect
    [result_str, 'Профиль обработан']
  end

  def parse_endurance(message)
    text = message['text']
    result_str = ''

    user = User.find_or_create(message)
    endurance = message['text'].scan(/🔋Выносливость: (\d+)%/)[0][0]
    user.update_endurance(endurance)
    result_str << user.inspect
    [result_str, 'Сообщение о еде обработано']
  end

  private

  def practice_buff(practice, user)
    (practice.to_f / user.practice - 1) * 100 / (0.6 * (1 + user.rage * 0.2))
  end

  def theory_buff(theory, user)
    (theory.to_f / user.theory - 1) * 100 / (1.6 * (1 + user.rage * 0.2))
  end

  def buff(message, user)
    return nil unless message['text'].include?('🔨')
    return nil unless user.theory && user.practice
    current_practice = to_int(message['text'].scan(/🔨(.+)🎓/)[0][0])
    current_theory = to_int(message['text'].scan(/🎓(.+)🐿/)[0][0])
    message['text'].include?('Ты защищал') ? theory_buff(current_theory, user) : practice_buff(current_practice, user)
  end

  def battle_date(message)
    Time.at(message['forward_date']).strftime('%Y-%m-%d-') + message['text'].scan(/на (\d+) часов/)[0][0]
  end

  def yesterdays_battle_date(message)
    (Time.at(message['forward_date']) - 1.day).strftime('%Y-%m-%d-') + message['text'].scan(/на (\d+) часов/)[0][0]
  end

  def to_int(s)
    s.delete('  ').to_i
  end
end
