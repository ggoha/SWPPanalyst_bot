class Monster < ApplicationRecord
  NUMBERS_dative = { 1 => 'первой', 2 => 'второй', 3 => 'третьей', 4 => 'четвертой' }.freeze
  NUMBERS_accusative = { 1 => 'первую', 2 => 'вторую', 3 => 'третью', 4 => 'четвертую' }.freeze

  def regenerate
    hps = ['hp2', 'hp3', 'hp4', 'hp5']
    hps.each { |hp| update_attribute(hp, 1.1 * send(hp)) }
  end

  def interaction(user, head_id, score)
    message = user.company == Company.our ? damage(head_id, score) : heal(head_id, score)
    Telegram.bots[:division].send_message chat_id: user.telegram_id, text: message if [1, 2, 13].include?(user.id)
  end

  private

  def hp(id)
    return 0 if id == 1
    send('hp' + id.to_s)
  end

  def get_head(id)
    return id if hp(id).positive?
    [2..5].select{ |id| hp(id).positive? }.sample
  end

  def damage(id, damage)
    id = get_head(id)
    update_attribute('hp' + id.to_s, [hp(id) - damage, 0].max)
    "Ты нанес #{damage} урона #{NUMBERS_dative[id]} голове призрака"
  end

  def heal(id, heal)
    id = get_head(id)
    update_attribute('hp' + id.to_s, hp(id) + heal)
    "Ты отхилил на #{heal} #{NUMBERS_accusative[id]} голову призрака"
  end
end
