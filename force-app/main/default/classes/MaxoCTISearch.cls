global class MaxoCTISearch {
    webService static String getContacts( String searchVal, String id ){

        String searchNumber = '';
        if (searchVal.StartsWith('+61')) {
            searchNumber = searchVal.Substring(3);
        } else if (searchVal.StartsWith('61')) {
            searchNumber = searchVal.Substring(2);
        } else if (searchVal.StartsWith('0')) {
            searchNumber = searchVal.Substring(1);
        } else {
            searchNumber = searchVal;
        }

        searchNumber = '%' + searchNumber;

        List<Contact> response =  new List<Contact>();
        for(Contact contact: [SELECT Contact.Name, Contact.Salutation, Contact.Email, Contact.Department, Contact.Description, Contact.AccountId, Account.Name FROM Contact WHERE Phone LIKE :searchNumber]){
            response.add(contact);
        }
        String contactResponse = JSON.serialize(response);
        return JSON.serialize(JSON.deserializeUntyped('{"term":"'+searchVal+'","ID":"'+id+'","Contacts":'+contactResponse+',"UserID":"'+UserInfo.getUserId()+'"}'));
    }
    
    webService static String getAllAccounts(){
        List<Account> response =  new List<Account>();
        for(Account account: [SELECT Name FROM Account]){
            response.add(account);
        }
        
        return JSON.serialize(response);
    }

    webService static string getUserExtension(String userId) {
        User user = [SELECT CTI_Extension__c FROM User WHERE Id = :userId LIMIT 1];
        if (user != null) {
            return user.CTI_Extension__c;
        } else {
            return null;
        }
    }

    webService static string getKey() {
        List<CTI_API__c> maxoAPIList = [SELECT API_Identifier__c FROM CTI_API__c LIMIT 1];
        if (!maxoAPIList.isEmpty()) {
            return JSON.serialize(JSON.deserializeUntyped('{"key":"'+maxoAPIList[0].API_Identifier__c+'","UserID":"'+UserInfo.getUserId()+'"}'));
        } else {
            return null;
        }
    }
}