require "httparty"
require "json"

module MbudgetMobile
  class SelfCareService
    include HTTParty
    base_uri 'https://www.m-budget-mobile-service.ch/MBudget/Services/SelfCareService.svc'
    debug_output

    def self.start(args={})
      instance = new(*args)
      yield(instance)
    ensure
      instance.shutdown
    end

    def initialize(username, password)
      @log = nil
      @noraise = nil

      @username = username
      @password = password

      yield self if block_given?
    end

    def login
      begin
        response = self.class.post(
          '/LogOn',
          body: {
            userName: @username,
            password: @password
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      rescue SocketError
        raise ServiceNotReachableException unless @noraise
        return false
      end

      if response.code == 200
        @cookie = response.headers['Set-Cookie'][/MVNOMBMSCAUTH=[^;]+/]
        return true
      end

      raise InvalidLoginEception unless @noraise
      return false
    end

    def get_sim_details
      query_service '/GetSimDetails'
    end

    def get_contact_details
      query_service '/GetContactDetails'
    end

    def get_contract_details
      query_service '/GetContractDetails'
    end

    def get_service_context
      query_service '/GetSelfServiceContext'
    end

    def query_bundles
      query_service '/QueryBundles'
    end

    def get_totals_for_this_month
      query_service '/GetSdrTotalsForThisMonth'
    end

    def login_ok?
      return false if @cookie.nil?
      if get_sim_details.nil?
        @cookie = nil
        false
      else
        true
      end
    end

    @log = nil
    @noraise = true

    class << self
      ##
      # Default logger for all instances
      #
      #   MbudgetMobile::SelfCareService.log = Logger.new $stderr
      attr_accessor :log

      attr_accessor :noraise
    end

    ##
    # The current logger.  If no logger has been set MbudgetMobile::SelfCareService.log is used.
    def log
      @log || MbudgetMobile::SelfCareService.log
    end

    ##
    # Sets the +logger+ used by this instance of mbudget
    def log= logger
      @log = logger
    end

    def noraise
      if @noraise.nil?
        MbudgetMobile::SelfCareService.noraise
      else
        @noraise
      end
    end

    def noraise= val
      @noraise = val
    end

    class InvalidLoginEception < Exception
    end

    class ServiceNotReachableException < Exception
    end

    class UnknownError < Exception
    end

    private

      def query_service(path)
        begin
          response = self.class.post(
            path,
            headers: { 'Cookie' => @cookie }
          )
        rescue SocketError
          raise ServiceNotReachableException unless @noraise
          return nil
        end

        if response.code == 403
          raise InvalidLoginEception unless @noraise
          return nil
        end

        if response.code != 200
          raise UnknownError unless @noraise
          return nil
        end

        JSON.parse(response.body)
      end
  end
end
