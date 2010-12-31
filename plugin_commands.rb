class Commands
  include Cinch::Plugin
  prefix ">"
  
  def initialize(*args)
    super
    ObjectSpace.each_object(Team) do |teamObj|
      @team = teamObj
    end
    @mysql = nil
    ObjectSpace.each_object(Mysql) { |o|
	 @mysql = o
    }
  end
  
  def functionToExecute(m,*args)
  end


end