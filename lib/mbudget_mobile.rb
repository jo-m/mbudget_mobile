require "mbudget_mobile/version"
require "mbudget_mobile/self_care_service"

module MbudgetMobile
  SMS_BARRING_ALLOW_ALL = 0
  SMS_BARRING_FORBID_ADULT = 1
  SMS_BARRING_FORBID_ALL = 2

  USAGE_TYPE_ALL = 0
  USAGE_TYPE_CHARGES = 1
  USAGE_TYPE_DATA = 2
  USAGE_TYPE_SMS = 3
  USAGE_TYPE_MMS = 4
  USAGE_TYPE_CALLS = 5
end
