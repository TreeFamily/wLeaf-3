puts Time.now.to_i

#
#    begin
#      @mysql.query "INSERT INTO `team` (`auth`, `access`, `suspended`) VALUES ('#{user.authname}','#{access}',0)"
#	 rescue Mysql::Error => e
#	   puts "Error code: #{e.errno}"
#	   puts "Error message: #{e.error}"
#	   puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
#	 ensure
#    end
#