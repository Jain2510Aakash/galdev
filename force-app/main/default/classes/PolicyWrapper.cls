/*****
* Created by Saurabh Chandra[08-06-2025]
* Test Class: FetchPolicyFromInsightTest
* Description: deserialize the response from API for Policy
* Referenced From : FetchPolicyFromInsight
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================

*/

public class PolicyWrapper {
    public List<PolicyRecord> Results;
    public Integer PageCount;
    public Integer PageNumber;

    public class PolicyRecord {
        public Integer Id;
        public String CreatedWho;
        public Datetime CreatedWhen;
        public String UpdatedWho;
        public Datetime UpdatedWhen;
        public String RowVersion;
        public String Description;
        public Integer ClientId;
        public Integer BranchId;
        public Integer ClassOfRiskId;
        public String ClassOfRisk;
        public Integer ComplianceTypeId;
        public Integer InsurerId;
        public Integer TypeId;
        public String TypeDescription;
        public Integer StatusId;
        public Boolean IsCurrent;
        public String PolicyNumber;
        public Date EffectiveDate;
        public Date FromDate;
        public Date ToDate;
        public String Insured;
        public Decimal Balance;
        public Integer NumTransactions;
        public Integer CurrentPolicy;
        public Boolean IsInstalmentPolicy;
        public Boolean IsInstalmentPayment;
        public Integer Period;
        public Boolean IsHidden;
        public Boolean AnzsicInactive;
        public Boolean SICIsExternal;
        public Integer CancellationStatusId;
        public Integer LatestPolicyPeriodId;
        public Boolean HasCoinsurance;
        public Boolean HasMultiClient;
        public String ClientName;
        public String ClientTradingAs;
        public String ClientRef;
        public String ClientContact;
        public String ClientTelephone;
        public String ClientMobile;
        public String ClientEmail;
        public Integer ClientStatusId;
        public String InsurerName;
        public String InsurerTradingAs;
        public String InsurerRef;
        public String InsurerContact;
        public String InsurerTelephone;
        public String InsurerMobile;
        public String InsurerEmail;
        public Boolean CanEditPolicyRenewalType;
        public Boolean IsLatestTransactionPosted;
        public Boolean IsLatestTransactionSunrise;
        public Boolean IsLatestTransactionSVU;
        public Boolean IsLatestTransactionManual;
        public Integer UnderwriterId;
        public String UnderwriterName;
        public String UnderwriterRef;
        public String UnderwriterEmail;
        public Boolean IsScheduledPayment;
        public Boolean NoPolicyValidation;
        public Integer InstalmentPaymentDepositCount;
        public Boolean InstalmentPaymentIncludeBrokerFeeInDeposit;
        public Boolean InstalmentPaymentSpreadAnnualPremiums;
        public Boolean InstalmentPaymentSpreadReturnPremiums;
        public String AnzsicAutoComplete;
        public String StandardIndustryCode;
        public Integer PolicyTeamId;
    }
}