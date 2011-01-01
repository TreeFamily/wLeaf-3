class Test
  include Cinch::Plugin
  prefix ">"
  match /mysqlTest/, method: :mysqlTest
  match /mysqlqry(?: (.+))?/, method: :mysqlQry
  def initialize(*args)
    super
    @mysql = nil
    ObjectSpace.each_object(Mysql) { |o|
	 @mysql = o
    }
    @team = nil
    ObjectSpace.each_object(Team) do |teamObj|
      @team = teamObj
    end
  end
  
  def mysqlTest(m)
    return unless @team.helper(m.user)
    if @mysql.nil? 
    ObjectSpace.each_object(Mysql) { |o|
	 @mysql = o
    }
    end
    m.reply "Test:"
    m.reply @mysql::get_server_version()
  end
  
  
  def mysqlQry(m,qry)
    return unless @team.admin(m.user)
    if @mysql.nil? 
    ObjectSpace.each_object(Mysql) { |o|
	 @mysql = o
    }
    end
    qry ||= "SELECT * FROM `rubyTest`.`team`"
    result = @mysql::query(qry)
    result.each_hash do |ret|
	text = "" 
	 ret.each do |name,value|
	   text << "#{name}: #{value} "
	 end
	 m.reply text
    end
  end
  

  
end