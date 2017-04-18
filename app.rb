require 'sinatra'
require 'httparty'
require 'json'

require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/model'

post '/gateway' do
  return if params[:token] != ENV['SLACK_TOKEN']
  puts params

  message = params[:text].sub(params[:trigger_word], '').strip.downcase

  if message.split.first == ','
    action = message.split(' ')[1..-1].join(' ').split.first
     term = message.split(' ')[2..-1].join(' ').gsub("\"", "")
  else 
    action = message.split.first
    term = message.split(' ')[1..-1].join(' ').gsub("\"", "")
  end

  case action
  when 'ashley'
    respond_message "Ashley is my creator! She needs for nothing, except maybe a full time jorb"
  when 'nuke'
    @model = Model.find_by(term)
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
  when 'can'
    respond_message "Is that really appropriate for <##{params[:channel_id]}|#{params[:channel_name]}>?"
  when 'love'
    if term == "me"
      respond_message params[:user_name] + ", " + get_compliment
    elsif 
      respond_message term + ", " + get_compliment
    end
  else 

    hugs = [":hug:", ":moarhug:", ":oatmealhug:", ":grouphug:", ":hug:"]

    if term == "needs love" || term == "need love" 
      respond_message action + ", " + get_compliment
    elsif term.include? "love"
      respond_message get_compliment, params[:user_name]
    elsif message.include? "hug" 
      respond_message hugs[rand(hugs.length)]
    else
      respond_message "guys, sometimes I need love too"
    end
  end
end

def respond_message message, username = "slorkbot"
  content_type :json
  # {text: message}.to_json
  {
    text: message,
    username: username,
    # mrkdwn: false
  }.to_json
end


def add_compliment message
  @model = Model.new(compliment: message)
  if @model.save
    respond_message "Thanks! :blush: I'll pass it on."
  else
    respond_message "I don't know why, but there's been a massive fuckup"
  end
end

def get_compliment
  if @compliment = Model.order("RANDOM()").first
    @compliment.compliment
  else
    "I love you"
  end
end

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
