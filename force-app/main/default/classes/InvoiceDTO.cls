public with sharing class InvoiceDTO {
    public InvoiceDTO() {

    }

    public String Type {get;set;}
    public Contact Contact {get;set;}
    public String dt {get;set;}
    public String DateString {get;set;}
    public String DueDate {get;set;}
    public String DueDateString {get;set;}
    public String LineAmountTypes {get;set;}
    public List<LineItem> LineItems {get;set;}

    public class LineItem {
        public String Description {get;set;}
        public Decimal Quantity {get;set;}
        public Decimal UnitAmount {get;set;}
        public String AccountCode {get;set;}
        public String DiscountRate {get;set;}
    }

    public class Contact {
        public String ContactID {get;set;}
    }
}