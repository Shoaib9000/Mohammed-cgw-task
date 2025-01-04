public with sharing class InvoiceDTO {
    public InvoiceDTO() {

    }

    public String InvoiceNumber {get;set;}
    public Decimal Total {get;set;}
    public Date DueDate {get;set;}
    public Date InvoiceDate {get;set;}
    public String AccountName {get;set;}
    public List<LineItem> LineItems {get;set;}

    public class LineItem {
        public String LineDescription {get;set;}
        public Decimal Quantity {get;set;}
        public Decimal UnitPrice {get;set;}
    }
}