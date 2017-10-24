class Monster < ApplicationRecord
  NUMBERS_dative = { 1: 'первой', 2: 'второй', 3: 'третьей', 4: 'четвертой' }
  NUMBERS_accusative = { 1: 'первую', 2: 'вторую', 3: 'третью', 4: 'четвертую' }

  def regenerate
    hps = ['hp2', 'hp3', 'hp4', 'hp5']
    hps.each { |hp| update_attribute(hp, 1.1 * send(hp)) }
  end

  def interaction(user, head_id, score)
    return unless user.halloween_status == :active
    message = user.company == Company.our ? damage(user, head_id, score) : heal(user, head_id, score)
    Telegram.bots[:division].send_message chat_id: user.telegram_id, text: message
  end

  private

  def hp(id)
    return 0 if id == 1
    send('hp'+id.to_s)
  end

  def get_head(id)
    return id if hp(id).positive?
    [2..5].select{ |id| hp(id).positive? }.sample
  end

  def damage(user, id, damage)
    id = get_head(id)
    update_attribute('hp'+id.to_s, [hp(id) - damage, 0].max)
    "Ты нанес #{damage} урона #{NUMBERS_dative[id]} голове призрака"
  end

  def heal(user, id, heal)
    id = get_head(id)
    update_attribute('hp'+id.to_s, hp(id) + heal)
    "Ты отхилил на #{heal} #{NUMBERS_accusative[id]} голову призрака"
  end
end
