page 50262 "DX Posted Invoice API"
{
    PageType = API;
    APIPublisher = 'np';
    APIGroup = 'dx';
    APIVersion = 'v1.0';
    EntityName = 'dxPostedInvoice';
    EntitySetName = 'dxPostedInvoices';
    SourceTable = "Sales Invoice Header";
    DelayedInsert = true;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(invoiceNumber; Rec."No.")
                {
                    Caption = 'Invoice Number';
                }
                field(customerName; Rec."Bill-to Name")
                {
                    Caption = 'Customer Name';
                }
                field(customerId; Rec."Bill-to Customer No.")
                {
                    Caption = 'Customer Id';
                }
                field(amount; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including VAT';
                }
                field(amountExcludingVat; Rec.Amount)
                {
                    Caption = 'Amount Excluding VAT';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';
                }
                field(description; Rec."Your Reference")
                {
                    Caption = 'Description';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(paymentTermsCode; Rec."Payment Terms Code")
                {
                    Caption = 'Payment Terms Code';
                }
            }
            part(dxPostedInvoiceLines; "DX Posted Invoice Line API")
            {
                EntityName = 'dxPostedInvoiceLine';
                EntitySetName = 'dxPostedInvoiceLines';
                SubPageLink = "Document No." = field("No.");
            }
            part(dxPostedInvoiceDimensions; "DX Invoice Dimension API")
            {
                SubPageLink = "Dimension Set ID" = field("Dimension Set ID");
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Amount Including VAT", Amount);
    end;
}
