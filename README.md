# MbudgetMobile

A ruby gem to make access to the [Swiss Migros Budget Mobile provider customer website](https://www.m-budget-mobile-service.ch/MBudget/index.desktop.html?lang=d#/logon) easier. At the moment, only login and reading the current balance are supported.

## Installation

Add this line to your application's Gemfile:

    gem 'mbudget-mobile'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mbudget-mobile

## Usage

```ruby
require 'mbudget_mobile'

client = MbudgetMobile::SelfCareService.new '077<redacted>', '<redacted>' do |client|
  client.log = Logger.new $stderr
  client.noraise = true
  client.login
end

# common functions
client.get_sim_details
client.get_contact_details
client.get_contract_details
client.get_service_context
client.get_totals_for_this_month
client.change_password('12341234')
client.query_bundles

# services
client.get_premium_09000901
client.get_premium_0906
client.get_sms_barring
client.get_voicemail
client.update_premium_09000901(true)
client.update_premium_0906(true)
client.update_sms_barring(MbudgetMobile::SMS_BARRING_FORBID_ALL)
client.update_voicemail(true)

# query usage
client.get_usage_periods.inspect
client.get_usage_totals(0)
client.get_usage_for_period # not implemented yet
```

## Contributing

1. Fork it ( http://github.com/jo-m/mbudget_mobile/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
