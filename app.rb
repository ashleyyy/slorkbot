require 'sinatra'
require 'httparty'
require 'json'

require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/model'

post '/gateway' do
  return if params[:token] != ENV['SLACK_TOKEN']

  message = params[:text].sub(params[:trigger_word], '').strip # text minus 'slorkbot'

  if message.split.first == ',' # accounts for comma after slorkbot
    action = message.split(' ')[1..-1].join(' ').split.first #first word of string after stripping leading comma
     term = message.split(' ')[2..-1].join(' ').gsub("\"", "") #everything in string except the first word
  else 
    action = message.split.first #first word of string
    term = message.split(' ')[1..-1].join(' ').gsub("\"", "") #everything else
  end

  case action.downcase
  when 'listallcomplimentsplease'
    models = Model.all 
    puts models
    puts "if it works, it's below this line I guess!"
    models.each { |m| puts m.compliment }
    models.each { |m| respond_message m.compliment }
    # this doesn't actually work
  when 'ashley'
    respond_message "Ashley _is_ pretty cute, don't you think?"
  when 'nuke'
    @model = Model.find_by! compliment: "#{term}"
    if @model.destroy
      respond_message 'good bye!'
    else 
      respond_message 'bad news, yo!'
    end
  when 'i'
    respond_message params[:user_name] + ", " + get_compliment
  when 'define'
    term = term.gsub(" ", "+")
    respond_message "http://lmgtfy.com/?q=#{term}"
  when 'add'
    add_compliment term
  when /you.*/
    respond_message "it's true"
  when /we.*/
    respond_message "Absolutely we do!"
  when 'please'
    respond_message "_looks for the recursion emoji_"
  when 'can'
    respond_message "Is that really appropriate for <##{params[:channel_id]}|#{params[:channel_name]}>?"
  when 'love'
    if term == "me"
      respond_message params[:user_name] + ", " + get_compliment
      # compliment from user who triggered it 
    else
      respond_message term + ", " + get_compliment
      # compliment to person specified
    end
  else 

    hugs = [":hug:", ":moarhug:", ":oatmealhug:", ":grouphug:", ":hug:"]

    if term =~ /need.? love\W?/
      respond_message action + ", " + get_compliment
      # compliment to person specified
    elsif term.include? "love"
      respond_message get_compliment.capitalize, params[:user_name]
      # compliment from user who triggered it 
    elsif message.include? "hug" 
      respond_message hugs[rand(hugs.length)]
      # just give hugmoji
    elsif message.include? "needs"
      term = message.split("needs")[1]
      respond_message "We could all benefit from" + term +"!"
    else
      respond_message "I'm a robot who doesn't understand what you're asking. \nGood thing you also have human friends"
    end
  end
end

def respond_message message, username = "slorkbot", response_type = "in_channel"
  content_type :json
  {
    text: message,
    username: username, # overwrites slorkbot's displayed username
    response_type: response_type, # I don't think this works
    # mrkdwn: false
  }.to_json
end


def add_compliment message
  @model = Model.new(compliment: message)
  if @model.save
    respond_message "Thanks! :blush: I'll pass it on.", "slackbot", "ephemeral"
  else
    respond_message "I don't know why, but there's been a massive fuckup", "slackbot", "ephemeral"
  end
end

def get_compliment
  if @compliment = Model.order("RANDOM()").first
    @compliment.compliment
  else # handle db error
    "I love you"
  end
end

# ignore below.

# get '/anonymize' do
#   postback params[:text], params[:channel_id]
#   status 200
# end
 
# def postback message, channel
#     # slack_webhook = ENV['SLACK_WEBHOOK_URL']
#     url = ENV['SLACK_WEBHOOK_URL'] + "&channel=%23test"
#     msg = params[:text]
#     HTTParty.post(url, body: msg.to_json)

#     # HTTParty.post slack_webhook, body: {"text" => message.to_s, "username" => "John Doe", "channel" => params[:channel_id]}.to_json, headers: {'content-type' => 'application/json'}

# end
