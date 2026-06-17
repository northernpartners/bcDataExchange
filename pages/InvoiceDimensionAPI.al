page 50264 "DX Invoice Dimension API"
{
    PageType = API;
    APIPublisher = 'np';
    APIGroup = 'dx';
    APIVersion = 'v1.0';
    EntityName = 'dxInvoiceDimension';
    EntitySetName = 'dxInvoiceDimensions';
    SourceTable = "Dimension Set Entry";
    DelayedInsert = true;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code';
                }
                field(dimensionValueCode; Rec."Dimension Value Code")
                {
                    Caption = 'Dimension Value Code';
                }
                field(dimensionValueName; Rec."Dimension Value Name")
                {
                    Caption = 'Dimension Value Name';
                }
                field(dimensionId; DimensionSystemId)
                {
                    Caption = 'Dimension Id';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        Dim: Record Dimension;
    begin
        if Dim.Get(Rec."Dimension Code") then
            DimensionSystemId := Format(Dim.SystemId, 0, 4).ToLower()
        else
            DimensionSystemId := '';
    end;

    var
        DimensionSystemId: Text;
}
