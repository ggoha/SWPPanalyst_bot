module Grapher
  extend ActiveSupport::Concern
  def generate_graph(method, params)
    g = send(method, params)
    g.theme = {
      :colors => %w(#c32d39 #25717e #fcc245 #8b2ced #18181c),
      :font_color => 'white',
      :background_colors => %w(#454255 #78748c)
    }
    g.write 'public/line_xy.png'
  end

  def generate_stoks_line(filter)
    g = Gruff::Line.new
    g.title = 'Курс акций'

    g.hide_dots = true
    g.reference_lines[:baseline]  = { :value => 65 }
    g.reference_lines[:lots]      = { :value => 20 }
    g.baseline_color = 'red'

    Company.all.each do |company|
      stocks = company.stocks.public_send(filter)
      g.dataxy(company.title, stocks.map { |s| s.at.to_i }, stocks.map(&:price))
    end
    
    a, b = Company.take.stocks.first.at.to_i, Company.take.stocks.last.at.to_i
    result = {}
    (1..6).map { |i| a + (b - a) * i / 7 }.map { |i| result[i] = Time.at(i).strftime('%d.%m') }
    g.labels = result
    g
  end

  def generate_moneys_area(filter)
    g = Gruff::StackedArea.new
    g.title = 'Потери компаний во время битв'
    g.theme = {
      :colors => %w(#c32d39 #25717e #fcc245 #8b2ced #18181c),
      :font_color => 'white',
      :background_colors => %w(#454255 #78748c)
    }
    Company.all.each do |company|
      battles = company.battles.public_send(filter)
      g.data(company.title, battles.map(&:losses))
    end
    g
  end

  def generate_points_pie(filter)
    g = Gruff::Pie.new
    g.title = 'Очки компаний'
    Company.all.each do |company|
      if filter == :all
        g.data(company.title, company.score)
      else
        battles = company.battles.public_send(filter)
        g.data(company.title, battles.map(&:score).inject(0, :+))
      end
    end
    g
  end

  def generate_points_line(filter)
    g = Gruff::Line.new
    g.title = 'Рейтинг компаний'
    g.hide_dots = true
    Company.all.each do |company|
      battles = company.battles.public_send(filter)
      g.dataxy(company.title, battles.map { |s| s.at.to_i }, battles.map(&:summary_score))
    end
    g
  end

  def generate_points_bar(filter)
    g = Gruff::StackedBar.new
    g.title = 'Очки за битвы'
    Company.all.each do |company|
      battles = company.battles.public_send(filter)
      g.data(company.title, battles.map(&:score))
    end
    g
  end

  def generate_percent_points_bar(filter)
    g = Gruff::StackedBar.new
    g.title = 'Процент очков за битвы'
    Company.all.each do |company|
      battles = company.battles.public_send(filter)
      g.data(company.title, battles.map(&:percent_score))
    end
    g
  end
end
