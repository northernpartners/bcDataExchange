codeunit 50152 "Sales Invoice Handler"
{
    Permissions =
        tabledata "Sales Header" = rimd,
        tabledata "Sales Line" = rimd;

    trigger OnRun()
    begin
    end;

    /// <summary>
    /// POST endpoint for processing invoice operations.
    /// Accepts JSON with an "action" field to determine the operation.
    /// Supported actions: getDraftDetails, getPostedDetails, createDraft.
    /// </summary>
    [ServiceEnabled]
    procedure dxSalesInvoice(requestBody: Text): Text
    var
        InObj: JsonObject;
    begin
        if not InObj.ReadFrom(requestBody) then
            exit(CreateErrorResponse('Invalid JSON in requestBody.'));

        exit(ProcessInvoiceOperation(InObj));
    end;

    /// <summary>
    /// Processes invoice operations based on the requested action.
    /// </summary>
    local procedure ProcessInvoiceOperation(InObj: JsonObject): Text
    var
        ActionToken: JsonToken;
        Action: Text;
    begin
        if not InObj.Get('action', ActionToken) or not ActionToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "action" field.'));

        Action := ActionToken.AsValue().AsText();

        case Action of
            'getDraftDetails':
                exit(GetDraftInvoiceDetails(InObj));
            'getPostedDetails':
                exit(GetPostedInvoiceDetails(InObj));
            'createDraft':
                exit(CreateDraftInvoice(InObj));
            else
                exit(CreateErrorResponse('Unknown action: ' + Action));
        end;
    end;

    /// <summary>
    /// Gets full details of a draft invoice including all line items and optional dimensions.
    /// </summary>
    local procedure GetDraftInvoiceDetails(InObj: JsonObject): Text
    var
        Helpers: Codeunit "Sales Invoice Helpers";
        InvoiceIdToken: JsonToken;
        DimensionsToken: JsonToken;
        InvoiceId: Code[20];
        SalesHeader: Record "Sales Header";
        DimensionArray: JsonArray;
    begin
        if not InObj.Get('invoiceId', InvoiceIdToken) or not InvoiceIdToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "invoiceId" field.'));

        InvoiceId := CopyStr(InvoiceIdToken.AsValue().AsText(), 1, MaxStrLen(InvoiceId));

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange("No.", InvoiceId);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);

        if not SalesHeader.FindFirst() then
            exit(CreateErrorResponse('Invoice not found', 'The requested draft invoice does not exist.'));

        // Extract optional dimensions array
        if InObj.Get('dimensions', DimensionsToken) and DimensionsToken.IsArray() then
            DimensionArray := DimensionsToken.AsArray()
        else
            Clear(DimensionArray);

        exit(Helpers.CreateInvoiceDetailObject(SalesHeader, DimensionArray));
    end;

    /// <summary>
    /// Gets full details of a posted invoice including all line items and optional dimensions.
    /// </summary>
    local procedure GetPostedInvoiceDetails(InObj: JsonObject): Text
    var
        Helpers: Codeunit "Sales Invoice Helpers";
        InvoiceIdToken: JsonToken;
        DimensionsToken: JsonToken;
        InvoiceId: Code[20];
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DimensionArray: JsonArray;
    begin
        if not InObj.Get('invoiceId', InvoiceIdToken) or not InvoiceIdToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "invoiceId" field.'));

        InvoiceId := CopyStr(InvoiceIdToken.AsValue().AsText(), 1, MaxStrLen(InvoiceId));

        SalesInvoiceHeader.SetRange("No.", InvoiceId);

        if not SalesInvoiceHeader.FindFirst() then
            exit(CreateErrorResponse('Invoice not found', 'The requested posted invoice does not exist.'));

        // Extract optional dimensions array
        if InObj.Get('dimensions', DimensionsToken) and DimensionsToken.IsArray() then
            DimensionArray := DimensionsToken.AsArray()
        else
            Clear(DimensionArray);

        exit(Helpers.CreatePostedInvoiceDetailObject(SalesInvoiceHeader, DimensionArray));
    end;

    /// <summary>
    /// Creates a new draft invoice with the provided parameters.
    /// Validates all required fields and returns the new invoice number or error.
    /// Optionally creates line items if a "lines" array is provided.
    /// </summary>
    local procedure CreateDraftInvoice(InObj: JsonObject): Text
    var
        Helpers: Codeunit "Sales Invoice Helpers";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        CustomerIdToken: JsonToken;
        DocumentDateToken: JsonToken;
        DueDateToken: JsonToken;
        CurrencyCodeToken: JsonToken;
        PaymentTermsCodeToken: JsonToken;
        LinesToken: JsonToken;
        LinesArray: JsonArray;
        LineToken: JsonToken;
        LineObj: JsonObject;
        LineFieldToken: JsonToken;
        CustomerId: Code[20];
        DocumentDate: Date;
        DueDate: Date;
        CurrencyCode: Code[10];
        PaymentTermsCode: Code[10];
        LineNo: Integer;
        i: Integer;
        Result: JsonObject;
        LineArray: JsonArray;
        LineResult: JsonObject;
        LineTypeText: Text;
        LineErrorText: Text;
        EmptyDimArray: JsonArray;
        OutTxt: Text;
    begin
        // Validate and extract customerId
        if not InObj.Get('customerId', CustomerIdToken) or not CustomerIdToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "customerId" field.'));

        CustomerId := CopyStr(CustomerIdToken.AsValue().AsText(), 1, MaxStrLen(CustomerId));

        if not Customer.Get(CustomerId) then
            exit(CreateErrorResponse('Customer not found', 'The customer with ID "' + CustomerId + '" does not exist.'));

        // Validate and extract documentDate
        if not InObj.Get('documentDate', DocumentDateToken) or not DocumentDateToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "documentDate" field.'));

        if not Helpers.ParseDateISO(DocumentDateToken.AsValue().AsText(), DocumentDate) then
            exit(CreateErrorResponse('Invalid date format', 'documentDate must be in YYYY-MM-DD format.'));

        // Extract dueDate (optional - will be set by paymentTermsCode if omitted)
        Clear(DueDate);
        if InObj.Get('dueDate', DueDateToken) and DueDateToken.IsValue() then begin
            if not Helpers.ParseDateISO(DueDateToken.AsValue().AsText(), DueDate) then
                exit(CreateErrorResponse('Invalid date format', 'dueDate must be in YYYY-MM-DD format.'));
        end;

        // Validate and extract currencyCode
        if not InObj.Get('currencyCode', CurrencyCodeToken) or not CurrencyCodeToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "currencyCode" field.'));

        CurrencyCode := CopyStr(CurrencyCodeToken.AsValue().AsText(), 1, MaxStrLen(CurrencyCode));

        // Extract paymentTermsCode (optional)
        if InObj.Get('paymentTermsCode', PaymentTermsCodeToken) and PaymentTermsCodeToken.IsValue() then
            PaymentTermsCode := CopyStr(PaymentTermsCodeToken.AsValue().AsText(), 1, MaxStrLen(PaymentTermsCode))
        else
            Clear(PaymentTermsCode);

        // Create the invoice
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);

        // Set customer and dates
        SalesHeader.Validate("Sell-to Customer No.", CustomerId);
        SalesHeader.Validate("Document Date", DocumentDate);
        if DueDate <> 0D then
            SalesHeader.Validate("Due Date", DueDate);
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Validate("Payment Terms Code", PaymentTermsCode);
        SalesHeader.Modify(true);

        // Create line items if provided
        LineNo := 10000;
        Clear(LineArray);
        if InObj.Get('lines', LinesToken) and LinesToken.IsArray() then begin
            LinesArray := LinesToken.AsArray();
            for i := 0 to LinesArray.Count() - 1 do begin
                LinesArray.Get(i, LineToken);
                if LineToken.IsObject() then begin
                    LineObj := LineToken.AsObject();

                    // Require lineType
                    if not LineObj.Get('lineType', LineFieldToken) or not LineFieldToken.IsValue() then
                        exit(CreateErrorResponse('Missing lineType', 'Line ' + Format(i + 1) + ' is missing the required "lineType" field (Item, G/L Account, Resource, Charge (Item)).'));

                    LineTypeText := LineFieldToken.AsValue().AsText();
                    if not (LineTypeText in ['Item', 'G/L Account', 'Resource', 'Charge (Item)']) then
                        exit(CreateErrorResponse('Invalid lineType', 'Line ' + Format(i + 1) + ' has invalid lineType "' + LineTypeText + '". Valid values: Item, G/L Account, Resource, Charge (Item).'));

                    SalesLine.Init();
                    SalesLine."Document Type" := SalesHeader."Document Type";
                    SalesLine."Document No." := SalesHeader."No.";
                    SalesLine."Line No." := LineNo;
                    SalesLine.Insert(true);

                    // Validate line fields with error handling
                    ClearLastError();
                    if not TryValidateSalesLine(SalesLine, LineObj, LineTypeText) then begin
                        LineErrorText := GetLastErrorText();
                        if LineErrorText = '' then
                            LineErrorText := 'Unknown validation error';
                        exit(CreateErrorResponse('Line ' + Format(i + 1) + ' validation failed', LineErrorText));
                    end;

                    // Re-read line to get default dimensions applied by BC
                    SalesLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");

                    // Build line result with SystemId for dimension assignment
                    Clear(LineResult);
                    LineResult.Add('systemId', Format(SalesLine.SystemId, 0, 4).ToLower());
                    LineResult.Add('lineNumber', SalesLine."Line No.");
                    LineResult.Add('lineType', Format(SalesLine.Type));
                    LineResult.Add('itemNumber', SalesLine."No.");
                    LineResult.Add('description', SalesLine.Description);
                    LineResult.Add('quantity', SalesLine.Quantity);
                    LineResult.Add('unitOfMeasureCode', SalesLine."Unit of Measure Code");
                    LineResult.Add('unitPrice', SalesLine."Unit Price");
                    LineResult.Add('lineAmount', SalesLine."Line Amount");
                    LineResult.Add('lineDimensions', Helpers.GetLineDimensions(SalesLine."Dimension Set ID", EmptyDimArray));
                    LineArray.Add(LineResult);

                    LineNo += 10000;
                end;
            end;
        end;

        // Re-read header to get calculated amounts
        SalesHeader.Get(SalesHeader."Document Type"::Invoice, SalesHeader."No.");

        // Build and return response
        Result.Add('systemId', Format(SalesHeader.SystemId, 0, 4).ToLower());
        Result.Add('invoiceNumber', SalesHeader."No.");
        Result.Add('customerId', SalesHeader."Sell-to Customer No.");
        Result.Add('dueDate', Helpers.FormatDateISO(SalesHeader."Due Date"));
        Result.Add('documentDate', Helpers.FormatDateISO(SalesHeader."Document Date"));
        Result.Add('currencyCode', SalesHeader."Currency Code");
        Result.Add('paymentTermsCode', SalesHeader."Payment Terms Code");
        Result.Add('status', 'Open');
        Result.Add('amount', SalesHeader."Amount Including VAT");
        Result.Add('amountExcludingVat', SalesHeader.Amount);
        Result.Add('vat', SalesHeader."Amount Including VAT" - SalesHeader.Amount);
        if LineArray.Count() > 0 then
            Result.Add('lines', LineArray);
        Result.Add('dimensions', Helpers.GetInvoiceDimensions(SalesHeader."No.", 'SalesHeader', EmptyDimArray));

        Result.WriteTo(OutTxt);
        exit(OutTxt);
    end;

    /// <summary>
    /// Validates and populates a sales line from a JSON object.
    /// Wrapped in [TryFunction] so validation errors are caught by the caller.
    /// </summary>
    [TryFunction]
    local procedure TryValidateSalesLine(var SalesLine: Record "Sales Line"; LineObj: JsonObject; LineTypeText: Text)
    var
        LineFieldToken: JsonToken;
    begin
        // Set line type
        case LineTypeText of
            'G/L Account':
                SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
            'Resource':
                SalesLine.Validate(Type, SalesLine.Type::Resource);
            'Charge (Item)':
                SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
            'Item':
                SalesLine.Validate(Type, SalesLine.Type::Item);
        end;

        // Set item/account number
        if LineObj.Get('itemNumber', LineFieldToken) and LineFieldToken.IsValue() then
            SalesLine.Validate("No.", CopyStr(LineFieldToken.AsValue().AsText(), 1, 20));

        // Set description
        if LineObj.Get('description', LineFieldToken) and LineFieldToken.IsValue() then
            SalesLine.Validate(Description, CopyStr(LineFieldToken.AsValue().AsText(), 1, 100));

        // Set quantity
        if LineObj.Get('quantity', LineFieldToken) and LineFieldToken.IsValue() then
            SalesLine.Validate(Quantity, LineFieldToken.AsValue().AsDecimal());

        // Set unit of measure
        if LineObj.Get('unitOfMeasureCode', LineFieldToken) and LineFieldToken.IsValue() then
            SalesLine.Validate("Unit of Measure Code", CopyStr(LineFieldToken.AsValue().AsText(), 1, 10));

        // Set unit price
        if LineObj.Get('unitPrice', LineFieldToken) and LineFieldToken.IsValue() then
            SalesLine.Validate("Unit Price", LineFieldToken.AsValue().AsDecimal());

        SalesLine.Modify(true);
    end;

    /// <summary>
    /// Creates a standardized error response JSON object.
    /// </summary>
    local procedure CreateErrorResponse(ErrorCode: Text; ErrorMessage: Text): Text
    var
        Result: JsonObject;
        OutTxt: Text;
    begin
        Result.Add('error', true);
        Result.Add('code', ErrorCode);
        Result.Add('message', ErrorMessage);
        Result.WriteTo(OutTxt);
        exit(OutTxt);
    end;

    /// <summary>
    /// Creates a standardized error response with just a message.
    /// </summary>
    local procedure CreateErrorResponse(ErrorMsg: Text): Text
    var
        Result: JsonObject;
        OutTxt: Text;
    begin
        Result.Add('success', false);
        Result.Add('error', ErrorMsg);
        Result.WriteTo(OutTxt);
        exit(OutTxt);
    end;
}
