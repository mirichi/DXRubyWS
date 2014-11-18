Dir[File.dirname(__FILE__) + '/standardgui/*.rb'].sort.each do |path|
  require path
end
