####################################  
# Jason Ritenour
# CloudForms Automate Method: ListDiscoveredHosts  
#  
# This method is used generate a list of discovered hosts waiting for provisioning in Satellite 6/Foreman 
#  
###################################  
#  
# Method for logging  
begin  
  @method = 'ListDiscoveredHosts'  
  
  $evm.log(:info, "#{@method} - EVM Automate Method Started")  
  
  # Turn of verbose logging  
  @debug = true  
  
  
  ###################################  
  # Method: dumpRoot  
  #  
  ###################################  
  def dumpRoot  
    $evm.log(:info, "#{@method} - Root:<$evm.root> Begin Attributes")  
    $evm.root.attributes.sort.each { |k, v| $evm.log(:info, "#{@method} - Root:<$evm.root> Attributes - #{k}: #{v}")}  
    $evm.log(:info, "#{@method} - Root:<$evm.root> End Attributes")  
    $evm.log(:info, "")  
  end  
  
  dumpRoot  
  
  $evm.log(:info, "#{@method} - ================================= EVM Automate Method Started")  
  
  require 'rest-client'  
  require 'json'  
  require "active_support/core_ext"  
  require 'rubygems'  
  
  
  @satserver = nil || $evm.object['satserver']  
  @satuser = nil || $evm.object['satuser']  
  @satpw = nil || $evm.object.decrypt('satpw')  
  @url="https://#{@satserver}/api/v2/discovered_hosts"  
    
  def call_sat6()  
    params = {  
        :method=>"get",  
        :url=>@url,  
        :user=>@satuser,  
        :password=>@satpw,  
        :verify_ssl => OpenSSL::SSL::VERIFY_NONE,  
        :headers=>{ :content_type=>:json, :accept=>:json }  
    }  
    $evm.log(:info, "Calling -> Satellite:<#{@url}> payload:<#{params[:payload]}>")  
    response = RestClient::Request.new(params).execute  
    $evm.log(:info, "Success <- Satellite Response:<#{response.code}>")  
    response_hash = JSON.parse(response)  
    $evm.log(:info, "Inspecting response_hash: #{response_hash.inspect}")  
    return response_hash  
  end  
  
  hosts = call_sat6()  
  names=hosts['results'].map { |x| [x["name"],x["name"]] }  
  $evm.log(:info, "Inspecting Discovered Hosts: #{names.inspect}")  
  list_values = {  
    'sort_by' => :none,  
    'data_type'  => :string,  
    'required'   => false,  
    'values'     => [[nil, nil]] + names.to_a,  
    }  
  $evm.log(:info, "Dynamic drop down values: Hosts drop-down: [#{list_values}]")   
  list_values.each { |k,v| $evm.object[k] = v }  
    
  # Exit method  
  $evm.log(:info, "CFME Automate Method Ended")  
  exit MIQ_OK  
  
    # Set Ruby rescue behavior  
rescue => err  
  $evm.log(:error, "[#{err}]\n#{err.backtrace.join("\n")}")  
  exit MIQ_STOP  
end  
