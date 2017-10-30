class Journey
  PLACES = ['тридесятое царство', 'подземный переход', 'МФТИ', 'Монголию', 'вселенную Рика и Морти', 'прошлый год',
         'город без дорог', 'чемпионат России по футболу', 'Нидерланды', 'Орск', 'Пироляндию', 'прекрасное далеко', 'город N-ск']
  CHARACTERS = ['Рика и Морти', 'русалок', 'инспектора ГАИ', 'Джеки Чана', 'гладиолус', 'Александра Сергеевича', 'Витька из 2 подъезда',
          'кота из Простоквашино', 'мастера Йоду', 'тройного интеграла', 'мисс Вселенную']
  ACTIONS = ['выпили за любовь', 'подняли звездолет из болота', 'прошлись по цепи в другую сторону', 'согнулись 12 раз', 'сразились на дуэли',
          'вернулись в 2007', 'построили Рим', 'накатили FreeBSD', 'погладили белье', 'решили ничего не делать', 'отметить день рождения двоюродной сестры по материнской линии тестя знакомого', 'разобраться "Кому на Руси жить хорошо?"']
  CAMBAKS = ['разочарованный вернулся домой', 'решил больше никогда не пить', 'напиcал свою собственную текстовую игру', 'заюзал фаст-тревел', 
          'взял такси до дома', 'решил домой не возвращатьcя', 'перекатами добрался до ближайшей деревни',
          'дал обет молчания и пошел своей дорогой', 'был доставлен в ближайшую тюрьму', 'улетел на реактивной тяге', 'решил что нужно обязательно повторить', 'зарекся никогда так не делать']
  
  def self.start(user)
    if user.halloween_status == 'inactive' ||  user.halloween_status == 'active' || user.halloween_status == 'win'
      if user.star_journey_at.nil? || user.star_journey_at < DateTime.now-11.hour
        user.update_attributes(halloween_status: 'walk', star_journey_at: DateTime.now)
	user.add_achivment(Achivment.find(16)) unless user.achivments.include?(Achivment.find(16))
        'Ты успешно отправился в путешествие'
      else
        'Ты не смог отправиться в путешествие, потому что еще слишком устал от предыдущего, отправиться в путешествие можно раз 12 часов'
      end
    else
       case user.halloween_status
       when 'death' 
         'Твое путешествие закончилось неудачно, подожди пока кто-нибудь займется некромантией'
       when 'walk' 
         'Ты уже в путешествии'
       end
    end
  end

  def self.event(user)
    r  = rand(100)
    if r < 2
      return win(user)
    end
    if r < 5
      return death(user)
    end
    if r < 10
      return necromancy(user)
    end
    if r < 33
      return end_walk(user)
    end
    return walk(user)
  end

  def self.necromancy(user)
    target = User.where(halloween_status: 'death').order("RANDOM()").first
    if target
      target.update_attributes(halloween_status: 'active')
      bot = Telegram.bots[:division]
      bot.send_message chat_id: target.telegram_id, text: 'Тебя воскресил мимопроходящий путник'
      'Ты успешно попрактиковался в некромантии и поднял какого-то незадачливого путешественника'
    else
      'Твои эксперименты в некромантии не увенчались успехом'
    end
  end

  def self.end_walk(user)
    user.update_attributes(halloween_status: 'active')
    message = 'Ты передумал идти дальше на этом твое путешетвие закончилось'
  end

  def self.win(user)
    user.update_attributes(halloween_status: 'win')
    message = '🎉Ты победил монстра в неравном бою. Твое путешествие оконено, но при желании ты можешь начать новое.🎉'
  end

  def self.death(user)
    user.update_attributes(halloween_status: 'death')
    message = '😵Ты нашел монстра. Но лучше бы ты его не находил. Для тебя путешествие закончено. Но возможно тебе помогут😵'
  end

  def self.walk(user)
    message = "Твой персонаж долго шел и наконец пришел в #{PLACES.sample}," \
    " там ты встретил #{CHARACTERS.sample}," \
    " вместе вы #{ACTIONS.sample}," \
    " после чего ты #{CAMBAKS.sample}."
  end
end
