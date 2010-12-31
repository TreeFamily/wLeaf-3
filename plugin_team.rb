class Teamleden
  include Cinch::Plugin
  prefix "<"
  match /myaccess/i , method: :myaccess
  match /access (.+)/i , method: :access
  match /addhelper (.+)/i , method: :addHelper
  match /addadmin (.+)/i , method: :addAdmin
  def initialize(*args)
    super
    @team = nil
    ObjectSpace.each_object(Team) do |teamObj|
      @team = teamObj
    end

    @team = nil
    ObjectSpace.each_object(Team) do |teamObj|
      @team = teamObj
    end
    @mysql = nil
    ObjectSpace.each_object(Mysql) { |o|
	 @mysql = o
    }
  end
  
  
  def aLevel(user)
    if @team.suspended(user)
	 accessLevel = "suspended"
    elsif @team.admin(user)
	 accessLevel = "admin"
    elsif @team.helper(user)
	 accessLevel = "helper"
    else
	 accessLevel = "no"
    end
    accessLevel
  end
  
  
  def myaccess(m)
    accessLevel = aLevel(m.user)
    m.user.send "You (#{m.user.authname}) have #{accessLevel} access"
  end
  
  def access(m,nick)
    user = User(nick)
    accessLevel = aLevel(user)
    m.user.send "#{nick} (#{user.authname}) has #{accessLevel} access"
  end

  def addHelper(m, nick)
    return unless @team.admin(m.user)
    newHelper = User(nick)
    alvl = aLevel(newHelper)
    if alvl != "no"
	 m.user.send "#{nick} can't be added as helper, #{nick} already has #{alvl} access"
	 return
    end
    if newHelper.authed?
	 addedToDb = addTeamlerToDb(newHelper,"helper")
	 if addedToDb["error"]
	   m.user.send "Couldn't add #{nick} as helper, Error: #{addedToDb['errormsg']}"
	 else
	   @team.addHelper(newHelper.authname)
	   m.user.send "Added #{nick} (#{newHelper.authname}) as helper"
	 end
    else
	 m.user.send "No such nick  #{nick}... try again please"
    end
  end
  def addAdmin(m, nick)
    return unless admin(m.user)
    newAdmin = User(nick)
    alvl = aLevel(newAdmin)
    case alvl
    when "helper"
	 m.user.send "#{nick} has helper access, promotion script not working yet"
	 return
    when "admin"
	 m.user.send "#{nick} can't be added as admin, #{nick} already has admin access"
	 return
    end
    if newAdmin.authed?
	 addedToDb = addTeamlerToDb(newAdmin,"admin")
	 if addedToDb["error"]
	   m.user.send "Couldn't add #{nick} as admin, Error: #{addedToDb['errormsg']}"
	 else
	   @team.addHelper(newAdmin.authname)
	   m.user.send "Added #{nick} (#{newAdmin.authname}) as admin"
	 end
    else
	 m.user.send "No such nick #{nick}... try again please"
    end
  end
  
  def addTeamlerToDb(user,access)
    returnVal = {'error'=>false}
    begin
      @mysql.query "INSERT INTO `team` (`auth`, `access`, `suspended`) VALUES ('#{user.authname}','#{access}',0)"
	 rescue Mysql::Error => e
	   returnVal = {'error'=>true,'errormsg'=>e.error}
	   puts returnVal
	 ensure
    end
    return returnVal
  end
  
  def suspendTeamler(user)
    
  end



end

