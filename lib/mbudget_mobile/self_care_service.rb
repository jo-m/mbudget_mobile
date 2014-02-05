require "httparty"
require "json"

module MbudgetMobile
  class SelfCareService
    include HTTParty
    base_uri 'https://www.m-budget-mobile-service.ch/MBudget/Services/SelfCareService.svc'

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

    def login_ok?
      return false if @cookie.nil?
      if get_sim_details.nil?
        @cookie = nil
        false
      else
        true
      end
    end

    def get_sim_details
      query_service 'GetSimDetails'
    end

    def get_contact_details
      query_service 'GetContactDetails'
    end

    def get_contract_details
      query_service 'GetContractDetails'
    end

    def get_service_context
      query_service 'GetSelfServiceContext'
    end

    def query_bundles
      query_service 'QueryBundles'
    end

    def get_totals_for_this_month
      query_service 'GetSdrTotalsForThisMonth'
    end

    def change_password(password)
      post_service('ChangePassword', {password: password, securityQuestion: 1})
    end

    # boolean
    def update_premium_09000901(active)
      post_service('UpdatePremium09000901', {active: active})
    end

    # boolean
    def update_premium_0906(active)
      post_service('UpdatePremium0906', {active: active})
    end

    # one of
    #   MbudgetMobile::SMS_BARRING_ALLOW_ALL = 0
    #   MbudgetMobile::SMS_BARRING_FORBID_ADULT = 1
    #   MbudgetMobile::SMS_BARRING_FORBID_ALL = 2
    def update_sms_barring(active)
      post_service('UpdateSmsBarring', {active: active})
    end

    # boolean
    def update_voicemail(active)
      post_service('UpdateVoicemail', {active: active})
    end

    # boolean
    def get_premium_09000901
      (query_service 'GetPremium09000901') == 'true'
    end

    # boolean
    def get_premium_0906
      (query_service 'GetPremium0906') == 'true'
    end

    # one of
    #   0 = MbudgetMobile::SMS_BARRING_ALLOW_ALL
    #   1 = MbudgetMobile::SMS_BARRING_FORBID_ADULT
    #   2 = MbudgetMobile::SMS_BARRING_FORBID_ALL
    def get_sms_barring
      query_service 'GetSmsBarring'
    end

    # boolean
    def get_voicemail
      (query_service 'GetVoicemail') == 'true'
    end

    def get_usage_periods
      query_service 'GetSdrPeriods'
    end

    # period: index of period in get_usage_periods
    # returns: AccumulatedAmount is amount in francs
    # SdrType is one of
    #   0 = MBudgetMobile::USAGE_TYPE_ALL
    #   1 = MBudgetMobile::USAGE_TYPE_CHARGES
    #   2 = MBudgetMobile::USAGE_TYPE_DATA
    #   3 = MBudgetMobile::USAGE_TYPE_SMS
    #   4 = MBudgetMobile::USAGE_TYPE_MMS
    #   5 = MBudgetMobile::USAGE_TYPE_CALLS
    def get_usage_totals(period)
      post_service('GetSdrTotals', {period: period})
    end

    def get_usage_for_period
      raise NotImplementedError
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

    class InvalidArgumentsException < Exception
    end

    private

      def query_service(path)
        begin
          response = self.class.post(
            "/#{path}",
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

        begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          return true if response.body.empty?
          response.body
        end
      end

      def post_service(path, data)
        begin
          response = self.class.post(
            "/#{path}",
            body: data.to_json,
            headers: {
              'Cookie' => @cookie,
              'Content-Type' => 'application/json'
            }
          )

        rescue SocketError
          raise ServiceNotReachableException unless @noraise
          return false
        end

        if response.code == 403
          raise InvalidLoginEception unless @noraise
          return false
        end

        if response.code == 400
          raise InvalidLoginEception unless @noraise
          return false
        end

        if response.code != 200
          raise UnknownError unless @noraise
          return false
        end

        return response.body.empty? ? true : JSON.parse(response.body)
      end
  end
end
