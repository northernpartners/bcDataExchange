codeunit 50153 "Sales Invoice Helpers"
{
    Permissions =
        tabledata "Dimension Set Entry" = rimd;

    /// <summary>
    /// Formats a date in ISO 8601 format (YYYY-MM-DD).
    /// </summary>
    procedure FormatDateISO(InputDate: Date): Text
    begin
        if InputDate = 0D then
            exit('');
        exit(Format(InputDate, 0, '<Year4>-<Month,2>-<Day,2>'));
    end;

    /// <summary>
    /// Parses a date string in ISO 8601 format (YYYY-MM-DD) to a Date value.
    /// </summary>
    procedure ParseDateISO(DateString: Text; var OutputDate: Date): Boolean
    var
        Year: Integer;
        Month: Integer;
        Day: Integer;
        HyphenPos1: Integer;
        HyphenPos2: Integer;
        YearStr: Text;
        MonthStr: Text;
        DayStr: Text;
        RemainStr: Text;
    begin
        // Find first hyphen
        HyphenPos1 := StrPos(DateString, '-');
        if HyphenPos1 = 0 then
            exit(false);

        // Find second hyphen
        RemainStr := CopyStr(DateString, HyphenPos1 + 1);
        HyphenPos2 := StrPos(RemainStr, '-');
        if HyphenPos2 = 0 then
            exit(false);

        // Extract parts
        YearStr := CopyStr(DateString, 1, HyphenPos1 - 1);
        MonthStr := CopyStr(DateString, HyphenPos1 + 1, HyphenPos2 - 1);
        DayStr := CopyStr(DateString, HyphenPos1 + HyphenPos2 + 1);

        // Parse values
        if not Evaluate(Year, YearStr) or (Year < 1900) or (Year > 2099) then
            exit(false);

        if not Evaluate(Month, MonthStr) or (Month < 1) or (Month > 12) then
            exit(false);

        if not Evaluate(Day, DayStr) or (Day < 1) or (Day > 31) then
            exit(false);

        // Create the date
        OutputDate := DMY2Date(Day, Month, Year);
        exit(true);
    end;

    /// <summary>
    /// Constructs the PDF download URL for a posted invoice.
    /// Returns the OData endpoint URL to download the invoice PDF.
    /// </summary>
    procedure GetPostedInvoicePdfUrl(InvoiceNumber: Code[20]): Text
    begin
        exit('SalesInvoices/SalesInvoiceDocument/' + InvoiceNumber);
    end;

    /// <summary>
    /// Creates a detailed invoice JSON object including all line items and optional dimensions for draft invoices.
    /// </summary>
    procedure CreateInvoiceDetailObject(SalesHeader: Record "Sales Header"; DimensionArray: JsonArray): Text
    var
        SalesLine: Record "Sales Line";
        LineArray: JsonArray;
        LineObject: JsonObject;
        Result: JsonObject;
        OutTxt: Text;
    begin
        Result.Add('id', SalesHeader."No.");
        Result.Add('invoiceNumber', SalesHeader."No.");
        Result.Add('customerName', SalesHeader."Bill-to Name");
        Result.Add('customerId', SalesHeader."Bill-to Customer No.");
        Result.Add('amount', SalesHeader."Amount Including VAT");
        Result.Add('amountExcludingVat', SalesHeader.Amount);
        Result.Add('vat', SalesHeader."Amount Including VAT" - SalesHeader.Amount);
        Result.Add('dueDate', FormatDateISO(SalesHeader."Due Date"));
        Result.Add('documentDate', FormatDateISO(SalesHeader."Document Date"));
        Result.Add('status', Format(SalesHeader.Status));
        Result.Add('description', SalesHeader."Your Reference");
        Result.Add('currencyCode', SalesHeader."Currency Code");
        Result.Add('paymentTermsCode', SalesHeader."Payment Terms Code");
        Result.Add('pdfUrl', '');

        // Add line items
        Clear(LineArray);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                LineObject.Add('lineNumber', SalesLine."Line No.");
                LineObject.Add('lineType', Format(SalesLine.Type));
                LineObject.Add('itemNumber', SalesLine."No.");
                LineObject.Add('description', SalesLine.Description);
                LineObject.Add('quantity', SalesLine.Quantity);
                LineObject.Add('unitOfMeasureCode', SalesLine."Unit of Measure Code");
                LineObject.Add('unitPrice', SalesLine."Unit Price");
                LineObject.Add('lineAmount', SalesLine."Line Amount");

                // Add line dimensions if requested
                if DimensionArray.Count() > 0 then
                    LineObject.Add('lineDimensions', GetLineDimensions(SalesLine."Dimension Set ID", DimensionArray));

                LineArray.Add(LineObject);
                Clear(LineObject);
            until SalesLine.Next() = 0;

        Result.Add('lines', LineArray);

        // Add dimensions if requested
        if DimensionArray.Count() > 0 then
            Result.Add('dimensions', GetInvoiceDimensions(SalesHeader."No.", 'SalesHeader', DimensionArray));

        Result.WriteTo(OutTxt);
        exit(OutTxt);
    end;

    /// <summary>
    /// Creates a detailed invoice JSON object including all line items and optional dimensions for posted invoices.
    /// </summary>
    procedure CreatePostedInvoiceDetailObject(SalesInvoiceHeader: Record "Sales Invoice Header"; DimensionArray: JsonArray): Text
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        LineArray: JsonArray;
        LineObject: JsonObject;
        Result: JsonObject;
        OutTxt: Text;
    begin
        Result.Add('id', SalesInvoiceHeader."No.");
        Result.Add('invoiceNumber', SalesInvoiceHeader."No.");
        Result.Add('customerName', SalesInvoiceHeader."Bill-to Name");
        Result.Add('customerId', SalesInvoiceHeader."Bill-to Customer No.");
        Result.Add('amount', SalesInvoiceHeader."Amount Including VAT");
        Result.Add('amountExcludingVat', SalesInvoiceHeader.Amount);
        Result.Add('vat', SalesInvoiceHeader."Amount Including VAT" - SalesInvoiceHeader.Amount);
        Result.Add('dueDate', FormatDateISO(SalesInvoiceHeader."Due Date"));
        Result.Add('documentDate', FormatDateISO(SalesInvoiceHeader."Document Date"));
        Result.Add('status', 'Released');
        Result.Add('description', SalesInvoiceHeader."Your Reference");
        Result.Add('currencyCode', SalesInvoiceHeader."Currency Code");
        Result.Add('paymentTermsCode', SalesInvoiceHeader."Payment Terms Code");
        Result.Add('pdfUrl', GetPostedInvoicePdfUrl(SalesInvoiceHeader."No."));

        // Add line items
        Clear(LineArray);
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                LineObject.Add('lineNumber', SalesInvoiceLine."Line No.");
                LineObject.Add('lineType', Format(SalesInvoiceLine.Type));
                LineObject.Add('itemNumber', SalesInvoiceLine."No.");
                LineObject.Add('description', SalesInvoiceLine.Description);
                LineObject.Add('quantity', SalesInvoiceLine.Quantity);
                LineObject.Add('unitOfMeasureCode', SalesInvoiceLine."Unit of Measure Code");
                LineObject.Add('unitPrice', SalesInvoiceLine."Unit Price");
                LineObject.Add('lineAmount', SalesInvoiceLine."Line Amount");

                // Add line dimensions if requested
                if DimensionArray.Count() > 0 then
                    LineObject.Add('lineDimensions', GetLineDimensions(SalesInvoiceLine."Dimension Set ID", DimensionArray));

                LineArray.Add(LineObject);
                Clear(LineObject);
            until SalesInvoiceLine.Next() = 0;

        Result.Add('lines', LineArray);

        // Add dimensions if requested
        if DimensionArray.Count() > 0 then
            Result.Add('dimensions', GetInvoiceDimensions(SalesInvoiceHeader."No.", 'SalesInvoiceHeader', DimensionArray));

        Result.WriteTo(OutTxt);
        exit(OutTxt);
    end;

    /// <summary>
    /// Retrieves dimension values for a specific line, filtered by requested dimension codes.
    /// </summary>
    procedure GetLineDimensions(DimensionSetId: Integer; RequestedDimensions: JsonArray): JsonArray
    var
        DimensionSetEntry: Record "Dimension Set Entry";
        DimensionArray: JsonArray;
        DimensionObject: JsonObject;
    begin
        if DimensionSetId = 0 then
            exit(DimensionArray);

        DimensionSetEntry.SetRange("Dimension Set ID", DimensionSetId);

        if DimensionSetEntry.FindSet() then
            repeat
                if RequestedDimensions.Count() > 0 then begin
                    if IsDimensionInArray(DimensionSetEntry."Dimension Code", RequestedDimensions) then begin
                        Clear(DimensionObject);
                        DimensionObject.Add('code', DimensionSetEntry."Dimension Code");
                        DimensionObject.Add('value', DimensionSetEntry."Dimension Value Code");
                        DimensionArray.Add(DimensionObject);
                    end;
                end;
            until DimensionSetEntry.Next() = 0;

        exit(DimensionArray);
    end;

    /// <summary>
    /// Retrieves dimension values for an invoice, filtered by requested dimension codes.
    /// </summary>
    procedure GetInvoiceDimensions(DocumentNo: Code[20]; TableId: Text; RequestedDimensions: JsonArray): JsonArray
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DimensionSetEntry: Record "Dimension Set Entry";
        DimensionSetId: Integer;
        DimToken: JsonToken;
        DimensionArray: JsonArray;
        DimensionObject: JsonObject;
    begin
        case TableId of
            'SalesHeader':
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::Invoice, DocumentNo);
                    DimensionSetId := SalesHeader."Dimension Set ID";
                end;
            'SalesInvoiceHeader':
                begin
                    SalesInvoiceHeader.Get(DocumentNo);
                    DimensionSetId := SalesInvoiceHeader."Dimension Set ID";
                end;
            else
                exit(DimensionArray);
        end;

        DimensionSetEntry.SetRange("Dimension Set ID", DimensionSetId);

        if DimensionSetEntry.FindSet() then
            repeat
                if RequestedDimensions.Count() > 0 then begin
                    if IsDimensionInArray(DimensionSetEntry."Dimension Code", RequestedDimensions) then begin
                        Clear(DimensionObject);
                        DimensionObject.Add('code', DimensionSetEntry."Dimension Code");
                        DimensionObject.Add('value', DimensionSetEntry."Dimension Value Code");
                        DimensionArray.Add(DimensionObject);
                    end;
                end else begin
                    Clear(DimensionObject);
                    DimensionObject.Add('code', DimensionSetEntry."Dimension Code");
                    DimensionObject.Add('value', DimensionSetEntry."Dimension Value Code");
                    DimensionArray.Add(DimensionObject);
                end;
            until DimensionSetEntry.Next() = 0;

        exit(DimensionArray);
    end;

    /// <summary>
    /// Checks if a dimension code exists in the requested dimensions array.
    /// </summary>
    procedure IsDimensionInArray(DimensionCode: Code[20]; DimensionArray: JsonArray): Boolean
    var
        i: Integer;
        DimToken: JsonToken;
    begin
        for i := 0 to DimensionArray.Count() - 1 do begin
            DimensionArray.Get(i, DimToken);
            if DimToken.IsValue() and (DimToken.AsValue().AsText() = DimensionCode) then
                exit(true);
        end;
        exit(false);
    end;
}
