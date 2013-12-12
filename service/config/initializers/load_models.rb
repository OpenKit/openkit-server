
# Loading shared models first
shared_files = Dir.glob('../shared/app/models/*.rb')
shared_files.each do |file|
	class_name = File.basename(file, ".rb").camelize
	autoload class_name.to_sym, file
end

shared_files.each do |file|
	require file
end


# Loading extensions
Dir.glob('app/models/*.rb') do |file| 
	file = File.basename(file)
	require file
end

