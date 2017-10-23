every '45 6,9,12,15,18 * * *' do
  rake 'group:before_battle'
end
every '15 7,10,13,16,19 * * *' do
  rake 'group:after_battle'
end
every '5 19 * * *' do
  rake 'group:after_day'
end
every '0 12 * * *' do
  rake 'group:update_profile'
end
