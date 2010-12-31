class Teamleden
  include Cinch::Plugin
  prefix ">"
  match /myaccess/i , method: :myaccess
  match /access (.+)/i , method: :access
  match /addhelper (.+)/i , method: :addHelper
  match /addadmin (.+)/i , method: :addAdmin
  match /suspend (.+)/i , method: :suspend
  match /unsuspend (.+)/i , method: :unsuspend
  match /updateTeam/i , method: :updateTeam
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
    return unless @team.admin(m.user)
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
  
  def suspend(m,nick)
    return unless @team.admin(m.user)
    suspended = User(nick)
    alvl = aLevel(suspended)
    case alvl
    when "no"
	 m.user.send "Can't suspend #{nick} (#{suspended.authname}), user doesn't have access"
	 return
    when "suspended"
	 m.user.send "Can't suspend #{nick} (#{suspended.authname}), user is already suspended"
	 return
    end
    if suspended.authed?
      addedToDb = suspendTeamler(suspended,1)
	 if addedToDb["error"]
	   m.user.send "Couldn't suspend #{nick}, Error: #{addedToDb['errormsg']}"
	 else
	   m.user.send "Suspended #{nick} (#{suspended.authname})"
	   @bot.raw "CS suspend *#{suspended.authname}"
	 end
    else
	 m.user.send "No such nick #{nick}... try again please"
    end
  end
  
  def unsuspend(m,nick)
    return unless @team.admin(m.user)
    suspended = User(nick)
    alvl = aLevel(suspended)
    case alvl
    when "no"
	 m.user.send "Can't unsuspend #{nick} (#{suspended.authname}), user doesn't have access"
	 return
    when "admin"
	 m.user.send "Can't unsuspend #{nick} (#{suspended.authname}), user isn't suspended"
	 return
    when "helper"
	 m.user.send "Can't unsuspend #{nick} (#{suspended.authname}), user isn't suspended"
  	 return
    end
    if suspended.authed?
      addedToDb = suspendTeamler(suspended,0)
	 if addedToDb["error"]
	   m.user.send "Couldn't unsuspend #{nick}, Error: #{addedToDb['errormsg']}"
	 else
	   m.user.send "Unsuspended #{nick} (#{suspended.authname})"
	   @bot.raw "CS unsuspend *#{suspended.authname}"
	 end
    else
	 m.user.send "No such nick #{nick}... try again please"
    end
  end
  
  def updateTeam(m)
    @team.createTeam
    m.reply "Updated team database"
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
  
  def suspendTeamler(user,susp)
    susp ||= 0
    returnVal = {'error'=>false}
    begin
	 @mysql.query "UPDATE `team` SET `suspended`=#{susp} WHERE `auth`='#{user.authname}'"
	 rescue Mysql::Error => e
	   returnVal = {'error'=>true,'errormsg'=>e.error}
	   puts returnVal
	 ensure
    end
    return returnVal
  end



end

