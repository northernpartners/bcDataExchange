page 50263 "DX Posted Invoice Line API"
{
    PageType = API;
    APIPublisher = 'np';
    APIGroup = 'dx';
    APIVersion = 'v1.0';
    EntityName = 'dxPostedInvoiceLine';
    EntitySetName = 'dxPostedInvoiceLines';
    SourceTable = "Sales Invoice Line";
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
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line Number';
                }
                field(lineType; Rec.Type)
                {
                    Caption = 'Line Type';
                }
                field(itemNumber; Rec."No.")
                {
                    Caption = 'Item Number';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of Measure Code';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                }
                field(lineAmount; Rec."Line Amount")
                {
                    Caption = 'Line Amount';
                }
            }
            part(dxPostedInvoiceLineDimensions; "DX Invoice Dimension API")
            {
                SubPageLink = "Dimension Set ID" = field("Dimension Set ID");
            }
        }
    }
}
