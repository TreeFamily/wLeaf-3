class Team
  def initialize
    @admins = []
    @helpers = []
    @tijd = Time.now.to_i
    @userTime = {}
  end
  
  def addHelper(auth)
    @helpers.push(auth)
  end
  def addAdmin(auth)
    @admins.push(auth)
  end
  def getHelpers
    if @tijd <= (Time.now.to_i-3600)
	 @tijd=Time.now.to_i
	 createTeam
    end
    @helpers
  end
  def getAdmins
    if @tijd <= (Time.now.to_i-3600)
	 @tijd=Time.now.to_i
	 createTeam
    end
    @admins
  end
  def delTeamler(auth)
    @admins = @admins - auth
    @helpers = @helpers - auth
  end
  
  def getSuspended
    suspended = []
    mysql=nil
    ObjectSpace.each_object(Mysql) do |o|
      mysql = o
    end
    res = mysql.query("SELECT `auth` FROM `team` WHERE `suspended`=1")
    res.each do |row|
	 suspended.push(row[0])
    end
    suspended
  end
  
  
  #checking admin levels
  def helper(user)
    @userTime[user.authname] ||=1
    if @userTime[user.authname] < (Time.now.to_i-10)
	     user.refresh
	   @userTime[user.authname] = Time.now.to_i
    end
    @admins.include?(user.authname) || @helpers.include?(user.authname)
  end
  def admin(user)
    @userTime[user.authname] ||=1
    if @userTime[user.authname] < (Time.now.to_i-10)
	     user.refresh
	   @userTime[user.authname] = Time.now.to_i
    end
    @admins.include?(user.authname)
  end
  def suspended(user)
    @userTime[user.authname] ||=1
    if @userTime[user.authname] < (Time.now.to_i-10)
	     user.refresh
	   @userTime[user.authname] = Time.now.to_i
    end
    suspended = getSuspended
    suspended.include?(user.authname)
  end

  
  
  
  def createTeam
    mysql = nil
    @admins = []
    @helpers = []
    ObjectSpace.each_object(Team) do |teamObj|
      @team = teamObj
    end
    @admins = @team.getAdmins unless @team.nil?
    @helpers = @team.getHelpers unless @team.nil?
    ObjectSpace.each_object(Mysql) do |o|
      mysql = o
    end
    
    res = mysql::query("SELECT `auth`,`access` FROM `team` WHERE `suspended`=0")
    res.each_hash do |ret|
	 case ret["access"].downcase
	 when "helper"
	   puts "Adding helper: #{ret["auth"]}"
	   addHelper(ret["auth"])
	 when "admin"
	   puts "Adding admin: #{ret["auth"]}"
	   addAdmin(ret["auth"])
	 end
    end
  end
end

