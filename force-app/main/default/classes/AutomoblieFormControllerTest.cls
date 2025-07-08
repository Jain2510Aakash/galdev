@isTest(seeAlldata=false)
public class AutomoblieFormControllerTest {

    @isTest 
    public static void TestMethod1()
    {
        Account acc = new Account();
        acc.name = 'test';
        Database.insert(acc);
        
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'tes';
        con.Email = UserInfo.getUserEmail();
        con.AccountId = acc.id;
        Database.insert(con);
        
        CustomerProperty p = new CustomerProperty();
        p.PrimaryOwnerId = acc.id;
        
        Database.insert(p);
    
    	AutomoblieFormController.updateCustom(p, con);
        
        AutomoblieFormController.PreFillCustomer();
        AutomoblieFormController.PreFillContact();
    }
    /*
    @isTest 
    public static void TestMethod2()
    {
        Account acc = new Account();
        acc.name = 'test2';
        Database.insert(acc);
        
        Contact con = new Contact();
        con.FirstName = 'test2';
        con.LastName = 'tes2';
        con.Email = 'webdeveloper442@gmail.com';
        con.AccountId = acc.id;
        Database.insert(con);
        
        CustomerProperty p = new CustomerProperty();
        p.PrimaryOwnerId = acc.id;
        
        Database.insert(p);
    
    	AutomoblieFormController.updateCustom(p, con);
        
        AutomoblieFormController.PreFillCustomer();
        AutomoblieFormController.PreFillContact();
    }
    */
    //
}