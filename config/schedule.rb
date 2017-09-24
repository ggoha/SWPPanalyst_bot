every '45 6,8,12,15,18 * * *' do
  rake "group:mvp"
  rake "group:current_situation"
  rake "group:remind"
end