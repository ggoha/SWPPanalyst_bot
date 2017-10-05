every '45 6,9,12,15,18 * * *' do
  rake 'group:before_battle'
end
every '15 7,10,13,16,19 * * *' do
  rake 'group:after_battle'
end
every '0 12 * * *' do
  rake 'group:profile_update'
end